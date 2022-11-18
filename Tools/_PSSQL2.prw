#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*/{Protheus.doc} _PSSQL2

Tela personalizada para execucao de querys

@type    Function
@author  Cesar Padovani
@since   23/10/2022
@version 2.0
/*/
User Function _PSSQL2()

Private oFont1 := TFont():New("MS Sans Serif",,009,,.F.,,,,,.F.,.F.)
Private lBegin 

DEFINE MSDIALOG Dlg_PSSQL TITLE "QUERY" From 000, 000  TO 415,765 PIXEL

_cMemSQL := ""
@ 05,05 GET oMemDet VAR _cMemSQL MEMO SIZE 375,180 PIXEL OF Dlg_PSSQL

oChkBeg := TCheckBox():New(190,005,"Begin Transaction" ,bSETGET(lBegin),Dlg_PSSQL,090,009,,,,,,,,.T.,,,{|o| .T. }) 

oButExe := tButton():New(190,245,'Executar',Dlg_PSSQL,{|| _ExecSQL(_cMemSQL) },65,12,,oFont1,,.T.)
oButEnd := tButton():New(190,315,'Fechar'  ,Dlg_PSSQL,{|| Dlg_PSSQL:End() },65,12,,oFont1,,.T.)

ACTIVATE MSDIALOG Dlg_PSSQL CENTERED

Return

/*/{Protheus.doc} _ExecSQL

Executa o comando

@type    Function
@author  Cesar Padovani
@since   23/10/2022
@version 2.0
/*/
Static Function _ExecSQL(_cMemSQL)

If lBegin
	Begin Transaction

	If (TCSQLExec(_cMemSQL) < 0)
		MsgAlert("Erro na Query: "+  TCSQLError())
	Else
		MsgInfo("Query executada com sucesso!")
	EndIf

	If !FwAlertYesNo("Executar Commit? ")
		DisarmTransaction()
		Return
	EndIf

	End Transaction
Else
	If (TCSQLExec(_cMemSQL) < 0)
		MsgAlert("Erro na Query: "+  TCSQLError())
	Else
		MsgInfo("Query executada com sucesso!")
	EndIf
EndIf

Return
