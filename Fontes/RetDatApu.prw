#Include "Protheus.ch"

User Function RetDatApu()

Local dRet
Local cQuery := ""
Local aSetField := {}

aAdd(aSetField,{"FI9_APURA",GetSX3Cache("FI9_APURA","X3_TIPO"),GetSX3Cache("FI9_APURA","X3_TAMANHO"),GetSX3Cache("FI9_APURA","X3_DECIMAL")})

cQuery := "SELECT FI9_APURA "
cQuery += "FROM "+RetSQLName("FI9")+" "
cQuery += "WHERE D_E_L_E_T_='' "
cQuery += "AND FI9_EMISS='"+DTOS(SE2->E2_EMISSA)+"' "
cQuery += "AND FI9_PREFIX = '"+SE2>E2_PREFIXO+"' "
cQuery += "AND FI9_NUM = '"+SE2>E2_NUM+"' "
cQuery += "AND FI9_PARCEL = '"+SE2>E2_PARCELA+"' "
cQuery += "AND FI9_TIPO = '"+SE2>E2_TIPO+"' "
MPSysOpenQuery(cQuery,"TRBFI9",aSetField)

DbSelectArea("TRBFI9")
DbGoTop()
If TRBFI9->(!Eof())
    dRet := TRBFI9->FI9_APURA
EndIf

dRet := GRAVADATA(dRet,.F.,5)

Return dRet
