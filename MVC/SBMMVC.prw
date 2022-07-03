#Include "Protheus.ch"
#Include "FWMVCDEF.ch"

/*/{Protheus.doc} User Function SBMMVC

@type  Function
@author Cesar Padovani
@since 11/12/2021
@version version
/*/
User Function SBMMVC()

Local aArea := GetArea()
Local oBrowse

oBrowse := FwMBrowse():New()

oBrowse:SetAlias("SBM")

oBrowse:SetDescription("Grupo de Produtos")

oBrowse:Activate()

RestArea(aArea)

Return
