#include "protheus.ch"
//--------------------------------------------------------
/*/{Protheus.doc} pocTKeyBoard

Exemplo de utiliza��o da classe TKeyBoard

https://tdn.engpro.totvs.com.br/display/framework/TKeyboard

@author framework
@version 1.0
/*/
//--------------------------------------------------------
User Function pocTKeyBoard()
    // -------------------------------------------------
    // Declara��o das vari�veis que ser�o utilizadas
    // -------------------------------------------------
    Local cGet1         := "                                  "
    Local cGet2         := "                                  "
    Local cGet3         := "                                  "
    Local oDlg          := Nil
    Local oGet1         := Nil
    Local oGet2         := Nil
    Local oGet3         := Nil
    Local oSay1         := Nil
    Local oSay2         := Nil
    Local oSay3         := Nil
    Local oKey          := Nil
    Local lHasButton    := .T.
    // -------------------------------------
    // Fonte que ser� usada no objeto say
    // -------------------------------------
    oFont := TFont():New('Arial',,-14,.T.)
    // ------------------------------------------
    // Dialogo principal utilizada pelo teclado
    // ------------------------------------------
    oDlg  := TDialog():New( 180, 180, 550, 700, 'Exemplo TKeyBoard',,,,,,,,,.T. )
    // -----------------------------------
    // Cria��o do primeiro SAY e GET 
    // -----------------------------------
    oSay1 := TSay():New (006,011,{||'Get 01'},oDlg,,oFont,,,,.T.,,,200,20 )
    oGet1 := TGet():New( 015, 009, { | u | If( PCount() == 0, cGet1, cGet1 := u ) },oDlg, 070, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGet1",,,,lHasButton  )
    // --------------------------------------------------------
    // Atribui��o do objeto quando o foco for recebido no GET
    // --------------------------------------------------------
    oGet1:bGotFocus  := {|| oKey:SetVars( oGet1, 10 )}
    // -----------------------------------
    // Cria��o do segundo SAY e GET 
    // -----------------------------------
    oSay2 := TSay():New( 006,97,{||'Get 02'},oDlg,,oFont,,,,.T.,,,200,20 )
    oGet2 := TGet():New( 015, 95, { | u | If( PCount() == 0, cGet2, cGet2 := u ) },oDlg, 070, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGet2",,,,lHasButton  )
    // --------------------------------------------------------
    // Atribui��o do objeto quando o foco for recebido no GET
    // --------------------------------------------------------
    oGet2:bGotFocus  := {|| oKey:SetVars( oGet2, 6 )}
    // -----------------------------------
    // Cria��o do terceiro SAY e GET 
    // -----------------------------------
    oSay3 := TSay():New( 006,182,{||'Get 03'},oDlg,,oFont,,,,.T.,,,200,20 )
    oGet3 := TGet():New( 015, 180, { | u | If( PCount() == 0, cGet3, cGet3 := u ) },oDlg, 070, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGet3",,,,lHasButton  )
    // -------------------------------------------------------
    // Atribui��o do objeto quando o foco for recebido no GET
    // -------------------------------------------------------
    oGet3:bGotFocus  := {|| oKey:SetVars( oGet3, 6 )}
    // ---------------------------------------
    // Cria��o do objeto do teclado virtual
    // ---------------------------------------
    oKey := TKeyboard():New( 050, 10, 2, oDlg )
    // ----------------------------------------------------------------------
    // Informo o objeto que ser� utilizado pelo teclado na abertura da tela
    // ----------------------------------------------------------------------
    oKey:SetVars( oGet1, 10 )
    // -----------------------------------
    // Atribuo a��o do ENTER no teclado
    // -----------------------------------
    oKey:SetEnter( { || MsgInfo( oKey:GetContext(), "Conte�do do GET posicionado" ) } )
    // -------------------------------
    // Ativa��o do objeto de dialogo
    // -------------------------------
    oDlg:Activate( ,,,.T. )
Return
