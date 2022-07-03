#Include "protheus.ch"

User Function Aviso()

Local cArq := "TESTE.TXT"
Local cTit := "Atencao!"
Local aOp  := {}
Local cMsg := ""
Local nOpWhile := .T.	

If !File(cArq)
	aOp  := {"Sim","Nao","Cancela"}	
    cMsg := "O arquivo "+cArq+" não foi encontrado!”	    
    cMsg := cMsg + " Tenta novamente?"	   
    
    nOp:= Aviso(cTit,cMsg,aOp)                   	    
    
    If nOp == 1 // Sim               	    	
        ApMsgAlert("Usuário tentando novamente")		    
        Loop	    
    ElseIf nOp == 3 // Cancela	    	
        ApMsgAlert("Usuário cancelou operação")	    	    	
        Return	    
    Else // Nao ou ESC                   	    	
        ApMsgAlert("Usuário não tentou novamente")	    	    	
        Exit	 	
    Endif	 
Endif

Return
