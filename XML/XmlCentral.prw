#include "protheus.ch"         
#INCLUDE "TOPCONN.CH"   
#INCLUDE "VKEY.CH"
#include "tbiconn.ch"
#INCLUDE "XmlXFun.Ch"
#include "spednfe.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³XMLCENTRALºAutor  ³Marcelo A. Lauschner  Data ³  19/08/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de interface para gerenciamento de Arquivos XML     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function XmlCENTRAL

Local	oDlg               
If !U_CriaTblXml()
	Return
Endif

Private  cPergXml	:= "XMLCENTRAL"

Private aSize 		:= MsAdvSize( .T., .F., 400 )		// Size da Dialog
Private nAltura 	:= aSize[6]/2.2
Private nMetade 	:= aSize[6]/5
Private	oVermelho	:= LoaDbitmap( GetResources(), "BR_VERMELHO" )
Private	oAzul 		:= LoaDbitmap( GetResources(), "BR_AZUL" )
Private	oAmarelo	:= LoaDbitmap( GetResources(), "BR_AMARELO" )
Private	oVerde		:= LoaDbitmap( GetResources(), "BR_VERDE" )
Private	oPreto		:= LoaDbitmap( GetResources(), "BR_PRETO" )
Private	oPink		:= LoaDbitmap( GetResources(), "BR_PINK" )
Private	oVioleta	:= LoaDbitmap( GetResources(), "BR_VIOLETA" )
Private oLaranja	:= LoadBitmap( GetResources(), "BR_LARANJA" )
Private oGrey		:= LoadBitmap( GetResources(), "BR_CINZA" )
Private oMarrom		:= LoadBitmap( GetResources(), "BR_MARROM" )
Private	oNoMarked  	:= LoadBitmap( GetResources(), "LBNO" )
Private	oMarked    	:= LoadBitmap( GetResources(), "LBOK" )
Private aCampos   	:= {}
Private	aArqXml		:= {}
Private	oArqXml
Private cArqXml
Private cNota		:= ""
Private	cVarPesq	:= Space(TamSX3("F1_SERIE")[1]+TamSX3("F1_DOC")[1])
Private aHeader 	:= {}
Private aCols		:= {}
Private n			:= 1
Private oMulti	
Private	cCodForn	:= Space(6)
Private	cLojForn    := Space(2)               
Private oCgcDest,oCgcEmit,oNomEmit,oNomDest,oMunEmit,oMunDest,oMsgNfe,oOrdem
Private cMsgNfe		:= ""
Private nTotalNfe	:= 0   
Private nTotalXml	:= 0
Private oTotalNfe,oTotalXml
Private bRefrXmlT	:= {|| Iif(Pergunte(cPergXml,.T.),(Processa({|| stRefresh() },"Aguarde, procurando registros ...."),Processa({|| stRefrItens() },"Aguarde carregando itens....")),Nil)}
Private bRefrXmlF	:= {|| Pergunte(cPergXml,.F.),(Processa({|| stRefresh() },"Aguarde, procurando registros ...."),Processa({|| stRefrItens() },"Aguarde carregando itens...."))}
Private lSuperUsr	:= __cUserId $ GetMv("XM_USRXMLN")  // Verifica usuarios Escrita Fiscal ou Superiores
Private lComprUsr 	:= __cUserId $ GetMv("XM_USRXMLC")	// Verifica Usuarios habilitados a marcar XML como conferido para lançamento
Private nAlertPrc	:= 1	// 1-Chama a Pergunta  2-Exibe alerta 3-Nao Exibe alerta no primeiro preço divergente e pergunta se continua para todos
Private	aAlter		:= {}	// Lista de campos com permissão de edição
Private lSortOrd	:= .F.
Private lMVXPCNFE	:= GetMv("XM_XPCNFE")
Private cCFOPNPED	:= GetNewPar("XM_CFNPCNF","5906") // Lista de CFOPs de notas de saida recebidas que não precisam de Pedido de Compra
Private aRetPoder3	:= &(GetNewPar("XM_RETPOD3",'{{"5906","308"},{"6906","308"}}'))
Private aDupSE2		:= {}
Private aChvNfes	:= {}	// Chaves de Nfe de origem conforme tag refNFE do Xml

ValidPerg()
If !Pergunte(cPergXml,.T.)
	REturn
Endif

DbSelectArea("SC7")
DbSetOrder(1)

Define MsDialog oDlg From 0,0 TO aSize[6] , aSize[5]  Pixel Title "Controle de gerenciamento de Arquivos Xml e importação de NF-e " + SM0->M0_NOMECOM

@ 002, 110 Button oBtnPrint PROMPT "Receber Emails" Size 60,10 Action (Processa({|| U_MYEMAIL(mv_par11==1)},"Aguarde recebendo emails ...."),Eval(bRefrXmlF)) of oDlg Pixel
If lSuperUsr
	@ 002, 175 Button oBtnCons PROMPT "Consultar Sefaz" Size 60,10 Action (stConSefaz(aArqXml[oArqXml:nAt,5]),Eval(bRefrXmlF)) Of oDlg Pixel
Endif
@ 002, 240 Button oBtnRefr PROMPT "Filtrar dados" Size 60,10 Action(ValidPerg(),Eval(bRefrXmlT)) Of oDlg Pixel
@ 002, 305 Button oBtnSave PROMPT "Gerar Doc.Entrada" Size 60,10 Action(stGeraNfe(),Eval(bRefrXmlF)) of oDlg Pixel
@ 002, 370 Button oBtnRej PROMPT "Enviar Email Rejeição" Size 60,10 Action(stRejeita(aArqXml[oArqXml:nAt,5]),Eval(bRefrXmlF)) of oDlg Pixel
@ 015, 110 Button oBtnView PROMPT "Visualizar Danfe" Size 60,10 Action(stViewNfe()) of oDlg Pixel
If lComprUsr
	@ 015, 175 Button oBtnView PROMPT "Concluir Conferência" Size 60,10 Action(stConferida(),Eval(bRefrXmlF)) of oDlg Pixel
Endif 
If lSuperUsr
	@ 015, 240 Button oBtnView PROMPT "Class.Pré-Nota" Size 60,10 Action(U_XMLMT103(aArqXml[oArqXml:nAt,5],{},.T.,.T.) ,Eval(bRefrXmlF)) of oDlg Pixel
	@ 002, 435 Button oBtnSave PROMPT "Alterar Tipo Documento" Size 60,10 Action(sfAltTipDC(),Eval(bRefrXmlF)) of oDlg Pixel
	@ 015, 435 Button oBtnView PROMPT "Excluir Doc.Entrada" Size 60,10 Action(U_XMLMT103(aArqXml[oArqXml:nAt,5],{},.T.,.T.,.T.) ,Eval(bRefrXmlF)) of oDlg Pixel
Endif
@ 015, 305 Button oBtnView PROMPT "Visual.Doc.Entrada" Size 60,10 Action(U_XMLMT103(aArqXml[oArqXml:nAt,5],{},.T.) ,Eval(bRefrXmlF)) of oDlg Pixel

		  
@ 015, 370 Button oBtnSair PROMPT "Sair" Size 60,10 Action(oDlg:End()) Of oDlg Pixel
//WaitRun( 'photoview.exe "' + cPath + AllTrim(SB1->B1_IMGAP) + '" ')

//Aadd(aHeader,{Trim(X3Titulo()), SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,"",SX3->X3_TIPO,"","" })

/*01*/Aadd(aHeader,{"Ok"				,	"OK"		    ,   "@BMP"     			,	1,	0,"",,	"C","",""})                         	
Private nPxItem    := 2
/*02*/Aadd(aHeader,{"Item"				,	"XIT_ITEM"		,   "@!"     			,	04,	0,"AllwaysFalse()",,	"C","","V"})                         	// 14
Private nPxCodNfe 	:= 3
/*03*/Aadd(aHeader,{"Ref.Fornecedor"	,	"XIT_CODNFE"	,	"@!"	 			,	20, 0,"AllwaysTrue()" ,,	"C","","V"})	// 1	
Aadd(aAlter,"XIT_CODNFE")
Private nPxPrd	    := 4
/*04*/Aadd(aHeader,{"Ref.Protheus"		,	"D1_COD"		,	"@!"	 			,	15,	0,"U_VldSA5(oMulti:aCols[oMulti:nAt,nPxCodNfe],cCodForn,cLojForn,oMulti:aCols[oMulti:nAt,nPxDescri]) .And. ExistCpo('SB1',M->D1_COD)",,	"C","SB1",""})	// Código Produto no Protheus
Aadd(aAlter,"D1_COD")
Private nPxDescri  := 5
/*05*/Aadd(aHeader,{"Descrição NF-e"	,	"XIT_DESCRI"	,	"@!"	 			,	50,	0,"AllwaysTrue()",,	"C","","V"})	// Descrição Produto no Xml
Aadd(aAlter,"XIT_DESCRI")
Private nPxQteNfe  := 6
/*06*/Aadd(aHeader,{"Qte NFe"			,	"XIT_QTENFE"	,	"@E 999,999.99"		,	10,	2,"AllwaysTrue()",,	"N","","V"})	// Quantidade no Xml
Aadd(aAlter,"XIT_QTENFE")
Private nPxUMNFe   := 7
/*07*/Aadd(aHeader,{"UM NFe"			,	"XIT_UMNFE"		,	"@!"	 			,	05,	0,"AllwaysTrue()",,	"C","","V"})	// Unidade Medida no Xml
Aadd(aAlter,"XIT_UMNFE")
Private nPxPrcNfe	:= 8
/*08*/Aadd(aHeader,{"R$ Unit.NFe"		,	"XIT_PRCNFE"	,	"@E 9,999,999.99" 	,	12,	2,"AllwaysTrue()",,	"N","","V"})	// Preço Unitário
Aadd(aAlter,"XIT_PRCNFE")
Private nPxTotNfe  := 9
/*09*/Aadd(aHeader,{"R$ Tot.NFe"  		,	"XIT_TOTAL"		,	"@E 9,999,999.99" 	,	12,	2,"AllwaysTrue()",,	"N","","V"})	// Preço Unitário
Aadd(aAlter,"XIT_TOTAL")
Private nPxQte		:= 10
/*10*/Aadd(aHeader,{"Quantidade"		,	"D1_QUANT"		,	"@E 999,999.99"		,	10,	2,"U_XmlVldTt(1)",,	"N","","V"})	// Quantidade 
Aadd(aAlter,"D1_QUANT")
Private nPxUm		:= 11
/*11*/Aadd(aHeader,{"Unid.Medida"		,	"D1_UM"			,	"@!"	 			,	05,	0,"",,	"C","","V"})	// Unidade Medida
Aadd(aAlter,"D1_UM")
Private nPxPrunit  := 12
/*12*/Aadd(aHeader,{"Preço Unitário"	,	"D1_VUNIT"		,	"@E 9,999,999.9999" ,	14,	4,"U_XmlVldTt(2)",,	"N","","V"})	// Preço Unitário
Aadd(aAlter,"D1_VUNIT")
Private nPxTotal   := 13
/*13*/Aadd(aHeader,{"Total Item"		,	"D1_TOTAL "		,	"@E 9,999,999.99"	,	12,	2,"U_XmlVldTt(3)",,	"N","","V"})	// Valor Total do Item
Aadd(aAlter,"D1_TOTAL")
Private nPxD1Tes     := 14
/*14*/Aadd(aHeader,{"Tipo Entrada"		,	"D1_TES"		,	"@!"	 			,	03,	0,"ExistCpo('SF4',M->D1_TES) .And. U_VlsSF4()",,	"C","SF4",""}) // Código do TES
Aadd(aAlter,"D1_TES")
Private nPxCFNFe   := 15
/*15*/Aadd(aHeader,{"CFOP NF-e"			,	"XIT_CFNFE"		,	"@!"	 			,	05,	0,"AllwaysTrue()",,	"C","","V"})	//Código do CFOP
Private nPxCF	   := 16
Aadd(aAlter,"XIT_CFNFE")
/*16*/Aadd(aHeader,{"CFOP Entrada"		,	"D1_CF"			,	"@!"	 			,	05,	0,"AllwaysTrue()",,	"C","","V"})	//Código do CFOP
Aadd(aAlter,"D1_CF")
Private nPxNcm		:= 17
/*17*/Aadd(aHeader,{"NCM"				,	"XIT_NCM"		,	"@!"	 			,	10,	0,"AllwaysFalse()",,	"C","","V"})	//Código do NCM
Private nPxPedido	:= 18
/*18*/Aadd(aHeader,{"Pedido Compra"		,	"XIT_PEDIDO"	,	"@!"	 			,	06,	0,"U_VldItemPc(oMulti:nAt)",,	"C","","V"})	//Número Pedido Compra
Aadd(aAlter,"XIT_PEDIDO")
Private nPxItemPc	:= 19
/*19*/Aadd(aHeader,{"Item PC"			,	"XIT_ITEMPC"	,	"@!"	 			,	04,	0,"",,	"C","","V"})	// Item pedido compra
Aadd(aAlter,"XIT_ITEMPC")
Private nPxValDesc := 20
/*20*/Aadd(aHeader,{"R$ Desconto"		,	"XIT_VALDES"	,	"@E 99,999.99" 		,	09,	2,"AllwaysFalse()",,	"N","","V"})	//	Valor do Desconto
Private nPxBasIcm  := 21
/*21*/Aadd(aHeader,{"Base ICMS"			,	"XIT_BASICM"	,	"@E 9,999,999.99"	,   12, 2,"AllwaysFalse()",,	"N","","V"})	// Base Calculo Icms
Private nPxPicm	:= 22
/*22*/Aadd(aHeader,{"% ICMS"			,	"XIT_PICM  "	,	"@E 999.99"			,   05, 2,"AllwaysFalse()",,	"N","","V"})  // Percentual Icms
Private nPxValIcm	:= 23
/*23*/Aadd(aHeader,{"R$ ICMS"			,	"XIT_VALICM"	,	"@E 9,999,999.99"	,	12, 2,"AllwaysFalse()",,	"N","","V"})	// Valor do Icms
Private nPxBasIpi	:= 24
/*24*/Aadd(aHeader,{"Base IPI"			,	"XIT_BASIPI"	,	"@E 9,999,999.99"	, 	12, 2,"AllwaysFalse()",,	"N","","V"})	// Base Calculo IPI
Private nPxPIpi	:= 25
/*25*/Aadd(aHeader,{"% IPI"				,	"XIT_PIPI  "	,	"@E 999.99"			,	05, 2,"AllwaysFalse()",,	"N","","V"})  // Percentual IPI
Private nPxValIpi	:= 26
/*26*/Aadd(aHeader,{"R$ IPI"			,	"XIT_VALIPI"	,	"@E 9,999,999.99"	, 	12, 2,"AllwaysFalse()",,	"N","","V"})	// Valor do IPI
Private nPxBasPis	:= 27
/*27*/Aadd(aHeader,{"Base PIS"			,	"XIT_BASPIS"	,	"@E 9,999,999.99"	, 	12, 2,"AllwaysFalse()",,	"N","","V"})	// Base Calculo PIS
Private nPxPPis	:= 28
/*28*/Aadd(aHeader,{"% PIS"				,	"XIT_PPIS  "	,	"@E 999.99"			,	05, 2,"AllwaysFalse()",,	"N","","V"})  // Percentual PIS
Private nPxValPis	:= 29
/*29*/Aadd(aHeader,{"R$ PIS"			,	"XIT_VALPIS"	,	"@E 9,999,999.99"	, 	12, 2,"AllwaysFalse()",,	"N","","V"})	// Valor do PIS
Private nPxBasCof	:= 30
/*30*/Aadd(aHeader,{"Base Cofins"		,	"XIT_BASCOF"	,	"@E 9,999,999.99"	,	12, 2,"AllwaysFalse()",,	"N","","V"})	// Base Calculo Cofins
Private nPxPCof	:= 31
/*31*/Aadd(aHeader,{"% Cofins"			,	"XIT_PCOF  "	,	"@E 999.99"			,	05, 2,"AllwaysFalse()",,	"N","","V"})  // Percentual Cofins
Private nPxValCof	:= 32
/*32*/Aadd(aHeader,{"R$ Cofins"			,	"XIT_VALCOF"	,	"@E 9,999,999.99"	,	12, 2,"AllwaysFalse()",,	"N","","V"})	// Valor do Cofins
Private nPxBasRet	:= 33
/*33*/Aadd(aHeader,{"Base Retido"		,	"XIT_BASRET"	,	"@E 9,999,999.99"	,	12, 2,"AllwaysFalse()",,	"N","","V"})	// Base Calculo Icms Retido
Private nPxMva		:= 34
/*34*/Aadd(aHeader,{"% MVA"				,	"XIT_PMVA  "	,	"@E 999.99"			,	07, 2,"AllwaysFalse()",,	"N","","V"})  // Percentual Icms Retido
Private nPxIcmRet	:= 35
/*35*/Aadd(aHeader,{"R$ ICMS ST"		,	"XIT_VALRET"	,	"@E 9,999,999.99"	,	12, 2,"AllwaysFalse()",,	"N","","V"})	// Valor do Icms Retido
Private nPxCST		:= 36
/*36*/Aadd(aHeader,{"CST"				,	"D1_CLASFIS"	,	"@!"				,	03, 0,"AllwaysFalse()",,	"C","","V"})  // Classificação fiscal
Private nPxKey		:= 37
/*37*/Aadd(aHeader,{"Chave Sistema"		,	"XIT_KEYSD1"	,	"@!"				,	30, 0,"AllwaysFalse()",,	"C","","V"})  // Chave SD1 - D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
DbSelectArea("SX3")
DbSetOrder(2)
DbSeek("D1_NFORI")
Aadd(aHeader,{TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_ORDEM })
Private	nPNfOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_NFORI"})
DbSeek("D1_SERIORI")
Aadd(aHeader,{ TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_ORDEM })
Private	nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_SERIORI"})
DbSelectArea("SX3")
DbSeek("D1_ITEMORI")
Aadd(aHeader,{ TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_ORDEM })
Private	nPItemOri := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMORI"})
            
DbSeek("D1_LOCAL")
Aadd(aHeader,{ TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_ORDEM })
Private	nPxLocal := aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOCAL"})
Aadd(aAlter,"D1_LOCAL")

DbSeek("D1_VALDESC")
Aadd(aHeader,{ TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_ORDEM })
Private	nPxVlDesc := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VALDESC"})
Aadd(aAlter,"D1_VALDESC")

DbSeek("D1_DESC")
Aadd(aHeader,{ TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_ORDEM })
//Private	nPDesc    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_DESC"})

DbSeek("D1_IDENTB6")
Aadd(aHeader,{ TRIM(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_ARQUIVO,SX3->X3_CONTEXT,SX3->X3_ORDEM })
Private	nXmlIdentB6    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_IDENTB6"})

	
Private bChangeXIT	:= {|| stLinOk() }
U_DbSelArea("CENTRALXMLITENS",.F.,1)

//@ nMetade+20, 005 To nAltura-45, aSize[5]/2.01 Multiline Modify Valid stLinOk() Object oMulti  
aCols	:= {Array(Len(aHeader)+1)}
aCols[Len(aCols),Len(aHeader)+1]	:= .F.
aCols[Len(aCols),1]	:= oVermelho

Private oMulti := MsNewGetDados():New(nmetade+20,005,nAltura-45,aSize[5]/2.01,GD_INSERT+GD_DELETE+GD_UPDATE,"AllwaysTrue()"/*cLinhaOk*/,"AllwaysTrue()"/*cTudoOk*/,"+XIT_ITEM",;
aAlter,4/*nFreeze*/,10000/*nMax*/,"U_XMLVLEDT()"/*cCampoOk*/,"AllwaysTrue()"/*cSuperApagar*/,"U_XMLVLEDT()"/*cApagaOk*/,oDlg,@aHeader,@aCols,bChangeXIT)
                                          
@ nMetade+05, 0005 Button oBtnHist PROMPT "Historico do Produto" Size 70,10 Action(IIf(!Empty(oMulti:aCols[oMulti:nAt,nPxPrd]),( aRotina   := {{ ,"A103NFiscal", 0, 2}},MaComView(oMulti:aCols[oMulti:nAt][nPxPrd])),MsgAlert("Não há produto digitado!","XML CENTRAL!")) ) Of oDlg Pixel

@ nMetade+05, 0085 Button oBtnGrvIte PROMPT "Gravar Alterações Itens" Size 70,10 Action(Processa({|| stGrvItens() },"Aguarde gravação...")) Of oDlg Pixel
@ nMetade+05, 0165 Button oBtnExecel PROMPT "Exportar Excel" Size 40,10 Action(stExpExcel()) Of oDlg Pixel
@ nMetade+05, 0215 Say "Total XML" of oDlg Pixel 
@ nMetade+05, 0240 MsGet oTotalXml Var nTotalXml Picture "@E 999,999,999.99" Size 50,10 READONLY COLOR CLR_BLUE noborder of oDlg Pixel 
@ nMetade+05, 0295 Say "Total NFE" of oDlg Pixel 
@ nMetade+05, 0320 MsGet oTotalNfe Var nTotalNfe Picture "@E 999,999,999.99" Size 50,10 READONLY COLOR CLR_BLUE noborder of oDlg Pixel 
@ nMetade+05, 0415 Button oBtnRelDiv PROMPT "Rel.Divergência" Size 45,10 Action(sfReport()) Of oDlg Pixel
@ nMetade+05, 0470 Button oBtnRelDiv PROMPT "Ped.Nf/Origem" Size 45,10 Action(U_VldItemPc()) Of oDlg Pixel


//CENTRALXMLITENS->(DbCloseArea())

@ 025,005 ListBox oArqXml VAR cArqXml ;
Fields HEADER " ",;    		// 1
"Série/Nº NF-e",;      		// 2
"Emissão",;    		   		// 3
"Fornecedor/Loja-Nome",;    // 4
"Chave NF-e",;              // 5
"Destinatário",;            // 6
"Recebida em",;				// 7
"Conf.Sefaz",;				// 8
"Lançada em" ,;				// 9
"Conf.Compras",;			// 10
"Rev.Sefaz",;				// 11
"Tipo Nota";				// 12
SIZE aSize[5]/2.01,nMetade-20;
ON DBLClick (sfTracker()) OF oDlg PIXEL

oArqXml:bChange := {|| Pergunte(cPergXml,.F.),Processa({|| stRefrItens() },"Aguarde carregando itens....")}

oArqXml:bHeaderClick := {|| cVarPesq := aArqXml[oArqXml:nAt,2],nColPos :=oArqXml:ColPos,lSortOrd := !lSortOrd, aSort(aArqXml,,,{|x,y| Iif(lSortOrd,x[nColPos] > y[nColPos],x[nColPos] < y[nColPos]) }),stPesquisa()} 

U_DbSelArea("CENTRALXML",.F.,1)

@ nAltura-40,005 To nAltura+15,130 of oDlg Pixel
@ nAltura-46,005 Say "Dados Emitente" of oDlg Pixel
@ nAltura-35,008 Say "CNPJ:" of oDlg Pixel
@ nAltura-37,028 MsGet oCgcEmit Var CENTRALXML->XML_EMIT Size 60,10 Picture "@R 99.999.999/9999-99" READONLY COLOR CLR_BLUE noborder of oDlg Pixel 
@ nAltura-25,008 Say "Nome:" of oDlg Pixel
@ nAltura-27,028 MsGet oNomEmit Var CENTRALXML->XML_NOMEMT Size 102,10 READONLY COLOR CLR_BLUE noborder of oDlg Pixel 
@ nAltura-15,008 Say "Cidade:" of oDlg Pixel
@ nAltura-17,028 MsGet oMunEmit Var CENTRALXML->XML_MUNMT Size 102,10 READONLY COLOR CLR_BLUE noborder of oDlg Pixel 

@ nAltura-40,130 To nAltura+15,255  of oDlg Pixel     
@ nAltura-46,130 Say "Dados Destinatário" of oDlg Pixel
@ nAltura-35,133 Say "CNPJ:" of oDlg Pixel     
@ nAltura-37,153 MsGet oCgcDest Var CENTRALXML->XML_DEST Size 60,10 Picture "@R 99.999.999/9999-99" READONLY COLOR CLR_RED NOBORDER of oDlg Pixel 
@ nAltura-25,133 Say "Nome:" of oDlg Pixel
@ nAltura-27,153 MsGet oNomDest Var CENTRALXML->XML_NOMEDT Size 102,10 READONLY COLOR CLR_RED noborder of oDlg Pixel 
@ nAltura-15,133 Say "Cidade:" of oDlg Pixel
@ nAltura-17,153 MsGet oMunDest Var CENTRALXML->XML_MUNDT Size 102,10 READONLY COLOR CLR_RED noborder of oDlg Pixel 

@ nMetade+04, 0375 Say "Ordem Compra" of oDlg Pixel 
@ nMetade+10, 0375 MsGet oOrdem	Var CENTRALXML->XML_PCOMPR Size 30,08 READONLY COLOR CLR_BLUE noborder of oDlg Pixel 

//@ nAltura-40,255 To nAltura+15,485  of oDlg Pixel     
@ nAltura-46,258 Say "Mensagens da Danfe" of oDlg Pixel
@ nAltura-40,255 Get oMsgNfe Var cMsgNfe of oDlg MEMO Size 250,55 Pixel READONLY
@ nAltura+15,005 BITMAP oBmp RESNAME "BR_VERDE" SIZE 16,16 NOBORDER of oDlg pixel
@ nAltura+15,012 SAY "- NF-e Doc.Entrada" of oDlg pixel
@ nAltura+15,065 BITMAP oBmp RESNAME "BR_VERMELHO" SIZE 16,16 NOBORDER of oDlg pixel
@ nAltura+15,072 SAY "- NF-e Pendente" of oDlg pixel
@ nAltura+15,125 BITMAP oBmp RESNAME "BR_AMARELO" SIZE 16,16 NOBORDER of oDlg pixel
@ nAltura+15,132 SAY "- NF-e Rejeitada" of oDlg pixel
@ nAltura+15,185 BITMAP oBmp RESNAME "BR_AZUL" SIZE 16,16 NOBORDER of oDlg pixel
@ nAltura+15,192 SAY "- NF-e Pré-Nota" of oDlg pixel
@ nAltura+15,245 BITMAP oBmp RESNAME "BR_PRETO" SIZE 16,16 NOBORDER of oDlg pixel
@ nAltura+15,252 SAY "- NF-e Outra Empresa" of oDlg pixel

@ nAltura+15,305 BITMAP oBmp RESNAME "BR_PINK" SIZE 16,16 NOBORDER of oDlg pixel
@ nAltura+15,312 SAY "- NF-e Devolução" of oDlg pixel
@ nAltura+15,365 BITMAP oBmp RESNAME "BR_VIOLETA" SIZE 16,16 NOBORDER of oDlg pixel
@ nAltura+15,372 SAY "- NF-e Beneficiamento" of oDlg pixel

@ nAltura+15,425 BITMAP oBmp RESNAME "BR_MARROM" SIZE 16,16 NOBORDER of oDlg pixel
@ nAltura+15,432 SAY "- NF-e Compl.ICMS" of oDlg pixel
@ nAltura+15,485 BITMAP oBmp RESNAME "BR_CINZA" SIZE 16,16 NOBORDER of oDlg pixel
@ nAltura+15,492 SAY "- NF-e Compl.IPI" of oDlg pixel
@ nAltura+15,545 BITMAP oBmp RESNAME "BR_LARANJA" SIZE 16,16 NOBORDER of oDlg pixel
@ nAltura+15,552 SAY "- NF-e Compl.Preço/Frete" of oDlg pixel

Processa({|| stRefresh() },"Aguarde procurando registros ....")

@ 002,005 SAY "NF-e Nº" of oDlg pixel
@ 002,030 MSGET cVarPesq Valid stPesquisa() of oDlg pixel

Set Key  VK_F6 TO U_VldItemPc()

Activate MsDialog oDlg Centered

SetKey(VK_F6,Nil)

Return


Static Function stRefresh()

Local	cFornece	:= ""
Local	aDestino	:= {}
Local	nRecSM0		:= 0 
Local	lExistSF1	:= .F.  
Local	cF1Status	:= ""
Local	bFiltxml	:= Nil

aArqXml := {}

U_DbSelArea("CENTRALXML",.F.,2)

If MV_PAR08==1
	If MV_PAR01 == 1
		Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. Empty(XML_LANCAD) .And. !Empty(XML_CONFCO) .And. Alltrim(XML_DEST) == Alltrim(SM0->M0_CGC)
	Else
		Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. Empty(XML_LANCAD)  .And. !Empty(XML_CONFCO)
	Endif	
ElseIf MV_PAR08==2
	If MV_PAR01 == 1
		Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And.  Empty(XML_CONFCO) .And. Alltrim(XML_DEST) == Alltrim(SM0->M0_CGC)
	Else
		Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And.  Empty(XML_CONFCO)
	Endif
ElseIf MV_PAR08==3
	If MV_PAR01 == 1
		Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. !Empty(XML_REJEIT) .And. Alltrim(XML_DEST) == Alltrim(SM0->M0_CGC)
	Else
		Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. !Empty(XML_REJEIT)
	Endif
ElseIf MV_PAR08==4
	If MV_PAR01 == 1
		Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And.  Empty(XML_CONFER) .And. Alltrim(XML_DEST) == Alltrim(SM0->M0_CGC)
	Else
		Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And.  Empty(XML_CONFER)
	Endif
Else
	If MV_PAR01 == 1
		Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 .And. Alltrim(XML_DEST) == Alltrim(SM0->M0_CGC)
	Else	
		Set Filter to XML_EMISSA >= MV_PAR06 .And. XML_EMISSA <= MV_PAR07 
	Endif
Endif     

//MsgInfo("Ajustar Destinatario")

Count to nRegXml
ProcRegua(nRegXml)
DbGotop()
While !Eof()
	
	lExistSF1	:= .F.
	cF1Status	:= ""
	
	cFornece := "      /  - Destinatário não pertence a Empresa atual"
	
	IncProc("Processando NF-e" + CENTRALXML->XML_NUMNF)
	
	// Filtro Cnpj de emitentes                                        	
	If CENTRALXML->XML_EMIT < MV_PAR09 .Or. CENTRALXML->XML_EMIT > MV_PAR10
		DbSelectArea("CENTRALXML")
		DbSkip()
		Loop
	Endif
	
	If Alltrim(CENTRALXML->XML_DEST) == Alltrim(SM0->M0_CGC)
		If CENTRALXML->XML_TIPODC $ "N#C#I#P"
			DbSelectArea("SA2")
			DbSetOrder(3)
			If DbSeek(xFilial("SA2")+CENTRALXML->XML_EMIT)
				cFornece := SA2->A2_COD+"/"+SA2->A2_LOJA + "-" +SA2->A2_NOME
			Endif             
			lExistSF1	:= .T.
		
			If SA2->A2_COD < MV_PAR02 .Or. SA2->A2_LOJA < MV_PAR03 .Or. SA2->A2_COD > MV_PAR04 .Or. SA2->A2_LOJA > MV_PAR05
				DbSelectArea("CENTRALXML")
				DbSkip()
				Loop
			Endif
	 	Else
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek(xFilial("SA1")+CENTRALXML->XML_EMIT)
				cFornece := SA1->A1_COD+"/"+SA1->A1_LOJA + "-" +SA1->A1_NOME
			Endif             
			lExistSF1	:= .T.
		
			If SA1->A1_COD < MV_PAR02 .Or. SA1->A1_LOJA < MV_PAR03 .Or. SA1->A1_COD > MV_PAR04 .Or. SA1->A1_LOJA > MV_PAR05
				DbSelectArea("CENTRALXML")
				DbSkip()
				Loop
			Endif
	 	Endif	
	Else
		If MV_PAR01 == 1
			DbSelectArea("CENTRALXML")
			DbSkip()
			Loop
		Endif
	Endif
	nPx := aScan(aDestino,{|x| x[1] == CENTRALXML->XML_DEST})
	If lExistSF1	
		// -- Valido se Nota Fiscal já existe na base ?    
		If CENTRALXML->XML_TIPODC $ "N#C#I#P"
			DbSelectArea("SF1")
			DbSetOrder(1)
			If DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(Substr(CENTRALXML->XML_NUMNF,TamSX3("F1_SERIE")[1]+1,TamSX3("F1_DOC")[1])),TamSX3("F1_DOC")[1])+;
									 Padr(Alltrim(Substr(CENTRALXML->XML_NUMNF,1,TamSX3("F1_SERIE")[1])),TamSX3("F1_SERIE")[1])+;
									 SA2->A2_COD+SA2->A2_LOJA+CENTRALXML->XML_TIPODC) 
				RecLock("CENTRALXML",.F.)
				CENTRALXML->XML_KEYF1	:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
//										        F1_FILIAL+     F1_DOC+     F1_SERIE+     F1_FORNECE+     F1_LOJA+     F1_TIPO
		    	CENTRALXML->XML_LANCAD	:= SF1->F1_DTDIGIT
		    	MsUnlock()
		  	Else
				RecLock("CENTRALXML",.F.)
				CENTRALXML->XML_KEYF1	:= "" 
		    	CENTRALXML->XML_LANCAD	:= CTOD("  /  /  ")
		    	MsUnlock()		
			Endif

		Else
			DbSelectArea("SF1")
			DbSetOrder(1)
			If DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(Substr(CENTRALXML->XML_NUMNF,TamSX3("F1_SERIE")[1]+1,TamSX3("F1_DOC")[1])),TamSX3("F1_DOC")[1])+;
									 Padr(Alltrim(Substr(CENTRALXML->XML_NUMNF,1,TamSX3("F1_SERIE")[1])),TamSX3("F1_SERIE")[1])+;
									 SA1->A1_COD+SA1->A1_LOJA+CENTRALXML->XML_TIPODC) 
				RecLock("CENTRALXML",.F.)
				CENTRALXML->XML_KEYF1	:= SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
//										        F1_FILIAL+     F1_DOC+     F1_SERIE+     F1_FORNECE+     F1_LOJA+     F1_TIPO
		    	CENTRALXML->XML_LANCAD	:= SF1->F1_DTDIGIT
		    	MsUnlock()
		  	Else
				RecLock("CENTRALXML",.F.)
				CENTRALXML->XML_KEYF1	:= "" 
			    CENTRALXML->XML_LANCAD	:= CTOD("  /  /  ")
		    	MsUnlock()		
			Endif
		EndIf
		
		DbSelectArea("SF1")
		DbSetOrder(1)
		If DbSeek(CENTRALXML->XML_KEYF1)
			cF1Status	:= SF1->F1_STATUS
		Endif
	Endif
		// Verifico se a nota ainda não foi revalidada e se o prazo de horas para reconferencia já expirou o parametro
	If Empty(CENTRALXML->XML_DTRVLD) .And. CENTRALXML->XML_EMISSA <=  (Date() - (GetMv("XM_SPEDEXC")/24)) .And. Empty(CENTRALXML->XML_REJEIT)
			cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
			// Trecho para validar autorização da NF
			cMensagem:= ""
			oWs:= WsNFeSBra():New()
			oWs:cUserToken   := "TOTVS"
			oWs:cID_ENT    := StaticCall(SPEDNFE,GetIdEnt)
			ows:cCHVNFE		 := Alltrim(CENTRALXML->XML_CHAVE)
			oWs:_URL         := AllTrim(cURL)+"/NFeSBRA.apw"
			
			If oWs:ConsultaChaveNFE()
				cMensagem := ""
				If !Empty(oWs:oWSCONSULTACHAVENFERESULT:cVERSAO)
					cMensagem += STR0129+": "+oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
				EndIf
				cMensagem += STR0035+": "+IIf(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,STR0056,STR0057)+CRLF //"Produção"###"Homologação"
				cMensagem += STR0068+": "+oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
				cMensagem += STR0069+": "+oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF
				If oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1 .And. !Empty(oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO)
					cMensagem += STR0050+": "+oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
				EndIf
				If Alltrim(oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE) == "100"
					DbSelectArea("CENTRALXML")
					RecLock("CENTRALXML",.F.)		
					CENTRALXML->XML_DTRVLD := Date()
					MsUnLock()
				Else
					Aviso(STR0107,cMensagem+Chr(13)+Chr(10)+"Nota fiscal '"+CENTRALXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CENTRALXML->XML_NOMEMT)+"' não está mais Autorizada na SEFAZ!",{"Ok"},3)
				Endif
				//	Aviso(STR0107,cMensagem,{STR0114},3)
			Else
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))+Chr(13)+Chr(10)+"Nota fiscal '"+CENTRALXML->XML_NUMNF+"' do Fornecedor/Cliente '"+Alltrim(CENTRALXML->XML_NOMEMT)+"' não está mais Autorizada na SEFAZ!",{STR0114},3)
			EndIf
	Endif

	Aadd(aArqXml,{IIf(!lExistSF1,;
								5,;
								Iif(!Empty(CENTRALXML->XML_REJEIT),;
																 3,;
																 Iif(Empty(CENTRALXML->XML_KEYF1),;
																 								IIf(CENTRALXML->XML_TIPODC== "D",6,IIf(CENTRALXML->XML_TIPODC=="B",7,IIf(CENTRALXML->XML_TIPODC=="I",8,IIf(CENTRALXML->XML_TIPODC=="P",9,IIf(CENTRALXML->XML_TIPODC=="C",10,1))))),;
																 								Iif(!Empty(cF1STATUS),;
																 														 2,;
																 														 4)))),;							// 1 Status
	CENTRALXML->XML_NUMNF,;				//"Nº NF-e/Série",;      		// 2
	CENTRALXML->XML_EMISSA,;				//"Emissão",;    		   		// 3
	cFornece,	;				   		//  "Fornecedor/Loja-Nome",;    // 4
	Alltrim(CENTRALXML->XML_CHAVE),;		//	"Chave NF-e",;              // 5
	Transform(CENTRALXML->XML_DEST,"@R 99.999.999/9999-99")+" - " +Capital(CENTRALXML->XML_NOMEDT),;		//	"Destinatário",;            // 6
	CENTRALXML->XML_RECEB,; 				//	"Recebida em",;				// 7
	CENTRALXML->XML_CONFER,;				//"Conferida em",;		   		// 8
	CENTRALXML->XML_LANCAD,;				//"Lançada em" ;				// 9
	CENTRALXML->XML_CONFCO,; 			// Conf.Compras			   		// 10
	CENTRALXML->XML_DTRVLD,;				// Data Reconsulta Sefaz		// 11
	CENTRALXML->XML_TIPODC})				// Tipo de Documento			// 12
	                              
	
	DbSelectArea("CENTRALXML")
	DbSkip()
Enddo

If Len(aArqXml) == 0
	MsgAlert("Não houveram registros para este filtro!")  
	Aadd(aArqXml,{1,"",CTOD("  /  /    "),CTOD("  /  /    ")," "," "," ",CTOD("  /  /    "),CTOD("  /  /    "),CTOD("  /  /    "),CTOD("  /  /    ")," "})
	oArqXml:nAt := 1
Endif

If oArqXml:nAt > Len(aArqXml)
	oArqXml:nAt := Len(aArqXml)
Endif	

//CENTRALXML->(DbCloseArea())

oArqXml:SetArray(aArqXml)
oArqXml:bLine:={ ||{stLegenda(),;
aArqXml[oArqXml:nAT,02],;
aArqXml[oArqXml:nAT,03],;
aArqXml[oArqXml:nAT,04],;
aArqXml[oArqXml:nAT,05],;
aArqXml[oArqXml:nAT,06],;
aArqXml[oArqXml:nAT,07],;
aArqXml[oArqXml:nAT,08],;
aArqXml[oArqXml:nAT,09],;
aArqXml[oArqXml:nAT,10],;
aArqXml[oArqXml:nAt,11],;
aArqXml[oArqXml:nAt,12]}}
oArqXml:Refresh()

U_DbSelArea("CENTRALXML",.F.,1)
DbSeek(aArqXml[oArqXml:nAt,5])
oCgcDest:Refresh()
oCgcEmit:Refresh()
oMunEmit:Refresh()
oMunDest:Refresh()
oNomEmit:Refresh()
oNomDest:Refresh()
oOrdem:Refresh()
cMsgNfe := Substr(CENTRALXML->XML_ARQ,At("<infCpl",CENTRALXML->XML_ARQ)+8,At("</infCpl>",CENTRALXML->XML_ARQ)-At("<infCpl",CENTRALXML->XML_ARQ)-7)
oMsgNfe:Refresh()

Return




Static Function stLegenda()

Local	oRet	:= oVermelho
//	Aadd(aArqXml,{Iif(!Empty(CENTRALXML->XML_REJEIT),3,Iif(Empty(CENTRALXML->XML_KEYF1),1,Iif(Empty(SF1->F1_STATUS),2,4))),;							// 1 Status

If Len(aArqXml) <= 0
	Return oRet
Endif

If	aArqXml[oArqXml:nAt,1] == 1
	oRet	:= oVermelho
ElseIf	aArqXml[oArqXml:nAt,1] == 2
	oRet	:= oVerde
ElseIf	aArqXml[oArqXml:nAt,1] == 3
	oRet	:= oAmarelo
ElseIf	aArqXml[oArqXml:nAt,1] == 4
	oRet	:= oAzul               
ElseIf	aArqXml[oArqXml:nAt,1] == 5
	oRet 	:= oPreto
ElseIf	aArqXml[oArqXml:nAt,1] == 6
	oRet 	:= oPink
ElseIf	aArqXml[oArqXml:nAt,1] == 7
	oRet 	:= oVioleta
ElseIf	aArqXml[oArqXml:nAt,1] == 8
	oRet 	:= oMarrom
ElseIf	aArqXml[oArqXml:nAt,1] == 9
	oRet 	:= oGrey
ElseIf	aArqXml[oArqXml:nAt,1] == 10
	oRet 	:= oLaranja
EndIf

Return(oRet)
                 

Static Function stLegItens(nValLinha)

Local	oRet	:= oVermelho

If Len(oMulti:aCols) <= 0
	Return oRet
Endif

If nValLinha== 1
	oRet	:= oVermelho
ElseIf nValLinha == 2
	oRet	:= oVerde
ElseIf	nValLinha == 3
	oRet	:= oAmarelo
Else
	oRet	:= oAzul
EndIf

Return(oRet)


Static Function stPesquisa()

nAscan := Ascan(aArqXml,{|x| Substr(x[2],1,Len(Alltrim(cVarPesq))) == Alltrim(cVarPesq)})

If nAscan <=0
	nAscan	:= 1
EndIF
oArqXml:nAT 	:= nAscan
oArqXml:Refresh()
cVarPesq		:= Space(TamSX3("F1_SERIE")[1]+TamSX3("F1_DOC")[1])
Eval(oArqXml:bChange)

Return (.T.)




Static Function stConSefaz(cChave)

Local	oDlg
Local	lConsulta	:= .F.
If !Empty(cChave)
	cNavegado	:= Alltrim(GetMv("XM_URLCSFZ"))+cChave
	Define MsDialog oDlg From 0,0 TO aSize[6] , aSize[5]  Pixel Title "Web Browser"
	@ 005,010 Say "Endereço URL da Consulta" of oDlg Pixel
	@ 015,010 MsGet oNavegado var cNavegado Size 300,05 Of oDlg Pixel
	oTIBrowser:= TIBrowser():New(025,010, aSize[5]/2.04,nAltura, cNavegado, oDlg )
	
	@ 010, 350 Button oBtnPrint PROMPT "Confirmar Consulta" Size 70,10 Action (lConsulta := .T. ,oDlg:End()) Of oDlg Pixel
	@ 010, 440 Button oBtnPrint PROMPT "Imprimir" Size 40,10 Action oTIBrowser:Print() Of oDlg Pixel
	@ 010, 490 Button oBtnSair PROMPT "Sair" Size 40,10 Action(oDlg:End()) Of oDlg Pixel
	Activate MsDialog oDlg Centered                                            
	
	If lConsulta
		U_DbSelArea("CENTRALXML",.F.,1)
        If DbSeek(cChave)
        	RecLock("CENTRALXML",.F.)
        	CENTRALXML->XML_CONFER := Date()
        	CENTRALXML->XML_HORCON := Time()
        	CENTRALXML->XML_USRCCO := Padr(cUserName,30)
        	// Efetuo verificação se a Nota não validou pelo padrão do Webservice a consulta, grava a consulta manual na Sefaz
        	If Empty(CENTRALXML->XML_DTRVLD) .And. CENTRALXML->XML_EMISSA <=  (Date() - (GetMv("XM_SPEDEXC")/24)) .And. Empty(CENTRALXML->XML_REJEIT)
        		CENTRALXML->XML_DTRVLD	:= Date()
        	Endif
        	MsUnlock()
        Endif
	Endif	
Endif
Return




Static Function ValidPerg()

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPergXml :=  PADR(cPergXml,Len(SX1->X1_GRUPO))
//     "X1_GRUPO" ,"X1_ORDEM","X1_PERGUNT"    		,"X1_PERSPA"		,"X1_PERENG"		,"X1_VARIAVL","X1_TIPO"	,"X1_TAMANHO"	,"X1_DECIMAL"	,"X1_PRESEL"	,"X1_GSC"	,"X1_VALID"	,"X1_VAR01"	,"X1_DEF01"	,"X1_DEFSPA1"	,"X1_DEFENG1"	,"X1_CNT01"	,"X1_VAR02"	,"X1_DEF02"		,"X1_DEFSPA2"		,"X1_DEFENG2"		,"X1_CNT02"	,"X1_VAR03"	,"X1_DEF03"	,"X1_DEFSPA3"	,"X1_DEFENG3"	,"X1_CNT03"	,"X1_VAR04"	,"X1_DEF04"	,"X1_DEFSPA4"	,"X1_DEFENG4"	,"X1_CNT04"	,"X1_VAR05"	,"X1_DEF05"	,"X1_DEFSPA5","X1_DEFENG5"	,"X1_CNT05"	,"X1_F3"	,"X1_PYME"	,"X1_GRPSXG"	,"X1_HELP"
Aadd(aRegs,{cPergXml ,"01"		,"Apenas NF-e Empresa"  ,"Apenas NF-e Empresa","Apenas NF-e","mv_ch1"	 ,"N"		,1				,0				,1				,"C"		,""			,"mv_par01"	,"Apenas Empresa","Apenas"	,"Apenas esa"	,""			,""			,"Todas Empresas","Todas Empresas"	,"Todas Empresas"	,""			,""			,"",""	,""	,""			,""			,""			,""				,""				,""			,""			,""			,""			,""				,""			,"" 		,"S"		,""				,""})
Aadd(aRegs,{cPergXml ,"02"		,"Fornecedor de"		,"Fornecedor de "	 ,"Fornecedor de"	,"mv_ch2"	,"C"	,6				,0				,0				,"G"		,""			,"mv_par02"	,""			,""				,""				,""			,""			,""				,""					,""					,""			,""			,""			,""				,""				,""			,""			,""			,""				,""				,""			,""			,""			,""			,""				,""			,"SA2" 		,"S"		,"001"			,""})
Aadd(aRegs,{cPergXml ,"03"		,"Loja "				,"Loja "			,"Loja "			,"mv_ch3"	,"C"	,2				,0				,0				,"G"		,""			,"mv_par03"	,""			,""				,""				,""			,""			,""				,""					,""					,""			,""			,""			,""				,""				,""			,""			,""			,""				,""				,""			,""			,""			,""			,""				,""			,"" 		,"S"		,""				,""})
Aadd(aRegs,{cPergXml ,"04"		,"Fornecedor Até"		,"Fornecedor Até"	 ,"Fornecedor Até"	,"mv_ch4"	,"C"	,6				,0				,0				,"G"		,""			,"mv_par04"	,""			,""				,""				,""			,""			,""				,""					,""					,""			,""			,""			,""				,""				,""			,""			,""			,""				,""				,""			,""			,""			,""			,""				,""			,"SA2" 		,"S"		,"001"			,""})
Aadd(aRegs,{cPergXml ,"05"		,"Loja "				,"Loja "			,"Loja Até"			,"mv_ch5"	,"C"	,2				,0				,0				,"G"		,""			,"mv_par05"	,""			,""				,""				,""			,""			,""				,""					,""					,""			,""			,""			,""				,""				,""			,""			,""			,""				,""				,""			,""			,""			,""			,""				,""			,"" 		,"S"		,""				,""})
Aadd(aRegs,{cPergXml ,"06"		,"Emissão de"			,"Emissão de "	 	,"Emissão de"		,"mv_ch6"	,"D"	,8				,0				,0				,"G"		,""			,"mv_par06"	,""			,""				,""				,""			,""			,""				,""					,""					,""			,""			,""			,""				,""				,""			,""			,""			,""				,""				,""			,""			,""			,""			,""				,""			,"" 		,"S"		,""				,""})
Aadd(aRegs,{cPergXml ,"07"		,"Emissão até"			,"Emissão até"		,"Emissão"			,"mv_ch7"	,"D"	,8				,0				,0				,"G"		,""			,"mv_par07"	,""			,""				,""				,""			,""			,""				,""					,""					,""			,""			,""			,""				,""				,""			,""			,""			,""				,""				,""			,""			,""			,""			,""				,""			,"" 		,"S"		,""				,""})
Aadd(aRegs,{cPergXml ,"08"		,"Status da Nota"       ,"Status"           ,"Status"	        ,"mv_ch8"	,"N"	,1				,0				,1				,"C"		,""			,"mv_par08"	,"Apenas Conf.Compras","Conf.","Conf.",""	        ,""			,"Sem Conf.Compras","Sem Conf.pras"	,"Sem Conf.Compras" ,""			,""         ,"Rejeitadas","Rejeitadas"	,"Rejeitadas"	,""			,""			,"Sem Conf.SEFAZ","Sem Conf.","Sem Conf.AZ"	,""			,""			,"Todos XML","" 		,""				,"S"		,""			,""})
Aadd(aRegs,{cPergXml ,"09"		,"CNPJ Forn.de"			,"Fornecedor de "	 ,"Fornecedor de"	,"mv_ch9"	,"C"	,14				,0				,0				,"G"		,""			,"mv_par09"	,""			,""				,""				,""			,""			,""				,""					,""					,""			,""			,""			,""				,""				,""			,""			,""			,""				,""				,""			,""			,""			,""			,""				,""			,"" 		,"S"		,""			,""})
Aadd(aRegs,{cPergXml ,"10"		,"CNPJ Forn.Até"		,"Fornecedor Até"	 ,"Fornecedor Até"	,"mv_cha"	,"C"	,14				,0				,0				,"G"		,""			,"mv_par10"	,""			,""				,""				,""			,""			,""				,""					,""					,""			,""			,""			,""				,""				,""			,""			,""			,""				,""				,""			,""			,""			,""			,""				,""			,"" 		,"S"		,""			,""})
Aadd(aRegs,{cPergXml ,"11"		,"Conf.Sefaz?"          ,"Conf.Sefaz?"      ,"Confere Sefaz?"   ,"mv_chb"	,"N"    ,1				,0				,1				,"C"		,""			,"mv_par11"	,"Sim"		,"Sim"			,"Sim"			,""			,""			,"Não"			,"Nã"				,"Não"				,""			,""			,"",""	,""	,""			,""			,""			,""				,""				,""			,""			,""			,""			,""				,""			,"" 		,"S"		,""				,""})
Aadd(aRegs,{cPergXml ,"12"		,"Cons.Impostos XML?"   ,"Cons.Impostos XML?","Cons.Impostos XML?","mv_chc"	,"N"    ,1				,0				,1				,"C"		,""			,"mv_par12"	,"Sim"		,"Sim"			,"Sim"			,""			,""			,"Não"			,"Nã"				,"Não"				,""			,""			,"",""	,""	,""			,""			,""			,""				,""				,""			,""			,""			,""			,""				,""			,"" 		,"S"		,""				,""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPergXml+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock("SX1")
	Endif
Next

dbSelectArea(_sAlias)

Return
                      

Static Function  stRefrItens()
    
Local	cQry		:= ""
Local	lConvProd	:= .F.                       

cCodForn	:= Space(6)
cLojForn    := Space(2)

cQry += "SELECT XML_DEST,XML_CHAVE,A2_COD,A2_LOJA,A2_CGC "
cQry += "  FROM CENTRALXML XM, "+RetSqlName("SA2") + " A2 "
cQry += " WHERE A2.D_E_L_E_T_ = ' ' "
cQry += "   AND A2_CGC = XML_EMIT "
cQry += "   AND A2_FILIAL = '"+xFilial("SA2")+"' "
cQry += "   AND XM.D_E_L_E_T_ = ' ' "
cQry += "   AND XML_TIPODC IN('N','C','I','P') "
cQry += "   AND XML_CHAVE = '"+Alltrim(aArqXml[oArqXml:nAt,5])+"' "
cQry += "   AND XML_DEST = '"+SM0->M0_CGC+"' " // Ajustar // 
cQry += "UNION ALL "
cQry += "SELECT XML_DEST,XML_CHAVE,A1_COD A2_COD,A1_LOJA A2_LOJA,A1_CGC A2_CGC "
cQry += "  FROM CENTRALXML XM, "+RetSqlName("SA1") + " A1 "
cQry += " WHERE A1.D_E_L_E_T_ = ' ' "
cQry += "   AND A1_CGC = XML_EMIT "
cQry += "   AND A1_FILIAL = '"+xFilial("SA2")+"' "
cQry += "   AND XM.D_E_L_E_T_ = ' ' " 
cQry += "   AND XML_TIPODC IN('D','B') "
cQry += "   AND XML_CHAVE = '"+Alltrim(aArqXml[oArqXml:nAt,5])+"' "
cQry += "   AND XML_DEST = '"+SM0->M0_CGC+"' " // Ajustar // 

TCQUERY cQry NEW ALIAS "QRY"
DbSelectArea("QRY")
If !Empty(QRY->XML_DEST)
	lConvProd	:= .T.               
	cCodForn    := QRY->A2_COD
	cLojForn    := QRY->A2_LOJA      
	cCgcDest	:= QRY->A2_CGC
Endif
QRY->(DbCloseArea())	
     
// Notas que não estejam pendentes de serem lançadas não serão validados os itens.

If aArqXml[oArqXml:nAt,1] > 1 .And. aArqXml[oArqXml:nAt,1] < 6
	lConvProd 	:= .F.
Endif
	

nTotalNfe	:= 0
nTotalXml   := 0
//Use &("CENTRALXMLITENS") Alias &("CENTRALXMLITENS") SHARED NEW Via "TOPCONN"
//DbSetIndex("CENTRALXMLITENS01")
//DbSetNickName(OrdName(1),"CENTRALXMLITENS01")
//DbSetIndex("CENTRALXMLITENS02")
//DbSetNickName(OrdName(2),"CENTRALXMLITENS02")
U_DbSelArea("CENTRALXML",.F.,1)
DbSeek(aArqXml[oArqXml:nAt,5])
oCgcDest:Refresh()
oCgcEmit:Refresh()
oMunEmit:Refresh()
oMunDest:Refresh()
oNomEmit:Refresh()
oNomDest:Refresh()
oOrdem:Refresh()
oMulti:oBrowse:Refresh()  
oTotalXml:Refresh()
oTotalNfe:Refresh()            
cMsgNfe := Substr(CENTRALXML->XML_ARQ,At("<infCpl",CENTRALXML->XML_ARQ)+8,At("</infCpl>",CENTRALXML->XML_ARQ)-At("<infCpl",CENTRALXML->XML_ARQ)-8)
oMsgNfe:Refresh()

aChvNfes := {}
// Tratativa adicionada que localiza se Existe a Tag de Chaves eletronicas referenciadas na Nota fiscal e as exibe na tela
// e alimenta array para futuro uso da mesma.
If At("<NFref><refNFe>",CENTRALXML->XML_ARQ) > 0
	cAviso	:= ""
	cErro	:= ""
	oNfe := XmlParser(CENTRALXML->XML_ARQ,"_",@cAviso,@cErro)
	
	If !Empty(cErro)
		MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
	Endif
	
	If Type("oNFe:_NfeProc")<> "U"
		oNF := oNFe:_NFeProc:_NFe
	Else
		oNF := oNFe:_NFe
	Endif
    oIdent     	:= oNF:_InfNfe:_IDE
	
	If Type("oIdent:_NFref") <> "U"
		oRef	:= oIdent:_NFref
		
		oChv  := oRef:_refNFe
		oChv  := IIf(ValType(oChv)=="O",{oChv},oChv)			
		For nP := 1 To Len(oChv) 
			Aadd(aChvNfes,oChv[nP]:TEXT)	
			cMsgNfe += Chr(13)+Chr(10)+"Chave Nfe Origem:"+oChv[nP]:TEXT
			oMsgNfe:Refresh()
		Next 
	Endif                      
Endif
oMulti:aCols	:= {}

//DbSelectArea("CENTRALXMLITENS")
U_DbSelArea("CENTRALXMLITENS",.F.,2)

Set Filter to Alltrim(CENTRALXMLITENS->XIT_CHAVE) == Alltrim(aArqXml[oArqXml:nAt,5])
Count to nRegXit
//DbSelectArea("CENTRALXMLITENS")
ProcRegua(nRegXit)
DbGotop()
While !Eof() .And. Alltrim(CENTRALXMLITENS->XIT_CHAVE) == Alltrim(aArqXml[oArqXml:nAt,5])
	IncProc("Processando item "+CENTRALXMLITENS->XIT_ITEM)      
	
	Aadd(oMulti:aCols,{Iif(Empty(CENTRALXMLITENS->XIT_PEDIDO),oVermelho,;                         	// 1
		         Iif(CENTRALXMLITENS->XIT_PRUNIT <> Posicione("SC7",1,xFilial("SC7")+CENTRALXMLITENS->XIT_PEDIDO+CENTRALXMLITENS->XIT_ITEMPC,"C7_PRECO"),oAmarelo,oVerde)),;
	 			CENTRALXMLITENS->XIT_ITEM,;      // 2
				Alltrim(CENTRALXMLITENS->XIT_CODNFE),; // 3
		 		Iif(lConvProd .And. Empty(CENTRALXML->XML_KEYF1),stValidSA5(CENTRALXMLITENS->XIT_CODNFE,cCodForn,cLojForn,CENTRALXMLITENS->XIT_DESCRI,IIf(CENTRALXML->XML_TIPODC$"N#C#I#P",Nil,CENTRALXMLITENS->XIT_CODPRD),CENTRALXMLITENS->XIT_UMNFE,CENTRALXML->XML_TIPODC,.F.),CENTRALXMLITENS->XIT_CODPRD),;	// 4 Código Produto no Protheus
				CENTRALXMLITENS->XIT_DESCRI,;	// 5  Descrição Produto no Xml
				CENTRALXMLITENS->XIT_QTENFE,;	// 6  Quantidade no Xml
				CENTRALXMLITENS->XIT_UMNFE,;		// 7  Unidade Medida no Xml
				CENTRALXMLITENS->XIT_PRCNFE,;	// 8  Preço Unitário
				CENTRALXMLITENS->XIT_TOTNFE,;	// 9  Valor Total do Item Xml
				CENTRALXMLITENS->XIT_QTE,;		// 10  Quantidade 
				CENTRALXMLITENS->XIT_UM,;		// 11 Unidade Medida 
				CENTRALXMLITENS->XIT_PRUNIT,;	// 12 Preço Unitário
				CENTRALXMLITENS->XIT_TOTAL,;		// 13 Valor Total do Item
				CENTRALXMLITENS->XIT_TES,;		// 14 Código do TES
				CENTRALXMLITENS->XIT_CFNFE,;		// 15 Código do CFOP no Xml
				CENTRALXMLITENS->XIT_CF,;		// 16 Código do CFOP
				CENTRALXMLITENS->XIT_NCM,;		// 17 Código do NCM
				CENTRALXMLITENS->XIT_PEDIDO,;	// 18 Número Pedido Compra
				CENTRALXMLITENS->XIT_ITEMPC,;	// 19 Item pedido compra
				CENTRALXMLITENS->XIT_VALDES,;	// 20 Valor do Desconto				
				CENTRALXMLITENS->XIT_BASICM,;	// 21 Base Calculo Icms
				CENTRALXMLITENS->XIT_PICM  ,; 	// 22 Percentual Icms
				CENTRALXMLITENS->XIT_VALICM,;	// 23 Valor do Icms
				CENTRALXMLITENS->XIT_BASIPI,;	// 24 Base Calculo IPI
				CENTRALXMLITENS->XIT_PIPI ,;		// 25 Percentual IPI
				CENTRALXMLITENS->XIT_VALIPI,;	// 26 Valor do IPI				
				CENTRALXMLITENS->XIT_BASPIS,;	// 27 Base Calculo PIS
				CENTRALXMLITENS->XIT_PPIS,; 		// 28 Percentual PIS
				CENTRALXMLITENS->XIT_VALPIS,;	// 29 Valor do PIS				
				CENTRALXMLITENS->XIT_BASCOF,;	// 30 Base Calculo Cofins
				CENTRALXMLITENS->XIT_PCOF ,;		// 31 Percentual Cofins
				CENTRALXMLITENS->XIT_VALCOF,;	// 32 Valor do Cofins				
				CENTRALXMLITENS->XIT_BASRET,;	// 33 Base Calculo Icms Retido
				CENTRALXMLITENS->XIT_PMVA  ,;	// 34 Percentual Icms Retido
				CENTRALXMLITENS->XIT_VALRET,;	// 35 Valor do Icms Retido				
				CENTRALXMLITENS->XIT_CLASFI,;    // 36 Classificação fiscal
				CENTRALXMLITENS->XIT_KEYSD1,; 	// 37 Chave SD1 - D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				"",;							// 38 Nf Origem
				"",;							// 39 Serie Origem
				"",;							// 40 Item Origem
				"01",;							// 41 Armazém
				0,;								// 42 Valor do Desconto
				0,;								// 43 Perc.Desconto
				"",;							// 44 Identificação SB6 Retorno
				.F.})
				// Se a nota for da empresa em uso, já valido o pedido de compra por item automatico
				If lConvProd .And. Empty(CENTRALXMLITENS->XIT_PEDIDO) .And. Empty(CENTRALXML->XML_KEYF1)
					If nAlertPrc == 1
						If CENTRALXML->XML_TIPODC == "N" .And. lMVXPCNFE .And. !Alltrim(CENTRALXMLITENS->XIT_CFNFE) $ cCFOPNPED .And. MsgNoYes("Exibir alerta de divergência de preço para todos os itens?","A T E N Ç Ã O !! ")
							nAlertPrc := 2
						Else
							nAlertPrc := 3
						Endif
					Endif						      
					U_VldItemPc(Len(oMulti:aCols),.T.)					
				ElseIf lConvProd .And. !Empty(CENTRALXMLITENS->XIT_PEDIDO) .And. Empty(CENTRALXML->XML_KEYF1) .And. CENTRALXML->XML_TIPODC == "N"
					U_VldItemPc(Len(oMulti:aCols),.T.,CENTRALXMLITENS->XIT_PEDIDO,CENTRALXMLITENS->XIT_ITEMPC)									    	
				Else
					sfRefLeg(Len(oMulti:aCols))
				Endif

	DbSelectArea("CENTRALXMLITENS")
	DbSkip()
Enddo                          
nAlertPrc	:= 1
oMulti:oBrowse:Refresh()

nTotalNFe 	:= 0
nTotalXml	:= 0
For iR := 1 To Len(oMulti:aCols)
	If !oMulti:aCols[iR,Len(oMulti:aHeader)+1]
		nTotalNfe += oMulti:aCols[iR,nPxTotal] - oMulti:aCols[iR,nPxVlDesc]
		nTotalXml += oMulti:aCols[iR,nPxTotNfe]
	Endif
Next
oTotalNfe:Refresh()                  
oTotalXml:Refresh()

U_DbSelArea("CENTRALXMLITENS",.F.,2)
Set Filter to                      

//CENTRALXMLITENS->(DbCloseArea())	
Return


Static Function stLinOk()

If Empty(oMulti:aCols[oMulti:nAt,nPxItem])
	Return .F.
Endif
     

DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(xFilial("SB1")+oMulti:aCols[oMulti:nAt,nPxPrd]) .And. !Empty(oMulti:aCols[oMulti:nAt,nPxNCM])
	// Efetua a atualização do NCM do produto
	If Empty(SB1->B1_POSIPI) .and. !Empty(oMulti:aCols[oMulti:nAt,nPxNCM]) .and. oMulti:aCols[oMulti:nAt,nPxNCM] != '00000000'
		RecLock("SB1",.F.)
		Replace B1_POSIPI with oMulti:aCols[oMulti:nAt,nPxNCM]
		MSUnLock()
	Endif
	
	// Efetuo validação que envia email ao Departamento Fiscal informando sobre diferença no cadastro do NCM do Produto
	If Alltrim(SB1->B1_POSIPI) <> Alltrim( oMulti:aCols[oMulti:nAt,nPxNCM] )
		cRecebe		:= GetMv("XM_MAILXML")	// Destinatarios de email do lançamento da nota
		cAssunto 	:= "Divergência NCM do Produto '"+Alltrim(SB1->B1_COD)+"-"+Alltrim(SB1->B1_DESC)+" na Empresa:"+Capital(SM0->M0_NOMECOM)
		cMensagem	:= "Produto  :"+Alltrim(SB1->B1_COD)+"-"+Alltrim(SB1->B1_DESC)
		cMensagem 	+= Chr(13)+Chr(10)
		cMensagem	+= "Empresa  :"+Capital(SM0->M0_NOMECOM)
		cMensagem 	+= Chr(13)+Chr(10)
		cMensagem	+= "NCM Atual:"+Alltrim(SB1->B1_POSIPI)
		cMensagem 	+= Chr(13)+Chr(10)
		cMensagem	+= "NCM XML  :"+oMulti:aCols[oMulti:nAt,nPxNCM]
		cMensagem 	+= Chr(13)+Chr(10)
		cMensagem	+= "NF-e Nº  :"+Alltrim(aArqXml[oArqXml:nAt,2])
		cMensagem 	+= Chr(13)+Chr(10)
		stSendMail( cRecebe, cAssunto, cMensagem )
	Endif
	
Endif


nTotalNFe 	:= 0
nTotalXml	:= 0
For iR := 1 To Len(oMulti:aCols)
	If !oMulti:aCols[iR,Len(oMulti:aHeader)+1]
		nTotalNfe += oMulti:aCols[iR,nPxTotal] - oMulti:aCols[iR,nPxVlDesc]
		nTotalXml += oMulti:aCols[iR,nPxTotNfe]
	Endif
Next
oTotalNfe:Refresh()                  
oTotalXml:Refresh()


Return .T.

User Function VldSA5(cCodProd,cCodForn,cLojForn,cDescForn)
Local	lRet	:= .F.
Local	cRetA5	:= ""

// Evita que abra a tela de validação de Produto X Fornecedor quando não houver item digitado
If Empty(oMulti:aCols[oMulti:nAt,nPxItem])
	Return
Endif
cRetA5	:= stValidSA5(cCodProd,cCodForn,cLojForn,cDescForn,M->D1_COD,oMulti:aCols[oMulti:nAt,nPxUMNFe],aArqXml[oArqXml:nAt,12],.T.)

DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(xFilial("SB1")+cRetA5 )
	M->D1_COD	:= SB1->B1_COD
	oMulti:aCols[oMulti:nAt,nPxD1Tes] 	:= SB1->B1_TE
	oMulti:aCols[oMulti:nAt,nPxUM]		:= SB1->B1_UM
	oMulti:aCols[oMulti:nAt,nPxCF]		:= Posicione("SF4",1,xFilial("SF4")+SB1->B1_TE,"F4_CF")
	lRet := .T.
Endif

Return lRet

User Function VlsSF4()

//oMulti:aCols[oMulti:nAt,nPxCF]		:= Posicione("SF4",1,xFilial("SF4")+M->D1_TES,"F4_CF")
cRetCF	:= "1"
If aArqXml[oArqXml:nAt,12]	$ "B#D"
	DbSelectArea("SA1")
	DbSetOrder(3)
	If DbSeek(xFilial("SA1")+CENTRALXML->XML_EMIT)
		If SA1->A1_EST == SuperGetMv("MV_ESTADO")
			cRetCF := "1"
		Else
			cRetCF := "2"
		EndIf
	Endif
Else
	DbSelectArea("SA2")
	DbSetOrder(3)
	If DbSeek(xFilial("SA2")+CENTRALXML->XML_EMIT)
		If SA2->A2_EST == SuperGetMv("MV_ESTADO")
			cRetCF := "1"
		Else
			cRetCF := "2"
		EndIf
	Endif
Endif

_cTes := ""
If !Empty(&(ReadVar()))
	_cTes := &(ReadVar())
Else
	_cTes := oMulti:aCols[oMulti:nAt][nPxD1Tes]
EndIf
oMulti:aCols[oMulti:nAt][nPxCF] 	:=  cRetCF+Substr(Posicione("SF4",1,xFilial("SF4")+_cTes,"F4_CF"),2,3)
	
Return .T.


Static Function stValidSA5(cCodProd,cCodForn,cLojForn,cDescForn,cRefProtheus,cInUnidForn,cTipoDoc,_lRef)

Local		cVar			:= Padr(" ",TamSX3("B1_COD")[1])
Local		lPergAtu		:= .T.
Local		lAtuSA5			:= .F.
Local		lAtuSA7			:= .F.
Default 	cRefProtheus	:= cVar                                                              
Default		cTipoDoc		:= "N"
Private		cUnidForn		:= cInUnidForn     

If cTipoDoc $ "N#C#P#I"
	cQry := "SELECT A5_CODPRF,A5_PRODUTO,A5_NOMPROD"
	cQry += "  FROM " + RetSqlName("SA5")
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	cQry += "   AND A5_FORNECE = '"+ cCodForn+ "' "    
	cQry += "   AND A5_LOJA = '"+cLojForn+"' "
	cQry += "   AND A5_CODPRF ='" + Alltrim(cCodProd) + "' "     
	cQry += "   AND A5_FILIAL = '" + xFilial("SA5") + "' "
	
	TCQUERY cQry NEW ALIAS "QRY"
	
	Count to nCountA5
	
	If nCountA5 > 0                    // Abre 05
		
		aCampos := {}
		aTam:=TamSX3("A5_CODPRF")
		AADD(aCampos,{"CODPRF" ,"C",aTam[1],aTam[2]})
		aTam:=TamSX3("A5_PRODUTO")
		AADD(aCampos,{"PRODUTO" ,"C",aTam[1],aTam[2]})
		aTam:=TamSX3("A5_NOMPROD")
		AADD(aCampos,{"NOMPROD" ,"C",aTam[1],aTam[2]})
		aTam:=TamSX3("B1_DESC")
		AADD(aCampos,{"DESC" ,"C",aTam[1],aTam[2]})
		
		cArqTra  := CriaTrab(aCampos,.T.)
		dbUseArea(.T.,,cArqTra,"_SA5", .T. , .F. )
		DbSelectArea("QRY")
		DbGotop()
		While !Eof()
			DbSelectArea("_SA5")
			RecLock("_SA5",.T.)
			_SA5->CODPRF	:= QRY->A5_CODPRF
			_SA5->PRODUTO	:= QRY->A5_PRODUTO
			_SA5->NOMPROD	:= cDescForn
			_SA5->DESC		:= Posicione("SB1",1,xFilial("SB1")+QRY->A5_PRODUTO,"B1_DESC")
			MsUnlock()
			DbSelectArea("QRY")
			DbSkip()
		Enddo
		
		aCpos := {}
		AADD(aCpos   , {"CODPRF" , "Cod.Fornecedor" })
		AADD(aCpos   , {"PRODUTO", "Referência Protheus" })
		AADD(aCpos   , {"NOMPROD", "Descrição Fornecedor" })
		AADD(aCpos   , {"DESC"   , "Descrição Interno" })
		
		If nCountA5 > 1 .and. _lRef
		
			DEFINE MSDIALOG oDlg Title OemToAnsi("Produtos X Fornecedor") FROM 001,001 TO 380,810 PIXEL
			DbSelectArea("_SA5")
			DbGoTop()
			iw_browse(10,10,160,390,"_SA5",,,aCpos)
			@ 165,060 BUTTON "&Confirma" Action(cVar := _SA5->PRODUTO,oDlg:End())	Pixel Of oDlg
			@ 165,180 Button "&Aborta" Action (oDlg:End())  Pixel Of oDlg
			ACTIVATE MsDialog oDlg Centered
		Else
			cVar := _SA5->PRODUTO
		Endif
		
		DbSelectArea("_SA5")
		DbCloseArea()
		cDelArq:=cArqTra+".*"
		Ferase(cDelArq)
	Endif	
	
	QRY->(DbCloseArea())
	    
		cQry := "SELECT B1_COD "
		cQry += "  FROM " + RetSqlName("SB1")
		cQry += " WHERE D_E_L_E_T_ = ' '  "
		cQry += "   AND B1_PROC = '"+cCodForn + "' "
		cQry += "   AND B1_FABRIC = '"+Alltrim(cCodProd)+ "' "
		cQry += "   AND B1_FILIAL = '"+xFilial("SB1") +"' "
	 	
	 	TCQUERY cQry NEW ALIAS "_SB1"
	 	
	 	If !Eof()
	 		cRefProtheus	:= _SB1->B1_COD 
	 		lPergAtu		:= .F.
	 	Endif
	 	_SB1->(DbCloseArea())
	
		cQry := "SELECT A5_PRODUTO,A5_NOMPROD "
		cQry += "  FROM " + RetSqlName("SA5")
		cQry += " WHERE D_E_L_E_T_ = ' ' "
		cQry += "   AND A5_CODPRF = '"+cCodProd+"' "
		cQry += "   AND A5_PRODUTO != '  ' "
		cQry += "   AND A5_LOJA = '"+cLojForn+"' "
		cQry += "   AND A5_FORNECE = '"+  cCodForn  + "' "
		cQry += "   AND A5_PRODUTO ='" + Padr(cVar,TamSX3("A5_PRODUTO")[1])+ "' "
		cQry += "   AND A5_FILIAL = '" + xFilial("SA5") + "' "
		
		TCQUERY cQry NEW ALIAS "_SA5"
		
		Count to nCountA5
		
		If nCountA5 == 0 
			lAtuSA5		:= .T.
		ElseIf !Empty(cRefProtheus)
			If  lPergAtu
				If MsgYesNo("Força atualização da Conversão de Produto X Fornecedor?","A T E N Ç Ã O !!")
					lAtuSA5	:= .T.      
				Endif
			ElseIf nCountA5 == 0	
	            lAtuSA5 	:= .T.
	        Endif
	    Endif
	    _SA5->(DbCloseArea())	
		
	    If lAtuSA5 .and. _lRef
				
			cCodAux	:= cCodProd
			lAtuA5 := .F.			
			cVar		:= Padr(cRefProtheus,TamSX3("B1_COD")[1])			
						
			DEFINE MSDIALOG oDlgA5 Title OemToAnsi("Atualizar Produto X Fornecedor") FROM 001,001 TO 190,450 PIXEL
			@ 010,010 Say ("Informe os códigos para conversão das Referências'") Pixel of oDlgA5
			@ 022,010 Say "'"+ cCodProd+"-"+cDescForn+"'" Pixel Of oDlgA5
			@ 032,010 Say "Referência Fornecedor" Pixel of oDlgA5
			@ 032,080 MsGet oCodAux Var cCodAux Size 80,10 Picture "@!" Pixel Of oDlgA5
			@ 045,010 Say "Código Protheus" Pixel of oDlgA5
			@ 045,080 MsGet oCod Var cVar Valid ExistCpo("SB1",cVar,1) F3 "SB1" Size 50,10 Picture "@!" Pixel Of oDlgA5
			
			@ 057,010 Say "2ª Unidade/Med.Fornecedor" Pixel of oDlgA5
			@ 057,080 MsGet oUnidFor Var cUnidForn Valid ExistCpo("SAH",cUnidForn,1) F3 "SAH" Size 50,10 Picture "@!" Pixel Of oDlgA5
			
			@ 075,010 BUTTON "Confirma" Size 70,10 Action (ExistCpo("SB1",cVar,1),lAtuA5 := .T.,oDlgA5:End())	Pixel Of oDlgA5
			@ 075,090 BUTTON "Cancela" Size 70,10 Action (oDlgA5:End())	Pixel Of oDlgA5
			
			ACTIVATE MsDialog oDlgA5 Centered
			
			If lAtuA5                              
				DbSelectArea("SA5")
				DbSetOrder(2)
				If DbSeek(xFilial("SA5")+cVar+cCodForn+cLojForn)
					RecLock("SA5",.F.)
					SA5->A5_CODPRF  :=	cCodAux
					SA5->A5_NOMPROD	:=  cDescForn
					SA5->A5_NOMEFOR	:=	Posicione("SA2",1,xFilial("SA2")+cCodForn+cLojForn,"A2_NOME")
					SA5->A5_NOMPROD	:=  cDescForn
					SA5->A5_UNID	:=  cUnidForn
					MsUnlock()
				Else
					RecLock("SA5",.T.)
					SA5->A5_FILIAL 	:=	xFilial("SA5")
					SA5->A5_FORNECE	:= 	cCodForn
					SA5->A5_LOJA	:= 	cLojForn
					SA5->A5_NOMEFOR	:=	Posicione("SA2",1,xFilial("SA2")+cCodForn+cLojForn,"A2_NOME")
					SA5->A5_PRODUTO	:=  cVar
					SA5->A5_NOMPROD	:=  cDescForn
					SA5->A5_CODPRF	:=  cCodAux
					SA5->A5_UNID	:=  cUnidForn
					MsUnlock()
				Endif                	
			Endif                       
		Endif    						
Else                   
	//A7_FILIAL    CHAR(2)           '  '                                      
	//A7_CLIENTE   CHAR(6)           '      '                                  
	//A7_LOJA      CHAR(2)           '  '                                      
	//A7_PRODUTO   CHAR(15)          '               '                         
	//A7_CODCLI    CHAR(15)          '               '                         
	//A7_DESCCLI   CHAR(30)          '                              '          
    
	cQry := "SELECT B1_COD "
	cQry += "  FROM " + RetSqlName("SB1")
	cQry += " WHERE D_E_L_E_T_ = ' '  "
	cQry += "   AND B1_COD IN('"+Alltrim(cCodProd)+ "','"+Alltrim(cRefProtheus)+"') "
	cQry += "   AND B1_FILIAL = '"+xFilial("SB1") +"' "
 	
 	TCQUERY cQry NEW ALIAS "_SB1"
 	
 	If !Eof()
 		cRefProtheus	:= _SB1->B1_COD 
 		lPergAtu		:= .F.
 	Endif                  
 	
 	_SB1->(DbCloseArea())
    
	cQry := "SELECT A7_PRODUTO,A7_CODCLI,A7_DESCCLI,B1_DESC "
	cQry += "  FROM " + RetSqlName("SA7") + " A7, "+ RetSqlName("SB1")+ " B1 "
	cQry += " WHERE B1.D_E_L_E_T_ = ' ' "
	cQry += "   AND B1_COD = A7_PRODUTO "
	cQry += "   AND B1_FILIAL = '"+xFilial("SB1")+"' "
	cQry += "   AND A7_CLIENTE = '"+ cCodForn+ "' "    
	cQry += "   AND A7_LOJA = '"+cLojForn+"' "
	cQry += "   AND A7_CODCLI ='" + Alltrim(cCodProd) + "' "     
	cQry += "   AND A7_FILIAL = '" + xFilial("SA7") + "' "
	
	TCQUERY cQry NEW ALIAS "QRY"
	
	Count to nCountA7
	              
	
	If nCountA7 == 0 .And. lPergAtu                   // Abre 05
		cQry := "SELECT DISTINCT D2_COD A7_PRODUTO,' ' A7_CODCLI,' ' A7_DESCCLI,B1_DESC  "
		cQry += "  FROM "+RetSqlName("SD2")+" D2, "+RetSqlName("SB1") + " B1 "
		cQry += " WHERE B1.D_E_L_E_T_ = ' ' "
		aStrDesc	:= StrTokArr(cDescForn," ")
		For xZ := 1 To Len(aStrDesc)        
			If xZ == 1
				cQry += "   AND ( B1_DESC LIKE '%"+aStrDesc[xZ]+"%' "
			Else
				cQry += "   OR B1_DESC LIKE '%"+aStrDesc[xZ]+"%' "			
			Endif
			If xZ == Len(aStrDesc)
				cQry += " )"
			Endif
		Next 			
		cQry += "   AND B1_COD = D2_COD "
		cQry += "   AND B1_FILIAL = '"+xFilial("SB1")+"' "
		cQry += "   AND D2.D_E_L_E_T_ = ' ' "
		cQry += "   AND D2_QTDEDEV < D2_QUANT "
		cQry += "   AND D2_LOJA = '"+cLojForn+"' "
		cQry += "   AND D2_CLIENTE = '"+cCodForn+"' "
		cQry += "   AND D2_FILIAL = '"+xFilial("SD2")+"' "
		cQry += " ORDER BY 4,1 "
		
		QRY->(DbCloseArea())
		
		TCQUERY cQry NEW ALIAS "QRY"
		
		Count to nCountA7
	
	Endif
		
	If nCountA7 > 0                    // Abre 05
		
		aCampos := {}
		aTam:=TamSX3("A7_CODCLI")
		AADD(aCampos,{"CODPRF" ,"C",aTam[1],aTam[2]})
		aTam:=TamSX3("A7_PRODUTO")
		AADD(aCampos,{"PRODUTO" ,"C",aTam[1],aTam[2]})
		aTam:=TamSX3("A7_DESCCLI")
		AADD(aCampos,{"NOMPROD" ,"C",aTam[1],aTam[2]})
		aTam:=TamSX3("B1_DESC")
		AADD(aCampos,{"DESC" ,"C",aTam[1],aTam[2]})
		
		cArqTra  := CriaTrab(aCampos,.T.)
		dbUseArea(.T.,,cArqTra,"_SA7", .T. , .F. )
		DbSelectArea("QRY")
		DbGotop()
		While !Eof()
			DbSelectArea("_SA7")
			RecLock("_SA7",.T.)
			_SA7->CODPRF	:= QRY->A7_CODCLI
			_SA7->PRODUTO	:= QRY->A7_PRODUTO
			_SA7->NOMPROD	:= cDescForn
			_SA7->DESC		:= QRY->B1_DESC
			MsUnlock()
			DbSelectArea("QRY")
			DbSkip()
		Enddo
		
		aCpos := {}
		AADD(aCpos   , {"CODPRF" , "Cod.Fornecedor" })
		AADD(aCpos   , {"PRODUTO", "Referência AP" })
		AADD(aCpos   , {"NOMPROD", "Descrição Fornecedor" })
		AADD(aCpos   , {"DESC"   , "Descrição Interno" })
		
		If nCountA7 > 1 .and. _lRef
		
			DEFINE MSDIALOG oDlg Title OemToAnsi("Produtos X Cliente") FROM 001,001 TO 380,810 PIXEL
			DbSelectArea("_SA7")
			DbGoTop()
			iw_browse(10,10,160,390,"_SA7",,,aCpos)
			@ 165,060 BUTTON "&Confirma" Action(cVar := _SA7->PRODUTO,oDlg:End())	Pixel Of oDlg
			@ 165,180 Button "&Aborta" Action (oDlg:End())  Pixel Of oDlg
			ACTIVATE MsDialog oDlg Centered
		Else
			cVar := _SA7->PRODUTO
		Endif
		
		DbSelectArea("_SA7")
		DbCloseArea()
		cDelArq:=cArqTra+".*"
		Ferase(cDelArq)
	Endif	
	
	QRY->(DbCloseArea())
	
	 
	cQry := "SELECT A7_PRODUTO,A7_DESCCLI "
	cQry += "  FROM " + RetSqlName("SA7")
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	cQry += "   AND A7_CODCLI = '"+cCodProd+"' "
	cQry += "   AND A7_PRODUTO != '  ' "
	cQry += "   AND A7_LOJA = '"+cLojForn+"' "
	cQry += "   AND A7_CLIENTE = '"+  cCodForn  + "' "
	cQry += "   AND A7_PRODUTO ='" + Padr(cVar,TamSX3("A7_PRODUTO")[1])+ "' "
	cQry += "   AND A7_FILIAL = '" + xFilial("SA7") + "' "
		
	TCQUERY cQry NEW ALIAS "_SA7"
		
	Count to nCountA7
		
	If nCountA7 == 0 
		lAtuSA7		:= .T.
	ElseIf !Empty(cRefProtheus)
		If  lPergAtu
			If MsgYesNo("Força atualização da Conversão de Produto X Cliente?","A T E N Ç Ã O !!")
				lAtuSA7	:= .T.      
			Endif
		ElseIf nCountA7 == 0	
            lAtuSA7 	:= .T.
        Endif
    Endif
    _SA7->(DbCloseArea())	
		
    If lAtuSA7 .and. _lRef
				
		cCodAux	:= cCodProd
		lAtuA7 := .F.			
		
		cVar		:= Padr(Iif(Empty(cRefProtheus),cVar,cRefProtheus),TamSX3("B1_COD")[1])			
						
		DEFINE MSDIALOG oDlgA5 Title OemToAnsi("Atualizar Produto X Cliente") FROM 001,001 TO 190,450 PIXEL
		@ 010,010 Say ("Informe os códigos para conversão das Referências'") Pixel of oDlgA5
		@ 022,010 Say "'"+ cCodProd+"-"+cDescForn+"'" Pixel Of oDlgA5
		@ 032,010 Say "Referência Cliente" Pixel of oDlgA5
		@ 032,080 MsGet oCodAux Var cCodAux Size 80,10 Picture "@!" Pixel Of oDlgA5
		@ 045,010 Say "Código Protheus" Pixel of oDlgA5
		@ 045,080 MsGet oCod Var cVar Valid ExistCpo("SB1",cVar,1) F3 "SB1" Size 50,10 Picture "@!" Pixel Of oDlgA5
						
		@ 075,010 BUTTON "Confirma" Size 70,10 Action (ExistCpo("SB1",cVar,1),lAtuA7 := .T.,oDlgA5:End())	Pixel Of oDlgA5
		@ 075,090 BUTTON "Cancela" Size 70,10 Action (oDlgA5:End())	Pixel Of oDlgA5
			
		ACTIVATE MsDialog oDlgA5 Centered
			
			If lAtuA7                              
				DbSelectArea("SA7")
				DbSetOrder(2)
				If DbSeek(xFilial("SA7")+cVar+cCodForn+cLojForn)
					RecLock("SA7",.F.)
					SA7->A7_CODCLI  :=	cCodAux
					SA7->A7_DESCCLI	:=  cDescForn
					MsUnlock()
				Else
					RecLock("SA7",.T.)
					SA7->A7_FILIAL 	:=	xFilial("SA7")
					SA7->A7_CLIENTE	:= 	cCodForn
					SA7->A7_LOJA	:= 	cLojForn
					SA7->A7_PRODUTO	:=  cVar
					SA7->A7_DESCCLI	:=  cDescForn
					SA7->A7_CODCLI	:=  cCodAux
					MsUnlock()
				Endif                	
			Endif                       
		Endif    			
Endif

Return cVar



/**
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ºFPAPITEMPCºAutor  ºMarcelo Lauschner   º Data º 06/08/2010	                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     º Validação do produto D1_COD                                                         º±±
±±º          º 																	                   º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
**/
User Function VldItemPc(nLinha,lAutoSC7,cNumC7,cItemC7,lConfFinal)

Local nOpca      := 0
Local aAreaOld      := GetArea()
Local aStruSC7   := SC7->(dbStruct())
Local aCab       := {}
Local aCampos    := {}
Local aArrSldo	  := {}
Local aArrayF4	  := {}
Local aTamCab     := {}
Local aButtons	  := { {'PESQUISA',{||A103VisuPC(aArrSldo[oQual:nAt][2]),Pergunte(cPergXml,.F.)},OemToAnsi("Visualiza Pedido"),OemToAnsi("Visualiza pedido")},;
					   {'ALTERA',{|| U_XmlAltPC(aArrSldo[oQual:nAt][2])},OemToAnsi("Altera Pedido"),OemToAnsi("Altera pedido")}} 
Local nFreeQt     := 0
Local cVar        := ""
Local cQuery      := ""
Local cAliasSC7   := "SC7"
Local cCpoObri    := ""
Local nSavQual
Local nPed        := 0
Local nX          := 0
Local nAuxCNT     := 0
Local lRet103Vpc  := .T.
Local lContinua   := .T.
Local oQual
Local oDlg
Local bWhile           
DEFAULT nLinha		:= oMulti:nAt                     
Default lAutoSC7	:= .F.                    
Default cNumC7		:= ""
Default cItemC7		:= ""
Default lConfFinal	:= .F.
Private	aRotina		:= {}
PRIVATE nTipo 		:= 1
PRIVATE cCadastro	:= OemToAnsi("Visualização de Pedido de Compra") 
PRIVATE l120Auto	:= .F. 
PRIVATE nTipoPed    := 1 // 1 - Ped. Compra 2 - Aut. Entrega
Private INCLUI		:= .F.
Private ALTERA		:= .T.
PRIVATE l120Auto    := .F.
PRIVATE lPedido     := .T.
PRIVATE lGatilha    := .T.                          // Para preencher aCols em funcoes chamadas da validacao (X3_VALID)
PRIVATE lVldHead    := GetNewPar( "MV_VLDHEAD",.T. )// O parametro MV_VLDHEAD e' usado para validar ou nao o aCols (uma linha ou todo), a partir das validacoes do aHeader -> VldHead()
Private aRotina		:= StaticCall(MATA103,MenuDef)

cVar	:=	oMulti:aCols[nLinha][nPxPrd]                          

// Faço o preenchimento do armazém
If Empty(oMulti:aCols[nLinha][nPxLocal])
	oMulti:aCols[nLinha][nPxLocal]   := Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nLinha,nPxPrd],"B1_LOCPAD")
Endif

If aArqXml[oArqXml:nAt,12]	$ "B#D"
	cRetCF	:= "1"
	DbSelectArea("SA1")
	DbSetOrder(3)
	If DbSeek(xFilial("SA1")+CENTRALXML->XML_EMIT)
		If SA1->A1_EST == SuperGetMv("MV_ESTADO")
			cRetCF := "1"
		Else
			cRetCF := "2"
		EndIf
	Endif

	oMulti:aCols[nLinha][nPxUM]		:= 	Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nLinha,nPxPrd],"B1_UM")				
	oMulti:aCols[nLinha][nPxQte]       :=  oMulti:aCols[nLinha,nPxQteNfe] 
	oMulti:aCols[nLinha][nPxPrunit]	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],4)
	oMulti:aCols[nLinha][nPxTotal]	  	:= 	oMulti:aCols[nLinha,nPxTotNfe]   
	
	If aArqXml[oArqXml:nAt,12]	$ "B" 		
		// Efetuo a conversão de CFOP de retorno de Terceiros conforme parametro
		If aScan(aRetPoder3,{|x| Alltrim(x[1]) == Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) }) > 0
			oMulti:aCols[nLinha][nPxD1Tes]	:=  aRetPoder3[aScan(aRetPoder3,{|x| Alltrim(x[1]) == Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) }),2]
			oMulti:aCols[nLinha][nPxCF] 	:= cRetCF+Substr(Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_CF"),2,3)	
		Endif
	Endif
	oMulti:oBrowse:Refresh()
    
    If oMulti:aCols[nLinha,nPxQte] > 0
		aCols		:= aClone(oMulti:aCols)
		aHeader		:= oMulti:aHeader                             
		aHeadBk		:= aClone(aHeader)                                               
		n			:= nLinha
		nRecSD2		:= 0            
		nRegistro	:= 0
		
		DbSelectArea("SF4")
        DbSetOrder(1)
        DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])
        
		If aArqXml[oArqXml:nAt,12]	$ "B" .And. SF4->F4_PODER3 == "D"
            
			F4Poder3(cVar,,"B","E",cCodForn,cLojForn,@nRegistro,)			
			nRecSD2	:= nRegistro
		//  F4Poder3(cProduto,cLocal                  ,cTpNF,cES,cCliFor ,cLoja   ,nRegistro,cEstoque,cNumPV)
		//  F4Poder3(cProduto,cLocal,                 M->C5_TIPO,"S",M->C5_CLIENTE,M->C5_LOJACLI,,SF4->F4_ESTOQUE,M->C5_NUM)
		Endif
		
		If aArqXml[oArqXml:nAt,12]	$ "D" 				
			F4NFORI(       ,      ,"_NFORI",cCodForn,cLojForn,cVar    ,"A100","01" , @nRecSD2 )
		Endif
		// xunxo....
		oMulti:aCols[nLinha] := aCols[nLinha]
		
		// Efetuo ajuste do TES correto conforme TES de Devolução no Cadastro
		DbSelectArea("SD2")
		DbGoto(nRecSD2)
		If !Empty(Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_TESDV"))
			oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_TESDV")
			oMulti:aCols[nLinha][nPxCF] 	:=  cRetCF+Substr(Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_CF"),2,3)
		Endif
		oMulti:oBrowse:Refresh()
    
		Return .T.
	Else          
		MsgAlert("Não há como buscar histórico da devolução se não tiver quantidade digitada!","Operação não permitida")
		Return .F.
	Endif
ElseIf aArqXml[oArqXml:nAt,12]	$ "CPI"
	
	cRetCF	:= "1"
	DbSelectArea("SA2")
	DbSetOrder(3)
	If DbSeek(xFilial("SA2")+CENTRALXML->XML_EMIT)
		If SA2->A2_EST == SuperGetMv("MV_ESTADO")
			cRetCF := "1"
		Else
			cRetCF := "2"
		EndIf
	Endif

	oMulti:aCols[nLinha][nPxUM]		:= 	Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nLinha,nPxPrd],"B1_UM")				
	oMulti:aCols[nLinha][nPxPrunit]	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],4)
	oMulti:aCols[nLinha][nPxTotal]	  	:= 	oMulti:aCols[nLinha,nPxTotNfe]   
	
	oMulti:oBrowse:Refresh()
    
    aCols		:= aClone(oMulti:aCols)
	aHeader		:= oMulti:aHeader                             
	aHeadBk		:= aClone(aHeader)                                               
	n			:= nLinha
	nRecSD1		:= 0            
		
	DbSelectArea("SF4")
    DbSetOrder(1)
    DbSeek(xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes])       
		
	//F4NFORI(       ,      ,"_NFORI",cCodForn,cLojForn,cVar    ,"A100","01" , @nRecSD2 )
	If F4COMPL(,,,cCodForn,cLojForn,cVar,"A100",@nRecSD1,"M->D1_NFORI") .And. nRecSD1<>0
	// xunxo....
		oMulti:aCols[nLinha] := aCols[nLinha]		
	Endif	
	oMulti:oBrowse:Refresh()    
	Return .T.
Else
		
	cRetCF	:= "1"
	DbSelectArea("SA2")
	DbSetOrder(3)
	If DbSeek(xFilial("SA2")+CENTRALXML->XML_EMIT)
		If SA2->A2_EST == SuperGetMv("MV_ESTADO")
			cRetCF := "1"
		Else
			cRetCF := "2"
		EndIf
	Endif    
Endif
// Atribuo valor default
oMulti:aCols[nLinha,1]	:= oVermelho                                                                                    

             
DbSelectArea("SB1")
DbSetOrder(1)
If !DbSeek(xFilial("SB1")+cVar)
	// Padrao GP // MsgAlert("Não há Referência Protheus válida digitada na Coluna "+Alltrim(Str(nPxPRD)) + " na linha "+Alltrim(Str(nLinha)) )
	Return .F.
Endif
    
	
	
// Efetuo a conversão de CFOP de retorno de Terceiros conforme parametro
If aScan(aRetPoder3,{|x| Alltrim(x[1]) == Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) }) > 0
	oMulti:aCols[nLinha][nPxD1Tes]		:=  aRetPoder3[aScan(aRetPoder3,{|x| Alltrim(x[1]) == Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) }),2]
	oMulti:aCols[nLinha][nPxCF] 		:=  cRetCF+Substr(Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_CF"),2,3)	
	oMulti:aCols[nLinha][nPxUM]		:= 	Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nLinha,nPxPrd],"B1_UM")				
	oMulti:aCols[nLinha][nPxQte]       :=  oMulti:aCols[nLinha,nPxQteNfe] 
	oMulti:aCols[nLinha][nPxPrunit]	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],4)
	oMulti:aCols[nLinha][nPxTotal]	  	:= 	oMulti:aCols[nLinha,nPxTotNfe]   
	oMulti:oBrowse:Refresh()

	aCols		:= aClone(oMulti:aCols)
	aHeader		:= oMulti:aHeader                             
	aHeadBk		:= aClone(aHeader)                                               
	n			:= nLinha
	nRegistro	:= 0
		
    F4Poder3(cVar,,"N","E",cCodForn,cLojForn,@nRegistro,)			
	//  F4Poder3(cProduto,cLocal                  ,cTpNF,cES,cCliFor ,cLoja   ,nRegistro,cEstoque,cNumPV)
	//  F4Poder3(cProduto,cLocal,                 M->C5_TIPO,"S",M->C5_CLIENTE,M->C5_LOJACLI,,SF4->F4_ESTOQUE,M->C5_NUM)
	// xunxo....
	oMulti:aCols[nLinha] := aCols[nLinha]
	// Uso o TES de Devolução para os casos de retorno também
	If !Empty(Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_TESDV"))
		oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+SD2->D2_TES,"F4_TESDV")
		oMulti:aCols[nLinha][nPxCF] 	:=  cRetCF+Substr(Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_CF"),2,3)
		oMulti:oBrowse:Refresh()
	Endif
	oMulti:oBrowse:Refresh()
	lContinua	:= .F.
Endif
	
If lContinua 	// Abre 01
  	dbSelectArea("SC7")
	cAliasSC7 := "QRYSC7"
	
	cQuery := "SELECT SC7.*, R_E_C_N_O_ RECSC7 "
	cQuery += "  FROM "+ RetSqlName("SC7") + " SC7 "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	If !Empty(cVar)					
		cQuery += "AND C7_PRODUTO = '"+cVar+"' "
	Endif                           
	cQuery += "   AND C7_RESIDUO = ' '" 
	cQuery += "   AND C7_QUJE < C7_QUANT "
	
	If !Empty(cNumC7)
		cQuery += "   AND C7_NUM = '"+cNumC7+"' "
		cQuery += "   AND C7_ITEM = '"+cItemC7+"' "
	// Somente no automático e se houver ordem de compra no XML
	ElseIf lAutoSC7 
		If !Empty(CENTRALXML->XML_PCOMPR)
			cQuery += "   AND (C7_NUM LIKE '%"+Alltrim(CENTRALXML->XML_PCOMPR)+"%'  OR C7_NUM = C7_NUM) "
		Endif
	Endif
	
	cQuery += "   AND C7_FORNECE = '"+cCodForn+"' "
	cQuery += "   AND C7_FILIAL = '"+xFilial("SC7") + "' "
	
  	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)
	
	For nX := 1 To Len(aStruSC7)
		If aStruSC7[nX,2]<>"C"
			TcSetField(cAliasSC7,aStruSC7[nX,1],aStruSC7[nX,2],aStruSC7[nX,3],aStruSC7[nX,4])
		EndIf				
	Next nX
	
	bWhile := {|| (cAliasSC7)->(!Eof())}
	
	cCpoObri := "C7_LOJA|C7_QTSEGUM|C7_QUANT|C7_PRECO|C7_QUJE|C7_DESCRI|C7_TIPO|C7_LOCAL|C7_OBS"
	
	aCampos := {}
	If (cAliasSC7)->(!Eof())   
	
		dbSelectArea("SX3")
		dbSetOrder(2)
		MsSeek("C7_NUM")
		AAdd(aCab,x3Titulo())
		Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
		aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))
		dbSelectArea("SX3")
		dbSetOrder(1)
		MsSeek("SC7")
		While !Eof() .And. SX3->X3_ARQUIVO == "SC7"
			IF ( SX3->X3_BROWSE=="S".And.X3Uso(SX3->X3_USADO).And. AllTrim(SX3->X3_CAMPO)<>"C7_PRODUTO" .And. AllTrim(SX3->X3_CAMPO)<>"C7_NUM").Or.;
					(AllTrim(SX3->X3_CAMPO) $ cCpoObri)
				AAdd(aCab,x3Titulo())
				Aadd(aCampos,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_CONTEXT,SX3->X3_PICTURE})
				aadd(aTamCab,CalcFieldSize(SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_PICTURE,X3Titulo()))
			EndIf
			dbSelectArea("SX3")	
			dbSkip()		
		Enddo						
	Endif
	
	dbSelectArea(cAliasSC7)				
	While Eval(bWhile)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra os Pedidos Bloqueados e Previstos.                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SuperGetMV("MV_RESTNFE") == "S" .And. (cAliasSC7)->C7_CONAPRO == "B") .Or. (cAliasSC7)->C7_TPOP == "P"
			dbSkip()
			Loop
		EndIf
		nFreeQT := 0
		For nAuxCNT := 1 To Len( oMulti:aCols )
			If (nAuxCNT # nLinha) .And. ;
					(oMulti:aCols[ nAuxCNT,nPxPRD ] == (cAliasSC7)->C7_PRODUTO) .And. ;
					(oMulti:aCols[ nAuxCNT,nPxPedido ] == (cAliasSC7)->C7_NUM) .And. ;
					(oMulti:aCols[ nAuxCNT,nPxItemPc ] == (cAliasSC7)->C7_ITEM) .And. ;
					!ATail( oMulti:aCols[ nAuxCNT ] ) .And. !oMulti:aCols[nAuxCNT,Len(oMulti:aHeader)+1]
				nFreeQT += oMulti:aCols[ nAuxCNT,nPxQte ]
			EndIf
		Next
	
			lRet103Vpc := .T.
	
			If lRet103Vpc
				If ((nFreeQT := ((cAliasSC7)->C7_QUANT-(cAliasSC7)->C7_QUJE-(cAliasSC7)->C7_QTDACLA-nFreeQT)) > 0)
					Aadd(aArrayF4,Array(Len(aCampos)))							
					For nX := 1 to Len(aCampos)
						If aCampos[nX][3] != "V"
							If aCampos[nX][2] == "N"
								If Alltrim(aCampos[nX][1]) == "C7_QUANT"
									aArrayF4[Len(aArrayF4)][nX] :=Transform(nFreeQt,PesqPict("SC7",aCampos[nX][1]))
								Else
									aArrayF4[Len(aArrayF4)][nX] := Transform((cAliasSC7)->(FieldGet(FieldPos(aCampos[nX][1]))),PesqPict("SC7",aCampos[nX][1]))
								Endif											
							Else
								aArrayF4[Len(aArrayF4)][nX] := (cAliasSC7)->(FieldGet(FieldPos(aCampos[nX][1])))								
							Endif	
						Else
							aArrayF4[Len(aArrayF4)][nX] := CriaVar(aCampos[nX][1],.T.)
							If Alltrim(aCampos[nX][1]) == "C7_CODGRP"
								SB1->(dbSetOrder(1))
								SB1->(MsSeek(xFilial("SB1")+(cAliasSC7)->C7_PRODUTO))
								aArrayF4[Len(aArrayF4)][nX] := SB1->B1_GRUPO                            									
							EndIf
							If Alltrim(aCampos[nX][1]) == "C7_CODITE"
								SB1->(dbSetOrder(1))
								SB1->(MsSeek(xFilial("SB1")+(cAliasSC7)->C7_PRODUTO))
								aArrayF4[Len(aArrayF4)][nX] := SB1->B1_CODITE
							EndIf
						Endif
					Next
					AAdd( aArrSldo,{nFreeQT,(cAliasSC7)->RECSC7} )
				EndIf
			Endif
		(cAliasSC7)->(dbSkip())
	EndDo
	     
	                   
	If !Empty(aArrayF4) .And. !lAutoSC7
		DEFINE MSDIALOG oDlg FROM 30,20  TO 265,551 TITLE OemToAnsi("Selecionar pedido de compra ( por item ) ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra ( por item )"
		oQual := TWBrowse():New( 29,4,263,76,,aCab,aTamCab,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oQual:SetArray(aArrayF4)
		oQual:bLine := { || aArrayF4[oQual:nAT] }
		OQual:nFreeze := 1
		@ 15  ,4   SAY OemToAnsi("Produto") Of oDlg PIXEL SIZE 47 ,9 //"Produto"
		@ 14  ,30  MSGET cVar PICTURE PesqPict('SB1','B1_COD') When .F. Of oDlg PIXEL SIZE 60,9
		@ 15  ,95  SAY OemToAnsi("Qte XML") Of oDlg PIXEL SIZE 25 ,9
		@ 14  ,115  MsGet oMulti:aCols[nLinha][nPxQteNfe] Picture "@E 999,999" When .F. Of oDlg Pixel Size 30,09
		@ 15  ,150 SAY OemToAnsi("R$ XML") Of oDlg PIXEL SIZE 25 ,9		
		@ 14  ,170  MsGet oMulti:aCols[nLinha][nPxPrcNFe] Picture "@E 999,999.99" When .F. Of oDlg Pixel Size 30,09
		@ 15  ,205 Say OemToAnsi("Ord.Compra") Of oDlg PIXEL SIZE 27 ,9
		@ 14  ,235  MsGet CENTRALXML->XML_PCOMPR When .F. Of oDlg Pixel Size 30,09
		
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nSavQual:=oQual:nAT,nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)
	
		If nOpca == 1
			dbSelectArea("SC7")
			MsGoto(aArrSldo[nSavQual][2])                               
			oMulti:aCols[nLinha][nPxPedido]	:=	SC7->C7_NUM
			oMulti:aCols[nLinha][nPxItemPc]	:= 	SC7->C7_ITEM
			// Se a segunda unidade de medida for igual a do xml
			DbSelectArea("SA5")
			DbSetOrder(2)
			DbSeek(xFilial("SA5")+SC7->C7_PRODUTO+cCodForn+cLojForn)
			
			If Alltrim(oMulti:aCols[nLinha,nPxUMNFe]) $ (Alltrim(Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_SEGUM"))+"#"+SA5->A5_UNID)
			    // Se o Saldo do pedido for Menor que a quantidade calculada no item, assume apenas o que tem no saldo do pedido
			    If aArrSldo[nSavQual][1]  < (oMulti:aCols[nLinha,nPxQteNfe] * Iif(SB1->B1_TIPCONV =="D",SB1->B1_CONV,Iif(SB1->B1_CONV<>0,1/SB1->B1_CONV,0)))
					oMulti:aCols[nLinha][nPxQte]		:= 	aArrSldo[nSavQual][1]
					If MsgNoYes("Para o produto " + SC7->C7_PRODUTO + SC7->C7_DESCRI+" não há saldo de pedido suficiente conforme quantidade acusada na Nota. Deseja alterar o pedido de compra?","A T E N Ç Ã O!! Divergência Pedido de Compra!")   
						oMulti:aCols[nLinha][nPxQte]		:= 0                                              					
						U_XmlAltPC(aArrSldo[nSavQual][2])					
						oMulti:aCols[nLinha][nPxPedido]	:=	""
						oMulti:aCols[nLinha][nPxItemPc]	:= 	""		
					Endif
					
					nPrunitAux	:= oMulti:aCols[nLinha,nPxQteNfe] * Iif(SB1->B1_TIPCONV =="D",SB1->B1_CONV,Iif(SB1->B1_CONV<>0,1/SB1->B1_CONV,0))
					nPrunitAux	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / nPrunitAux,4)
					oMulti:aCols[nLinha][nPxPrunit]	:= 	nPrunitAux
					oMulti:aCols[nLinha][nPxTotal]	:=  Round(oMulti:aCols[nLinha][nPxQte] * oMulti:aCols[nLinha][nPxPrunit] , 2)	//aCols[nLinha,nPxTotNfe]
					
				Else
					oMulti:aCols[nLinha][nPxQte]      :=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(SB1->B1_TIPCONV =="D",SB1->B1_CONV,Iif(SB1->B1_CONV<>0,1/SB1->B1_CONV,0))
					oMulti:aCols[nLinha][nPxPrunit]	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],4)
					oMulti:aCols[nLinha][nPxTotal]	:= 	oMulti:aCols[nLinha,nPxTotNfe]
				Endif
				If oMulti:aCols[nLinha][nPxPrunit] <> SC7->C7_PRECO
					If nAlertPrc == 2
						MsgAlert("Para o produto "+ SC7->C7_PRODUTO + SC7->C7_DESCRI+" foi encontrada divergência de preço. Favor conferir!","Divergência de preço!")
					Endif
				Endif
			Else				
				oMulti:aCols[nLinha][nPxQte]		:= 	aArrSldo[nSavQual][1]
				oMulti:aCols[nLinha][nPxPrunit]	:= 	SC7->C7_PRECO
				oMulti:aCols[nLinha][nPxTotal]	:= 	Round((aArrSldo[nSavQual][1])*SC7->C7_PRECO,2)			
			Endif
			oMulti:aCols[nLinha][nPxUM]		:= 	Iif(!Empty(SC7->C7_UM),SC7->C7_UM,Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_UM"))
			If Empty(cNumC7)
				oMulti:aCols[nLinha][nPxD1Tes]	:= 	Iif(!Empty(SC7->C7_TES),SC7->C7_TES,Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_TE")) //SC7->C7_TES	 
			Endif
			// Verifica se é bonificação e força conversão da TES
			If Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) $ "5910#6910" .And. Empty(cNumC7)
				oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_TESBONI")
			Endif
			oMulti:aCols[nLinha][nPxCF] := cRetCF+Substr(Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_CF"),2,3)

			oMulti:oBrowse:Refresh()
		EndIf
	Elseif lAutoSC7 .And. !Empty(aArrayF4)
		If Len(aArrayF4) > 1
			DEFINE MSDIALOG oDlg FROM 30,20  TO 265,551 TITLE OemToAnsi("Selecionar pedido de compra ( por item ) ") Of oMainWnd PIXEL //"Selecionar Pedido de Compra ( por item )"
			oQual := TWBrowse():New( 29,4,263,76,,aCab,aTamCab,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oQual:SetArray(aArrayF4)
			oQual:bLine := { || aArrayF4[oQual:nAT] }
			OQual:nFreeze := 1
			@ 15  ,4   SAY OemToAnsi("Produto") Of oDlg PIXEL SIZE 47 ,9 //"Produto"
			@ 14  ,30  MSGET cVar PICTURE PesqPict('SB1','B1_COD') When .F. Of oDlg PIXEL SIZE 60,9
			@ 15  ,95  SAY OemToAnsi("Qte XML") Of oDlg PIXEL SIZE 25 ,9
			@ 14  ,115  MsGet oMulti:aCols[nLinha][nPxQteNfe] Picture "@E 999,999" When .F. Of oDlg Pixel Size 30,09
			@ 15  ,150 SAY OemToAnsi("R$ XML") Of oDlg PIXEL SIZE 25 ,9		
			@ 14  ,170  MsGet oMulti:aCols[nLinha][nPxPrcNFe] Picture "@E 999,999.99" When .F. Of oDlg Pixel Size 30,09
			@ 15  ,205 Say OemToAnsi("Ord.Compra") Of oDlg PIXEL SIZE 27 ,9
			@ 14  ,235  MsGet CENTRALXML->XML_PCOMPR When .F. Of oDlg Pixel Size 30,09
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| nSavQual:=oQual:nAT,nOpca:=1,oDlg:End()},{||oDlg:End()},,aButtons)
	
	   		If nOpca == 1
				dbSelectArea("SC7")
				MsGoto(aArrSldo[nSavQual][2])
				oMulti:aCols[nLinha][nPxPedido]	:=	SC7->C7_NUM
				oMulti:aCols[nLinha][nPxItemPc]	:= 	SC7->C7_ITEM
		
				DbSelectArea("SA5")
				DbSetOrder(2)
				DbSeek(xFilial("SA5")+SC7->C7_PRODUTO+cCodForn+cLojForn)

				// Se a segunda unidade de medida for igual a do xml
				If Alltrim(oMulti:aCols[nLinha,nPxUMNFe]) $ (Alltrim(Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_SEGUM")) +"#"+SA5->A5_UNID)
				    // Se o Saldo do pedido for Menor que a quantidade calculada no item, assume apenas o que tem no saldo do pedido
				    If (aArrSldo[nSavQual][1])  < (oMulti:aCols[nLinha,nPxQteNfe] * Iif(SB1->B1_TIPCONV =="D",SB1->B1_CONV,Iif(SB1->B1_CONV<>0,1/SB1->B1_CONV,0)))
						oMulti:aCols[nLinha][nPxQte]		:= 	aArrSldo[nSavQual][1] 
						If MsgNoYes("Para o produto " + SC7->C7_PRODUTO + SC7->C7_DESCRI+" não há saldo de pedido suficiente conforme quantidade acusada na Nota. Deseja alterar o pedido de compra?","A T E N Ç Ã O!! Divergência Pedido de Compra!")   
							oMulti:aCols[nLinha][nPxQte]		:= 0                                              					
							U_XmlAltPC(aArrSldo[nSavQual][2])					
							oMulti:aCols[nLinha][nPxPedido]	:=	""
							oMulti:aCols[nLinha][nPxItemPc]	:= 	""		
						Endif
						nPrunitAux	:= oMulti:aCols[nLinha,nPxQteNfe] * Iif(SB1->B1_TIPCONV =="D",SB1->B1_CONV,Iif(SB1->B1_CONV<>0,1/SB1->B1_CONV,0))
						nPrunitAux	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / nPrunitAux,4)
						oMulti:aCols[nLinha][nPxPrunit]	:= 	nPrunitAux
						oMulti:aCols[nLinha][nPxTotal]	:= Round(oMulti:aCols[nLinha][nPxQte] * oMulti:aCols[nLinha][nPxPrunit] , 2)//	aCols[nLinha,nPxTotNfe]
					Else
						oMulti:aCols[nLinha][nPxQte]      :=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(SB1->B1_TIPCONV =="D",SB1->B1_CONV,Iif(SB1->B1_CONV<>0,1/SB1->B1_CONV,0))
						oMulti:aCols[nLinha][nPxPrunit]	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],4)
						oMulti:aCols[nLinha][nPxTotal]	:= 	oMulti:aCols[nLinha,nPxTotNfe]
					Endif
					If oMulti:aCols[nLinha][nPxPrunit] <> SC7->C7_PRECO
						If nAlertPrc == 2
							MsgAlert("Para o produto "+ SC7->C7_PRODUTO + SC7->C7_DESCRI+" foi encontrada divergência de preço. Favor conferir!","Divergência de preço!")
						Endif
					Endif
				Else				
					oMulti:aCols[nLinha][nPxQte]		:= 	aArrSldo[nSavQual][1]
					oMulti:aCols[nLinha][nPxPrunit]	:= 	SC7->C7_PRECO
					oMulti:aCols[nLinha][nPxTotal]	:= 	Round((aArrSldo[nSavQual][1])*SC7->C7_PRECO,2)			
				Endif
	
				oMulti:aCols[nLinha][nPxUM]		:= 	Iif(!Empty(SC7->C7_UM),SC7->C7_UM,Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_UM"))
				If Empty(cNumC7)
					oMulti:aCols[nLinha][nPxD1Tes]		:= 	Iif(!Empty(SC7->C7_TES),SC7->C7_TES,Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_TE")) //SC7->C7_TES			
				Endif
				// Verifica se é bonificação e força conversão da TES
				If Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) $ "5910#6910"	.And. Empty(cNumC7)
					oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_TESBONI")
				Endif
				oMulti:aCols[nLinha][nPxCF] := cRetCF+Substr(Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_CF"),2,3)

				oMulti:oBrowse:Refresh()
			EndIf
		Else
			If Empty(cNumC7)
				dbSelectArea("SC7")
				MsGoto(aArrSldo[1][2])
				oMulti:aCols[nLinha][nPxPedido]	:=	SC7->C7_NUM
				oMulti:aCols[nLinha][nPxItemPC]	:= 	SC7->C7_ITEM
			
				DbSelectArea("SA5")
				DbSetOrder(2)
				DbSeek(xFilial("SA5")+SC7->C7_PRODUTO+cCodForn+cLojForn)
	
				// Se a segunda unidade de medida for igual a do xml
				If Alltrim(oMulti:aCols[nLinha,nPxUMNFe]) $ (Alltrim(Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_SEGUM")) + "#"+SA5->A5_UNID)
				    // Se o Saldo do pedido for Menor que a quantidade calculada no item, assume apenas o que tem no saldo do pedido
				    If (aArrSldo[1][1])  < (oMulti:aCols[nLinha,nPxQteNfe] * Iif(SB1->B1_TIPCONV =="D",SB1->B1_CONV,Iif(SB1->B1_CONV<>0,1/SB1->B1_CONV,0)))
						oMulti:aCols[nLinha][nPxQte]		:= 	aArrSldo[1][1]
						If MsgNoYes("Para o produto " + SC7->C7_PRODUTO + SC7->C7_DESCRI+" não há saldo de pedido suficiente conforme quantidade acusada na Nota. Deseja alterar o pedido de compra?","A T E N Ç Ã O!! Divergência Pedido de Compra!")   
							oMulti:aCols[nLinha][nPxQte]		:= 0                                              					
							U_XmlAltPC(aArrSldo[1][2])					
							oMulti:aCols[nLinha][nPxPedido]	:=	""
							oMulti:aCols[nLinha][nPxItemPc]	:= 	""		
						Endif
						nPrunitAux	:= oMulti:aCols[nLinha,nPxQteNfe] * Iif(SB1->B1_TIPCONV =="D",SB1->B1_CONV,Iif(SB1->B1_CONV<>0,1/SB1->B1_CONV,0))
						nPrunitAux	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / nPrunitAux,4)
						oMulti:aCols[nLinha][nPxPrunit]	:= 	nPrunitAux
						oMulti:aCols[nLinha][nPxTotal]	:=  Round(oMulti:aCols[nLinha][nPxQte] * oMulti:aCols[nLinha][nPxPrunit] , 2)//	aCols[nLinha,nPxTotNfe]
					Else
						oMulti:aCols[nLinha][nPxQte]      :=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(SB1->B1_TIPCONV =="D",SB1->B1_CONV,Iif(SB1->B1_CONV<>0,1/SB1->B1_CONV,0))
						oMulti:aCols[nLinha][nPxPrunit]	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],4)
						oMulti:aCols[nLinha][nPxTotal]	:= 	oMulti:aCols[nLinha,nPxTotNfe]
					Endif
				Else				
					oMulti:aCols[nLinha][nPxQte]		:= 	aArrSldo[1][1]
					oMulti:aCols[nLinha][nPxPrunit]	:= 	SC7->C7_PRECO
					oMulti:aCols[nLinha][nPxTotal]	:= 	Round((aArrSldo[1][1])*SC7->C7_PRECO,2)			
				Endif
				oMulti:aCols[nLinha][nPxUM]		:= 	Iif(!Empty(SC7->C7_UM),SC7->C7_UM,Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_UM"))
				If Empty(cNumC7)
					oMulti:aCols[nLinha][nPxD1Tes]		:= 	Iif(!Empty(SC7->C7_TES),SC7->C7_TES,Posicione("SB1",1,xFilial("SB1")+SC7->C7_PRODUTO,"B1_TE")) //SC7->C7_TES			
				Endif
				// Verifica se é bonificação e força conversão da TES
				If Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) $ "5910#6910" .And. Empty(cNumC7)
					oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_TESBONI")
				Endif
				oMulti:aCols[nLinha][nPxCF] := cRetCF+Substr(Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_CF"),2,3)
	
				oMulti:oBrowse:Refresh()
			Endif
		Endif
	Else             
		If !lAutoSC7 .Or. !Empty(cNumC7)
			If lMVXPCNFE .And. !Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) $ cCFOPNPED
				Alert("Não há saldo de pedido de compra em aberto para o item '"+oMulti:aCols[nLinha,nPxItem]+"'/Produto '"+oMulti:aCols[nLinha,nPxPrd]+oMulti:aCols[nLinha,nPxDescri]+"' ")
				oMulti:aCols[nLinha][nPxPedido]	:=	""
				oMulti:aCols[nLinha][nPxItemPc]	:= 	""		
				oMulti:aCols[nLinha][nPxPrunit]	:= 	0
				oMulti:aCols[nLinha][nPxTotal]	:=  0
				oMulti:oBrowse:Refresh()
			Else
				oMulti:aCols[nLinha][nPxUM]		:= 	Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nLinha,nPxPrd],"B1_UM")				
				oMulti:aCols[nLinha][nPxQte]      :=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(SB1->B1_TIPCONV =="D",SB1->B1_CONV,Iif(SB1->B1_CONV<>0,1/SB1->B1_CONV,0))
				oMulti:aCols[nLinha][nPxPrunit]	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],4)
				oMulti:aCols[nLinha][nPxTotal]	:= 	oMulti:aCols[nLinha,nPxTotNfe]
				oMulti:aCols[nLinha][nPxD1Tes]	:= 	SB1->B1_TE
				
				// Verifica se é bonificação e força conversão da TES
				If Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) $ "5910#6910" .And. !(Alltrim(oMulti:aCols[nLinha][nPxCF]) $ "1910#2910")
					oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_TESBONI")
				Endif
				oMulti:aCols[nLinha][nPxCF] := cRetCF+Substr(Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_CF"),2,3)
				oMulti:oBrowse:Refresh()
	
            Endif
		ElseIf lAutoSC7	.And. !lConfFinal	

			If !lMVXPCNFE .And. !Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) $ cCFOPNPED
				oMulti:aCols[nLinha][nPxUM]		:= 	Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nLinha,nPxPrd],"B1_UM")				
				oMulti:aCols[nLinha][nPxQte]       :=  oMulti:aCols[nLinha,nPxQteNfe] * Iif(SB1->B1_TIPCONV =="D",Iif(SB1->B1_CONV<>0,SB1->B1_CONV,1),Iif(SB1->B1_CONV<>0,1/SB1->B1_CONV,1))
				oMulti:aCols[nLinha][nPxPrunit]	:= 	Round(oMulti:aCols[nLinha,nPxTotNfe] / oMulti:aCols[nLinha,nPxQte],4)
				oMulti:aCols[nLinha][nPxTotal]	  	:= 	oMulti:aCols[nLinha,nPxTotNfe]
				oMulti:aCols[nLinha][nPxD1Tes]		:= 	SB1->B1_TE
				
				// Verifica se é bonificação e força conversão da TES
				If Alltrim(oMulti:aCols[nLinha][nPxCFNFe]) $ "5910#6910" .And. !(Alltrim(oMulti:aCols[nLinha][nPxCF]) $ "1910#2910")
					oMulti:aCols[nLinha][nPxD1Tes]	:=  Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_TESBONI")
				Endif
				oMulti:aCols[nLinha][nPxCF] := cRetCF+Substr(Posicione("SF4",1,xFilial("SF4")+oMulti:aCols[nLinha][nPxD1Tes],"F4_CF"),2,3)
				oMulti:oBrowse:Refresh()
	        Endif
		Endif
	Endif                    
	
	sfRefLeg(nLinha)

	dbSelectArea(cAliasSC7)
	dbCloseArea()
	dbSelectArea("SC7")
	
Endif 


nTotalNFe := 0
For iR := 1 To Len(oMulti:aCols)
	If !oMulti:aCols[iR,Len(oMulti:aHeader)+1]
		nTotalNfe += oMulti:aCols[iR,nPxTotal] - oMulti:aCols[iR,nPxVlDesc]
	Endif
Next
oTotalNfe:Refresh()

RestArea(aAreaOld)

Return .T.

// Atualiza o status do item    

Static Function sfRefLeg(nLinha)

If !Empty(oMulti:aCols[nLinha][nPxPedido])
	DbSelectArea("SC7")
	DbSetOrder(1)
	If DbSeek(xFilial("SC7")+oMulti:aCols[nLinha][nPxPedido]+oMulti:aCols[nLinha][nPxItemPc])
		oMulti:aCols[nLinha,1]	:= Iif(Empty(oMulti:aCols[nLinha][nPxPedido]),oVermelho,Iif(oMulti:aCols[nLinha][nPxPrunit] <> SC7->C7_PRECO,oAmarelo,oVerde))
	Else
		oMulti:aCols[nLinha,1]	:= oVermelho
	Endif
Else
		oMulti:aCols[nLinha,1]	:= oVermelho
Endif

oMulti:oBrowse:Refresh()

Return
  
User Function XmlAltPC(nRecSC7)

Local aArea			:= GetArea()
Local aAreaSC7		:= SC7->(GetArea())
Local nSavNF		:= MaFisSave()
Local cSavCadastro	:= cCadastro
Local nBack         := n
PRIVATE nTipo 		:= 1
PRIVATE cCadastro	:= OemToAnsi("Alteração de Pedido de Compra") 
PRIVATE l120Auto	:= .F.
PRIVATE aBackSC7  	:= {}  

MaFisEnd()

dbSelectArea("SC7")
MsGoto(nRecSC7)

A120Pedido(Alias(),RecNo(),4)
n := nBack
cCadastro	:= cSavCadastro
MaFisRestore(nSavNF)

Set Key  VK_F6 TO U_VldItemPc()

Pergunte(cPergXml,.F.)

RestArea(aAreaSC7)
RestArea(aArea)

Return .T.
  
  
Static Function stGrvItens()
Local	aAreaOld	:= GetArea()

//Use &("CENTRALXMLITENS") Alias &("CENTRALXMLITENS") SHARED NEW Via "TOPCONN"
//DbSetIndex("CENTRALXMLITENS01")
//DbSetNickName(OrdName(1),"CENTRALXMLITENS01")
                
ProcRegua(Len(oMulti:aCols))   
	
For nY	:= 1 To Len(oMulti:aCols)
	IncProc()
	If !oMulti:aCols[nY][Len(aHeader)+1]
		U_DbSelArea("CENTRALXMLITENS",.F.,1)
  		If DbSeek(Padr(aArqXml[oArqXml:nAt,5],250)+Padr(oMulti:aCols[nY][nPxCodNfe],30)+oMulti:aCols[nY][nPxItem])
			RecLock("CENTRALXMLITENS",.F.)        	                                                         
   	    Else
   	    	RecLock("CENTRALXMLITENS",.T.)
   	    	CENTRALXMLITENS->XIT_CHAVE		:= Padr(aArqXml[oArqXml:nAt,5],250)
			CENTRALXMLITENS->XIT_ITEM		:= oMulti:aCols[nY][nPxItem]
			CENTRALXMLITENS->XIT_CODNFE		:= oMulti:aCols[nY][nPxCodNfe]
			CENTRALXMLITENS->XIT_DESCRI		:= oMulti:aCols[nY][nPxDescri]
   	    Endif
   	    
   	    CENTRALXMLITENS->XIT_CODPRD	:= oMulti:aCols[nY,nPxPrd]
   	    CENTRALXMLITENS->XIT_QTE		:= oMulti:aCols[nY,nPxQte]
   	    CENTRALXMLITENS->XIT_UM		:= oMulti:aCols[nY,nPxUm]
        CENTRALXMLITENS->XIT_PRUNIT	:= oMulti:aCols[nY,nPxPrunit]
        CENTRALXMLITENS->XIT_TOTAL	:= oMulti:aCols[nY,nPxTotal]
        CENTRALXMLITENS->XIT_TES		:= oMulti:aCols[nY,nPxD1Tes] 
        CENTRALXMLITENS->XIT_CF		:= oMulti:aCols[nY,nPxCF]         	
        CENTRALXMLITENS->XIT_PEDIDO	:= oMulti:aCols[nY,nPxPedido]
        CENTRALXMLITENS->XIT_ITEMPC	:= oMulti:aCols[nY,nPxItemPc]        	
        MsUnLock()                     
	Else
		U_DbSelArea("CENTRALXMLITENS",.F.,1)
  		If DbSeek(Padr(aArqXml[oArqXml:nAt,5],250)+Padr(oMulti:aCols[nY][nPxCodNfe],30)+oMulti:aCols[nY][nPxItem])
			RecLock("CENTRALXMLITENS",.F.)        	                                                         
			DbDelete()
   	        MsUnlock()
   	    Endif
	Endif                                             
Next         
MsgAlert("Gravação dos itens concluída!","Processo concluído")
RestArea(aAreaOld)
Return


Static Function stGeraNfe
                         
Local	aAreaOld	:= GetArea()
Local	lPreNfe		:= .F.
Local	cItemD1		:= StrZero(1,TamSX3("D1_ITEM")[1])
Local	cTipoBox	:= "N=Normal"
Local	lContinua	:= 	.F.
Private	aCabec 		:= {}
Private	aItems 		:= {}
Private aLinha		:= {}
Private	lMsErroAuto	:=.f.
Private	lMsHelpAuto	:=.T.     
Private cCondicao	:= "001"     
Private cNumDoc		:= ""
Private cSerDoc		:= ""             
Private cCodFor		:= ""
Private cLojFor 	:= ""
Private dData	

//Fields HEADER " ",;    		// 1
//"Série/Nº NF-e",;      		// 2
//"Emissão",;    		   		// 3
//"Fornecedor/Loja-Nome",;    // 4
//"Chave NF-e",;              // 5
//"Destinatário",;            // 6
//"Recebida em",;				// 7
//"Conferida em",;			// 8
//"Lançada em" ;				// 9


// Efetua validação impedindo que produto não cadastrado tenha continuidade
For nI := 1 To Len(oMulti:aCols)
	DbSelectArea("SB1")
	DbSetOrder(1)
	If !DbSeek(xFilial("SB1")+oMulti:aCols[nI,nPxPrd])
		MsgAlert("Não há Referência Protheus informada para a linha "+Str(nI),"Validação de dados antes do lançamento")
		Return		
	Endif
Next

//Use &("CENTRALXML") Alias &("CENTRALXML") SHARED NEW Via "TOPCONN"
//DbSetIndex("CENTRALXML01")
//DbSetNickName(OrdName(1),"CENTRALXML01")

//DbSelectArea("CENTRALXML")    
//DbSetOrder(1)
U_DbSelArea("CENTRALXML",.F.,1)

If !DbSeek(aArqXml[oArqXml:nAt,5]) 
    MsgAlert("Erro ao localizar registro")
//    CENTRALXML->(DbCloseArea())
    Return
Endif

If !Empty(CENTRALXML->XML_REJEIT) 
	MsgAlert("Nota fiscal rejeitada em "+DTOC(CENTRALXML->XML_REJEIT)+". Não é permitido lançar!")
	Return
Endif



cAviso	:= ""
cErro	:= ""
oNfe := XmlParser(CENTRALXML->XML_ARQ,"_",@cAviso,@cErro)


If Type("oNFe:_NfeProc")<> "U"
	oNF := oNFe:_NFeProc:_NFe
Else
	oNF := oNFe:_NFe
Endif
          				                        
If !Empty(cErro)
	MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
Endif
				
oIdent     	:= oNF:_InfNfe:_IDE
oEmitente  	:= oNF:_InfNfe:_Emit
oDestino   	:= oNF:_InfNfe:_Dest    
oTotal		:= oNF:_InfNfe:_Total
If Type("oNF:_InfNfe:_Cobr") <> "U"
	oCobr		:= oNF:_InfNfe:_Cobr
Endif

// Valido se esta empresa/filial certa conforme destinatário do XML
If SM0->M0_CGC <> oDestino:_CNPJ:TEXT
	MsgAlert("Empresa errada! Destinatário é diferente do CNPJ do XML("+oDestino:_CNPJ:TEXT+").","Destinatário errado!")
	Return
Endif
	    
If Type("oNFe:_NfeProc:_protNFe:_infProt:_chNFe")<> "U"
	oNF := oNFe:_NFeProc:_NFe
	cChave	:= oNFe:_NfeProc:_protNFe:_infProt:_chNFe:TEXT
Else
	cChave	:= " "
Endif	

If CENTRALXML->XML_TIPODC $ "N#C#I#P"
	DbSelectArea("SA2")
	DbSetOrder(3)
	If !DbSeek(xFilial("SA2")+oEmitente:_CNPJ:TEXT)
	    MsgAlert("Não há cadastro de fornecedor para este CNPJ")
	Endif
	                 
	cCodFor	  := SA2->A2_COD
	cLojFor	  := SA2->A2_LOJA
	cCondicao := SA2->A2_COND
Else                 
	// Forço a gravação dos itens para eventual esquecimento de quem lançar a NF
	stGrvItens()
	
	DbSelectArea("SA1")
	DbSetOrder(3)
	If !DbSeek(xFilial("SA1")+oEmitente:_CNPJ:TEXT)
	    MsgAlert("Não há cadastro de cliente para este CNPJ")
	Endif
	                 
	cCodFor	  := SA1->A1_COD
	cLojFor	  := SA1->A1_LOJA	
	cCondicao := SA1->A1_COND
Endif                 

// Padrao GP //
// Atualiza Condicao de Pagamento quando houver Pedido de Compra
For j:=1 To Len(oMulti:aCols)
	If !Empty(oMulti:aCols[j,nPxPedido])
		cCondicao := Posicione("SC7",1,xFilial("SC7")+oMulti:aCols[j,nPxPedido]+oMulti:aCols[j,nPxItemPC],"C7_COND")
	EndIf
Next

// -- Valido se Nota Fiscal já existe na base ?
DbSelectArea("SF1")
DbSetOrder(1)
If DbSeek(CENTRALXML->XML_KEYF1)
	
	If CENTRALXML->XML_TIPODC $ "N#C#P#I"
		MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSX3("F1_DOC")[1])+"/"+OIdent:_serie:TEXT+" do Fornecedor "+SA2->A2_COD+"/"+SA2->A2_LOJA+" Já Existe. A Importação será interrompida!")	
    Else
    	MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSX3("F1_DOC")[1])+"/"+OIdent:_serie:TEXT+" do Cliente "+SA1->A1_COD+"/"+SA1->A1_LOJA+" Já Existe. A Importação será interrompida!")	
    Endif
    
	RecLock("CENTRALXML",.F.)
	If CENTRALXML->XML_TIPODC $ "N#C#P#I"
		CENTRALXML->XML_KEYF1	:= xFilial("SF1")+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSX3("F1_DOC")[1])+Padr(OIdent:_serie:TEXT,TamSX3("F1_SERIE")[1])+SA2->A2_COD+SA2->A2_LOJA+CENTRALXML->XML_TIPODC 
	Else
    	CENTRALXML->XML_KEYF1	:= xFilial("SF1")+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSX3("F1_DOC")[1])+Padr(OIdent:_serie:TEXT,TamSX3("F1_SERIE")[1])+SA1->A1_COD+SA1->A1_LOJA+CENTRALXML->XML_TIPODC 
    Endif
    CENTRALXML->XML_LANCAD	:= SF1->F1_DTDIGIT
    CENTRALXML->XML_USRLAN	:= Padr("Manual- "+cUserName,30)
    MsUnlock()
	Return
EndIf

// Validação para impedir que notas com pedidos não vinculados corretamente sejam importadas
For nR := 1 To Len(oMulti:aCols)   
	If CENTRALXML->XML_TIPODC == "N" .And. !Alltrim(oMulti:aCols[nR][nPxCFNFe]) $ cCFOPNPED
		U_VldItemPc(nR,.T.,oMulti:aCols[nR,nPxPedido],oMulti:aCols[nR,nPxItemPC],.T.)  	
	Else
		lContinua	:= .T.
	Endif
Next 

If Empty(CENTRALXML->XML_CONFCO) .And. CENTRALXML->XML_TIPODC == "N" .And. !lContinua
	MsgAlert("Nota fiscal ainda não foi conferida pelo Compras.Não é permitido lançar!")
	Return
Endif
                  
// Restauro o valor da variavel para continuar o uso da mesma para outro fim
lContinua	:= .F.

If nTotalNfe <> nTotalXml
	// Padrao GP //
	//MsgAlert("O Valor dos produtos constantes no Arquivo XML é diferente do Valor apurado com alocação dos pedidos de compra! Favor conferir novamente!","A T E N Ç Ã O!! Conferência incompleta!")
	MsgAlert("O Valor dos produtos constantes no Arquivo XML é diferente do Valor apurado com alocação dos pedidos de compra!")
    //Return
Endif


cNumDoc	:=  Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSX3("F1_DOC")[1])
cSerDoc	:= 	Padr(OIdent:_serie:TEXT,TamSX3("F1_SERIE")[1])
Aadd(aCabec,{"F1_FILIAL"  	,xFilial("SF1")		,Nil,Nil})


cTipoBox	:= CENTRALXML->XML_TIPODC
		
DEFINE MSDIALOG oDlgCond TITLE "Continuar lançamento da Nota Fiscal?" FROM 001,001 TO 170,400 PIXEL
@ 010,018 Say "Informe a Condicao de Pagamento" Pixel of oDlgCond
@ 010,110 MsGet cCondicao F3 "SE4" Valid ExistCpo("SE4") Size 30,10 Pixel of oDlgCond // When cTipoBox == "P"
@ 022,018 Say "Tipo de Nota fiscal" Pixel of oDlgCond
@ 022,110 Combobox cTipoBox Items {"N=Normal","B=Beneficiamento","D=Devolução","C=Compl. Preço/Frete","P=Compl. IPI","I=Compl. ICMS"} Pixel of oDlgCond When lSuperUsr 
@ 035,018 BUTTON "Confirma" Size 40,10 Pixel of oDlgCond Action (lContinua	:= .T.,oDlgCond:End())
@ 035,068 BUTTON "Cancela"  Size 40,10 Pixel of oDlgCond Action (oDlgCond:End())
		
ACTIVATE MSDIALOG oDlgCond CENTERED

If !lContinua
	Return
Endif

// Validação que permite que o tipo de documento seja alterado
If cTipoBox <> CENTRALXML->XML_TIPODC
	If MsgNoYes("Você alterou o tipo de nota fiscal de '"+CENTRALXML->XML_TIPODC+"' para '"+cTipoBox+"'!"+Chr(13)+Chr(10)+;
	            "Deseja realmente efetuar a troca do tipo de Nota para '"+cTipoBox+"'? ","Troca do Tipo de Documento de Entrada!")
   		RecLock("CENTRALXML",.F.)
		CENTRALXML->XML_TIPODC 	:= cTipoBox
    	MsUnlock()
  	Endif
  	Return
Endif
	            

cData:=Alltrim(OIdent:_dEmi:TEXT)
dData:=CTOD(Right(cData,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
If cTipoBox $ "N#C#I#P"
	DbSelectArea("SA2")
	Aadd(aCabec,{"F1_TIPO"   	,cTipoBox			,Nil,Nil})
	Aadd(aCabec,{"F1_FORMUL" 	,"N"				,Nil,Nil})
	Aadd(aCabec,{"F1_DOC"    	,Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSX3("F1_DOC")[1]),Nil,Nil})
	Aadd(aCabec,{"F1_SERIE"     ,Padr(OIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]),Nil,Nil})
	Aadd(aCabec,{"F1_EMISSAO"	,dData				,Nil,Nil})
	Aadd(aCabec,{"F1_FORNECE"	,SA2->A2_COD		,Nil,Nil})
	Aadd(aCabec,{"F1_LOJA"   	,SA2->A2_LOJA		,Nil,Nil})		
	Aadd(aCabec,{"F1_ESPECIE"	,"SPED"				,Nil,Nil})
	Aadd(aCabec,{"F1_EST"		,SA2->A2_EST		,Nil,Nil})
	Aadd(aCabec,{"F1_COND"		, cCondicao				,Nil,Nil})
Else
	DbSelectArea("SA1")
	Aadd(aCabec,{"F1_TIPO"   	,cTipoBox			,Nil,Nil})
	Aadd(aCabec,{"F1_FORMUL" 	,"N"				,Nil,Nil})
	Aadd(aCabec,{"F1_DOC"    	,Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSX3("F1_DOC")[1]),Nil,Nil})
	Aadd(aCabec,{"F1_SERIE"     ,Padr(OIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]),Nil,Nil})
	Aadd(aCabec,{"F1_EMISSAO"	,dData				,Nil,Nil})
	Aadd(aCabec,{"F1_FORNECE"	,SA1->A1_COD		,Nil,Nil})
	Aadd(aCabec,{"F1_LOJA"   	,SA1->A1_LOJA		,Nil,Nil})		
	Aadd(aCabec,{"F1_ESPECIE"	,"SPED"				,Nil,Nil})
	Aadd(aCabec,{"F1_EST"		,SA1->A1_EST		,Nil,Nil})
	Aadd(aCabec,{"F1_COND"		,cCondicao				,Nil,Nil})
Endif

If SF1->(FieldPos("F1_CHVNFE")) > 0 
	Aadd(aCabec,{"F1_CHVNFE"		,cChave		,Nil,Nil})
Endif	
                         

If mv_par12 == 1
	Aadd(aCabec,{"F1_BASEICM"	,Val(oTotal:_ICMSTot:_vBC:TEXT)		,Nil,Nil})
	Aadd(aCabec,{"F1_VALICM"	,Val(oTotal:_ICMSTot:_vICMS:TEXT)	,Nil,Nil})

	Aadd(aCabec,{"F1_BRICMS" 	,Val(oTotal:_ICMSTot:_vBCST:TEXT)	,Nil,Nil})
	Aadd(aCabec,{"F1_ICMSRET"	,Val(oTotal:_ICMSTot:_vST:TEXT)		,Nil,Nil})

	Aadd(aCabec,{"F1_VALMERC"	,Val(oTotal:_ICMSTot:_vProd:TEXT)	,Nil,Nil})
	Aadd(aCabec,{"F1_FRETE"		,Val(oTotal:_ICMSTot:_vFrete:TEXT)	,Nil,Nil})
	Aadd(aCabec,{"F1_VALIMP5"	,Val(oTotal:_ICMSTot:_vPIS:TEXT)	,Nil,Nil})
	Aadd(aCabec,{"F1_VALIMP6"	,Val(oTotal:_ICMSTot:_vCOFINS:TEXT)	,Nil,Nil})
	Aadd(aCabec,{"F1_VALBRUT"	,Val(oTotal:_ICMSTot:_vNF:TEXT)		,Nil,Nil})        
Endif
			
// Inicio loop nos itens da nota
For nX := 1 To Len(oMulti:aCols)
		                                
	If !oMulti:aCols[nX,Len(oMulti:aHeader)+1]
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+oMulti:aCols[nX,nPxPrd])		
		aLinha := {}
	
		Aadd(aLinha,{"D1_FILIAL"	, xFilial("SD1")		,Nil,Nil})
		Aadd(aLinha,{"D1_ITEM"		, cItemD1				,Nil,Nil})		
		Aadd(aLinha,{"D1_COD"		, oMulti:aCols[nX,nPxPrd]		,Nil,Nil})		
		Aadd(aLinha,{"D1_UM"		,oMulti:aCols[nX,nPxUm]		,Nil,Nil})
	
		If !Empty(oMulti:aCols[nX,nPxPedido]) .and. !Empty(oMulti:aCols[nX,nPxItemPC]) // Padrao GP // lMVXPCNFE .And. CENTRALXML->XML_TIPODC == "N" .And. !Alltrim(oMulti:aCols[nX][nPxCFNFe]) $ cCFOPNPED
			Aadd(aLinha,{"D1_PEDIDO"	,oMulti:aCols[nX,nPxPedido]	,Nil,Nil})
			Aadd(aLinha,{"D1_ITEMPC"	,oMulti:aCols[nX,nPxItemPC]	,Nil,Nil})
			
			// Padrao GP //
			// Preencher Centro de Custo no Documento de Entrada conforme o Pedido de Compra
			_cCc := Posicione("SC7",1,xFilial("SC7")+oMulti:aCols[nX,nPxPedido]+oMulti:aCols[nX,nPxItemPC],"C7_CC")
			If !Empty(_cCc)
				Aadd(aLinha,{"D1_CC"	,_cCc,Nil,Nil})
			EndIf
		Endif
		
	    If CENTRALXML->XML_TIPODC $ "D#B"
			
			Aadd(aLinha,{"D1_NFORI"		,oMulti:aCols[nX,nPNfOri]	,Nil,Nil})
			Aadd(aLinha,{"D1_SERIORI"	,oMulti:aCols[nX,nPSerOri]	,Nil,Nil})
			Aadd(aLinha,{"D1_ITEMORI"	,oMulti:aCols[nX,nPItemOri]	,Nil,Nil})
			
			DbSelectArea("SD2")
			DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			DbSeek(xFilial("SD2")+oMulti:aCols[nX,nPNfOri]+oMulti:aCols[nX,nPSerOri]+SA1->A1_COD+SA1->A1_LOJA+oMulti:aCols[nX,nPxPrd]+oMulti:aCols[nX,nPItemOri])
	    	
	    	DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek(xFilial("SF4")+oMulti:aCols[nX,nPxD1Tes])		
	
	   		If SF4->F4_PODER3=="D"
				AAdd( aLinha, { "D1_IDENTB6", oMulti:aCols[nX,nXmlIdentB6], Nil,Nil } )								
			Endif                                                                                           
	        
			Aadd(aLinha,{"D1_QUANT"		,oMulti:aCols[nX,nPxQte]		,Nil,Nil})
			Aadd(aLinha,{"D1_VUNIT"		,oMulti:aCols[nX,nPxPrunit]	,Nil,Nil})
			
			Aadd(aLinha,{"D1_TES"		,oMulti:aCols[nX,nPxD1Tes]		,Nil,Nil})		
			Aadd(aLinha,{"D1_CF"		,oMulti:aCols[nX,nPxCF]		,Nil,Nil})                
		
	   		Aadd(aLinha,{"D1_TOTAL"		,oMulti:aCols[nX,nPxTotal]	,Nil,Nil})
			Aadd(aLinha,{"D1_LOCAL"		,oMulti:aCols[nX,nPxLocal]	,Nil,Nil})
			
	    Else
	   		DbSelectArea("SD2")
			DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			DbSeek(xFilial("SD2")+oMulti:aCols[nX,nPNfOri]+oMulti:aCols[nX,nPSerOri]+SA2->A2_COD+SA2->A2_LOJA+oMulti:aCols[nX,nPxPrd]+oMulti:aCols[nX,nPItemOri])
	    	
	    	DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek(xFilial("SF4")+oMulti:aCols[nX,nPxD1Tes])		
	
	   		If SF4->F4_PODER3=="D" .Or. CENTRALXML->XML_TIPODC $ "C#I#P"
				Aadd(aLinha,{"D1_NFORI"		,oMulti:aCols[nX,nPNfOri]	,Nil,Nil})
				Aadd(aLinha,{"D1_SERIORI"	,oMulti:aCols[nX,nPSerOri]	,Nil,Nil})
				Aadd(aLinha,{"D1_ITEMORI"	,oMulti:aCols[nX,nPItemOri]	,Nil,Nil})
				AAdd(aLinha,{"D1_IDENTB6"   ,oMulti:aCols[nX,nXmlIdentB6], Nil,Nil } )								
				Aadd(aLinha,{"D1_LOCAL"		,oMulti:aCols[nX,nPxLocal]	,Nil,Nil})
			Endif                                                                                           
	   
	   	 	
			If CENTRALXML->XML_TIPODC $ "N"
				Aadd(aLinha,{"D1_QUANT"		,oMulti:aCols[nX,nPxQte]		,Nil,Nil})
			Endif
			Aadd(aLinha,{"D1_VUNIT"		,oMulti:aCols[nX,nPxPrunit]	,Nil,Nil})
	   		
			Aadd(aLinha,{"D1_TOTAL"		,oMulti:aCols[nX,nPxTotal]	,Nil,Nil})
		
			Aadd(aLinha,{"D1_TES"		,oMulti:aCols[nX,nPxD1Tes]		,Nil,Nil})		
			Aadd(aLinha,{"D1_CF"		,oMulti:aCols[nX,nPxCF]		,Nil,Nil})                		
		
	    Endif
	    	
		Aadd(aLinha,{"D1_VALDESC"		,oMulti:aCols[nX,nPxVlDesc]	,Nil,Nil})
		
		
		// Conforme pergunta 12 - Considera ou não os impostos destacados no XML para fins de importação
		If mv_par12 == 1
			If oMulti:aCols[nX,nPxBasIpi] > 0
				Aadd(aLinha,{"D1_BASEIPI"	,oMulti:aCols[nX,nPxBasIpi]	,Nil,Nil})
			Endif 
			If oMulti:aCols[nX,nPxPIpi]	> 0
				Aadd(aLinha,{"D1_IPI"		,oMulti:aCols[nX,nPxPIpi]		,Nil,Nil})
			Endif
			If oMulti:aCols[nX,nPxValIpi]	> 0
				Aadd(aLinha,{"D1_VALIPI"	,oMulti:aCols[nX,nPxValIpi]	,Nil,Nil})
			Endif
			If oMulti:aCols[nX,nPxBasIcm] > 0
				Aadd(aLinha,{"D1_BASEICM"	,oMulti:aCols[nX,nPxBasIcm]	,Nil,Nil})
			Endif
			If oMulti:aCols[nX,nPxPIcm] > 0
				Aadd(aLinha,{"D1_PICM"	 	,oMulti:aCols[nX,nPxPIcm]		,Nil,Nil})
			Endif
			If oMulti:aCols[nX,nPxValIcm]	> 0
				Aadd(aLinha,{"D1_VALICM" 	,oMulti:aCols[nX,nPxValIcm]	,Nil,Nil})
			Endif
			If oMulti:aCols[nX,nPxBasRet] > 0
				Aadd(aLinha,{"D1_BRICMS" 	,oMulti:aCols[nX,nPxBasRet]	,Nil,Nil})
			Endif
			If oMulti:aCols[nX,nPxIcmRet] > 0
				Aadd(aLinha,{"D1_ICMSRET"	,oMulti:aCols[nX,nPxIcmRet]	,Nil,Nil})
			Endif
			If oMulti:aCols[nX,nPxMva] > 0
				Aadd(aLinha,{"D1_MARGEM" 	,oMulti:aCols[nX,nPxMva]		,Nil,Nil})		
			Endif
			Aadd(aLinha,{"D1_CLASFIS"	,oMulti:aCols[nX,nPxCST]		,Nil,Nil})		
			
			If oMulti:aCols[nX,nPxBasPis] > 0
				Aadd(aLinha,{"D1_BASIMP6"	,oMulti:aCols[nX,nPxBasPis]	,Nil,Nil})
			Endif
			If oMulti:aCols[nX,nPxPPis] > 0
				Aadd(aLinha,{"D1_ALQIMP6"	,oMulti:aCols[nX,nPxPPis]		,Nil,Nil})
			Endif
			If oMulti:aCols[nX,nPxValPis] > 0
				Aadd(aLinha,{"D1_VALIMP6"	,oMulti:aCols[nX,nPxValPis]	,Nil,Nil})
			Endif
			If oMulti:aCols[nX,nPxBasCof] > 0
				Aadd(aLinha,{"D1_BASIMP5"	,oMulti:aCols[nX,nPxBasCof]	,Nil,Nil})
			Endif
			If oMulti:aCols[nX,nPxPCof] > 0
				Aadd(aLinha,{"D1_ALQIMP5"	,oMulti:aCols[nX,nPxPCof]		,Nil,Nil})
			Endif
			If oMulti:aCols[nX,nPxValCof] > 0
				Aadd(aLinha,{"D1_VALIMP5"	,oMulti:aCols[nX,nPxValCof]	,Nil,Nil})
			Endif
		Endif
			
		Aadd(aItems,aLinha)
		cItemD1	:= Soma1(cItemD1)
	Endif	
Next nX                                                                  


If Type("oCobr:_dup") <> "U"
	// Zero a variavel Private, para evitar que venha com dados de outra nota          
	// Neste trecho carrego um array contendo os vencimentos e valores das parcelas contidos no XML e permito levar para o Documento de entrada
	aDupSE2	:= {}                                       
	oDup  := oCobr:_dup
	oDup := IIf(ValType(oDup)=="O",{oDup},oDup)			
	For nP := 1 To Len(oDup)
		If Type("oDup[nP]:_dVenc:TEXT") <> "U" .and. Type("oDup[nP]:_vDup:TEXT") <> "U"
			Aadd(aDupSE2,{	STOD(StrTran(Alltrim(oDup[nP]:_dVenc:TEXT),"-",""))	,;	// Data Vencimento
							Val(oDup[nP]:_vDup:TEXT)})	// Valor da Duplicata})
		EndIf
	Next 
Endif


If Len(aItems) > 0
	lMsErroAuto:=.f.
	lMsHelpAuto:=.T.
	nModulo	:= 02
	cModulo	:= "COM"
	Begin Transaction
		If lSuperUsr 
			If !MsgYesNo("Deseja gerar Pré-Nota?")
				DbSelectArea("SC7")
				DbSetOrder(1)
				DbGotop()	
				U_XMLMT103(aArqXml[oArqXml:nAt,5],aItems,.F.)   
			Else
				DbSelectArea("SC7")
				DbSetOrder(1)
				DbGotop()
				MSExecAuto({|x,y,z|Mata140(x,y,z)},aCabec,aItems,3) 
				lPreNfe	:= .T.
			Endif
		ElseIf lComprUsr .And. !MsgYesNo("Deseja gerar Pré-Nota?")
			DbSelectArea("SC7")
			DbSetOrder(1)
			DbGotop()
			MSExecAuto({|x,y,z|Mata140(x,y,z)},aCabec,aItems,3) 
			lPreNfe	:= .T.
		Endif
    End Transaction
        
	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
		Return
	Else      
		// Valido que o documento realmente está lançado no sistema
		DbSelectArea("SF1")
		DbSetOrder(1)
		If DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSX3("F1_DOC")[1])+Padr(OIdent:_serie:TEXT,TamSX3("F1_SERIE")[1])+Iif(cTipoBox == "N=Normal",SA2->A2_COD+SA2->A2_LOJA+"N",SA1->A1_COD+SA1->A1_LOJA+"B"))
			
			RecLock("CENTRALXML",.F.)
			CENTRALXML->XML_KEYF1	:= xFilial("SF1")+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSX3("F1_DOC")[1])+Padr(OIdent:_serie:TEXT,TamSX3("F1_SERIE")[1])+Iif(cTipoBox == "N=Normal",SA2->A2_COD+SA2->A2_LOJA+"N",SA1->A1_COD+SA1->A1_LOJA+"B")
	        CENTRALXML->XML_LANCAD	:= SF1->F1_DTDIGIT
	        CENTRALXML->XML_HORLAN 	:= Time()
	        CENTRALXML->XML_USRLAN	:= Padr(cUserName,30)
	        MsUnlock()
	        
			MsgAlert(Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2])+" - DOC.GERADO ")
//			cRecebe		:= "marcelo@gmeyer.com.br"
			cRecebe		:= GetMv("XM_MAILXML")	// Destinatarios de email do lançamento da nota
			cAssunto 	:= IIf(lPreNfe,"Pré-","")+"Nota Fiscal "+ Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2]) + " - " + Capital(SM0->M0_NOMECOM)
			cMensagem	:= IIf(lPreNfe,"Pré-","")+"Nota Fiscal "+ Alltrim(aCabec[3,2])+' / '+Alltrim(aCabec[4,2]) + " lançada no sistema no dia " + Dtoc( Date() ) + " as " + Time() + " por "+cUserName
			cMensagem 	+= Chr(13)+Chr(10)
			
			stSendMail( cRecebe, cAssunto, cMensagem )
		Else
			RecLock("CENTRALXML",.F.)
			CENTRALXML->XML_KEYF1	:= " " 
	        CENTRALXML->XML_LANCAD	:= CTOD("  /  /  ")
	        CENTRALXML->XML_HORLAN 	:= " "               
	        CENTRALXML->XML_USRLAN	:= " "
	        MsUnlock()	
		Endif 
	Endif
Endif                     

Set Key  VK_F6 TO U_VldItemPc()

RestArea(aAreaOld)

Return
       
// Função que serve para atualizar o status de que a nota foi conferida pelo compras
Static Function stConferida

U_DbSelArea("CENTRALXML",.F.,1)

If !DbSeek(aArqXml[oArqXml:nAt,5]) 
    MsgAlert("Erro ao localizar registro")
    Return
Endif                      
  
If !Empty(CENTRALXML->XML_KEYF1)
	MsgAlert("Esta nota fiscal já tem vinculo de lançamento no Sistema! Verifique!","Rotina não permitida!")
	Return
Endif
 
If nTotalNfe <> nTotalXml
	// Padrao GP //
	//MsgAlert("O Valor dos produtos constantes no Arquivo XML é diferente do Valor apurado com alocação dos pedidos de compra! Favor conferir novamente!","A T E N Ç Ã O!! Conferência incompleta!")
	MsgAlert("O Valor dos produtos constantes no Arquivo XML é diferente do Valor apurado com alocação dos pedidos de compra!")
    //Return
Endif

If !Empty(CENTRALXML->XML_CONFCO) 
	If MsgYesNo("Nota fiscal já foi conferida em "+DTOC(CENTRALXML->XML_CONFCO)+". Deseja limpar status de conferência do Compras?")
		RecLock("CENTRALXML",.F.)
		CENTRALXML->XML_CONFCO	:= CTOD("  /  /  ")
		CENTRALXML->XML_HORCCO	:= " "
		MsUnlock()	
	Endif
Else
	If MsgYesNo("Deseja marcar a Nota fiscal como conferida pelo Compras?")
		
		stGrvItens()
		
		RecLock("CENTRALXML",.F.)
		CENTRALXML->XML_CONFCO	:= Date()
		CENTRALXML->XML_HORCCO	:= Time()
		CENTRALXML->XML_USRCCO	:= Padr(cUserName,30)
		MsUnlock()	
		
		cRecebe		:= GetMv("XM_MAILXML")	// Destinatarios de email do lançamento da nota
		cAssunto 	:= "Nota Fiscal "+ aArqXml[oArqXml:nAt,2] + " - " + Capital(SM0->M0_NOMECOM)
		cMensagem	:= "Nota Fiscal "+aArqXml[oArqXml:nAt,2	] + " conferida pelo Compras no dia " + Dtoc( Date() ) + " as " + Time() + " por "+cUserName
		cMensagem 	+= Chr(13)+Chr(10)
			
		stSendMail( cRecebe, cAssunto, cMensagem )
	
	Endif
Endif

Return 


// User Function para validar a Edição ou exclusão de registros do GetDados, entre outras opções
User Function XMLVLEDT()

If !Empty(CENTRALXML->XML_KEYF1)
	MsgAlert("Esta nota fiscal já tem vinculo de lançamento no Sistema! Verifique!","Rotina não permitida!")
	Return .F.
Endif

Return .T.



Static Function stSendMail( cRecebe, cAssunto, cMensagem )
	
Local cServer   := GETMV("MV_RELSERV")
Local cAccount  := AllTrim(GETMV("MV_WFMAIL"))
Local cPassword := AllTrim(GETMV("MV_WFPASSW"))
Local cEnvia    := AllTrim(GETMV("MV_WFMAIL"))
	
CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword Result lConectou
	
If lConectou
	SEND MAIL FROM cEnvia;
	TO cRecebe;
	SUBJECT cAssunto;
	BODY cMensagem;
	RESULT lEnviado
	If !lEnviado
		cMensagem := ""
		GET MAIL ERROR cMensagem
		Alert(cMensagem)
		Conout( "ERRO SMTP EM: " + cAssunto )
	Else
		DISCONNECT SMTP SERVER
		Conout( cAssunto )
	Endif
Else
	Conout( "ERRO SMTP EM: " + cAssunto )
	MsgAlert("Erro ao se conectar no servidor: " + cServer)
Endif
	
Return


Static Function stExpExcel()

If FindFunction("RemoteType") .And. RemoteType() == 1
	DlgToExcel({{"GETDADOS","Importação de Arquivo XML",aHeader,oMulti:aCols}}) 
EndIf

Return                                         


Static Function stRejeita(cChave)

Local oServer
Local oMessage
Local oDlgEmail
	
    
U_DbSelArea("CENTRALXML",.F.,1)
DbSeek(cChave)   
If !Empty(CENTRALXML->XML_KEYF1)
	MsgAlert("Esta nota fiscal já tem vinculo de lançamento no Sistema! Verifique!","Rejeição não permitida!")
	Return
Endif
	// Padrao GP
	// Verifica o e-mail do cadastro de Cliente ou Fornecedor
	_cMail := ""
	If Alltrim(CENTRALXML->XML_TIPODC)$"DB"
		_cMail := Posicione("SA1",3,xFilial("SA1")+CENTRALXML->XML_EMIT,"A1_EMAIL")
	Else
		_cMail := Posicione("SA2",3,xFilial("SA2")+CENTRALXML->XML_EMIT,"A2_EMAIL")
	EndIf                    

    //cTo			:= CENTRALXML->XML_CFROM       
    cTo			:= If(!Empty(_cMail),_cMail,CENTRALXML->XML_CFROM)       
    cSubject    := "Rejeição de Nota fiscal Eletrônica:" +CENTRALXML->XML_NUMNF
    
    cBody		:= "Motivo:  "+Chr(13)+Chr(10)
	
	cBody 		+= "Por meio deste email notificamos que estamos rejeitando"+Chr(13)+Chr(10)+" o recebimento da NF-e: "+CENTRALXML->XML_NUMNF +Chr(13)+Chr(10)
	cBody 		+= " Chave: "+CENTRALXML->XML_CHAVE+Chr(13)+Chr(10)
	cBody 		+= " emitida em : "+DTOC(CENTRALXML->XML_EMISSA)+ " para: "+Transform(CENTRALXML->XML_DEST,"@R 99.999.999/9999-99")+"-"+CENTRALXML->XML_NOMEDT 
	cBody 		+= " "+Chr(13)+Chr(10)
	cBody		+= CENTRALXML->XML_SUBJECT+Chr(13)+Chr(10)+CENTRALXML->XML_BODY
	lSend	:= .F.
	           	
	DEFINE MSDIALOG oDlgEmail Title OemToAnsi("Enviar email de Rejeição da Nota Fiscal Eletrônica") FROM 001,001 TO 380,620 PIXEL
	@ 010,010 Say "Para: " Pixel of oDlgEmail
	@ 010,050 MsGet cTo Size 180,10 Pixel Of oDlgEmail
	@ 025,010 Say "Assunto" Pixel of oDlgEmail
	@ 025,050 MsGet cSubject Size 250,10 Pixel Of oDlgEmail
	@ 040,050 Get cBody of oDlgEmail MEMO Size 250,100 Pixel	
	@ 160,050 BUTTON "Envia Email" Size 70,10 Action (lSend := .T.,oDlgEmail:End())	Pixel Of oDlgEmail
	@ 160,130 BUTTON "Cancela" Size 70,10 Action (oDlgEmail:End())	Pixel Of oDlgEmail
		
	ACTIVATE MsDialog oDlgEmail Centered
		
	If lSend
		//Crio a conexão com o server STMP ( Envio de e-mail )
		oServer := TMailManager():New()
	
		
		// Usa SSL na conexao
		If GetMv("XM_SMTPSSL")
			oServer:setUseSSL(.T.)
		Endif

    	oServer:Init( ""		,Alltrim(GetMv("XM_SMTP")), Alltrim(GetMv("XM_SMTPUSR"))	,Alltrim(GetMv("XM_PSWSMTP")),	0			, GetMv("XM_SMTPPOR") )
	     
		//seto um tempo de time out com servidor de 1min
		If oServer:SetSmtpTimeOut( 60 ) != 0
			Conout( "Falha ao setar o time out" )
			Return .F.
		EndIf
	         
		//realizo a conexão SMTP
		If oServer:SmtpConnect() != 0
			Conout( "Falha ao conectar" )
			Return .F.
		EndIf
	
		// Realiza autenticacao no servidor
		If GetMv("XM_SMTPAUT")
 			nErr := oServer:smtpAuth(Alltrim(GetMv("XM_SMTPUSR")), Alltrim(GetMv("XM_PSWSMTP")))
			If nErr <> 0
			 	ConOut("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr))      
			  	Alert("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr))
			  	oServer:smtpDisconnect()
			  	Return .F.
			Endif
		Endif
		//Apos a conexão, crio o objeto da mensagem
		oMessage := TMailMessage():New()
		//Limpo o objeto
		oMessage:Clear()
		//Populo com os dados de envio
		oMessage:cFrom 		:= GetMv("XM_SMTPDES")
		oMessage:cTo 		:= cTo
//		oMessage:cCc 		:= "nfe@gmeyer.com.br"
		oMessage:cSubject 	:= cSubject
		//oMessage:MsgBodyType( "text" )
    	oMessage:cBody 		:= cBody
	     
	
		cAviso	:= ""
		cErro	:= ""				                                     
		        
        oNfe := XmlParser(CENTRALXML->XML_ARQ,"_",@cAviso,@cErro)
        
		If Type("oNFe:_NfeProc")<> "U"
			oNF := oNFe:_NFeProc:_NFe
		Else
			oNF := oNFe:_NFe
		Endif
	           				                        
		If !Empty(cErro)
			MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
		Endif
				
//		SAVE<oXml>< [ XMLSTRING <cString>] | [ XMLFILE <cFile> ] > [ NEWLINE ]
		SAVE oNfe XMLFILE ("\Nf-e\"+Alltrim(CENTRALXML->XML_CHAVE)+".xml") 

	     
		//Adiciono um attach
		If oMessage:AttachFile( "\Nf-e\"+Alltrim(CENTRALXML->XML_CHAVE)+".xml" ) < 0
			Conout( "Erro ao atachar o arquivo" )
			MsgAlert("Não foi possível anexar o arquivo.","Erro" )
			Return .F.
		Else                     
			//adiciono uma tag informando que é um attach e o nome do arq
			oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+Alltrim(CENTRALXML->XML_CHAVE)+'.xml')
		EndIf
	    
		//Envio o e-mail
		If oMessage:Send( oServer ) != 0
			Conout( "Erro ao enviar o e-mail" )
			Return .F.
		Else
			MsgAlert("Email enviado com sucesso!","Concluído")
		EndIf
	
		//Disconecto do servidor
		If oServer:SmtpDisconnect() != 0
			Conout( "Erro ao disconectar do servidor SMTP" )
			Return .F.
		EndIf
		
		DbSelectArea("CENTRALXML")
		RecLock("CENTRALXML",.F.)
		CENTRALXML->XML_REJEIT	:= Date()
		CENTRALXML->XML_BODY		:= cBody
		CENTRALXML->XML_KEYF1	:= " " 
        CENTRALXML->XML_LANCAD	:= CTOD("  /  /  ")
        CENTRALXML->XML_HORLAN 	:= " " 
        CENTRALXML->XML_USRREJ	:= Padr(cUserName,30)

        MsUnlock()			
    Endif
    
Return

Static Function stViewNfe()

Local	cLocDir	:= "C:\NF-e\"

MakeDir(cLocDir)

U_DbSelArea("CENTRALXML",.F.,1)
DbSeek(Alltrim(aArqXml[oArqXml:nAt,5]))   
cAviso	:= ""
cErro	:= ""				                                     
		        
oNfe := XmlParser(CENTRALXML->XML_ARQ,"_",@cAviso,@cErro)
       
If Type("oNFe:_NfeProc")<> "U"
	oNF := oNFe:_NFeProc:_NFe
Else
	oNF := oNFe:_NFe
Endif
	           				                        
If !Empty(cErro)
	MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
Endif
	    
SAVE oNfe XMLFILE (cLocDir+Alltrim(aArqXml[oArqXml:nAt,5])+".xml") 

ShellExecute("open",cLocDir+Alltrim(aArqXml[oArqXml:nAt,5])+'.xml',"",cLocDir,1)

//WaitRun( '"%ProgramFiles%"\DanfeView\danfev.exe '+cLocDir+Alltrim(aArqXml[oArqXml:nAt,5])+'.xml"')

Return           



User Function XmlVldTt(nTipo)

Local	lRet	:= .T.

If nTipo == 1 // Quantidade
	If lMVXPCNFE .And. !Alltrim(oMulti:aCols[oMulti:nAt][nPxCFNFe]) $ cCFOPNPED .And. !CENTRALXML->XML_TIPODC $ "C#I#P"
		DbSelectArea("SC7")
		DbSetOrder(1)
		If DbSeek(xFilial("SC7")+oMulti:aCols[oMulti:nAt][nPxPedido]+oMulti:aCols[oMulti:nAt][nPxItemPc])
			If M->D1_QUANT > SC7->C7_QUANT - SC7->C7_QUJE
				MsgAlert("A quantidade digitada é maior que a quantidade disponível para entrega no pedido!","Divergência com pedido de compra!")
				lRet	:= .F.
			Endif
		Endif  
	ElseIf	CENTRALXML->XML_TIPODC $ "C#I#P"
		If M->D1_QUANT > 0
			MsgAlert("Para notas fiscais de complemento não pode haver quantidade digitada!","Quantidade não permitida!")
			lRet	:= .F.
		Endif
	Endif
ElseIf nTipo == 2           
	If lMVXPCNFE .And. !Alltrim(oMulti:aCols[oMulti:nAt][nPxCFNFe]) $ cCFOPNPED .And. !CENTRALXML->XML_TIPODC $ "C#I#P"
		DbSelectArea("SC7")
		DbSetOrder(1)
		If DbSeek(xFilial("SC7")+oMulti:aCols[oMulti:nAt][nPxPedido]+oMulti:aCols[oMulti:nAt][nPxItemPc])
			If M->D1_VUNIT <> SC7->C7_PRECO
				MsgAlert("O preço digitado não confere com a preço do pedido de compras" )
			Endif
		Endif
	Endif
Elseif nTipo == 3
	If M->D1_TOTAL <> oMulti:aCols[oMulti:nAt,nPxTotNfe]
		MsgAlert("O Valor total do item digitado não confere com o valor total do item constante no XML")
		lRet	:= .F.
	Endif
Endif

Return lRet


Static Function sfReport()

Local aStru := {}
Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Conferência de Nota fiscal Eletrônico X Pedido de Compra"
Local cPict          := ""
Local titulo       := "Conferência de Nota fiscal Eletrônica X Pedido de Compra"
Local nLin         := 80
        //             012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
        //                       1         2         3         4         5         6         7         8         9         10  
Local Cabec1       := "Ref Fornecedor   Código Protheus  Descrição                                            Qte XML  UM   R$ Unit.XML    R$ Total XML Quantidade UM     R$ Unit NF     R$ Total NF      R$ Pedido Observações          %Difer"

Local Cabec2       := "CGC: " +Transform(CENTRALXML->XML_EMIT,"@R 99.999.999/9999-99")  + " - " + Alltrim(CENTRALXML->XML_NOMEMT) + " NFº " + CENTRALXML->XML_NUMNF
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 220
Private tamanho          := "G"
Private nomeprog         := "XMLCONFNFE" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "NOME" // Coloque aqui o nome do arquivo usado para impressao em disco

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,"")

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  14/02/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local	nTotXml	:= 0
Local	nTotNfe	:= 0

For nI := 1 To Len(oMulti:aCols)

   If oMulti:aCols[nI,Len(oMulti:aHeader)+1]
   		Loop
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Verifica o cancelamento pelo usuario...                             ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio. . .                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif

		@nLin,000 Psay oMulti:aCols[nI,nPxCodNfe]
		@nLin,017 Psay oMulti:aCols[nI,nPxPrd]
		@nLin,034 Psay Posicione("SB1",1,xFilial("SB1")+oMulti:aCols[nI,nPxPrd],"B1_DESC")
		@nLin,085 Psay Transform(oMulti:aCols[nI,nPxQteNfe],"@E 99,999.99")
		@nLin,096 Psay oMulti:aCols[nI,nPxUMNFe]
		@nLin,099 Psay Transform(oMulti:aCols[nI,nPxPrcNfe]+IIf(GetNewPar("XM_PRCCIST",.T.),oMulti:aCols[nI,nPxIcmRet]/oMulti:aCols[nI,nPxQteNfe],0),"@E 9,999,999.9999")
		@nLin,115 Psay Transform(oMulti:aCols[nI,nPxTotNfe]+IIf(GetNewPar("XM_PRCCIST",.T.),oMulti:aCols[nI,nPxIcmRet],0),"@E 9,999,999.9999")
		@nLin,130 Psay Transform(oMulti:aCols[nI,nPxQte],"@E 999,999.99")
		@nLin,141 Psay oMulti:aCols[nI,nPxUm]
		@nLin,144 Psay Transform(oMulti:aCols[nI,nPxPrunit],"@E 9,999,999.9999")
		@nLin,160 Psay Transform(oMulti:aCols[nI,nPxTotal],"@E 9,999,999.9999")
		DbSelectArea("SC7")
		DbSetOrder(1)
		If DbSeek(xFilial("SC7")+oMulti:aCols[nI][nPxPedido]+oMulti:aCols[nI][nPxItemPc])
			@nLin,175 Psay Transform(SC7->C7_PRECO+IIf(GetNewPar("XM_PRCCIST",.T.),SC7->C7_ICMSRET/SC7->C7_QUANT,0),"@E 9,999,999.9999")
			If oMulti:aCols[nI,nPxPrunit] <> SC7->C7_PRECO
				@nLin,190 Psay "Dif R$ " + Transform(SC7->C7_PRECO-oMulti:aCols[nI,nPxPrunit],"@E 999,999.9999")
			Endif
			@nLin,210 Psay Transform(Round((oMulti:aCols[nI,nPxPrunit]-SC7->C7_PRECO)/SC7->C7_PRECO * 100,2),"@E 999.99%")
		Else
			@nLin,190 Psay "Não há pedido de compra"
		Endif
		nTotXml	+= oMulti:aCols[nI,nPxTotNfe]+IIf(GetNewPar("XM_PRCCIST",.T.),oMulti:aCols[nI,nPxIcmRet],0)
		nTotNfe	+= oMulti:aCols[nI,nPxTotal]

	   nLin++ // Avanca a linha de impressao

Next
nLin++	

@nLin,115 Psay Transform(nTotXml,"@E 99,999,999.99")
@nLin,160 Psay Transform(nTotNfe,"@E 99,999,999.99")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return


Return


// Função que permite buscar o Historico do cliente e posição
Static Function sfTracker()

Local		aAreaOld	:= GetArea()
Private 	aRotina		:= StaticCall(MATA410,MenuDef)
Private		cCadastro   := "Posição do Cliente"
Private		INCLUI		:= .F.
Private		ALTERA		:= .T.
Private		aHeader		:= {}
Private		aCols		:= {}

Aviso("Histórico da Nota",	"Enviado por:"+CENTRALXML->XML_CFROM + Chr(13)+Chr(10) +;
							"Corpo Email:"+CENTRALXML->XML_BODY + Chr(13)+Chr(10) +;
							"Data de Emissão:"+DTOC(CENTRALXML->XML_EMISSA) + Chr(13)+Chr(10) +;
							"Data Recebimento:"+DTOC(CENTRALXML->XML_RECEB) + " " +CENTRALXML->XML_HORREC + " por:"+CENTRALXML->XML_USRREC + Chr(13)+Chr(10)+ ;
                            "Data Conf.Sefaz: "+DTOC(CENTRALXML->XML_CONFER) + " " +CENTRALXML->XML_HORCON + " por:"+CENTRALXML->XML_USRCON + Chr(13)+Chr(10)+ ;
                            "Data Lançamento: "+DTOC(CENTRALXML->XML_LANCAD) + " " + CENTRALXML->XML_HORLAN + " por:"+CENTRALXML->XML_USRLAN + Chr(13)+Chr(10)+; 
                            "Data Rejeição XML:"+DTOC(CENTRALXML->XML_REJEIT) + " por:"+CENTRALXML->XML_USRREJ + Chr(13)+Chr(10)+ ;
                            "Data Conf.Compras:"+DTOC(CENTRALXML->XML_CONFCO) + " " + CENTRALXML->XML_HORCCO + " por:"+CENTRALXML->XML_USRCCO + Chr(13)+Chr(10)+  ;
                            "Data Revalidação Sefaz: "+DTOC(CENTRALXML->XML_DTRVLD)  + Chr(13)+Chr(10);
	  ,{"Ok"},3)                         

DbSelectArea("SA1")
DbSetOrder(1)

If aArqXml[oArqXml:nAt,12] $ "B#D"
	a450F4Con()
	// Atualizo variavel de pesquisa e efetuo refresh 
	cVarPesq := aArqXml[oArqXml:nAt,2]
	stPesquisa()
Endif                             

RestArea(aAreaOld)

Return 



Static Function sfAltTipDC
      
Local	aAreaOld	:= GetArea()
Local	cTipoBox	:= "N=Normal"
Local	lContinua	:= 	.F.

U_DbSelArea("CENTRALXML",.F.,1)
If !DbSeek(aArqXml[oArqXml:nAt,5]) 
    MsgAlert("Erro ao localizar registro")
    Return
Endif

If !Empty(CENTRALXML->XML_REJEIT) 
	MsgAlert("Nota fiscal rejeitada em "+DTOC(CENTRALXML->XML_REJEIT)+". Não é permitido fazer alterações!","Nota fiscal rejeitada!")
	Return
Endif
// -- Valido se Nota Fiscal já existe na base ?
If !Empty(CENTRALXML->XML_KEYF1) 
	MsgAlert("Nota fiscal já está lançada no Sistema no dia "+DTOC(CENTRALXML->XML_LANCAD)+". Não é permitido fazer alterações!","Nota fiscal já lançada!")
	Return
Endif




cAviso	:= ""
cErro	:= ""
oNfe := XmlParser(CENTRALXML->XML_ARQ,"_",@cAviso,@cErro)


If Type("oNFe:_NfeProc")<> "U"
	oNF := oNFe:_NFeProc:_NFe
Else
	oNF := oNFe:_NFe
Endif
          				                        
If !Empty(cErro)
	MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
Endif
			
oIdent     	:= oNF:_InfNfe:_IDE
oEmitente  	:= oNF:_InfNfe:_Emit
oDestino   	:= oNF:_InfNfe:_Dest    
oTotal		:= oNF:_InfNfe:_Total
// Valido se esta empresa/filial certa conforme destinatário do XML
If SM0->M0_CGC <> oDestino:_CNPJ:TEXT
	MsgAlert("Empresa errada! Destinatário é diferente do CNPJ do XML("+oDestino:_CNPJ:TEXT+").","Destinatário errado!")
	Return
Endif
	    
If Type("oNFe:_NfeProc:_protNFe:_infProt:_chNFe")<> "U"
	oNF := oNFe:_NFeProc:_NFe
	cChave	:= oNFe:_NfeProc:_protNFe:_infProt:_chNFe:TEXT
Else
	cChave	:= " "
Endif	
If CENTRALXML->XML_TIPODC $ "N#C#I#P"
	DbSelectArea("SA2")
	DbSetOrder(3)
	If !DbSeek(xFilial("SA2")+oEmitente:_CNPJ:TEXT)
	    MsgAlert("Não há cadastro de fornecedor para este CNPJ")
	Endif
	cCodFor	:= SA2->A2_COD
	cLojFor	:= SA2->A2_LOJA
Else
	DbSelectArea("SA1")
	DbSetOrder(3)
	If !DbSeek(xFilial("SA1")+oEmitente:_CNPJ:TEXT)
	    MsgAlert("Não há cadastro de cliente para este CNPJ")
	Endif
	cCodFor	:= SA1->A1_COD
	cLojFor	:= SA1->A1_LOJA	
Endif                 

cNumDoc	:=  Right("000000000"+Alltrim(OIdent:_nNF:TEXT),TamSX3("F1_DOC")[1])
cSerDoc	:= 	Padr(OIdent:_serie:TEXT,TamSX3("F1_SERIE")[1])

cTipoBox	:= CENTRALXML->XML_TIPODC
		                                                                                     
/*	{'F1_TIPO=="N"'		,'DISABLE'   	},;	// NF Normal
	{'F1_TIPO=="P"'		,'BR_AZUL'   	},;	// NF de Compl. IPI
	{'F1_TIPO=="I"'		,'BR_MARROM' 	},;	// NF de Compl. ICMS
	{'F1_TIPO=="C"'		,'BR_PINK'   	},;	// NF de Compl. Preco/Frete
	{'F1_TIPO=="B"'		,'BR_CINZA'  	},;	// NF de Beneficiamento
	{'F1_TIPO=="D"'		,'BR_AMARELO'	} }	// NF de Devolucao
  */
DEFINE MSDIALOG oDlgCond TITLE "Alterar tipo de Documento!" FROM 001,001 TO 170,400 PIXEL
@ 010,018 Say "Tipo de Nota fiscal" Pixel of oDlgCond
@ 010,110 Combobox cTipoBox Items {"N=Normal","B=Beneficiamento","D=Devolução","C=Compl. Preço/Frete","P=Compl. IPI","I=Compl. ICMS"} Pixel of oDlgCond When lSuperUsr 
@ 035,018 BUTTON "Confirma" Size 40,10 Pixel of oDlgCond Action (lContinua	:= .T.,oDlgCond:End())
@ 035,068 BUTTON "Cancela"  Size 40,10 Pixel of oDlgCond Action (oDlgCond:End())
		
ACTIVATE MSDIALOG oDlgCond CENTERED

If !lContinua
	Return
Endif

// Validação que permite que o tipo de documento seja alterado
If cTipoBox <> CENTRALXML->XML_TIPODC
	If MsgNoYes("Você alterou o tipo de nota fiscal de '"+CENTRALXML->XML_TIPODC+"' para '"+cTipoBox+"'!"+Chr(13)+Chr(10)+;
	            "Deseja realmente efetuar a troca do tipo de Nota para '"+cTipoBox+"'? ","Troca do Tipo de Documento de Entrada!")
   		RecLock("CENTRALXML",.F.)
		CENTRALXML->XML_TIPODC 	:= cTipoBox
    	MsUnlock()
  	Endif
  	Return
Endif

Return
