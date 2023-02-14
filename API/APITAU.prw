#include "protheus.ch"
#Include "parmtype.ch"
#Include "totvs.ch"
#Include "RESTFUL.ch"

user function AFIN038()

Local cUrl := "https://autorizador-boletos.itau.com.br"
//Local cUrl := "https://oauth.itau.com.br/identity/connect/token"
Local cUsuariU := "aaa" // Usuario ficticio
Local cSenhaoA := "bbb" // Senha Ficticia
Local oRestClient := FWRest():New(cUrl)
Local aHeader := {}
Local cUnyJSon := {}
Local cJsonBol
// inclui o campo Authorization no formato : na base64
Aadd(aHeader, "Authorization: Basic " + Encode64(cUsuariU+":"+cSenhaoA))
Aadd(aHeader, "Content-Type: application/x-www-form-urlencoded")
                                   
oRestClient:setPath("/")

if oRestClient:POST(aHeader)
   Alert("POST OK - " + oRestClient:GetResult()) // aqui deveria aparecer o token de retorno
Else
   Alert("POST ERROR - " + oRestClient:GetLastError())
EndIf             

return

/*

scope - readonly
grant_type - client_credentials

*/
