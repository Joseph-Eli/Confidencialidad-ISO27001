-- PT-12: Exposición del puerto y cifrado de red
-- Qué demuestra: Limita las conexiones al propio equipo y cifra la comunicación.
-- Estado: prueba propuesta (batería del plan de mejora), no ejecutada.

-- PT-12  Exposición del puerto y cifrado de red
-- Anfitrión:
--   docker port oracle-eliasulate
--     antes:   1521/tcp -> 0.0.0.0:1521
--     después: 1521/tcp -> 127.0.0.1:1521
--   docker inspect --format '{{json .Mounts}}' oracle-eliasulate   (confirmar el volumen)
--   docker exec oracle-eliasulate lsnrctl status                  (ubicar sqlnet.ora)

-- Parámetros a añadir en el sqlnet.ora del servidor:
--   SQLNET.ENCRYPTION_SERVER = REQUIRED
--   SQLNET.ENCRYPTION_TYPES_SERVER = (AES256)
--   SQLNET.CRYPTO_CHECKSUM_SERVER = REQUIRED

SPOOL evidencias/PT-12.txt
-- En una sesión nueva desde SQL Developer:
SELECT SYS_CONTEXT('USERENV','NETWORK_PROTOCOL') AS protocolo FROM dual;
SELECT network_service_banner
FROM   v$session_connect_info
WHERE  sid = SYS_CONTEXT('USERENV','SID');
SPOOL OFF
