#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "APVT100.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#include 'parmtype.ch'
#INCLUDE "ap5mail.CH"

#DEFINE CRLF Chr(13)+Chr(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSDETIAVS  บAutor  ณRicardo Roda        บ Data ณ  04/10/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ         ETIQUETA DE PRODUTO AVULSA                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User function GATEETIAVS()

Private cProduto:= CriaVar("B1_COD")
Private cLote 	:= CriaVar("B8_LOTECTL")
Private nQtde	:= 0
Private nQtdEti	:= 0
Private cLocImp := space(6)
Private cTpDesc := "N"
Private cDocto:= space(9)
Private dDataRec := dDataBase
Private cQuality := "0" //0-Branco 1-Passagem Livre  2-APROVADO

if empty(cLocImp)
	VtClear()
	@ 0,00 VTSAY "Leia o codigo "
	@ 1,00 VTSAY "da Impressora "
	@ 2,00 VTGET cLocImp PICTURE '@!' F3 "CB5"
	VtRead
	
	If VtLastkey() == 27
		Return
	EndIf
	
Endif

cProduto := '1651-EM10001-PT'

While .T.
	DLVTCabec("Etiqueta Avulsa",.F.,.F.,.T.)
	@ 01,00 VTSay "Produto:"
	@ 02,00 VTGet cProduto Picture '@!' VALID !Empty(@cProduto) .and. fVldProd()
	
	If cProduto = '1651-EM10001-PT'
		cDocto := ALLTRIM(GETADVFVAL("SB5","B5_CODCLI",XFILIAL("SB5")+cProduto,1,""))
		@ 03,00 VTSay "PN SL:" + cDocto
	Else
		@ 03,00 VTSay "Documento:"
		@ 03,11 VTGet cDocto Picture '@!' VALID !Empty(@cDocto)
	EndIf
	
	@ 04,00 VTSay "Data Rec.:"
	@ 04,11 VTGet dDataRec Picture '@D' VALID !Empty(@dDataRec)
	@ 05,00 VTSay "Qtde."
	@ 05,05 VTGet nQtde PICTURE "@E 99999999.999999" VALID @nQtde > 0
	@ 06,00 VTSay "0- 1-Livre 2-Aprov" 
	@ 06,19 VTGet cQuality Picture '@!' VALID fVldQualy()
	@ 07,00 VTSay "Etiqs."
	@ 07,06 VTGet nQtdEti Picture PICTURE "@E 99999999.999999" VALID @nQtdEti > 0 .and. fImpEti()
	
	VtRead
	
	If VtLastkey() == 27
		Exit
	EndIf
	
End

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGATEETIAVSบAutor  ณMicrosiga           บ Data ณ  10/17/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function EtiqPrds(cProduto, nQtde,cDocto)

Private cLote 	:= CriaVar("B8_LOTECTL")
Private nQtdEti	:= 1

If VtLastkey() == 27
	Return
EndIf


fImpEti()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO3     บAutor  ณMicrosiga           บ Data ณ  04/10/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fVldProd()

Local aSave := VTSAVE()
Local lRet := .F.
Local lRastro:= Iif(Posicione("SB1",1,xFilial("SB1")+cProduto, "B1_RASTRO") == "L", .T.,.F.)

If !Empty(cProduto)
	
	aEtiqueta := CBRetEtiEan(cProduto)
	If Len(aEtiqueta) == 0
		VtBeep(3)
		VtAlert("Etiqueta invalida","Aviso",.t.,3000,3)
		VtKeyboard(Chr(20))  // zera o get
	Else
		cProduto:= aEtiqueta[1]
		lRet:= .T.
	EndIf
Endif

If lRastro
	VtClear()
	DLVTCabec("Etiqueta Avulsa",.F.,.F.,.T.)
	@ 01,00 VTSay " informe o numero"
	@ 02,00 VTSay " do lote ou ENTER"
	@ 03,00 VTSay " para escolher um"
	@ 04,00 VTSay "   lote valido   "
	@ 06,00 VTGet cLote Picture '@!' VALID fVldLote(@cLote)
	VtRead
	
	If VtLastkey() == 27
		lRet:= .F.
		VtRestore(,,,,aSave)
		cProduto:= CriaVar("B1_COD")
		cLote 	:= CriaVar("B8_LOTECTL")
		nQtde	:= 0
		nQtdEti	:= 0
		VtGetRefresh("cProduto")
		VtGetRefresh("cLote")
		VtGetRefresh("nQtde")
		VtGetRefresh("nQtdEti")
	Else
		VtRestore(,,,,aSave)
		VtGetRefresh("cProduto")
		VtGetRefresh("cLote")
		VtGetRefresh("nQtde")
		VtGetRefresh("nQtdEti")
	Endif
	
Endif

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfVldQualy บAutor  ณRegiane Barreira    บ Data ณ  18/10/21   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validar se o produto ้ BRANCO / PASSAGEM LIVRE ou APROVADO บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fVldQualy()

Local aSave := VTSAVE()
Local lRet := .F.

If cQuality $ "012"
	lRet := .T.
EndIf

Return lRet


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fVldLote()
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Local aSave := VTSAVE()
Local cDtValLote
Local cSaldo
Local aTemp3	:={}
Local nPos3		:= 1
Local lRet		:= .F.

if Empty(cLote)
	aTemp3 := aClone(MontaaLbx(1))
	If !Empty(aTemp3)
		VtClear()
		nPos3 := VTaBrowse(1,,,,{"Lote","Saldo","Data Valid"},aTemp3,{10,08,08},,nPos3)
		
		If VtLastkey() <> 27
			If nPos3 > 0
				lRet:= .T.
				cLote  		:= aTemp3[nPos3,1]
				cSaldo    	:= aTemp3[nPos3,2]
				cDtValLote  := aTemp3[nPos3,3]
				VtRestore(,,,,aSave)
				VtGetRefresh("cLote")
				VtGetRefresh("cDtValLote")
				VtGetRefresh("cSaldo")
			Endif
		Else
			VtRestore(,,,,aSave)
		Endif
	Else
		VtAlert("Nใo foram encontrados Lotes com saldo para este produto","Aviso", .T., 3000)
	Endif
Else
	aTemp3 := aClone(MontaaLbx(2))
	If Empty(aTemp3)
		VtAlert("Lote invalido","Aviso", .T., 3000)
	Else
		lRet:= .T.
	Endif
Endif

Return lRet
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function MontaaLbx(nOpc)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Local aListBox1:= {}

IF SELECT ("QRY") > 0
	QRY->(DBCLOSEAREA())
Endif

cQuery := " SELECT B8_PRODUTO, B8_LOTECTL, B8_DTVALID,sum(B8_SALDO) SALDO "
cQuery += " FROM "+RETSQLNAME("SB8")+" SB8  "
cQuery += " WHERE B8_PRODUTO = '"+Alltrim(cProduto)+"' "
cQuery += " AND SB8.D_E_L_E_T_ = ''"
If nOpc == 1
	cQuery += " AND B8_SALDO >0 "
ElseIf nOpc == 2
	cQuery += " AND B8_LOTECTL = '"+cLote+"' "
Endif
cQuery += " GROUP BY B8_PRODUTO,B8_DTVALID,B8_LOTECTL  "
cQuery += " ORDER BY B8_DTVALID,B8_LOTECTL "
cQuery := ChangeQuery(cQuery)
DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"Qry",.F.,.T.)

DBSelectArea("Qry")
While !Eof()
	Aadd(aListBox1,{Qry->B8_LOTECTL,Qry->SALDO,STOD(Qry->B8_DTVALID)})
	DBSkip()
EndDo
DBSelectArea("Qry")
DBCloseArea("Qry")

Return (aListBox1)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO3     บAutor  ณMicrosiga           บ Data ณ  04/10/18   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fImpEti()


Local aSave := VTSAVE()
Local _cDesc:= Posicione("SB1",1,xFilial("SB1")+cProduto, "B1_DESC")
Local _cUM:= Posicione("SB1",1,xFilial("SB1")+cProduto, "B1_UM")
Local cQtdEti:= cValtochar(nQtdEti)
Local _aArq		:= {}
Local aCodEtq 	:= {}
Local cDtEnt	:= DToC(dDatabase)
Local nP        := 1

//Regiane Barreira 15/10/2021 - alterado para preencher com zeros a esquerda e impressใo da data da nota de entrada digitada
Local cDocEnt := ""
Local cDataRec := DTOC(dDataRec)

If !CB5SetImp(cLocImp,IsTelNet())
	VtAlert("Local de impressao invalido!","Aviso",.t.,3000,2)
	Return
Endif
	
	_QRCODE:= cProduto 	+"|"
	_QRCODE+= cvaltochar(nQtde)	+"|"
	_QRCODE+= _cUM +"|"

//Regiane Barreira 15/10/2021 - alterado para preencher com zeros a esquerda e impressใo da data da nota de entrada digitada
//	_QRCODE+= cDocto +"|"
	
	If Alltrim(cProduto) $ GETMV("MV_XPNSL") // cProduto = '1651-EM10001-PT'
		cDocEnt := cDocto
		_QRCODE+= cDocEnt +"|"
	Else
		cDocEnt := StrZero(Val(cDocto),9)
		_QRCODE+= cDocEnt +"|"
	EndIf
	
	
//	_QRCODE+= dTos(dDataBase) +"|"
	_QRCODE+= cDataRec +"|"
	
	_QRCODE+= Time() +"|"
	
	
	MSCBBEGIN(1,6)
	// IMPRESSORA MODELO ZT230 ZEBRA
	AADD(_aArq,'CT~~CD,~CC^~CT~' + CRLF )
	AADD(_aArq,'^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ' + CRLF )
	AADD(_aArq,'^XA' + CRLF )
	AADD(_aArq,'^MMT' + CRLF )
	AADD(_aArq,'^PW863' + CRLF )
	AADD(_aArq,'^LL0519' + CRLF )
	AADD(_aArq,'^LS0' + CRLF )

	// Borda'
	AADD(_aArq,'^FO0,0^GFA,55296,55296,00108,:Z64:' + CRLF )
	AADD(_aArq,'eJzs0rERQFAURNEvEurg60RrlKYUhRjMPAIVbHRusOlJtjVJ0td6B9qKGhLUfZQ1RqwzaF1lTXviFMtrJajWa+eg1VksFovFYrFYLBaLxWKxWCwWi8VisVgsFovFYrFYLBaLxWKxWCwWi8VisVgsFovFYrFYLBaLxWKxWCwWi8VisVgsFovFYrFYLBaLxWKxWCwWi8VisVgsFovFYrFYLBaLxWKxWCwWi8Vi/XoAAAD//+3SoQ0AIBAEwaBw0H93FEJ4SsCQU7MNjFkWi8VisVgsFovFYrFYLBaLxWKxWCwWi8VisVgsFovFYrFYLBaLxWKxWCwWi8VisVgsFovFYrFYLBaLxWKxWCwWi8VisVgsFuuvNYLWDFq9Ep2gteNWi1grcoX07gKeMJ5n:7149' + CRLF )

	// Logo
	AADD(_aArq,'^FO0,32^GFA,03456,03456,00036,:Z64:' + CRLF )
	AADD(_aArq,'eJztlTFvI0UUx//L5DRWLHmuOXESixe5oaRdyGKfxGeIKPMVjm4RBu/JRZBOwj06xLWELzEnFy6uMM3VLHJBuxAkNllfHu/teL3ji0kKrkJ5GXkm1s//ffN/b2aBu3grcfCWdO4dc9wGZRKy6DTfdLz1Rufk1fEjIA3IhtA8eMHDILAN885g8ueA59hQzsAQWlOuqDBZyzw4pte1TkQFMxG0oULT2tiW6XTpUub4E5QPYY4y1UfZzeKuxzz4nEjm8Rhj0cl0H+M+IpN7+XzomLhEn5mR1QmSBMYU6ppOWiBi5v2cmTCFnqWtDmZEYk+cw4QwSa5jx8RePieO+TKvzQkL1sFj6OXYy+cjx3zsmCRli5hRs3CPjoV+xljKW0MBtez7/lRVrWOhvj/7OY5Vt2QmeHm4688r9vlr1vmRKOxzLSwzS73rz8DpCJP0NKiomemOjtRL8vnh+CQ0Gu+uhVEvWn+mdPVt5nSesT/6FFhLzh7T1F10xB+9APrCBL+1+QwmlwPnc+2PYqYn/uDc05E+1OKzEZ3g9xQR+zzDF60/EtAZ6xxy/8RYxejFUE8lw60OB+uMi7o3Qvw9RjTmbsSnXj5nZwPWSVMMJR9MEvSkfxDt+ANo+zip+zDEKEISYegz7A8zKi+iJ6X0D6IoWxseMG/oBFS4cxFyJ1OpqTSs7deLJzlTts7HKFnnBtf6ecJSuI+AB68xyQJe+P2DW6I5FzdFc75u05G63xjiT/bfdZp+vinuOZ0RXeSIaK1oTnTOs43WLdSlqpPhiEpusmrdpRVV5xVNs6+87WoivqNH9LrWiRbnokMLuz6xPsOffBHk6AFDpMiVVfMnRVvTTSQIcvT5OkMSMBOs5jl/8SbjdFKErJMFq2kWPL/2LKfDXe10FnJ77M9HPpjB6lTWe3Ukh42On4mq+yeWnx3WjMvnqc/s0dFWL5Yt8cGGGZ4951TOfnI6Vk+/u64zoj/E5wtb50Ok9uiMqOB6SWFFh66Up3N/776IPlv6jKGr1p9gXz4POYldndpnNV/KTe6iw51z2fjTcyaJP/MZtrXoYbJ51m69FouWMRnR2qsXM6hrcZpt68W72jBOh3uj1pkv7LZ/eJtUejox/7n+saphAmYKT+cbftHXz3rh9Sozee1zSbTknp8WLp/sapQ1zITI1swF0a/8Wqfc6dhJe3aO3OvrqCqr6mVVKv6P88Eqe6/cMs5mHBzw4OCD0ez4ry2jqOX/LQL65VbmLu7ifxL/APdcFeQ=:77A2' + CRLF )

	// Linha divisoria entre Logo e Produto
	AADD(_aArq,'^FO282,14^GB0,127,1^FS' + CRLF )

	// Codigo do Produto
	AADD(_aArq,'^FT300,38^AC,20,14^FH\^FDProduto:^FS' + CRLF )
	AADD(_aArq,'^FT297,109^A0N,70,76^FH\^FD'+cProduto+'^FS' + CRLF )

	// Descricao
	AADD(_aArq,'^FT30,182^A0N,34,33^FH\^FD'+Substring(_cDesc,1,45)+'^FS' + CRLF )
	AADD(_aArq,'^FT30,217^A0N,34,33^FH\^FD'+Substring(_cDesc,46,45)+'^FS' + CRLF )

	// Linhas Divisorias
	AADD(_aArq,'^FO388,312^GB221,0,2^FS' + CRLF )
	AADD(_aArq,'^FO23,401^GB363,0,1^FS' + CRLF )
	AADD(_aArq,'^FO384,269^GB0,233,3^FS' + CRLF )
	AADD(_aArq,'^FO608,267^GB0,237,2^FS' + CRLF )
	AADD(_aArq,'^FO22,141^GB814,0,2^FS' + CRLF )

	// Label Lote/Volume
	AADD(_aArq,'^FT30,255^AC,20,14^FH\^FDLote:^FS' + CRLF )
	AADD(_aArq,'^FT600,255^AC,20,14^FH\^FDVolume:^FS' + CRLF )

	// Documento
	If Alltrim(cProduto) $ GETMV("MV_XPNSL") // Tipo: C / Formato: 1651-EM10001,1651-EM10001-PT,1651-EM10002,1651-EM10002-PT
		AADD(_aArq,'^FT30,310^A0N,25,25^FH\^FDPN SL^FS' + CRLF )
	Else
		AADD(_aArq,'^FT30,310^A0N,25,25^FH\^FDDocumento^FS' + CRLF )
	EndIf

	AADD(_aArq,'^FT157,310^A0N,34,33^FH\^FD'+cDocEnt+'^FS' + CRLF )

	// Data Rec
	AADD(_aArq,'^FT30,376^AC,20,14^FH\^FDData Rec.^FS' + CRLF )
	AADD(_aArq,'^FT144,376^A0N,42,45^FH\^FD'+cDataRec+'^FS' + CRLF )

	// Quantidade
	AADD(_aArq,'^FT30,430^AC,20,14^FH\^FDQuant.^FS' + CRLF )
	AADD(_aArq,'^FT97,481^A0N,70,76^FH\^FD'+cvaltochar(nQtde)+'^FS' + CRLF )

	// Qualidade
	AADD(_aArq,'^FT444,300^A0N,23,24^FH\^FDQUALIDADE^FS' + CRLF )
	AADD(_aArq,'^FO25,266^GB814,0,2^FS' + CRLF )

	//***Regiane Barreira 18/10/2021 - alterado para impressใo conforme escolha em tela	
	DO CASE
		CASE cQuality = '1' //1-Passagem LIVRE
			AADD(_aArq,'^FO387,312^GB223,95,95^FS' + CRLF )
			AADD(_aArq,'^FT387,388^A0N,76,48^FB223,1,0,C^FR^FH\^FDPASSAGEM^FS' + CRLF )
			AADD(_aArq,'^FO387,407^GB223,95,95^FS' + CRLF )
			AADD(_aArq,'^FT387,483^A0N,76,48^FB223,1,0,C^FR^FH\^FDLIVRE^FS' + CRLF )
		CASE cQuality = '2'  //2-Aprovado
			AADD(_aArq,'^FO387,312^GB223,95,95^FS'+ CRLF)
			AADD(_aArq,'^FT387,388^A0N,76,48^FB223,1,0,C^FR^FH\^FDAPROVADO^FS'+ CRLF)
			AADD(_aArq,'^FO387,407^GB223,95,95^FS'+ CRLF)
	ENDCASE

	// Qrcode
	AADD(_aArq,'^FT630,480^BQN,2,5' + CRLF )
	AADD(_aArq,'^FDMA,'+_QRCODE+'^FS' + CRLF )

	AADD(_aArq,'^PQ'+cValtochar(nQtdEti)+',0,1,Y^XZ' + CRLF )

	
	
	AaDd(aCodEtq,_aArq)
	
	For nY:=1 To Len(aCodEtq)
		For nP:=1 To Len(aCodEtq[nY])
			MSCBWrite(aCodEtq[nY][nP])
		Next nP
	Next nY
	
	_aArq:= {}
	aCodEtq:= {}
	
	MSCBEND()
	MSCBCLOSEPRINTER()
	
	cProduto:= CriaVar("B1_COD")
	cLote 	:= CriaVar("B8_LOTECTL")
	nQtde	:= 0
	nQtdEti	:= 0
	cDocto:= space(9)
	VtRestore(,,,,aSave)
	VtGetRefresh("cProduto")
	VtGetRefresh("cLote")
	VtGetRefresh("nQtde")
	VtGetRefresh("nQtdEti")
	VtGetRefresh("cDocto")
	
	Return .T.
