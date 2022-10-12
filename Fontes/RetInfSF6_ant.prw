#Include "Protheus.ch"

User Function RetInfSF6(nOpc)

Local cRet
Local cQuery := ""

cQuery := "SELECT F6_MESREF, F6_ANOREF, F6_CODREC "
cQuery += "FROM "+RetSQLName("SF6")+" SF6, "+RetSQLName("SE2")+" SE2 "
cQuery += "WHERE F6_NUMERO = '"+SE2>E2_PREFIXO+SE2->E2_NUM+"' "
cQuery += "AND E2_PREFIXO='ICM' "
cQuery += "AND F6_FILIAL='"+SE2>E2_FILIAL+"' "
cQuery += "AND F6_VALOR="+Alltrim(Str(SE2->E2_VALOR))+" "
cQuery += "AND SF6.D_E_L_E_T_='' "
cQuery += "AND SE2.D_E_L_E_T_='' "
MPSysOpenQuery(cQuery,"TRBSF6")

DbSelectArea("TRBSF6")
DbGoTop()
If TRBSF6->(!Eof())
    If nOpc==1
        cRet := "00"+Left(TRBSF6->F6_CODREC,4) // Retornao Codigo de Retencao
    Else
        cRet := StrZero(TRBSF6->F6_MESREF,2)+Alltrim(Str(TRBSF6->F6_ANOREF)) // Retorna Mes e Ano de Referencia
    EndIf
EndIf

Return cRet
