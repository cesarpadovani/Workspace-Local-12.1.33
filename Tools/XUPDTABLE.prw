#INCLUDE 'RWMAKE.CH'
#Include "TOPCONN.CH"
#INCLUDE 'TBICONN.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'                       


User Function XUPDTABLE()

If !MsgYesNo("Confirma XUPDTABLE?")
    Return .F.
EndIf     

RpcSetType(3)
PREPARE ENVIRONMENT EMPRESA "02" FILIAL "01" MODULO "COM" //TABLES "SC7","SA2","SCR"    

X31UPDTABLE("SD1")

MsgAlert("Fim XUPDTABLE")

Return Nil


