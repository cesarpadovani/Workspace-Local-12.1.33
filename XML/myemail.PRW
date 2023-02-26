#include "Protheus.ch"
#include "topconn.ch"
#INCLUDE "XmlXFun.Ch"
#include "spednfe.ch"

User Function myEMail(lConsultaSefaz)

Local 	oServer
Local 	oMessage
Local 	oDlg
Local 	aSize 		:= MsAdvSize( .T., .F., 400 )		// Size da Dialog
Local   nAltura 	:= aSize[6]/2.2
Local 	nNumMsg 	:= 0
Local 	nTam    	:= 0
Local 	nI      	:= 0
Local	cChave 		:= ""
Local	cDirNfe    	:= IIf(IsSrvUnix(),"/Nf-e/", "\Nf-e\")
Local 	cDirMailNfe := IIf(IsSrvUnix(),"/Nf-e/Mail/", "\Nf-e\Mail\")
Local 	cDirSchema 	:= IIf(IsSrvUnix(),"/schemas/", "\schemas\")
Local	cTipoDoc	:= "N"	// Variavel para identificar o tipo de Nota fiscal N=Normal;B=Beneficiamento;D=Devolução

Default lConsultaSefaz := .T.

If !stControle(.F.)
	Return
Endif


MakeDir(cDirNfe)
MakeDir(cDirMailNfe)

//Crio uma nova conexão, agora de POP
oServer := TMailManager():New()
oMessage := TMailMessage():New()
// Usa SSL na conexao
If GetMv("XM_POPSSL")
	oServer:setUseSSL(.T.)
Endif

oServer:Init( Alltrim(GetMv("XM_POP")),"", Alltrim(GetMv("XM_POPUSR"))	,Alltrim(GetMv("XM_PSWPOP")), GetMv("XM_POPPORT") ,0)

If oServer:SetPopTimeOut( 60 ) != 0
	Conout( "Falha ao setar o time out" )
	Return .F.
EndIf

If oServer:PopConnect() != 0
	Conout( "Falha ao conectar" )
	Return .F.
EndIf

//Recebo o número de mensagens do servidor
oServer:GetNumMsgs( @nNumMsg )
nTam := nNumMsg

If nTam == 0
	MsgAlert("Não há e-mails a receber!")
Endif
nContOk	:= 0
//If nTam >= 100
//	nTam	:= 100	// Apesar de poder existir mais emails na caixa de Entrada, limito a 100 emails para evitar sobre carga da rotina
//Endif
ProcRegua(nTam)
For nI := 1 To nTam
	IncProc("Recebendo email "+Alltrim(Str(nI)) + " / " + Alltrim(Str(nTam))+ ". Aguarde!" )
	//Limpo o objeto da mensagem
	oMessage:Clear()
	//Recebo a mensagem do servidor
	oMessage:Receive( oServer, nI )
	cChave	:= " "
	
	//Escrevo no server os dados do e-mail recebido
	Begin Transaction
	
	nXmlArq	:= 0
	nContOk++
	
	For y := 1 To oMessage:getAttachCount()
		cText 	:= oMessage:getAttach(y)
		
		// Se o anexo contiver tag de arquivo xml
		//              Autorizado o uso da NF-e
		//                                                                                                              // Padrao GP // Considerar string de autorizacao em Maiusculo
		If At("<xMotivo>Autorizado o uso da NF-e</xMotivo>",cText) > 0  .Or. At("<xMotivo>Autorizado",cText) > 0 .or. At("<xMotivo>AUTORIZADO O USO DA NF-E</xMotivo>",cText) > 0 .Or. At("<xMotivo>AUTORIZADO",cText) > 0
			nXmlArq := y
			cAviso	:= ""
			cErro	:= ""
			cText := StrTran(cText,"_","-")
			cText := StrTran(cText,">>",">")
			cText := StrTran(cText,"<<","<")
			
			If File(cDirSchema+"NFe_v"+NfeIdSPED(cText,"versao")+"NoSig.xsd")
				If XmlSVldSch ( cText, cDirSchema+"NFe_v"+NfeIdSPED(cText,"versao")+".xsd", @cErro, @cAviso )
					MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
					Loop
				Endif
			ElseIf File(cDirSchema+"NFe_v"+NfeIdSPED(cText,"versao")+".xsd")
				If XmlSVldSch ( cText, cDirSchema+"NFe_v"+NfeIdSPED(cText,"versao")+".xsd", @cErro, @cAviso )
					MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
					Loop
				Endif
			Endif
			
			cAviso 	:= ""
			cErro	:= ""
			
			oNfe := XmlParser(cText,"_",@cAviso,@cErro)
			
			
			If !Empty(cErro)
				MsgAlert(cErro+chr(13)+cAviso,"Erro ao validar schema do Xml")
				Loop
			Endif
			
			If Type("oNFe:_NfeProc")<> "U"
				oNF := oNFe:_NFeProc:_NFe
			ElseIf Type("oNFe:")<> "U"
				oNF := oNFe:_NFe
			Else
				MsgAlert("Não foi possível importar email do texto: "+cText)
				Exit
			Endif
			
			
			oIdent     	:= oNF:_InfNfe:_IDE
			oEmitente  	:= oNF:_InfNfe:_Emit
			oDestino   	:= oNF:_InfNfe:_Dest
			
			If Type("oNFe:_NfeProc:_protNFe:_infProt:_chNFe")<> "U"
				oNF := oNFe:_NFeProc:_NFe
				cChave	:= oNFe:_NfeProc:_protNFe:_infProt:_chNFe:TEXT
			Else
				cChave	:= " "
			Endif
			
			cTipoDoc	:= "N"	// Atribuo Default N=Normal
			// Salvo o arquivo
			SAVE oNfe XMLFILE ("\Nf-e\"+Alltrim(cChave)+".xml")
			oMessage:SAVE(cDirMailNfe+Alltrim(cChave)+".eml")
			
			U_DbSelArea("CENTRALXML",.F.,1)
			Set Filter to
			
			lExistChv := !DbSeek(cChave)
			
			RecLock("CENTRALXML",lExistChv)
			CENTRALXML->XML_CFROM 	:= oMessage:cFrom
			CENTRALXML->XML_CTO		:= oMessage:cTo
			CENTRALXML->XML_SUBJECT 	:= oMessage:cSubject
			CENTRALXML->XML_BODY		:= oMessage:cBody
			CENTRALXML->XML_NROATT	:= oMessage:GetAttachCount()
			
			CENTRALXML->XML_ARQ		:= cText
			//CENTRALXML->XML_ATT2		:= Iif(nXmlArq==1 .And. oMessage:getAttachCount()>1,oMessage:getAttach(2),"")	//					"\Nf-e\"+Alltrim(cChave)+".xml" // Caminho do email
			//CENTRALXML->XML_ATT3		:= Iif(nXmlArq==2,oMessage:getAttach(1),"")
			CENTRALXML->XML_CHAVE		:= cChave
			CENTRALXML->XML_EMIT			:= oEmitente:_CNPJ:TEXT
			CENTRALXML->XML_NOMEMT		:= oEmitente:_xNome:TEXT // Nome emitente
			CENTRALXML->XML_MUNMT		:= oEmitente:_enderEmit:_xMun:TEXT+"/"+oEmitente:_enderEmit:_UF:TEXT // Municipio Emitente
			
			CENTRALXML->XML_NUMNF		:= Padr(oIdent:_serie:TEXT,TamSX3("F1_SERIE")[1]) + Right(StrZero(0,(TamSX3("F1_DOC")[1]) -Len(Trim(oIdent:_nNF:TEXT)) )+oIdent:_nNF:TEXT,TamSX3("F1_DOC")[1])
			cData:=Alltrim(oIdent:_dEmi:TEXT)
			dData:=CTOD(Right(cData,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
			CENTRALXML->XML_EMISSA		:= dData
			CENTRALXML->XML_DEST			:= oDestino:_CNPJ:TEXT
			CENTRALXML->XML_NOMEDT		:= oDestino:_xNome:TEXT  // Nome Destinatario
			CENTRALXML->XML_MUNDT		:= oDestino:_enderDest:_xMun:TEXT + "/"+oDestino:_enderDest:_UF:TEXT // Municipio Destinatario
			
			nPxCompra	:= At("<compra><xPed>",cText)
			If nPxCompra > 0
				CENTRALXML->XML_PCOMPR	:= Substr(cText,nPxCompra+14,6)
			Endif
			
			CENTRALXML->XML_RECEB		:= Date()
			CENTRALXML->XML_HORREC		:= Time()
			CENTRALXML->XML_USRREC		:= Padr(cUserName,30)
			
			If !Empty(cChave) .And. lConsultaSefaz
				cNavegado	:= Alltrim(GetMv("XM_URLCSFZ"))+cChave
				
				Define MsDialog oDlg From 0,0 TO aSize[6] , aSize[5]  Pixel Title "Web Browser"
				@ 005,010 Say "Chave da NF-e / Use CTRL+C para copiar, e depois colar na página abaixo" of oDlg Pixel
				@ 015,010 MsGet oNavegado var cChave Size 300,05 Of oDlg Pixel
				oTIBrowser:= TIBrowser():New(025,010, aSize[5]/2.04,nAltura, cNavegado, oDlg )
				
				@ 010, 350 Button oBtnPrint PROMPT "Confirmar Consulta" Size 70,10 Action (CENTRALXML->XML_CONFER := Date(),CENTRALXML->XML_HORCON := Time(),CENTRALXML->XML_USRCON := Padr(cUserName,30),oDlg:End()) Of oDlg Pixel
				@ 010, 440 Button oBtnPrint PROMPT "Imprimir" Size 40,10 Action oTIBrowser:Print() Of oDlg Pixel
				@ 010, 490 Button oBtnSair PROMPT "Sair" Size 40,10 Action(oDlg:End()) Of oDlg Pixel
				Activate MsDialog oDlg Centered
			Else
				cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
				// Trecho para validar autorização da NF
				cMensagem:= ""
				oWs:= WsNFeSBra():New()
				oWs:cUserToken   := "TOTVS"
				oWs:cID_ENT    := StaticCall(SPEDNFE,GetIdEnt)
				ows:cCHVNFE		 := cChave
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
						CENTRALXML->XML_CONFER := Date()
						CENTRALXML->XML_HORCON := Time()
						CENTRALXML->XML_USRCON := Padr("TSS-Central Xml-"+cUserName,30)
					Else
						Aviso(STR0107,cMensagem,{"Nota fiscal não Autorizada na SEFAZ"},3)
					Endif
					//	Aviso(STR0107,cMensagem,{STR0114},3)
				Else
					Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{STR0114},3)
				EndIf
			Endif
			
			MsUnlock()
			
			oDet       	:= oNF:_InfNfe:_Det
			
			oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
			
			
			IIf(Type("oNFe:_InfNfe:_compra:_xPed")=="U",Nil,cPedCompra := oNF:_InfNfe:_compra:_xPed:TEXT)
			
			// Inicio loop nos itens da nota
			For nX := 1 To Len(oDet)
				// Verifico se os 3 digitos finais do CFOP estão na lista de CFOPs que identificam a nota como nota de Beneficiamento
				If Substr(oDet[nX]:_Prod:_CFOP:TEXT,2,3) $ GetMv("XM_CFOPRET")
					cTipoDoc	:= "B"                                            
				// Verifico se os 3 digitos finais do CFOP da nota estão na lista de CFOPs que identifica a nota como de Devolução
				ElseIf Substr(oDet[nX]:_Prod:_CFOP:TEXT,2,3) $ GetMv("XM_CFOPDEV")
					cTipoDoc	:= "D"
				Endif	
				
				U_DbSelArea("CENTRALXMLITENS",.F.,1)
				Set Filter To
				lExistChv := !DbSeek(Padr(cChave,250)+Padr(oDet[nX]:_Prod:_cProd:TEXT,30)+StrZero(nX,4))
				RecLock("CENTRALXMLITENS",lExistChv)
				
				CENTRALXMLITENS->XIT_CHAVE		:= cChave
				CENTRALXMLITENS->XIT_ITEM		:= StrZero(nX,4)
				CENTRALXMLITENS->XIT_CODNFE		:= oDet[nX]:_Prod:_cProd:TEXT
				CENTRALXMLITENS->XIT_DESCRI		:= oDet[nX]:_Prod:_xProd:TEXT
				If Type("oDet[nX]:_Prod:_NCM") <> "U"
					CENTRALXMLITENS->XIT_NCM			:= oDet[nX]:_Prod:_NCM:TEXT
				Endif
				CENTRALXMLITENS->XIT_CFNFE		:= oDet[nX]:_Prod:_CFOP:TEXT
				CENTRALXMLITENS->XIT_QTENFE		:= Val(oDet[nX]:_Prod:_qCom:TEXT)
				CENTRALXMLITENS->XIT_PRCNFE		:= Val(oDet[nX]:_Prod:_vUnCom:TEXT)
				CENTRALXMLITENS->XIT_UMNFE		:= oDet[nX]:_Prod:_uCom:TEXT
				CENTRALXMLITENS->XIT_TOTNFE		:= Val(oDet[nX]:_Prod:_vProd:TEXT)
				
				
				If Type("oDet[nX]:_Prod:_vDesc")<> "U"
					CENTRALXMLITENS->XIT_VALDES  := Val(oDet[nX]:_Prod:_vDesc:TEXT)
				Endif
				
				
				Do Case
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS00")<> "U"
						oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS00
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS10")<> "U"
						oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS10
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS20")<> "U"
						oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS20
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS30")<> "U"
						oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS30
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS40")<> "U"
						oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS40
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS51")<> "U"
						oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS51
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS60")<> "U"
						oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS60
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS70")<> "U"
						oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS70
					Case Type("oDet[nX]:_Imposto:_ICMS:_ICMS90")<> "U"
						oICM:=oDet[nX]:_Imposto:_ICMS:_ICMS90
				EndCase
				
				If Type("oICM")<> "U"
					If Type("oICM:_vBC") <> "U"
						CENTRALXMLITENS->XIT_BASICM		:= Val(oICM:_vBC:TEXT)
					Endif
					If Type("oICM:_pICMS") <> "U" .And. Val(oICM:_pICMS:TEXT) < 100
						CENTRALXMLITENS->XIT_PICM		:= Val(oICM:_pICMS:TEXT)
					Endif
					If Type("oICM:_vICMS") <> "U"
						CENTRALXMLITENS->XIT_VALICM		:= Val(oICM:_vICMS:TEXT)
					Endif
					If Type("oICM:_vBCST") <> "U"
						CENTRALXMLITENS->XIT_BASRET		:= Val(oICM:_vBCST:TEXT)
					Endif
					If Type("oICM:_pICMSST") <> "U"
						CENTRALXMLITENS->XIT_PMVA		:= Val(oICM:_pICMSST:TEXT)
					Endif
					If Type("oICM:_vICMSST") <> "U"
						CENTRALXMLITENS->XIT_VALRET		:= Val(oICM:_vICMSST:TEXT)
					Endif
					If Type("oICM:_orig") <> "U"
						CENTRALXMLITENS->XIT_CLASFI		:= Padr(Alltrim(oICM:_orig:TEXT)+Alltrim(oICM:_CST:TEXT),TamSX3("D1_CLASFIS")[1])
					Endif
				Endif
				// Efetua a gravação dos dados referente ao IPI
				If Type("oDet[nX]:_Imposto:_IPI:_IPITRIB")<> "U"
					oIPI:=oDet[nX]:_Imposto:_IPI:_IPITRIB
					If Type("oIPI:_vBC:TEXT")<>"U"
						CENTRALXMLITENS->XIT_BASIPI		:= Val(oIPI:_vBC:TEXT)
					EndIf
					If Type("oIPI:_pIPI:TEXT")<>"U"
						CENTRALXMLITENS->XIT_PIPI		:= Val(oIPI:_pIPI:TEXT)
					EndIf
					If Type("oIPI:_vIPI:TEXT")<>"U"
						CENTRALXMLITENS->XIT_VALIPI		:= Val(oIPI:_vIPI:TEXT)
					EndIf
				Endif
				
				// Efetua a gravação dos dados referente ao PIS
				If Type("oDet[nX]:_Imposto:_PIS:_PISAliq")<> "U" .And. Val(oDet[nX]:_Imposto:_PIS:_PISAliq:_pPIS:TEXT) < 100
					oPIS:=oDet[nX]:_Imposto:_PIS:_PISAliq
					CENTRALXMLITENS->XIT_BASPIS		:= Val(oPIS:_vBC:TEXT)
					CENTRALXMLITENS->XIT_PPIS		:= Val(oPIS:_pPIS:TEXT)
					CENTRALXMLITENS->XIT_VALPIS		:= Val(oPIS:_vPIS:TEXT)
				Endif
				
				// Efetua a gravação dos dados referente ao COFINS
				If Type("oDet[nX]:_Imposto:_COFINS:_COFINSAliq")<> "U" .And. Val(oDet[nX]:_Imposto:_COFINS:_COFINSAliq:_pCOFINS:TEXT) < 100
					oPIS:=oDet[nX]:_Imposto:_COFINS:_COFINSAliq
					CENTRALXMLITENS->XIT_BASCOF		:= Val(oPIS:_vBC:TEXT)
					CENTRALXMLITENS->XIT_PCOF		:= Val(oPIS:_pCOFINS:TEXT)
					CENTRALXMLITENS->XIT_VALCOF		:= Val(oPIS:_vCOFINS:TEXT)
				Endif
				
				MsUnlock()
			Next
			// Gravo o tipo de Nota
			U_DbSelArea("CENTRALXML",.F.,1)
			RecLock("CENTRALXML",.F.)
			CENTRALXML->XML_TIPODC	:= cTipoDoc
			MsUnlock()
			
		Endif
	Next y
	End Transaction
	
	oServer:DeleteMsg( nI )
Next

//Deleto todas as mensagens do servidor
//	For nI := 1 To nContOk
//		oServer:DeleteMsg( nI )
//	Next

//Diconecto do servidor POP
oServer:POPDisconnect()
stControle(.T.)

Return

Static Function stControle(lLibera)

Local	cQry	:= ""
Default lLibera := .F.

If !Empty(GetMv("XM_BLQPOP")) .And. !lLibera
	MsgAlert(GetMv("XM_BLQPOP"))
	Return .F.
ElseIf lLibera
	PutMv("XM_BLQPOP"," ")
Else
	PutMv("XM_BLQPOP","Rotina em uso pelo operador(a) "+Alltrim(cUserName)+" desde "+ Time()+ "."+Chr(13)+"Caso haja algum erro solicite que o CPD limpe o paramêtro XM_BLQPOP")
Endif
Return .T.
