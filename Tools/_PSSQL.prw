#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  � _PSSQL    �Autor  � Cesar Padovani     � Data �  11/08/18   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela personalizada para execucao de querys                  ���
���          �                                                             ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              ���
��������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                              ���
��������������������������������������������������������������������������Ĵ��
���            �        �                           i                      ���
���            �        �                                                  ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
User Function _PSSQL()

Dlg_PSSQL := MSDIALOG():Create()
Dlg_PSSQL:cName := "Dlg_PSSQL"
Dlg_PSSQL:cCaption := "QUERY"
Dlg_PSSQL:nLeft := 0
Dlg_PSSQL:nTop := 0
Dlg_PSSQL:nWidth := 780
Dlg_PSSQL:nHeight := 445
Dlg_PSSQL:lShowHint := .F.
Dlg_PSSQL:lCentered := .T.

_cMemSQL := ""
@ 05,05 GET oMemDet VAR _cMemSQL MEMO SIZE 375,170 PIXEL OF Dlg_PSSQL

@ 190,270 BUTTON "Executar" SIZE 50,15 PIXEL OF Dlg_PSSQL ACTION _ExecSQL(_cMemSQL)
@ 190,330 BUTTON "Fechar"  SIZE 50,15 PIXEL OF Dlg_PSSQL ACTION Dlg_PSSQL:End()

Dlg_PSSQL:Activate()

Return

Static Function _ExecSQL(_cMemSQL)

If (TCSQLExec(_cMemSQL) < 0)
	MsgAlert("Erro na Query: "+  TCSQLError())
Else
	MsgInfo("Query executada com sucesso!")
EndIf


Return