#include "protheus.ch"
#include "topconn.ch"


User Function XMLMT103(cChaveNfe,aItems,lVisual,lClassif,lExclui)

Local	aAreaOld	:= GetArea()
Default lVisual     := .F.
Default lClassif	:= .F.                                  
Default	lExclui		:= .F.

Private	aColsBk		:= IIf(Type("aCols") == "A",aCols,{})
Private	aHeaderBk	:= Iif(Type("aHeader") == "A",aHeader,{})
Private	lXmlMt103   := !lVisual//.T.

Private aSD1Cols   := aClone(aItems)

//(cAlias,nReg,nOpcx,lWhenGet,lEstNfClass)

If !lVisual
	Mata103(aCabec, aIteMs , 3 , .T.)
Else
	U_DbSelArea("CENTRALXML",.F.,1)
	
	If DbSeek(aArqXml[oArqXml:nAt,5])
		If CENTRALXML->XML_DEST == SM0->M0_CGC
			DbSelectArea("SF1")
			DbSetOrder(1)
			If DbSeek(CENTRALXML->XML_KEYF1)
				If !lClassif
					Mata103( , , 2 ,)
				ElseIf lExclui
					If Empty(SF1->F1_STATUS) .And. MsgNoYes("Deseja excluir a pré-nota '"+SF1->F1_DOC + "' ??","Exclusão Pré-nota!")
						aCabAuto :=  {}
						Aadd(aCabAuto,{"F1_TIPO"   	,SF1->F1_TIPO			,Nil,Nil})
						Aadd(aCabAuto,{"F1_FORMUL" 	,SF1->F1_FORMUL			,Nil,Nil})
						Aadd(aCabAuto,{"F1_DOC"    	,SF1->F1_DOC 			,Nil,Nil})
						Aadd(aCabAuto,{"F1_SERIE"   ,SF1->F1_SERIE			,Nil,Nil})
						Aadd(aCabAuto,{"F1_EMISSAO"	,SF1->F1_EMISSAO		,Nil,Nil})
						Aadd(aCabAuto,{"F1_FORNECE"	,SF1->F1_FORNECE		,Nil,Nil})
						Aadd(aCabAuto,{"F1_LOJA"   	,SF1->F1_LOJA			,Nil,Nil})		
						Aadd(aCabAuto,{"F1_ESPECIE"	,SF1->F1_ESPECIE		,Nil,Nil})
						Aadd(aCabAuto,{"F1_EST"		,SF1->F1_EST			,Nil,Nil})

						aItensAuto := {}                 
						
						DbSelectArea("SD1")
						DbSetOrder(1)
						Set Filter To SD1->D1_DOC == SF1->F1_DOC .And. SD1->D1_SERIE == SF1->F1_SERIE .And. SD1->D1_FORNECE == SF1->F1_FORNECE .And. SD1->D1_LOJA == SF1->F1_LOJA 
						While !Eof()
							aLinha	:= {}
							Aadd(aLinha,{"D1_FILIAL"	, SD1->D1_FILIAL		,Nil,Nil})
							Aadd(aLinha,{"D1_ITEM"		, SD1->D1_ITEM			,Nil,Nil})		
							Aadd(aLinha,{"D1_COD"		, SD1->D1_COD			,Nil,Nil})		
							Aadd(aLinha,{"D1_UM"		, SD1->D1_UM			,Nil,Nil})	
							Aadd(aLinha,{"D1_QUANT"		, SD1->D1_QUANT			,Nil,Nil})
							Aadd(aLinha,{"D1_VUNIT"		, SD1->D1_VUNIT			,Nil,Nil})
							Aadd(aLinha,{"D1_LOCAL"		, SD1->D1_LOCAL			,Nil,Nil})
			
							Aadd(aLinha,{"D1_TES"		, SD1->D1_TES			,Nil,Nil})		
		   					Aadd(aLinha,{"D1_TOTAL"		, SD1->D1_TOTAL			,Nil,Nil})
		   					Aadd(aItensAuto,aLinha)
			                DbSelectArea("SD1")
			                DbSkip()
			       		Enddo
				    	DbSelectArea("SD1")
						DbSetOrder(1)
						Set Filter To
						Mata140(aCabAuto,aItensAuto, 5 , ,1 )
					Else				
						Mata103(, , 5 , )
					Endif
				ElseIf lClassif .And. Empty(SF1->F1_STATUS)
					Mata103(, , 4 , )
				Else
					MsgAlert("Opção não permitida!","A T E N Ç Ã O!!")
				Endif
			Else
				MsgAlert("Nota fiscal não localizada!","A T E N Ç Ã O!!")
			Endif
		Else
			MsgAlert("Esta nota não pertence a empresa "+Capital(SM0->M0_NOMECOM),"Empresa errada!")
		Endif
	Endif
	
Endif

// Restauro variaveis
aCols	:= aColsBk
aHeader := aHeaderBk
RestArea(aAreaOld)

Return



// Ponto de entrada para alterar os vencimentos e valores das parcelas
User Function A103CND2()

If Type("aDupSE2") == "A"    
	If Len(aDupSE2) > 0     
		Return aDupSE2
	Endif
Endif
//a103Cnd2 := ExecBlock("A103CND2",.F.,.F.,a103Cnd2)

Return Nil


// Padrao GP //
// Eliminar ponto de entrada do poder de terceiros
/*
User Function MTPROCP3

Local	lRet		:= .T.
Local	cAliasB6	:= ParamIxb[1]           
Local	lQueryB6	:= ParamIxb[2]
Local	cQry		:= ""

If Type("aChvNfes") <> "U" .And. Type("oMulti") <> "U"
	lRet	:= .F.    
	
	If Len(aChvNfes) > 0
		
		cQry += "SELECT D2_NUMSEQ "
		cQry += "  FROM "+RetSqlName("SD2") + " D2," + RetSqlName("SF2") + " F2 "
		cQry += " WHERE F2.D_E_L_E_T_ = ' ' "
		For xT := 1 To Len(aChvNfes)
			If xT == 1
				cQry += "  AND F2_CHVNFE IN(' "
			Endif	                                  
		    cQry += "','"+aChvNfes[xT]+""
		    If xT == Len(aChvNfes)
		    	cQry += "')"
		    Endif
		Next 
		cQry += "   AND F2_LOJA = D2_LOJA "
		cQry += "   AND F2_CLIENTE = D2_CLIENTE "
		cQry += "   AND F2_SERIE = D2_SERIE "
		cQry += "   AND F2_DOC = D2_DOC "
		cQry += "   AND F2_FILIAL = '"+xFilial("SF2") + "' "
		cQry += "   AND D2.D_E_L_E_T_ = ' ' "                          
		cQry += "   AND D2_NUMSEQ = '"+(cAliasB6)->B6_IDENT+"' "
		cQry += "   AND D2_EMISSAO <= '"+DTOS(CENTRALXML->XML_EMISSA)+"' "
		cQry += "   AND D2_LOCAL = '"+oMulti:aCols[oMulti:nAt,nPxLocal]+"' "		
		cQry += "   AND D2_COD = '"+oMulti:aCols[oMulti:nAt,nPxProd]+"' "
		cQry += "   AND D2_FILIAL = '"+xFilial("SD2")+"' "       
		
		TCQUERY cQry NEW ALIAS "QPODER3" 
		
		If !Eof()
			lRet	:= .T.
		Endif
		QPODER3->(DbCloseArea())
	Endif
	
	If !lRet 
		If Round((cAliasB6)->B6_PRUNIT,TamSX3("B6_PRUNIT")[2]) == Round(aCols[n,nPxPrcNfe],TamSX3("B6_PRUNIT")[2])
			lRet	:= .T.
		ElseIf Round((cAliasB6)->D2_PRCVEN,TamSX3("D2_PRCVEN")[2]) == Round(aCols[n,nPxPrcNfe],TamSX3("D2_PRCVEN")[2])
			lRet	:= .T.
		ElseIf Round((cAliasB6)->D2_PRCVEN,TamSX3("D2_PRCVEN")[2]) == Round((aCols[n,nPxTotNfe]/aCols[n,nPxQteNfe]),TamSX3("D2_PRCVEN")[2])
			lRet	:= .T.
		ElseIf !GetNewPar("XM_POD3ALL",.T.)
			lRet	:= .T.
		Endif
	Endif
Endif

Return lRet
*/
