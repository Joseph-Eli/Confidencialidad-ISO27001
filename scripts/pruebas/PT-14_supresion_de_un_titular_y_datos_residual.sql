-- PT-14: Supresión de un titular y datos residuales
-- Qué demuestra: Borra un registro y muestra si queda alguna copia recuperable.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-14  Supresión de un titular
-- Conexión: APP_OWNER y luego SYS, servicio FREEPDB1
SET LINESIZE 200
SET PAGESIZE 100
SPOOL evidencias/PT-14.txt
PROMPT === PT-14: Supresión de un titular ===
SELECT SYS_CONTEXT('USERENV','CON_NAME') AS contenedor,
       USER AS ejecutado_por,
       TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS') AS fecha
FROM   dual;

-- Como APP_OWNER:
DELETE FROM app_owner.clientes WHERE id_cliente = 999;
COMMIT;
SELECT COUNT(*) FROM app_owner.clientes WHERE id_cliente = 999;   -- esperado 0

SELECT id_cliente, nombre
FROM   app_owner.clientes AS OF TIMESTAMP SYSTIMESTAMP - INTERVAL '5' MINUTE
WHERE  id_cliente = 999;   -- evidencia del dato residual en undo

-- Como SYS:
SELECT owner, original_name, droptime FROM dba_recyclebin WHERE owner = 'APP_OWNER';
SELECT name, value FROM v$parameter WHERE name IN ('recyclebin','undo_retention');
-- Tablas temporales sin pasar por la papelera: DROP TABLE ... PURGE;
SPOOL OFF
