#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"
#INCLUDE "topconn.ch" 
//-------------------------------------------------------------------
// Deleta registros das filiais das tabelas
//-------------------------------------------------------------------
user function IMYPRO08(aParam)   

Local lJob		:= GetRemoteType() == -1 // Verifica se é job

Private cxEmpAnt:= ''
Private cxFilAnt:= ''

If !lJob
	If MSGYESNO("Confirma a exclusão das filiais de todas as tabelas ?")
		FWMsgRun(,{|| fExecuta(lJob) },,"Executando a rotina. Aguarde...")
	Endif
Endif

Conout("["+LEFT(DTOC(Date()),5)+"]["+LEFT(Time(),5)+"][IMYPRO08] Finalizando a geração.")   

Return NIL

//-------------------------------------------------------------------
// Processa
//-------------------------------------------------------------------
Static Function fExecuta(lJob)

Private cAliasQry := "TRBDEL" 
Private cQuery    := ""   
Private nTotRegs  := 0   
Private nQtdRegs  := 0
Private nStatus   := 0

cQuery := " select SX2.*, X3_CAMPO FROM SX2"+CEMPANT + "0 SX2 INNER JOIN SX3"+CEMPANT+"0 SX3 ON X2_CHAVE = X3_ARQUIVO AND SX3.D_E_L_E_T_ = '' WHERE SX2.D_E_L_E_T_ = '' AND X3_ORDEM = '01' "
cQuery += " Order by 1 "
cQuery := ChangeQuery(cQuery)

MPSysOpenQuery(cQuery,cAliasQry)
		
(cAliasQry)->(dbEval( {|| nTotRegs++},,{ || (cAliasQry)->(!Eof()) } ))

If nTotRegs > 0 

	ProcRegua(nTotRegs)

	(cAliasQry)->(DbGoTop()) 
	While (cAliasQry)->(!Eof())
	    
	    nQtdRegs++

		CTABE := (cAliasQry)->X2_CHAVE
		CCAMPO:= (cAliasQry)->X3_CAMPO
	    
		cQry:= "UPDATE " + RETSQLNAME(CTABE) +; 
		" SET D_E_L_E_T_ = '*',R_E_C_D_E_L_=R_E_C_N_O_" +; 
		" WHERE D_E_L_E_T_='' "+; 
		" AND "+CCAMPO+"  NOT IN ('1814030012','1814030011','1814','1814030')
		
		nStatus := TCSqlExec(cQry)
		
		if (nStatus < 0)
			Conout("Erro na deleção da tabela: "+ TCSQLError()) 
		else
			Conout("Filiais deletadas da tabela: "+ CTABE) 
		endif

	    IncProc("Processando Registro: "+Alltrim(Str(nQtdRegs)) + " de "+Alltrim(Str(nTotRegs))  )

		(cAliasQry)->(dbskip())

	EndDo

Else
	MsgInfo("Não há dados para serem deletados.")	
	Return
EndIf

(cAliasQry)->(DbCloseArea())

Return
