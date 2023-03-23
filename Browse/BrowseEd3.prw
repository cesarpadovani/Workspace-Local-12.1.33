#Include "Protheus.ch"
#INCLUDE "FWBROWSE.CH"
#Include "TOPCONN.ch"

User Function BrowseEd3()

//Informações para preparação da tela
Local aCoors := FWGetDialogSize( oMainWnd ), oDlg, lOk := .F., cTitulo := "Alteração de Embarques"
Local bValid		:= {|| If(PossuiEmbMarcado(), lOk := MsgYesNo("Confirma a atualiação dos embarques marcados?", "Aviso"), MsgYesNo("Não foram marcados processos para atualização, deseja sair?", "Aviso"))}
//Informações dos campos que serão exibidos na tela
Local aCampos		:= {"EEC_FILIAL", "EEC_PREEMB", "EEC_DTEMBA", "EEC_NRCONH", "EEC_DTCONH"}
Local aEditaveis    := {"EEC_DTEMBA", "EEC_NRCONH", "EEC_DTCONH"}
Local aIndices      := {{"EEC_FILIAL", "EEC_PREEMB"}, {"EEC_PREEMB"},{"EEC_DTEMBA", "EEC_PREEMB"},{"EEC_DTCONH", "EEC_DTEMBA"}}
//Informações sobre o grid de seleção/alteração de embarques
Local oColumn, aFields := {}
Local bMarca		:= {|| If(Empty(WORKEEC->WK_MARCA), WORKEEC->WK_MARCA := cMarca, WORKEEC->WK_MARCA := "") }
Local bMarcaTodos	:= {|oBrowse| MarkAllItens(Empty(WORKEEC->WK_MARCA)), oBrowse:Refresh() }
Local aFilter       := {}, aPesquisa := {}, oTemp, i, j
Private cMarca := GetMark()
Private oBrowse
//Variável necessária para execução da atualização automática
Private lEE7Auto := .T.

//Cria arquivo temporário para registrar as informações dos embarques que ainda não foram embarcados
//Adiciona no array a Fields a estrutura do campo de marcação
aAdd(aFields, {"WK_MARCA", "C", 2, 0})
//Adiciona no array aFields a estrutura dos campos relacionados no array aCampos
aEval(aCampos, {|x| aAdd(aFields, {x, GetSx3Cache(x, "X3_TIPO"), GetSx3Cache(x, "X3_TAMANHO"), GetSx3Cache(x, "X3_DECIMAL")}) })
//Adiciona no array aFilter a estrutura das chaves definidas no array aIndices
aEval(aCampos, {|x| AAdd(aFilter, {x, GetSx3Cache(x, "X3_TITULO"), GetSx3Cache(x, "X3_TIPO"), GetSx3Cache(x, "X3_TAMANHO"), GetSx3Cache(x, "X3_DECIMAL"), GetSx3Cache(x, "X3_PICTURE")}) })
For i := 1 To Len(aIndices)
    cNomeIndice := ""
    aIdCampos := {}
    For j := 1 To Len(aIndices[i])
        cNomeIndice += AllTrim(GetSx3Cache(aIndices[i][j], "X3_TITULO")) + If(j<Len(aIndices[i]), "+", "")
        aAdd(aIdCampos, {, GetSx3Cache(aIndices[i][j], "X3_TIPO"),GetSx3Cache(aIndices[i][j], "X3_TAMANHO"),GetSx3Cache(aIndices[i][j], "X3_DECIMAL"), GetSx3Cache(aIndices[i][j], "X3_TITULO")})
    Next
    aAdd(aPesquisa, {cNomeIndice, aIdCampos, i})
Next
//Cria o arquivo temporário no banco de dados
oTemp := FWTemporaryTable():New("WORKEEC", aFields)
//Adiciona os índices
For i := 1 To Len(aIndices)
    oTemp:AddIndex(StrZero(i, 2), aIndices[i])
Next
//Cria um índice no campo de marcação
oTemp:AddIndex(StrZero(i, 2), {"WK_MARCA"})
oTemp:Create()

dDataLimite := dtos((dDatabase-30))
//Consulta a base de dados para identificar os processos disponíveis. Não serão retornados na consulta processos não embarcados que ainda possuam algum item sem nota fiscal ou processos embarcados com câmbio contratado
BeginSql Alias "EMBARQUES"
    column EEC_DTEMBA as Date
    Select Distinct
       EEC.R_E_C_N_O_ AS REC_EEC
    From 
        %table:EEC% EEC
    inner join %table:EE9% EE9
        on  EE9.EE9_FILIAL = EEC.EEC_FILIAL
        And EE9.EE9_PREEMB = EEC.EEC_PREEMB
        And EE9.%NotDel%
    Where
        EEC.%NotDel%
        AND EEC.EEC_STATUS NOT IN ('9','A')
        AND EEC.EEC_INTERM<>'1'
        AND EEC.EEC_TIPO=' '
        AND ((EEC.EEC_DTEMBA=' ' AND EE9.EE9_NF<>' ')
            OR 
            (EEC.EEC_DTEMBA<>'' AND EEC.EEC_DTEMBA>= %exp:(dDatabase-30)%))
EndSql

//Adiciona os embarques identificados no arquivo temporário
EMBARQUES->(dbgotop())
While EMBARQUES->(!Eof())
    EEC->(DbGoTo(EMBARQUES->REC_EEC))
    WORKEEC->(RECLOCK("WORKEEC",.T.))
    For i := 1 To Len(aCampos)
        WORKEEC->&(aCampos[i]) := EEC->&(aCampos[i])
    Next
    EMBARQUES->(DbSkip())
EndDo
WORKEEC->(MsUnlock())
EMBARQUES->(DbCloseArea())

//Cria tela para exibição das informações
oDlg := MSDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],cTitulo,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,)

    //Cria objeto Browse para listar os embarques e receber as informações
    oBrowse := FWBrowse():New(oDlg)
    oBrowse:SetDataTable(.T.)
    oBrowse:SetAlias("WORKEEC")
    oBrowse:SetDescription("Seleção de Embarques para atualização em lote")
    oBrowse:SetLocate()
    oBrowse:SetSeek(,aPesquisa)
    oBrowse:SetUseFilter()
    oBrowse:SetFieldFilter(aFilter)
    //oBrowse:AddFilter ("Processos não embarcados", "Empty(WORKEEC->EEC_DTEMBA) .Or. !Empty(WORKEEC->WK_MARCA)",,.T.) 
    oBrowse:SetEditCell (.T., {|| .T. })
 
    // Cria uma coluna de marca/desmarca
    oColumn := oBrowse:AddMarkColumns({|| If(Empty(WORKEEC->WK_MARCA), 'LBNO', 'LBOK') },bMarca,bMarcaTodos)
    
    //Cria as colunas com base no array aCampos
    For i := 1 To Len(aCampos)
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&("{ ||" + aCampos[i] + " }"))
        oColumn:SetTitle(GetSx3Cache(aCampos[i], "X3_TITULO"))
        oColumn:SetSize(GetSx3Cache(aCampos[i], "X3_TAMANHO"))
        oColumn:SetEdit(.T.)
        //Habilita a edição dos campos definidos no array aEditaveis
        If aScan(aEditaveis, aCampos[i]) > 0
            oColumn:SetReadVar("WORKEEC->"+aCampos[i])
            oColumn:SetValid({|| ValidCampo(ReadVar()) })
        EndIf
        oBrowse:SetColumns({oColumn})
    Next

	oBrowse:Activate()
	oDlg:lMaximized := .T.

ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, {|| If(Eval(bValid), oDlg:End(), Nil) }, {|| oDlg:End() }) CENTERED

If lOk//Caso o usuário tenha confirmado e existam embarques marcados, executa a atualização
    oProcess := MsNewProcess():New({|| AtuEmbarque(aCampos, oProcess)}, "Atualizando processos de embarque", "Iniciando execução", .F.)
    oProcess:Activate()
EndIf
//Apaga o temporário
oTemp:Delete()
Return Nil
