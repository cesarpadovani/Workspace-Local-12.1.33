#Include "Protheus.ch"

/*/{Protheus.doc} User Function XMLSOMAI

XMLSOMAI

@type  Function
@author user
@since 19/05/2023
@version version
*/
User Function XLSSOMAI()

Private oFWMsExcel
Private oExcel
Private aLinha    := {}

Private cPerg := "XLS"
Private cArquivo := ""

ValidPerg()
Pergunte(cPerg,.T.)

cArquivo := cGetFile("Selecione o diretorio","xml",,"",.F.,GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE)

If Empty(cArquivo)
	Return
EndIf 

Processa({|| PROCXLS() })

/*/{Protheus.doc} User Function PROCXLS

PROCXLS

@type  Function
@author user
@since 19/05/2023
@version version
*/
Static Function PROCXLS()

Local nTotReg := 0 

oFWMsExcel := FWMSExcel():New()
oFWMsExcel:AddworkSheet("Planilha SOMAI") 
oFWMsExcel:AddTable("Planilha SOMAI","Pedidos") 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Numero",1,1) // 1-Caractere | 2 Numérico | 3 Moeda
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Cliente",1,1) 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Loja",1,1) 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Nome",1,1) 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Emissao",1,1) 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Vendedor",1,1) 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Nome Vendedor",1,1) 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Transp",1,1) 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Nome Transp",1,1) 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Produto",1,1) 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Descricao",1,1) 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Quantidade",2,2) 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Unitario",3,3) 
oFWMsExcel:AddColumn("Planilha SOMAI","Pedidos","Total",3,3) 

nTotReg := Val(mv_par02) - Val(mv_par01)

ProcRegua(nTotReg)

DbSelectArea("SC5")
DbSetOrder(1)
DbGoTop()
If DbSeek(xFilial("SC5")+mv_par01) // 679224 x SC5
    Do While !Eof() .and. SC5->C5_NUM<=mv_par02 // 679200

        // Posiciona no Cliente
        DbSelectArea("SA1")
        DbSetOrder(1)
        DbGoTop()
        DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI) // SA1

        // Posiciona no Vendedor
        DbSelectArea("SA3")
        DbSetOrder(1)
        DbGoTop()
        DbSeek(xFilial("SA3")+SC5->C5_VEND1) // SA3

        // Posiciona na Transportadora
        DbSelectArea("SA4")
        DbSetOrder(1)
        DbGoTop()
        DbSeek(xFilial("SA4")+SC5->C5_TRANSP) // SA4

        // Itens do Pedido
        DbSelectArea("SC6")
        DbSetOrder(1)
        DbGoTop()
        DbSeek(xFilial("SC6")+SC5->C5_NUM) // SC6
        Do While !Eof() .and. SC6->C6_NUM==SC5->C5_NUM
            IncProc("Incluindo Pedido "+SC6->C6_NUM)

            // Posiciona no Produto
            DbSelectArea("SB1")
            DbSetOrder(1)
            DbSeek(xFilial("SB1")+SC6->C6_PRODUTO) // SB1

            aLinha := Array(14)
            aLinha[01] := SC5->C5_NUM
            aLinha[02] := SC5->C5_CLIENTE
            aLinha[03] := SC5->C5_LOJACLI
            aLinha[04] := SA1->A1_NOME
            aLinha[05] := SC5->C5_EMISSAO
            aLinha[06] := SC5->C5_VEND1
            aLinha[07] := SA3->A3_NOME
            aLinha[08] := SC5->C5_TRANSP
            aLinha[09] := SA4->A4_NOME
            aLinha[10] := SC6->C6_PRODUTO
            aLinha[11] := SB1->B1_DESC
            aLinha[12] := SC6->C6_QTDVEN
            aLinha[13] := SC6->C6_PRCVEN
            aLinha[14] := SC6->C6_VALOR

            oFWMsExcel:AddRow("Planilha SOMAI","Pedidos",aLinha)

            SC6->(DbSkip())
        EndDo

        DbSelectArea("SC5")
        DbSkip()
    EndDo

    //Ativando o arquivo e gerando o xml
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cArquivo+"XLSSOMAI.xml")

    oExcel := MsExcel():New() 
    oExcel:WorkBooks:Open(cArquivo+"XLSSOMAI.xml") 
    oExcel:SetVisible(.T.)   
    oExcel:Destroy() 

Else
    FwAlertWarning("Pedido nao encontrato","ALERTA")
EndIf

Return 

/*/{Protheus.doc} ValidPerg

Atualiza grupo de perguntas
	 
@author  Cesar Padovani 
@since   19/01/2022
@version 1.0
@type    Relatorio
/*/
Static Function ValidPerg()

Local _sAlias, aRegs, i,j

_sAlias := Alias()
aRegs := {}
I := 0
J := 0

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))

// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
//          Grupo/Ordem    /Pergunta/ /   
aRegs := {}
aAdd(aRegs,{cPerg,'01','Pedido de ?'        ,'','','mv_ch1','C',06,0,0,'G',''   	    ,'mv_par01',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'02','Pedido ate ?'       ,'','','mv_ch2','C',06,0,0,'G',''           ,'mv_par02',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'11','Emissao de ?'       ,'','','mv_chb','D',08,0,0,'G','NaoVazio'   ,'mv_par11',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'12','Emissao ate ?'      ,'','','mv_chc','D',08,0,0,'G','NaoVazio'   ,'mv_par12',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})

/*
aAdd(aRegs,{cPerg,'01','Filial de ?'        ,'','','mv_ch1','C',06,0,0,'G',''   		,'mv_par01',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'02','Filial ate ?'       ,'','','mv_ch2','C',06,0,0,'G','NaoVazio'   ,'mv_par02',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'05','Produto de ?'       ,'','','mv_ch5','C',15,0,0,'G',''   	    ,'mv_par05',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','','SB1',''})
aAdd(aRegs,{cPerg,'06','Produto ate ?'      ,'','','mv_ch6','C',15,0,0,'G','NaoVazio'   ,'mv_par06',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','','SB1',''})
aAdd(aRegs,{cPerg,'07','Fornecedor de ?'    ,'','','mv_ch7','C',06,0,0,'G',''   	    ,'mv_par07',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','','SA2',''})
aAdd(aRegs,{cPerg,'08','Fornecedor ate ?'   ,'','','mv_ch8','C',06,0,0,'G','NaoVazio'   ,'mv_par08',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','','SA2',''})
aAdd(aRegs,{cPerg,'09','Loja de ?'          ,'','','mv_ch9','C',02,0,0,'G',''   	    ,'mv_par09',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'10','Loja ate ?'         ,'','','mv_cha','C',02,0,0,'G','NaoVazio'   ,'mv_par10',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'11','Emissao de ?'       ,'','','mv_chb','D',08,0,0,'G','NaoVazio'   ,'mv_par11',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'12','Emissao ate ?'      ,'','','mv_chc','D',08,0,0,'G','NaoVazio'   ,'mv_par12',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'13','Entrega de ?'       ,'','','mv_chd','D',08,0,0,'G','NaoVazio'   ,'mv_par13',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'14','Entrega ate ?'      ,'','','mv_che','D',08,0,0,'G','NaoVazio'   ,'mv_par14',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'15','Tipo ?'             ,'','','mv_chf','C',01,0,0,'C','NaoVazio'   ,'mv_par15','P-Pendentes','','','','','E-Encerradas','','','','','T-Todas','','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'16','Seleciona Filiais ?','','','mv_chg','C',01,0,0,'C',''   		,'mv_par16','S-Sim'      ,'','','','','N-Nao'       ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
aAdd(aRegs,{cPerg,'17','Usuario    ?'       ,'','','mv_chh','C',25,0,0,'G',''   	    ,'mv_par17',''           ,'','','','',''            ,'','','','',''       ,'','','','','','','','','','','','','',''   ,''})
*/

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(_sAlias)

Return
