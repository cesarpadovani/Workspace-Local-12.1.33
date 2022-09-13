#Include "Protheus.ch"

/*/{Protheus.doc} xFilOri

Retorna dados da Filial Origem

@type    Function
@author  Cesar Padovani
@since   26/08/2022
@version 1.0
/*/
User Function xFilOri(xEmpOri,xFilOri,xCampo)

Local cRet  := ""
Local aArea := GetArea()

DbSelectArea("SM0")
DbSetOrder(1)
If DbSeek(xEmpOri+xFilOri)
    cRet := &("SM0->"+xCampo)
EndIf

RestArea(aArea)

Return cRet

