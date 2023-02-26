#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#DEFINE RDDSPED "TOPCONN"

Static __nConecta
Static lInitSped := .F.
/*/
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta rotina tem como objetivo efetuar a inicializacao do    ³±±
±±³          ³ambiente de tabela para Nfe customizado CENTRAL             ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CriaTblXml()

Local oWizard
Local oCombo 
Local cCombo    := ""
Local aTexto    := {}
Local aPerg     := {}
Local aPerg2    := {}
Local aPerg3	:= {}
Local aParam    := {}
Local aParam2   := {}
Local aParam3	:= {}


// Retirar este trecho se mandar codigo oficialmente
/*
DbSelectArea("SX6")
DbSetOrder(1)
                                                        
If !DbSeek(xFilial("SX6")+"MV_ZXXX")
	RecLock("SX6",.T.)
	SX6->X6_FIL     := xFilial( "SX6" )
	SX6->X6_VAR     := "MV_ZXXX"
	SX6->X6_TIPO    := "N"
	SX6->X6_DESCRIC := " "
	MsUnLock()
	PutMv("MV_ZXXX",1)
EndIf

If GetMv("MV_ZXXX") > 100 .Or. Date() >= CTOD("15/09/11")
	MsgAlert("Este programa não está mais liberado para rodar como Demostração.")
	Return .F.
Endif
PutMv("MV_ZXXX",GetMv("MV_ZXXX")+1)
*/
// ------------------------------------------------------------

If PswAdmin( , ,RetCodUsr()) == 0

	DbSelectArea("SX6")
	DbSetOrder(1)
	
	// Servidor SMTP
	
	If !DbSeek(xFilial("SX6")+"XM_SMTP   ")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_SMTP"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/Servidor SMTP"
		MsUnLock()
		PutMv("XM_SMTP","mail.meuservidor.com.br")
	EndIf
	// 1
	Aadd(aParam,PadR(GetMv("XM_SMTP"),250))
	
	
	// Porta SMTP 25/995
	If !DbSeek(xFilial("SX6")+"XM_SMTPPOR")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_SMTPPOR"
		SX6->X6_TIPO    := "N"
		SX6->X6_DESCRIC := "Central NF-e/Porta SMTP"
		MsUnLock()
		PutMv("XM_SMTPPOR",25)
	EndIf
	// 2
	Aadd(aParam,PadR(GetMv("XM_SMTPPOR"),3))
	
	// Conta usuário SMTP
	If !DbSeek(xFilial("SX6")+"XM_SMTPUSR")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_SMTPUSR"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/E-mail autenticação "    	
		MsUnLock()                                            
		PutMv("XM_SMTPUSR","meu_usuario_smtp")
	EndIf
	// 3
	Aadd(aParam,PadR(GetMv("XM_SMTPUSR"),250))
	
	// Senha usuário SMTP
	If !DbSeek(xFilial("SX6")+"XM_PSWSMTP")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_PSWSMTP"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/Senha Conta SMTP"
		MsUnLock()
		PutMv("XM_PSWSMTP","senha1234")
	EndIf
	// 4
	Aadd(aParam,PadR(GetMv("XM_PSWSMTP"),25))
	
	// Descrição Conta SMTP
	If !DbSeek(xFilial("SX6")+"XM_SMTPDES")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_SMTPDES"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/E-mail"
		MsUnLock()                       
		PutMv("XM_SMTPDES","Minha Empresa<meuemail@meudominio.com.br>")
	EndIf
	// 5
	Aadd(aParam,PadR(GetMv("XM_SMTPDES"),250))
	
	// Usa SSL
	If !DbSeek(xFilial("SX6")+"XM_SMTPSSL")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_SMTPSSL"
		SX6->X6_TIPO    := "L"
		SX6->X6_DESCRIC := "Central NF-e/SMTP Usa SSL"
		MsUnLock()
		PutMv("XM_SMTPSSL",.F.)
	EndIf
	// 6
	Aadd(aParam,GetMv("XM_SMTPSSL"))
	
	// Autenticação Requerida
	If !DbSeek(xFilial("SX6")+"XM_SMTPAUT")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_SMTPAUT"
		SX6->X6_TIPO    := "L"
		SX6->X6_DESCRIC := "Central NF-e/SMTP Aut.Requerida"
		MsUnLock()
		PutMv("XM_SMTPAUT",.T.)
	EndIf
	// 7
	Aadd(aParam,GetMv("XM_SMTPAUT"))
	
	Aadd(aPerg,{1,"Servidor SMTP"	,aParam[1],"",".T.","",".T.",150,.F.})
	Aadd(aPerg,{1,"Porta"			,aParam[2],"",".T.","",".T.",20,.F.})
	Aadd(aPerg,{1,"Login Email"		,aParam[3],"",".T.","",".T.",120,.F.})	
	Aadd(aPerg,{1,"Senha"			,aParam[4],"",".T.","",".T.",120,.F.})	
	Aadd(aPerg,{1,"Conta de Email"	,aParam[5],"",".T.","",".T.",120,.F.})	
	Aadd(aPerg,{4,"Usa SSL"			,aParam[6],"Conexão Segura",080,".T.",.F.})
	Aadd(aPerg,{4,"Autenticação"	,aParam[7],"Requerida",060,".T.",.F.})
	
	// Servidor POP
	If !DbSeek(xFilial("SX6")+"XM_POP   ")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_POP"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/Servidor POP"
		MsUnLock()
		PutMv("XM_POP","mail.meuservidorpop.com.br")
	EndIf
	// 1
	Aadd(aParam2,PadR(GetMv("XM_POP"),250))
	
	// Porta POP3/POPS 110/465
	If !DbSeek(xFilial("SX6")+"XM_POPPORT")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_POPPORT"
		SX6->X6_TIPO    := "N"
		SX6->X6_DESCRIC := "Central NF-e/Porta POP"
		MsUnLock()
		PutMv("XM_POPPORT",110)
	EndIf
	// 2
	Aadd(aParam2,PadR(GetMv("XM_POPPORT"),3))
	
	// Conta usuário POP
	If !DbSeek(xFilial("SX6")+"XM_POPUSR")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_POPUSR"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/Usuário POP"
		MsUnLock()
		PutMv("XM_POPUSR","meu_usuario_pop")
	EndIf                                   
	// 3
	Aadd(aParam2,PadR(GetMv("XM_POPUSR"),250))
	
	// Senha usuário POP
	If !DbSeek(xFilial("SX6")+"XM_PSWPOP")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_PSWPOP"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/Senha POP"
		MsUnLock()
		PutMv("XM_PSWPOP","senha1234")
	EndIf
	// 4
	Aadd(aParam2,PadR(GetMv("XM_PSWPOP"),25))
	
	// Usa SSL
	If !DbSeek(xFilial("SX6")+"XM_POPSSL")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_POPSSL"
		SX6->X6_TIPO    := "L"
		SX6->X6_DESCRIC := "Central NF-e/POP Usa SSL"
		MsUnLock()
		PutMv("XM_POPSSL",.F.)
	EndIf
	// 5
	Aadd(aParam2,GetMv("XM_POPSSL"))
	
	aadd(aPerg2,{1,"Servidor POP"	,aParam2[1],"",".T.","",".T.",120,.F.})
	Aadd(aPerg2,{1,"Porta"			,aParam2[2],"",".T.","",".T.",20,.F.})
	Aadd(aPerg2,{1,"Login "			,aParam2[3],"",".T.","",".T.",120,.F.})	
	Aadd(aPerg2,{1,"Senha"			,aParam2[4],"",".T.","",".T.",120,.F.})	
	Aadd(aPerg2,{4,"Usa SSL"		,aParam2[5],"Conexão Segura",080,".T.",.F.})
	
	
	// Perguntas painel 3 - Parametros da rotina
	If !DbSeek(xFilial("SX6")+"XM_USRXMLN")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_USRXMLN"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/Id Usuarios Escrita Fiscal"
		MsUnLock()
		PutMv("XM_USRXMLN","000000#000001")
	EndIf
	// 1
	Aadd(aParam3,PadR(GetMv("XM_USRXMLN"),250))
	
	If !DbSeek(xFilial("SX6")+"XM_USRXMLC")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_USRXMLC"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/Id Usuarios Compras"
		MsUnLock()
		PutMv("XM_USRXMLC","000000#000001")
	EndIf
	// 2
	Aadd(aParam3,PadR(GetMv("XM_USRXMLC"),250))
	
	If !DbSeek(xFilial("SX6")+"XM_XPCNFE")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_XPCNFE"
		SX6->X6_TIPO    := "L"
		SX6->X6_DESCRIC := "Central NF-e/Pedido Compra Obrigatorio"
		MsUnLock()
		PutMv("XM_XPCNFE",.T.)
	EndIf
	// 3
	Aadd(aParam3,GetMv("XM_XPCNFE"))
	
	If !DbSeek(xFilial("SX6")+"XM_MAILXML")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_MAILXML"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/Dest. Lcto NF-e"
		MsUnLock()
		PutMv("XM_MAILXML","escritafiscal@seudominio.com.br;compras@seudominio.com.br")
	EndIf
	// 4
	Aadd(aParam3,PadR(GetMv("XM_MAILXML"),250))
	    
	
	If !DbSeek(xFilial("SX6")+"XM_BLQPOP")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_BLQPOP"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/Semaforo POP-NFe"
		MsUnLock()
		PutMv("XM_BLQPOP"," ")
	EndIf
	// 4

	// 5
	// Número de horas desde a emissão do Documento para revalidar XML se o mesmo ainda permanece autorizado na SEFAZ
	If !DbSeek(xFilial("SX6")+"XM_SPEDEXC")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_SPEDEXC"
		SX6->X6_TIPO    := "N"
		SX6->X6_DESCRIC := "Central NF-e/Qte Horas p/Exc"
		MsUnLock()
		PutMv("XM_SPEDEXC",24)
	EndIf
	// 5
	Aadd(aParam3,PadR(GetMv("XM_SPEDEXC"),3))
	
	//  6 
	If !DbSeek(xFilial("SX6")+"XM_PRCCIST")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_PRCCIST"
		SX6->X6_TIPO    := "L"
		SX6->X6_DESCRIC := "Central NF-e/ Rel.Diverg.C/Impostos"
		MsUnLock()
		PutMv("XM_PRCCIST",.T.)
	EndIf
	// 6
	Aadd(aParam3,GetMv("XM_PRCCIST"))
	
	// 7
	If !DbSeek(xFilial("SX6")+"XM_URLCSFZ")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_URLCSFZ"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/Url p/Consulta Sefaz"
		MsUnLock()
		PutMv("XM_URLCSFZ","http://www.nfe.fazenda.gov.br/portal/consulta.aspx?tipoConsulta=resumo&tipoConteudo=d09fwabTnLk=&nfe=")
	EndIf
	Aadd(aParam3,Padr(GetMv("XM_URLCSFZ"),Len(SX6->X6_CONTEUD)))
	// 7
	
	// 8
	If !DbSeek(xFilial("SX6")+"XM_CFOPRET")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_CFOPRET"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/CFO Saída p/Ent.Tipo B"
		MsUnLock()
		PutMv("XM_CFOPRET","902/903/906/907/909/913/916/925")
	EndIf
	Aadd(aParam3,Padr(GetMv("XM_CFOPRET"),Len(SX6->X6_CONTEUD)))
	// 8
	
	// 9
	If !DbSeek(xFilial("SX6")+"XM_CFOPDEV")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_CFOPDEV"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/CFO Saída p/Ent.Tipo D"
		MsUnLock()
		PutMv("XM_CFOPDEV","201/202/208/209/210/410/411/412/413/503/553/555/556")
	EndIf
	Aadd(aParam3,Padr(GetMv("XM_CFOPDEV"),Len(SX6->X6_CONTEUD)))
	// 9
	
	// Lista de CFOPs de notas de saida recebidas que não precisam de Pedido de Compra
	If !DbSeek(xFilial("SX6")+"XM_CFNPCNF")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_CFNPCNF"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/CFOs Sem Pedido Compra"
		MsUnLock()
		PutMv("XM_CFNPCNF","5949/6949")
	EndIf
	Aadd(aParam3,Padr(GetMv("XM_CFNPCNF"),Len(SX6->X6_CONTEUD))) 
	//10 
	
	//11
	//&(GetNewPar("XM_RETPOD3",'{{"5906","308"},{"6906","308"}}'))
	If !DbSeek(xFilial("SX6")+"XM_RETPOD3")
		RecLock("SX6",.T.)
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "XM_RETPOD3"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Central NF-e/Conversão Poder3 CF X Tes"
		MsUnLock()
		PutMv("XM_RETPOD3",'{{"5906","4ZZ"},{"6906","4ZZ"}}')
	EndIf
	Aadd(aParam3,Padr(GetMv("XM_RETPOD3"),Len(SX6->X6_CONTEUD)))
	
	
	Aadd(aPerg3,{1,"ID Usuários Escrita Fiscal"	,aParam3[1],"",".T.","",".T.",120,.F.})
	Aadd(aPerg3,{1,"ID Usuários Compras"		,aParam3[2],"",".T.","",".T.",120,.F.})
	Aadd(aPerg3,{4,"Pedido de Compra"			,aParam3[3],"Obrigatório?"  ,080,".T.",.F.})	
	Aadd(aPerg3,{1,"Destinatários Inclusão NF-e",aParam3[4],"",".T.","",".T.",150,.F.})	
	Aadd(aPerg3,{1,"Qte Horas p/Revalidar XML"	,aParam3[5],"",".T.","",".T.",20,.F.})
	Aadd(aPerg3,{4,"Rel.Diverg.R$ Tot.c/IPI/ST?",aParam3[6],"Imprime Rel.Div.c/ST/IPI?"  ,080,".T.",.F.})		
	Aadd(aPerg3,{1,"URL Consulta NF-e Sefaz"	,aParam3[7],"",".T.","",".T.",220,.F.})
	
	Aadd(aPerg3,{1,"Cód.Finais CFOPs p/Beneficiamento"	,aParam3[8],"",".T.","",".T.",120,.F.})
	Aadd(aPerg3,{1,"Cód.Finais CFOPs p/Devolução",aParam3[9],"",".T.","",".T.",120,.F.})
	 
	Aadd(aPerg3,{1,"CFs Saida XML sem Ped.Compra"	,aParam3[10],"",".T.","",".T.",120,.F.})
	Aadd(aPerg3,{1,"Conv.Poder3 CF X TES",aParam3[11],"",".T.","",".T.",120,.F.})
	              
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da Interface                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aTexto,{})
	aTexto[1] := "Esta rotina tem como objetivo ajuda-lo na configuração da integração do Protheus com o serviço Email. "+CRLF
	aTexto[1] += "O primeiro passo é configurar a conexão SMTP."
	
	aadd(aTexto,{})
	aTexto[2] := "Configuração Finalizada. "+CRLF
	DbSelectArea("SF4")
	If SF4->(FieldPos("F4_TESBONI")) == 0
		aTexto[2] += "Será necessário que seja criado o campo F4_TESBONI na Tabela SF4. "+CRLF
		aTexto[2] += "Tipo=Caracter Tamanho=3 Decimal=0 Mascara=@! Titulo=Tes Bonif. F3=SF4"+CRLF
		aTexto[2] += "Este campo tem a finalidade de converter Notas bonificadas, "+CRLF
		aTexto[2] += "alterando o TES Padrão (B1_TE) para o Código Convertido no SF4"+CRLF+CRLF
	Else
		aTexto[2] += "O Sistema está pronto para ser usado agora."
	Endif
	
	DEFINE WIZARD oWizard ;
		TITLE "Assistente de configuração da Central NF-e";
		HEADER "Atenção";
		MESSAGE "Siga atentamente os passos para a configuração de SMTP e POP.";
		TEXT aTexto[1] ;
		NEXT {|| .T.} ;
		FINISH {||.T.}
	
	CREATE PANEL oWizard  ;
		HEADER "Assistente de configuração da Central NF-e - SMTP";
		MESSAGE ""	;
		BACK {|| oWizard:SetPanel(2),.T.} ;
		NEXT {|| IsMailReady(1,aParam)} ;
		PANEL
		
	ParamBox(aPerg,"Central XML",@aParam,,,,,,oWizard:oMPanel[2],"TESTE",.T.,.T.)
	
	CREATE PANEL oWizard  ;
		HEADER "Assistente de configuração da Central NF-e - POP ";
		MESSAGE ""	;
		BACK {|| oWizard:SetPanel(2),.T.} ;
		NEXT {|| IsMailReady(2,aParam2)} ;
		PANEL
		
	ParamBox(aPerg2,"Central XML",@aParam2,,,,,,oWizard:oMPanel[3],"teste2",.T.,.T.)

	CREATE PANEL oWizard  ;
		HEADER "Assistente de configuração da Central NF-e - Paramêtros";
		MESSAGE ""	;
		BACK {|| oWizard:SetPanel(2),.T.} ;
		NEXT {|| sfVldPar(aParam3) } ;
		PANEL
		
	ParamBox(aPerg3,"Central XML",@aParam3,,,,,,oWizard:oMPanel[4],"teste2",.T.,.T.)

	CREATE PANEL oWizard  ;
		HEADER "Assistente de configuração da Central NF-e - Criação Tabelas";
		MESSAGE ""	;
		BACK {|| oWizard:SetPanel(2),.T.} ;
		NEXT {|| sfCreateTbl() } ;
		PANEL


	CREATE PANEL oWizard  ;
		HEADER "Assistente de configuração da Central NF-e";
		MESSAGE "";
		BACK {|| oWizard:SetPanel(2),.T.} ;
		FINISH {|| lOk := .T.} ;
		PANEL
	@ 010,010 GET aTexto[2] MEMO SIZE 270, 115 READONLY PIXEL OF oWizard:oMPanel[6]
	
	ACTIVATE WIZARD oWizard CENTERED
	
	Return .T.


Else
	// Se não for usuário Administrador verifica se existe o Parametro especifico
	// e aborta o acesso a rotina pois a rotina ainda não foi rodada por um Administrador para configurar devidamente o programa
	DbSelectArea("SX6")
	DbSetOrder(1)
	
	If !DbSeek(xFilial("SX6")+"XM_SMTP   ")
		Return .F.
	Endif

Endif

Return .T.


Static Function IsMailReady(nTipo,aParamet)
                                       

If nTipo == 1
	//Crio a conexão com o server STMP ( Envio de e-mail )
	oServer := TMailManager():New()

	// Usa SSL na conexao
	If aParamet[6]
		oServer:setUseSSL(.T.)
	Endif

  //oServer:init(cPopAddr	, cSMTPAddr	, cUser			, cPass		, 	cPOPPort	, cSMTPPort
	oServer:Init( ""		,Alltrim(aParamet[1]), Alltrim(aParamet[3])	,Alltrim(aParamet[4]),	0			, Val(aParamet[2]))

     
	//seto um tempo de time out com servidor de 1min
	If oServer:SetSmtpTimeOut( 60 ) != 0
		Conout( "Falha ao setar o time out" )
		Alert("Falha ao setar o TimeOut")
		Return .F.
	EndIf
         
	//realizo a conexão SMTP
	If oServer:SmtpConnect() != 0
		Conout( "Falha ao conectar" )    
		Alert("Falha ao Conectar")
		Return .F.
	EndIf
	
	// Realiza autenticacao no servidor
	If aParamet[7]
		nErr := oServer:smtpAuth(Alltrim(aParamet[3]), Alltrim(aParamet[4]))
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
	oMessage:cFrom 		:= aParamet[5]
	oMessage:cTo 		:= aParamet[5]
	oMessage:cSubject 	:= "Teste de Email de Configuração Central XML"
	oMessage:cBody 		:= "Email enviado para validação SMTP da Central XML"

	//Envio o e-mail
	If oMessage:Send( oServer ) != 0
		Conout( "Erro ao enviar o e-mail" )
		Alert("Erro ao Enviar email")
		Return .F.
	Else
		Alert("Email enviado para "+Alltrim(aParamet[5]))
	EndIf

	//Disconecto do servidor
	If oServer:SmtpDisconnect() != 0
		Conout( "Erro ao disconectar do servidor SMTP" )
		Alert("Erro ao desconectar do Servidor SMTP")
		Return .F.
	EndIf
	
	// Servidor SMTP
	PutMv("XM_SMTP",aParamet[1])
	// Porta SMTP 25/995
	PutMv("XM_SMTPPOR",aParamet[2])
	// Conta usuário SMTP
	PutMv("XM_SMTPUSR",aParamet[3])
	// Senha usuário SMTP
	PutMv("XM_PSWSMTP",aParamet[4])
	// Descrição Conta SMTP
	PutMv("XM_SMTPDES",aParamet[5])
	// Usa SSL
	PutMv("XM_SMTPSSL",aParamet[6])
	// Autenticação Requerida
	PutMv("XM_SMTPAUT",aParamet[7])
Else
	//Crio uma nova conexão, agora de POP  
	oServer	:= Nil
	
	oServer := TMailManager():New()
	
	//oMessage := TMailMessage():New()
	// Usa SSL na conexao
	If aParamet[5]
		oServer:setUseSSL(.T.)
	Endif
	//oServer:init(cPopAddr	 			, cSMTPAddr , cUser					, cPass				 , cPOPPort				, cSMTPPort
	oServer:Init( Alltrim(aParamet[1])	, ""		, Alltrim(aParamet[3])	,Alltrim(aParamet[4]), Val(aParamet[2]) 	, 0)
	
	
	If oServer:SetPopTimeOut( 30 ) != 0
		Conout( "Falha ao setar o time out" )
		Alert("Falha ao setar o TimeOut")
		Return .F.
	EndIf

	If oServer:PopConnect() != 0
		Conout( "Falha ao conectar" )    
		Alert("Falha ao conectar")
		Return .F.
	Else
		Alert("Conexão POP OK!")
	EndIf
    
	//Diconecto do servidor POP
	oServer:POPDisconnect()
	
	// Servidor POP
	PutMv("XM_POP",aParamet[1])
	// Porta POP3/POPS 110/465
	PutMv("XM_POPPORT",aParamet[2])
	// Conta usuário POP
	PutMv("XM_POPUSR",aParamet[3])
	// Senha usuário POP
	PutMv("XM_PSWPOP",aParamet[4])
	// Usa SSL
	PutMv("XM_POPSSL",aParamet[5])

Endif

Return .T.	    

Static Function sfVldPar(aParam3)

PutMv("XM_USRXMLN",aParam3[1])
PutMv("XM_USRXMLC",aParam3[2])
PutMv("XM_XPCNFE",aParam3[3])
PutMv("XM_MAILXML",aParam3[4])
PutMv("XM_SPEDEXC",aParam3[5])
PutMv("XM_PRCCIST",aParam3[6])
PutMv("XM_URLCSFZ",aParam3[7])
PutMv("XM_CFOPRET",aParam3[8])
PutMv("XM_CFOPDEV",aParam3[9])
PutMv("XM_CFNPCNF",aParam3[10])
PutMv("XM_RETPOD3",aParam3[11])

Return .T.

Static Function sfCreateTbl()
Local bError := ErrorBlock({|e| ConOut("Totvs Sped Services - Internal error:"+e:errorstack),DisarmTransaction(),MS_QUIT()})

If !MsgYesNo("Deseja realmente rodar o processo de criação/Atualização das Tabelas do Controle XML?")
	Return .T.
Endif
CursorWait()

If !lInitSped
	lInitSped := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura os parametros iniciais                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PUBLIC __TTSINUSE   := .T.
	PUBLIC __cLogSiga   :="NNNNNN"
	PUBLIC __TTSBREAK   := .f.
	PUBLIC __TTSPush    := {}
	Public __lFkInUse   := .F.
	PUBLIC __TTSCommit
	PUBLIC __lACENTO    := .F.
	PUBLIC __Language   := 'PORTUGUESE'
	PUBLIC lMsFinalAuto := .T.
	PUBLIC __LocalDriver:= "DBFCDX"
	SET DELETED ON
	SET SCOREBOARD OFF
	SET DATE BRITISH
	SET(4,"DD/MM/YYYY")	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega as tabelas                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	LoadDicSPED("CENTRALXML") // Tabela de arquivos XML recebidos automaticamente
	If Select("CENTRALXML") > 0
		CENTRALXML->(DbCloseArea())
	Endif
	LoadDicSPED("CENTRALXMLITENS") // Tabela de arquivos XML recebidos automaticamente
	If Select("CENTRALXMLITENS") > 0
		CENTRALXMLITENS->(DbCloseArea())
	Endif

EndIf                                                                              

CursorArrow()

MsgAlert("Processo finalizado!")

Return(.T.)



User Function DbSelArea(cTable,lClose,nIndice)
    
Default lClose 	:= .F.
Default nIndice := 1

If lClose
	If Select(cTable) <> 0
		DbSelectArea(cTable)
		DbCloseArea()
	Endif
Else
	If cTable == "CENTRALXMLITENS"
		If Select("CENTRALXMLITENS") <> 0
			DbSelectArea("CENTRALXMLITENS")
			DbSetOrder(nIndice)
		Else
			Use &("CENTRALXMLITENS") Alias &("CENTRALXMLITENS") SHARED NEW Via "TOPCONN"
			DbSetIndex("CENTRALXMLITENS01")
			DbSetNickName(OrdName(1),"CENTRALXMLITENS01")
			DbSetIndex("CENTRALXMLITENS02")
			DbSetNickName(OrdName(2),"CENTRALXMLITENS02")
			DbSetIndex("CENTRALXMLITENS03")
			DbSetNickName(OrdName(3),"CENTRALXMLITENS03")
			DbSelectArea("CENTRALXMLITENS")
			DbSetOrder(nIndice)
		Endif
	ElseIf cTable == "CENTRALXML"
		If Select("CENTRALXML") <> 0
			DbSelectArea("CENTRALXML")
			DbSetOrder(nIndice)
		Else
			Use &("CENTRALXML") Alias &("CENTRALXML") SHARED NEW Via "TOPCONN"
			DbSetIndex("CENTRALXML01")
			DbSetNickName(OrdName(1),"CENTRALXML01")
			DbSetIndex("CENTRALXML02")
			DbSetNickName(OrdName(2),"CENTRALXML02")
			DbSetIndex("CENTRALXML03")
			DbSetNickName(OrdName(3),"CENTRALXML03")
			DbSelectArea("CENTRALXML")
			DbSetOrder(nIndice)
		Endif
	ElseIf cTable == "CENTRALTMKC"
		If Select("CENTRALTMKC") <> 0
			DbSelectArea("CENTRALTMKC")
			DbSetOrder(nIndice)
		Else
			Use &("CENTRALTMKC") Alias &("CENTRALTMKC") SHARED NEW Via "TOPCONN"
			DbSetIndex("CENTRALTMKC01")
			DbSetNickName(OrdName(1),"CENTRALTMKC01")
			DbSetIndex("CENTRALTMKC02")
			DbSetNickName(OrdName(2),"CENTRALTMKC02")
			DbSetIndex("CENTRALTMKC03")
			DbSetNickName(OrdName(2),"CENTRALTMKC03")
			DbSelectArea("CENTRALTMKC")
			DbSetOrder(nIndice)
		Endif
	ElseIf cTable == "SPED050"
		If Select("SPED050") <> 0
			DbSelectArea("SPED050")
		Else
			Use &("SPED050") Alias &("SPED050") SHARED NEW Via "TOPCONN"
			DbSelectArea("SPED050")                  
		Endif
	ElseIf cTable == "SPED054"
		If Select("SPED054") <> 0
			DbSelectArea("SPED054")
		Else
			Use &("SPED054") Alias &("SPED054") SHARED NEW Via "TOPCONN"
			DbSelectArea("SPED054")				
			DbSetIndex("SPED05401")
			DbSetNickName(OrdName(1),"SPED05401")
			DbSetIndex("SPED05402")
			DbSetNickName(OrdName(2),"SPED05402")
			DbSetIndex("SPED05403")
			DbSetNickName(OrdName(3),"SPED05403")
			DbSelectArea("SPED054")				
			DbSetOrder(nIndice)
		Endif		
	Endif
Endif


Static Function LoadDicSped(cTable)

Local aCampos := {}
Local aArqStru:= {}
Local aIndices:= {}
Local aTemp   := {}

Local cUnique := ""
Local cDriver := RDDSPED
Local cOrd    := ""
Local cOrdName:= ""

Local cDataBase := ""
Local cAlias    := ""
Local cServer   := ""
Local cConType  := ""
Local cHasMapper:= ""
Local cProtect  := ""
Local CTSerial:= ""

Local nPort     := 0
Local nX

Local lBuildIndex:= .F.
Local lUnique
Local lCreate := .F.

Do Case
	Case cTable == "CENTRALXML"
		
		cUnique := "XML_CHAVE"
		
		Aadd(aCampos,{"XML_CHAVE ","C",250,0})  // Chave NFe
		Aadd(aCampos,{"XML_CFROM ","C",250,0})	// Enviado por
		Aadd(aCampos,{"XML_CTO   ","C",250,0})	// Enviado para
		Aadd(aCampos,{"XML_SUBJEC","C",250,0})	// Assunto      
		Aadd(aCampos,{"XML_BODY  ","M",010,0})	// Corpo email
		Aadd(aCampos,{"XML_NROATT","N",002,0})	// Numero Anexos
		Aadd(aCampos,{"XML_ARQ   ","M",010,0})	// Arquivo Xml	
		Aadd(aCampos,{"XML_ATT2  ","M",010,0})  // Segundo Arquivo
		Aadd(aCampos,{"XML_ATT3  ","M",010,0})  // Terceiro Anexo
		Aadd(aCampos,{"XML_EMIT  ","C",014,0})  // Cgc do Emitente		
		Aadd(aCampos,{"XML_NUMNF ","C",014,0})  // Serie e Numero nota
		Aadd(aCampos,{"XML_NOMEMT","C",100,0})  // Nome emitente
		Aadd(aCampos,{"XML_MUNMT","C",100,0})   // Municipio Emitente
		Aadd(aCampos,{"XML_EMISSA","D",008,0})	// Data Emissao NFe
		Aadd(aCampos,{"XML_DEST  ","C",014,0})	// CCG Destinatario	
		Aadd(aCampos,{"XML_NOMEDT","C",100,0})  // Nome Destinatario
		Aadd(aCampos,{"XML_MUNDT","C",100,0})   // Municipio Destinatario
		Aadd(aCampos,{"XML_RECEB ","D",008,0})	// Data Recebimento	
		Aadd(aCampos,{"XML_HORREC","C",008,0})  // Hora Recebimento
		Aadd(aCampos,{"XML_USRREC","C",030,0})	// Usuário que processou recebimento de email
		Aadd(aCampos,{"XML_CONFER","D",008,0})	// Data Conferencia Sefaz
		Aadd(aCampos,{"XML_HORCON","C",008,0})  // Hora Conferencia Sefaz
		Aadd(aCampos,{"XML_USRCON","C",030,0})	// Usuário que efetuou a 1 conferencia Sefaz
		Aadd(aCampos,{"XML_LANCAD","D",008,0})	// Data Lançamento
		Aadd(aCampos,{"XML_HORLAN","C",008,0})  // Hora Lançamento            
		Aadd(aCampos,{"XML_USRLAN","C",030,0})  // Usuário que Efetuou o lançamento do Documento como pré nota ou Nota fiscal
		Aadd(aCampos,{"XML_KEYF1" ,"C",050,0})  // Chave SF1 F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA
		Aadd(aCampos,{"XML_REJEIT","D",008,0})	// Data da Rejeicao
		Aadd(aCampos,{"XML_USRREJ","C",030,0})  // Usuário que Efetuou a rejeição da Nota fiscal
		Aadd(aCampos,{"XML_CONFCO","D",008,0})	// Data da Conferencia compras
		Aadd(aCampos,{"XML_HORCCO","C",008,0})  // Hora que o XML foi concluido na conferencia para liberação para o lançamento da mesma
		Aadd(aCampos,{"XML_USRCCO","C",030,0})  // Usuário que efetuou a conferência para liberação para lançamento da nota
		Aadd(aCampos,{"XML_PCOMPR","C",006,0})	// Ordem de compra
		Aadd(aCampos,{"XML_DTRVLD","D",008,0})  // Data da Revalidação do arquivo XML se o mesmo não foi cancelado depois de recebido
	    Aadd(aCampos,{"XML_TIPODC","C",001,0})	// Tipo de Documento - N-Normal;B=Beneficiamento;D=Devolução
	    	                                                           		
		Aadd(aIndices,{cUnique,"PK"})
		Aadd(aIndices,{"XML_EMIT+DTOS(XML_EMISSA)","01"})
		Aadd(aIndices,{"XML_DEST+DTOS(XML_RECEB)","02"})
		Aadd(aIndices,{"XML_KEYF1+XML_DEST+XML_CHAVE","03"})

	Case cTable == "CENTRALXMLITENS"
		
		cUnique := "XIT_CHAVE+XIT_CODNFE+XIT_ITEM"
		
		Aadd(aCampos,{"XIT_CHAVE ","C",250,0})  // Chave NFe
		Aadd(aCampos,{"XIT_ITEM  ","C",004,0})	// Item NF
		Aadd(aCampos,{"XIT_CODNFE","C",030,0})	// Código Produto no Xml
		Aadd(aCampos,{"XIT_CODPRD","C",015,0})	// Código Produto no Protheus
		Aadd(aCampos,{"XIT_DESCRI","C",050,0})	// Descrição Produto no Xml
		Aadd(aCampos,{"XIT_QTENFE","N",010,2})	// Quantidade no Xml
		Aadd(aCampos,{"XIT_UMNFE ","C",015,0})  // Unidade Medida no Xml
		Aadd(aCampos,{"XIT_PRCNFE","N",012,2})  // Preço Unitário
		Aadd(aCampos,{"XIT_QTE   ","N",010,2})	// Quantidade no Sistema
		Aadd(aCampos,{"XIT_UM	 ","C",015,0})  // Unidade Medida 
		Aadd(aCampos,{"XIT_PRUNIT","N",012,2})  // Preço Unitário
		Aadd(aCampos,{"XIT_TOTAL ","N",012,2})  // Valor Total do Item
		Aadd(aCampos,{"XIT_TOTNFE","N",012,2})  // Valor Total do Item no Xml
		Aadd(aCampos,{"XIT_TES 	 ","C",003,0})  // Código do TES
		Aadd(aCampos,{"XIT_CF	 ","C",005,0})	// Código do CFOP
		Aadd(aCampos,{"XIT_CFNFE ","C",005,0})	// Código do CFOP no Xml
		Aadd(aCampos,{"XIT_NCM	 ","C",010,0})	// Código do NCM
		Aadd(aCampos,{"XIT_PEDIDO","C",006,0})	// Número Pedido Compra
		Aadd(aCampos,{"XIT_ITEMPC","C",004,0})	// Item pedido compra
		Aadd(aCampos,{"XIT_VALDES","N",009,2})	// Valor do Desconto
		Aadd(aCampos,{"XIT_BASICM","N",012,2})	// Base Calculo Icms
		Aadd(aCampos,{"XIT_PICM  ","N",005,2})  // Percentual Icms
		Aadd(aCampos,{"XIT_VALICM","N",012,2})	// Valor do Icms

		Aadd(aCampos,{"XIT_BASIPI","N",012,2})	// Base Calculo IPI
		Aadd(aCampos,{"XIT_PIPI  ","N",005,2})  // Percentual IPI
		Aadd(aCampos,{"XIT_VALIPI","N",012,2})	// Valor do IPI

		Aadd(aCampos,{"XIT_BASPIS","N",012,2})	// Base Calculo PIS
		Aadd(aCampos,{"XIT_PPIS  ","N",005,2})  // Percentual PIS
		Aadd(aCampos,{"XIT_VALPIS","N",012,2})	// Valor do PIS

		Aadd(aCampos,{"XIT_BASCOF","N",012,2})	// Base Calculo Cofins
		Aadd(aCampos,{"XIT_PCOF  ","N",005,2})  // Percentual Cofins
		Aadd(aCampos,{"XIT_VALCOF","N",012,2})	// Valor do Cofins

		Aadd(aCampos,{"XIT_BASRET","N",012,2})	// Base Calculo Icms Retido
		Aadd(aCampos,{"XIT_PMVA  ","N",007,2})  // Percentual Icms Retido
		Aadd(aCampos,{"XIT_VALRET","N",012,2})	// Valor do Icms Retido

		Aadd(aCampos,{"XIT_CLASFI","C",003,0})  // Classificação fiscal
		Aadd(aCampos,{"XIT_KEYSD1","C",030,0})  // Chave SD1 - D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		
		Aadd(aIndices,{cUnique,"PK"})
		Aadd(aIndices,{"XIT_CHAVE+XIT_ITEM+XIT_CODNFE","01"})
		Aadd(aIndices,{"XIT_CHAVE+XIT_KEYSD1","02"})
	
EndCase
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RDD CTRE                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cDriver == "CTREECDX"
	If (AllTrim(upper(GetPvProfString("general","ctreemode","local",GetAdv97()))) $ "SERVER,BOUNDSERVER")
		CTSerial := CTSerialNumber()
		If !CTChkSerial(CTSerial)
			UserException('CTreeServer license limited to ISAM / SXS files only. Serial Number ['+CTSerial+']')
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ RDD TOP                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cDriver == "TOPCONN"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Conecta no TopConn                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If __nConecta == Nil
		cDataBase  := GetPvProfString("TopConnect","DataBase","ERROR",GetADV97())
		cAlias	   := GetPvProfString("TopConnect","Alias","ERROR",GetADV97())
		cServer	   := GetPvProfString("TopConnect","Server","ERROR",GetADV97())
		cConType   := Upper(GetPvProfString("TopConnect","Contype","TCPIP",GetADV97()))
		cHasMapper := Upper(GetPvProfString("TopConnect","Mapper","ON",GetADV97()))
		cProtect   := GetPvProfString("TopConnect","ProtheusOnly","0",GetADV97())
		nPort      := Val(GetPvProfString("TopConnect","Port","0",GetADV97()))
		
		cDataBase  := GetSrvProfString("TopDataBase",cDataBase)
		cAlias	   := GetSrvProfString("TopAlias",cAlias)
		cServer	   := GetSrvProfString("TopServer",cServer)
		cConType   := Upper(GetSrvProfString("TopContype",cConType))
		cHasMapper := Upper(GetSrvProfString("TopMapper",cHasMapper))
		cProtect   := GetSrvProfString("TopProtheusOnly",cProtect)
		nPort      := Val(GetSrvProfString("TopPort",StrZero(nPort,4,0)))
		
		If cProtect == "1"
			cProtect := "@@__@@"    //Assinatura para o TOP
		Else
			cProtect := ""
		EndIf
		If ! ( AllTrim(cContype) $ 'TCPIP/NPIPE' )
			Conout('TOPConnect (INI Protheus Server)','Contype: '+cConType)
			Ms_Quit()
		EndIf
		If ( 'ERROR' $ cDatabase )
			ConOut('TOPConnect (INI Protheus Server)', 'Database: '+cDatabase)
			Ms_Quit()
		EndIf
		If ( 'ERROR' $ cAlias )
			ConOut('TOPConnect (INI Protheus Server)', 'Alias: '+cAlias)
			Ms_Quit()
		EndIf
		If ( 'ERROR' $ cServer )
			ConOut('TOPConnect (INI Protheus Server)','Server: '+cServer )
			Ms_Quit()
		EndIf
		TCConType(cConType)
		If (("AS" $ cAlias) .And. ("400" $ cAlias))
			While ( !KillApp() .and. !GlbLock() )
				Sleep(100)
			EndDo
			__nConecta := TCLink(cDataBase,cServer,nPort)
			GlbUnlock()
		Else
			__nConecta := -1
			__nConecta := TCLink(cProtect+"@!!@"+cDataBase+"/"+cAlias,cServer,nPort)
			If (__nConecta < 0)
				Do Case
					Case ( __nConecta == -34 )
						ConOut("No license") //TOPConnect - Excedeu licenças.
						Ms_Quit()
					Case ( __nConecta == -99 )
						ConOut("incompatible version") //"A versao do TOPConnect e incompativel com o servidor Protheus, atualize o TOPConnect"
						Ms_Quit()
					OtherWise
						ConOut("Connection failed") // 'TOPConnect - Falha de conexao' ## Erro
						Ms_Quit()
				EndCase
			EndIf
			TcInternal( 8, "Totvs Services SPED Gateway" )
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao de tabelas conforme definicao                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( LockByName(cTable+cDriver,.F.,.F.,.T.) )
		If !MSFile(RetArq(cDriver,cTable,.T.), ,cDriver)
			lCreate := .T.
			If TcSrvType() == "AS/400"
				TcCommit(5,.T.)
				DbCreate(cTable,aCampos,"TOPCONN")
				TcCommit(5,.F.)
				TcSysExe("CHGOBJOWN OBJ("+AllTrim(cTable)+") OBJTYPE(*FILE) NEWOWN(QUSER)")
			Else
				DBCreate(cTable, aCampos, cDriver)
			EndIf             ,
			DbUseArea(.T.,cDriver,cTable,'__CREATETMP',.F.)
			If !Empty(cUnique) .And. !"AS"$TCSrvType()
				cUnique := ClearKey(cUnique)
				lUnique := TcCanOpen(cTable,cTable+"_UNQ")
				If ( lUnique .And. Empty(cUnique) ) .Or. (!lUnique .and. !Empty(cUnique) )
					If TcUnique(cTable,cUnique) <> 0
						UserException('Unique index creation error on table '+cTable+'. '+TCSQLError()+" or table is in use by other connection")
					EndIf
				EndIf
			EndIf
			DbCloseArea()
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se houve alteracao na tabela                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Use &(cTable) Alias &(cTable) SHARED NEW Via cDriver
			aArqStru := dbStruct()
			dbCloseArea()
			If CompStru(aCampos,aArqStru)
				lBuildIndex := .T.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se houve alteracao na tabela                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aTemp := aCampos
				If aScan(aArqStru,{|x| AllTrim(x[1])=="DATE"})<>0 .And. aScan(aArqStru,{|x| AllTrim(x[1])=="DATE_NFE"})==0
					aadd(aCampos,{"DATE","D",8,0})
					aadd(aCampos,{"TIME","C",8,0})
				EndIf
				If !TcAlter(cTable,aArqStru,aCampos)
					UserException('Alter table in '+cTable+' is not possible!')
				ElseIf aScan(aCampos,{|x| AllTrim(x[1])=="DATE"})<>0 .And. aScan(aCampos,{|x| AllTrim(x[1])=="DATE_NFE"})==0
					TcSqlExec("UPDATE "+cTable+" SET DATE_NFE = DATE ")
					TcSqlExec("UPDATE "+cTable+" SET TIME_NFE = TIME ")
					If !TcAlter(cTable,aArqStru,aTemp)
						UserException('Alter table in '+cTable+' is not possible!')
					EndIf
				EndIf
		    EndIf
		EndIf
		UnLockByName(cTable+cDriver,.F.,.F.,.T.)
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ RDD CTREE                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Criacao de tabelas conforme definicao                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !MSFile(RetArq(cDriver,cTable,.T.), ,cDriver)
		If ( LockByName(cTable+cDriver,.F.,.F.,.T.) )
			lCreate := .T.
			cOrdName := FileNoExt(cTable)+RetIndExt()
			If ( File(cOrdName) )
				If ( FErase(cOrdName) <> 0 )
					ConOut("Delete Index error. File in use.")
					Ms_Quit()
				EndIf
			EndIf
			DBCreate(cTable, aStruct, cDriver)
			UnLockByName(cTable+cDriver,.F.,.F.,.T.)
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se os indices estao criados                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cOrd := "00"
For nX := 1 To Len(aIndices)
	cOrd     := Soma1(cOrd)
	cOrdName := RetArq(cDriver,cTable+cOrd,.F.)
	If ( !MsFile(cTable,cOrdName,cDriver) )
		lBuildIndex := .T.
		Exit
	EndIf
Next nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao de indices conforme definicao                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lBuildIndex
	If ( LockByName(cTable+cDriver,.F.,.F.,.T.) )
		DbUseArea(.T.,cDriver,cTable,'__CREATETMP',.F.)
		dbClearIndex()
		If !NetErr()
			If cDriver == "TOPCONN"
				cOrd := "00"
				For nX := 1 To Len(aIndices)
					cOrd := Soma1(cOrd,2)
					cOrdName := cTable+cOrd
					If ( TcCanOpen(cTable,cOrdName) )
						cQuery := 'DROP INDEX ' + cTable + '.' + cOrdName
						If TcSqlExec( cQuery ) <> 0
							cQuery := 'DROP INDEX ' + cOrdName
							TcSqlExec('DROP INDEX ' + cOrdName)
						EndIf
                	EndIf															
				Next nX
				TcRefresh( cTable )
				cOrd := "00"
				For nX := 1 To Len(aIndices)
					cOrd := Soma1(cOrd,2)
					cOrdName := cTable+cOrd
					If ( !TcCanOpen(cTable,cOrdName) )
						INDEX ON &(ClearKey(aIndices[nX][1])) TO &(cOrdName)
                	EndIf
				Next nX				
			Else
				If lBuildIndex
					CTreeDelIdx()
					cOrd := "00"
					For nX := 1 To Len(aIndices)
						cOrd     := Soma1(cOrd)
						cOrdName := cTable+cOrd+RetIndExt()
						INDEX ON &(aIndices[nX][1]) TAG &(cOrdName) TO &(FileNoExt(cTable))
					Next nX
				EndIf
			EndIf
			DbCloseArea()
		EndIf
		UnLockByName(cTable+cDriver,.F.,.F.,.T.)
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura de tabelas                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Use &(cTable) Alias &(cTable) SHARED NEW Via cDriver
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura de indices                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cDriver == "TOPCONN"
	cOrd := "00"
	For nX := 1 To Len(aIndices)
		cOrd := Soma1(cOrd,2)
		cOrdName := cTable+cOrd
		DbSetIndex(cOrdName)
		DbSetNickName(OrdName(nX),cOrdName)
	Next nX
Else
	nX   := 1
	cOrd := "00"
	While ( ! Empty(OrdName(nX)) )
		cOrdName := cTable+cOrd
		If ( nX > Len(aIndices) )
			ConOut("Index OF "+cTable+" Corrupted")
			Ms_Quit()
		EndIf
		DbSetNickName(OrdName(nX),cOrdName)
		nX++
	EndDo
EndIf
DbSetOrder(1)

Return(.T.)

Static Function CompStru(aTarget,aSource)
Local nI		:= 0
Local nPx		:= 0
Local lUnlike	:= .F.
Local nIntS, nIntT
For nI := 1 To Len( aTarget )
	nPx := Ascan( aSource, { |x| AllTrim( x[1] ) == AllTrim( aTarget [nI][1]) } )
	If ( nPx == 0 )
		lUnlike	:= .T.
	Else
		nIntS := aSource[nPx,3]-aSource[nPx,4]
		nIntT := aTarget[ni,3]-aTarget[ni,4]
		If aSource[nPx,2] != "N"
			nIntS := aSource[nPx,3]
		EndIf
		If aTarget[ni,2] != "N"
			nIntT := aTarget[ni,3]
		EndIf
		If ( aSource [nPx][2] == aTarget[nI][2] )
			If nIntT == nIntS
				If ( aSource [nPx][4] <> aTarget[nI][4] )
					lUnlike	:= .T.
				EndIf
			Else
				If ( nIntS > nIntT )
				EndIf
				lUnlike	:= .T.
			EndIf
		Else
            lUnlike	:= .T.
		EndIf
	EndIf
	If ( lUnlike )
		Exit
	EndIf
Next
If ( ! lUnlike )
	For nI := 1 To Len( aSource )
		nPx := Ascan( aTarget, { |x| AllTrim( x[1] ) == AllTrim( aSource [nI][1]) } )
		If ( nPx == 0 )
			lUnLike := .T.
		EndIf
	Next
EndIf
Return( lUnlike )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FsLoadTxt ³ Autor ³Eduardo Riera          ³ Data ³24.10.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de leitura de arquivo texto para anexar ao layout    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExC1: Arquivo texto                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Nome do arquivo texto com path                       ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FsLoadTXT(cFileXml)

Local cTexto     := ""
Local nHandle    := 0
Local nTamanho   := 0
nHandle := FOpen(cFileXml)
If nHandle > 0
	nTamanho := Fseek(nHandle,0,FS_END)
	FSeek(nHandle,0,FS_SET)
	FRead(nHandle,@cTexto,nTamanho)
	FClose(nHandle)
EndIf
Return(cTexto)


