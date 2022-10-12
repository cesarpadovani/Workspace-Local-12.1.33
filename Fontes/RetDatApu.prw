#Include "Protheus.ch"

/*/{Protheus.doc} RetDaApu

Retorna dados dos titulos do controle de darf


/*/
User Function RetDatApu(nOpc)

Local xRet
Local cQuery := ""
Local aSetField := {}
aAdd(aSetField,{"FI9_APURA",GetSX3Cache("FI9_APURA","X3_TIPO"),GetSX3Cache("FI9_APURA","X3_TAMANHO"),GetSX3Cache("FI9_APURA","X3_DECIMAL")})

cQuery := "SELECT FI9_APURA,FI9_CODRET "
cQuery += "FROM "+RetSQLName("FI9")+" "
cQuery += "WHERE FI9_PREFIX = '"+SE2->E2_PREFIXO+"' "
cQuery += "AND FI9_NUM = '"+SE2->E2_NUM+"' "
cQuery += "AND FI9_PARCEL = '"+SE2->E2_PARCELA+"' "
cQuery += "AND FI9_TIPO = '"+SE2->E2_TIPO+"' "
MPSysOpenQuery(cQuery,"TRBFI9",aSetField)

DbSelectArea("TRBFI9")
DbGoTop()
If TRBFI9->(!Eof())
    If nOpc==1
        xRet := TRBFI9->FI9_APURA
        xRet := GRAVADATA(xRet,.F.,5)
    Else
        xRet := TRBFI9->FI9_CODRET
    EndIf
Else
    If nOpc==1
        xRet := SE2->E2_DTAPUR
        xRet := GRAVADATA(xRet,.F.,5)
    Else
        xRet := SE2->E2_CODRET
    EndIf
EndIf

Return xRet
