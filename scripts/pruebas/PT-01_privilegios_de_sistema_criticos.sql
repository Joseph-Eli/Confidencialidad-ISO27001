-- PT-01: Privilegios de sistema críticos
-- Qué demuestra: Busca cuentas con permisos de administrador que no deberían tener.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-01  Privilegios de sistema críticos
-- Conexión: SYS AS SYSDBA, servicio FREEPDB1
SET LINESIZE 200
SET PAGESIZE 100
SPOOL evidencias/PT-01.txt
PROMPT === PT-01: Privilegios de sistema críticos ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       USER AS ejecutado_por,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') AS fecha
FROM   dual;

SELECT grantee, privilege, admin_option
FROM   dba_sys_privs
WHERE  (privilege LIKE '%ANY%'
        OR privilege IN ('ALTER SYSTEM','BECOME USER',
                         'EXEMPT ACCESS POLICY','EXEMPT REDACTION POLICY'))
AND    grantee NOT IN (SELECT username FROM dba_users WHERE oracle_maintained = 'Y')
AND    grantee NOT IN (SELECT role FROM dba_roles WHERE oracle_maintained = 'Y')
ORDER  BY grantee, privilege;
SPOOL OFF
