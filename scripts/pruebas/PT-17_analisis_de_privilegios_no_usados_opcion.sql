-- PT-17: Análisis de privilegios no usados (opcional)
-- Qué demuestra: Encuentra permisos que se dieron pero nunca se usan, para quitarlos.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-17  Análisis de privilegios no usados
-- Conexión: SYS AS SYSDBA, servicio FREEPDB1
SET LINESIZE 200
SET PAGESIZE 100
SPOOL evidencias/PT-17.txt
PROMPT === PT-17: Análisis de privilegios no usados ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       USER AS ejecutado_por,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') AS fecha
FROM   dual;

BEGIN
  DBMS_PRIVILEGE_CAPTURE.CREATE_CAPTURE(
    name => 'CAP_APP',
    type => DBMS_PRIVILEGE_CAPTURE.G_DATABASE);
  DBMS_PRIVILEGE_CAPTURE.ENABLE_CAPTURE('CAP_APP');
END;
/
-- ...ejecutar la carga normal de la aplicación...
BEGIN
  DBMS_PRIVILEGE_CAPTURE.DISABLE_CAPTURE('CAP_APP');
  DBMS_PRIVILEGE_CAPTURE.GENERATE_RESULT('CAP_APP');
END;
/
SELECT * FROM dba_unused_privs WHERE capture = 'CAP_APP';
SPOOL OFF
