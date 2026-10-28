-- PT-04: Cuentas, estado y contraseñas por defecto
-- Qué demuestra: Lista las cuentas y comprueba que ninguna use una contraseña de fábrica.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-04  Cuentas, estado y contraseñas
-- Conexión: SYS AS SYSDBA, servicio FREEPDB1
SET LINESIZE 200
SET PAGESIZE 100
SPOOL evidencias/PT-04.txt
PROMPT === PT-04: Cuentas, estado y contraseñas ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       USER AS ejecutado_por,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') AS fecha
FROM   dual;

SELECT username, account_status, profile, authentication_type,
       password_versions, last_login
FROM   dba_users
WHERE  oracle_maintained = 'N'
ORDER  BY username;

SELECT u.username, u.account_status
FROM   dba_users_with_defpwd d
JOIN   dba_users u ON u.username = d.username
ORDER  BY u.account_status, u.username;
SPOOL OFF
