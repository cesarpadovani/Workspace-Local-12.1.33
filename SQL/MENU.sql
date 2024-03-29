USE TESTE01
GO

-- Verificar Menu do usu�rio
SELECT * FROM SYS_USR WHERE D_E_L_E_T_='' AND USR_CODIGO LIKE '%CESAR%'
SELECT * FROM SYS_USR_MODULE WHERE D_E_L_E_T_='' AND USR_ID='000842'

-- 1 - Verificar ID do M�dulo
--SELECT * FROM MPMENU_MENU MPN WHERE M_NAME LIKE '%SIGAFAT%'

-- 2 - Query com o ID
SELECT
I_TP_MENU, F_FUNCTION, I18N1.N_DESC N_PT, I_TABLES, I_ACCESS, I_STATUS, I_ORDER, I_DEFAULT, I_RESNAME, I_TYPE, I_OWNER, F_DEFAULT
, I_MODULE, I18N2.N_DESC N_ES, I18N3.N_DESC N_EN, KW1.K_DESC K_PT, KW2.K_DESC K_ES, KW3.K_DESC K_EN,M_ID, I_ID, I_ITEMID, I_FATHER
FROM MPMENU_MENU MPN
INNER JOIN MPMENU_ITEM MPI ON I_ID_MENU = M_ID AND MPI.D_E_L_E_T_ = ' '
LEFT JOIN MPMENU_FUNCTION MPF ON F_ID = I_ID_FUNC AND MPF.D_E_L_E_T_ = ' '
INNER JOIN MPMENU_I18N I18N1 ON I18N1.N_PAREN_ID = I_ID AND I18N1.N_LANG = '1' AND I18N1.D_E_L_E_T_ = ' '
INNER JOIN MPMENU_I18N I18N2 ON I18N2.N_PAREN_ID = I_ID AND I18N2.N_LANG = '2' AND I18N2.D_E_L_E_T_ = ' '
INNER JOIN MPMENU_I18N I18N3 ON I18N3.N_PAREN_ID = I_ID AND I18N3.N_LANG = '3' AND I18N3.D_E_L_E_T_ = ' '
LEFT JOIN MPMENU_KEY_WORDS KW1 ON KW1.K_ID_ITEM = I_ID AND KW1.K_LANG = '1' AND KW1.D_E_L_E_T_ = ' '
LEFT JOIN MPMENU_KEY_WORDS KW2 ON KW2.K_ID_ITEM = I_ID AND KW2.K_LANG = '2' AND KW2.D_E_L_E_T_ = ' '
LEFT JOIN MPMENU_KEY_WORDS KW3 ON KW3.K_ID_ITEM = I_ID AND KW3.K_LANG = '3' AND KW3.D_E_L_E_T_ = ' '
WHERE
M_ID ='7DF74C880039400085D011AC3CC7B1C8' 
AND MPN.D_E_L_E_T_ = ' ' 
--AND F_FUNCTION LIKE '%M730VD%'
ORDER  BY I_ORDER

SELECT * FROM SYS_USR_ACCESS WHERE D_E_L_E_T_='' AND USR_ID='000842'
SELECT * FROM SYS_USR_ACCRESTRIC WHERE D_E_L_E_T_='' AND USR_ID='000842'
SELECT * FROM SYS_USR_ACESSIB WHERE D_E_L_E_T_='' AND USR_ID='000842'
SELECT * FROM SYS_USR_FILIAL WHERE D_E_L_E_T_='' AND USR_ID='000842'
SELECT * FROM SYS_USR_GROUPS WHERE D_E_L_E_T_='' AND USR_ID='000842'
SELECT * FROM SYS_USR_LOGCFG WHERE D_E_L_E_T_='' AND USR_ID='000842'
