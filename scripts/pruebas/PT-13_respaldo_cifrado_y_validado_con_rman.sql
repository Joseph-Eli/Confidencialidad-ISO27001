-- PT-13: Respaldo cifrado y validado con RMAN
-- Qué demuestra: Crea un respaldo cifrado y comprueba que se puede restaurar.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-13  Respaldo cifrado y validado con RMAN
-- Anfitrión: docker exec -it oracle-eliasulate rman target /
-- (guardar la salida completa de RMAN como evidencia)
RMAN> SHOW ENCRYPTION FOR DATABASE;
RMAN> SET ENCRYPTION ON IDENTIFIED BY <clave_respaldo> ONLY;
RMAN> BACKUP PLUGGABLE DATABASE freepdb1;
RMAN> SET DECRYPTION IDENTIFIED BY <clave_respaldo>;
RMAN> RESTORE PLUGGABLE DATABASE freepdb1 VALIDATE;

-- En SQL*Plus, CDB$ROOT:
SPOOL evidencias/PT-13.txt
SELECT recid, handle, encrypted, completion_time
FROM   v$backup_piece
ORDER  BY completion_time DESC
FETCH FIRST 5 ROWS ONLY;
SPOOL OFF
