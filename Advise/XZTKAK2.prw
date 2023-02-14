#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

User Function XZTKAK2()

cArquivo := cGetFile('Arquivo CSV|*.csv','Selecione o arquivo',0,'C:\',.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE,.T.)
If !Empty(cArquivo)

	If !File(cArquivo)
		MsgAlert("Arquivo ["+cArquivo+"] nใo encontrado.")
	Else
		Processa( {|| ProcImp(cArquivo) },"Aguarde" ,"Processando...")
	EndIf

EndIf

Return Nil	

Static Function ProcImp(cArquivo)
Local ni
Local lPriVez 	:= .T.
Local aCampos   := {}      
Local nX
Local xValor
Local nPos 

Local aLogs     := {}
Local cLinha	:= ""
Local lErro		:= .F.
Local cMensagem	:= ""
Local cPath     := ""
Local cFileLog  := ""

cArquivo := AllTrim(cArquivo)
                                      
aEstrut := AK2->(dbStruct())
cArqTMP := CriaTrab( aEstrut, .T.)
dbUseArea(.T.,,cArqTMP,"TRB",.F.,.F.)
IndRegua("TRB",  cArqTMP,"AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CC+AK2_CO+AK2_ITCTB+AK2_CLASSE+AK2_OPER+DTOS(AK2_PERIODO)",,, 	"Criando Indice..." )

For ni := 1 to Len(aEstrut)
	If aEstrut[ni,2] != 'C'
		TCSetField("TRB", aEstrut[ni,1], aEstrut[ni,2],aEstrut[ni,3],aEstrut[ni,4])
	Endif
Next ni	

ConOut("Abrindo arquivo ")
FT_FUSE(cArquivo)
nTotal := FT_FLASTREC()
ProcRegua(nTotal)

aGrava := {}
nLinha := 0

While !FT_FEOF()

	ConOut("Lendo Linha "+StrZero(nLinha,9))
	IncProc("Lendo Linha "+StrZero(nLinha,9))
           
	// Capturar dados
	cBuffer := AllTrim(FT_FREADLN())
	cBuffer +=" ;"
               
	If lPriVez          
	
		aCampos :=CtoA(cBuffer, ";")
		lPriVez   := .F.
		
	Else
		aGrava := CtoA(cBuffer, ";")
		RecLock("TRB",.T.)

		For nX:=1 To Len(aCampos)
			nPos   := aScan(aCampos,{|x| x==aCampos[nX] })
			xValor := aGrava[nPos]

			// Ajusta formatacao dos campos
			If GetSX3Cache(Alltrim(aCampos[nX]),"X3_TIPO")=="D" 
				// Se o campo for tipo Data e o Valor estiver em Texto, converte para data
				If ValType(xValor)=="C" 
					xValor := CTOD(xValor)
				Endif
			ElseIf GetSX3Cache(Alltrim(aCampos[nX]),"X3_TIPO")=="N" 
				// Tratamentos para campo do tipo numerico
				xValor   := StrTran(aGrava[9],"R$","")
				xValor   := StrTran(xValor,"R","")
				xValor   := StrTran(xValor,"$","")
				xValor   := StrTran(xValor,".","")
				xValor   := StrTran(xValor,",",".")
				xValor   := Val(AllTrim(xValor))
			EndIf 

			&("TRB->"+Alltrim(aCampos[nX])) := xValor
		Next

		TRB->(MsUnLock()) 
	EndIf
		
	FT_FSKIP()
	
EndDo
FT_FUSE()  

If TRB->(RecCount()) == 0 
	TRB->(dbCloseArea())
	MsgAlert("Nenhum registro encontrado!")
	Return 
EndIf	

//EXCEL AK2_FILIAL	AK2_ORCAME	AK2_VERSAO	AK2_CC	AK2_CO	AK2_ITCTB	AK2_CLASSE	AK2_PERIODO	AK2_VALOR	AK2_OPER
//UNICO AK2_FILIAL, AK2_ORCAME, AK2_VERSAO, AK2_CO, AK2_PERIOD, AK2_ID, R_E_C_D_E_L_
                    
lCont := .T. 

dbSelectArea("TRB")
dbSetOrder(1)
ProcRegua(TRB->(RecCount()))
dbGotop()

nLinha := 1

While lCont .And. TRB->(!EOF())
		IncProc("Gravando Linha "+Alltrim(Str(nLinha)))
		lErro   := .F.
		cLinha	:= Alltrim(Str(nLinha))

		cChave  := TRB->(AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CC+AK2_CO+AK2_ITCTB+AK2_CLASSE+AK2_OPER)
		cFilAnt := TRB->AK2_FILIAL

		xAutoCab  	:= {}
		aAdd(xAutoCab,{"AK2_ORCAME", TRB->AK2_ORCAME , nil})
		aAdd(xAutoCab,{"AK2_VERSAO", TRB->AK2_VERSAO , nil})
		aAdd(xAutoCab,{"AK2_CO" , 	 TRB->AK2_CO 	 , nil})

		xAutoItens  := {}
		aAux   		:= {}

		aAdd(aAux,	{"AK2_ORCAME"		, TRB->AK2_ORCAME 			, NIL })
		aAdd(aAux,	{"AK2_VERSAO"		, TRB->AK2_VERSAO 			, NIL })
		aAdd(aAux,	{"AK2_CO"			, Alltrim(TRB->AK2_CO)		, NIL })
		aAdd(aAux,	{"AK2_ID"			, "*"			 			, NIL })
		aAdd(aAux,	{"AK2_CC"			, TRB->AK2_CC	 			, NIL })
		aAdd(aAux,	{"AK2_CLASSE"		, TRB->AK2_CLASSE			, NIL })	
		aAdd(aAux,	{"AK2_ITCTB"		, TRB->AK2_ITCTB			, NIL })
		aAdd(aAux,	{"AK2_OPER"			, TRB->AK2_OPER				, NIL })

		nUltPos := Len(aAux)
		aAdd(aAux,	{"P01"				, 0							, NIL })
		aAdd(aAux,	{"P02"				, 0							, NIL })
		aAdd(aAux,	{"P03"				, 0							, NIL })
		aAdd(aAux,	{"P04"				, 0							, NIL })
		aAdd(aAux,	{"P05"				, 0							, NIL })
		aAdd(aAux,	{"P06"				, 0							, NIL })
		aAdd(aAux,	{"P07"				, 0							, NIL })
		aAdd(aAux,	{"P08"				, 0							, NIL })
		aAdd(aAux,	{"P09"				, 0							, NIL })
		aAdd(aAux,	{"P10"				, 0							, NIL })
		aAdd(aAux,	{"P11"				, 0							, NIL })
		aAdd(aAux,	{"P12"				, 0							, NIL })

		While lCont .And. TRB->(!EOF())  .And. cChave == TRB->(AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CC+AK2_CO+AK2_ITCTB+AK2_CLASSE+AK2_OPER)

				
			nMes := Val(Substr(DTOS(TRB->AK2_PERIOD),5,2))
			aAux[nUltPos+nMes,2] := TRB->AK2_VALOR

			nLinha++
			ConOut("Grv Linha "+StrZero(nLinha,9))
			TRB->(dbSkip())
				
		EndDo
		aAdd(xAutoItens,aAux)
        lMsErroAuto := .F.
        MSExecAuto( {|x, y, z, a, b, c| PCOA100(x, y, z, a, b, c)}, 4/*nCallOpcx*/, /*cRevisa*/, /*lRev*/, /*lSim*/, xAutoCab, xAutoItens) //4=altera็ใo para manipular itens da planilha

		If lMsErroAuto
			ConOut("Erro")
			
			lErro     := .T.
			cMensagem := MostraErro("\","XZTKAK2.LOG")
		Else
			lErro     := .F.
			cMensagem := "Orcamento importado com sucesso"
		EndIf	
		Aadd(aLogs,{lErro,"Linha "+cLinha,cMensagem})
EndDo
TRB->(dbCloseArea())

If Len(aLogs)>0
	MostraLog(aLogs)
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCtoA      บAutor  ณMicrosiga           บ Data ณ  04/20/17   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function CtoA(_cTexto, _cDelim)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local _aRet := {}
Local _nAux1, _cAux1 := "", _cAux2 := "", _cAbreCpo := ""

// Verifica o delimitador foi passado por parametro.
_cDelim := IIf(ValType(_cDelim) == "C", _cDelim, ";,")

// Retira os espacos do comeco e do fim.
_cTexto := AllTrim(_cTexto)

For _nAux1 := 1 to len(_cTexto)
	
	// Pega o caractere da posicao.
	_cAux1 := SubStr(_cTexto, _nAux1, 1)
	
	// Se for o primeiro caracter do campo, verifica se abre com aspas.
	If empty(_cAux2) .and. (_cAux1 == "'" .or. _cAux1 == '"')
		_cAbreCpo := _cAux1
	Endif
	
	// Adiciona o caractere da posicao.
	_cAux2 += _cAux1
	
	// Verifica se acabou o campo ou se acabou a linha.
	// If at(_cAbreCpo + _cDelim, _cAux2) != 0 .or. _nAux1 == len(_cTexto)
	If _nAux1 == len(_cTexto) .or. (_cAux1 $ _cDelim .and. at(_cAbreCpo + _cAux1, _cAux2) != 0)
		
		// Adiciona o campo na matriz que sera retornada.
		aAdd(_aRet, SubStr(_cAux2, 1, len(_cAux2) - IIf(_nAux1 == len(_cTexto) .and. !(_cAux1 $ _cDelim), 0, 1)))
		
		// Zera os campos.
		_cAux2    := ""
		_cAbreCpo := ""
	Endif
	
Next _nAux1
Return(_aRet)



User Function XAK2JOB()

If !MsgYesNo("Confirma XAK2JOB?")
	Return Nil 
EndIf 	

ConOut(Repl("-",80))
ConOut("INICIO")
ConOut("Abrindo tabelas...")
ConOut(Repl("-",80))

//RpcClearEnv()
//RPCSetType(3)  // Nao utilizar licenca
//PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01011001" MODULO "PCO"

//ProcImp("C:\TEMP\TESTE.CSV") 

ProcImp("C:\TEMP\FINAL.CSV") 

ConOut(Repl("-",80))
ConOut("FIM")
ConOut(Repl("-",80))

Return Nil

/*/{Protheus.doc} MostraLog

Mostra Log de processamento 

@author  Cesar Padovani 
@since   06/01/2021
@version 1.0
@type    Rotina
/*/
Static Function MostraLog(aLogs)

Local oFontL 	:= TFont():New("Mono AS",,012,,.T.,,,,,.F.,.F.)
Local cMask    	:= "Arquivos Texto" + "(*.TXT)|*.txt|"
Local cMemo		:= ""
Local cFile    	:= ""
Local oBtnSair
Local oGrpLog
Local oPanelB
Local oMemo
Local oDlgLog

DEFINE MSDIALOG oDlgLog TITLE "Log de Processamento" FROM 000, 000  TO 400, 700 COLORS 0, 16777215 PIXEL

@ 182, 000 MSPANEL oPanelB SIZE 350, 017 OF oDlgLog COLORS 0, 16777215 RAISED
oPanelB:Align	:= CONTROL_ALIGN_BOTTOM

@ 002, 002 LISTBOX oLogs Fields HEADER "","Linha do Arquivo" SIZE 100, 176 OF oDlgLog PIXEL ColSizes 50,50
oLogs:SetArray(aLogs)
oLogs:bChange	:= {|| 	cMemo := aLogs[oLogs:nAt,3], oMemo:Refresh() }
oLogs:bLine		:= {||	{;
						IF( aLogs[oLogs:nAt,1], LoadBitmap( GetResources(), "BR_VERMELHO" ), LoadBitmap( GetResources(), "BR_VERDE" ) ),;
						aLogs[oLogs:nAt,2];
						}}

@ 001, 105 GROUP oGrpLog TO 178, 350 PROMPT " Log do Processamento " OF oDlgLog COLOR 0, 16777215 PIXEL

@ 009, 107 GET oMemo VAR cMemo OF oDlgLog MULTILINE SIZE 240, 166 COLORS 0, 16777215 HSCROLL PIXEL Font oFontL

DEFINE SBUTTON oBtnSair	FROM 185, 150 TYPE 01 OF oDlgLog ENABLE Action( oDlgLog:End() )
DEFINE SBUTTON oBtnSave	FROM 185, 180 TYPE 13 OF oDlgLog ENABLE Action( cFile := cGetFile( cMask, "" ), If( Empty(cFile), .T., GrvLog( aLogs, cFile ) ) )

ACTIVATE MSDIALOG oDlgLog CENTERED

Return Nil

/*/{Protheus.doc} MostraLog

Grava log em arquivo

@author  Cesar Padovani 
@since   06/01/2021
@version 1.0
@type    Rotina
/*/
Static Function GrvLog( aLogs, cFile )

Local nHandle	:= MsfCreate( cFile,0 )
Local cTexto	:= ""
Local nX		:= 0

If nHandle <= 0
	FwAlertInfo("Nใo foi possํvel criar o arquivo, verifique")
	Return Nil
Endif

//Gera o Arquivo Tabulado
For nX := 1 To Len( aLogs )
	
	//Armazena Loc
	cTexto := "Linha: " + aLogs[nX][02] + Space( 5 ) + aLogs[nX][03]
	
	//Grava Linha
	FWrite( nHandle, cTexto + CRLF )
	
Next nX

FClose(nHandle)

FwAlertInfo("Arquivo "+Alltrim(cFile)+" gravado com sucesso" )
	
Return Nil
