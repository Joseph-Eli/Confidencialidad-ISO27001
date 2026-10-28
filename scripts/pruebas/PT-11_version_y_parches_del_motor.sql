-- PT-11: Versión y parches del motor
-- Qué demuestra: Compara la versión instalada con la más reciente de Oracle.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-11  Versión y parches del motor
-- Conexión: SYS AS SYSDBA, servicio FREEPDB1
SET LINESIZE 200
SET PAGESIZE 100
SPOOL evidencias/PT-11.txt
PROMPT === PT-11: Versión y parches del motor ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       USER AS ejecutado_por,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') AS fecha
FROM   dual;

SELECT banner_full FROM v$version;
SELECT patch_id, action, status, action_time, description
FROM   dba_registry_sqlpatch
ORDER  BY action_time;
SPOOL OFF

-- Anfitrión:
--   docker exec oracle-eliasulate bash -c '$ORACLE_HOME/OPatch/opatch lspatches'
--   docker inspect --format '{{.Config.Image}} {{.Created}}' oracle-eliasulate
