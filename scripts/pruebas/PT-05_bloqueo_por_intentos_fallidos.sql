-- PT-05: Bloqueo por intentos fallidos
-- Qué demuestra: Demuestra que la cuenta se bloquea tras 3 contraseñas incorrectas.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-05  Bloqueo por intentos fallidos
-- Conexión: SYS AS SYSDBA, servicio FREEPDB1
SET LINESIZE 200
SET PAGESIZE 100
SPOOL evidencias/PT-05.txt
PROMPT === PT-05: Bloqueo por intentos fallidos ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       USER AS ejecutado_por,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') AS fecha
FROM   dual;

CREATE PROFILE perfil_app LIMIT
  FAILED_LOGIN_ATTEMPTS 3
  PASSWORD_LOCK_TIME    1/24
  PASSWORD_LIFE_TIME    90
  PASSWORD_REUSE_MAX    5
  PASSWORD_REUSE_TIME   365;
-- Opcional: PASSWORD_VERIFY_FUNCTION ora12c_verify_function, si existe en el PDB
ALTER USER usr_consulta PROFILE perfil_app;
ALTER USER usr_otro     PROFILE perfil_app;

SELECT resource_name, limit
FROM   dba_profiles
WHERE  profile = 'PERFIL_APP' AND resource_type = 'PASSWORD';

-- Ahora: 3 conexiones de USR_CONSULTA con clave errónea y una con la correcta.
SELECT username, account_status, lock_date
FROM   dba_users
WHERE  username = 'USR_CONSULTA';

-- Restaurar al terminar la prueba:
-- ALTER USER usr_consulta ACCOUNT UNLOCK;
SPOOL OFF
