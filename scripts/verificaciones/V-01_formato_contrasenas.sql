-- V-01  Formato de las contraseñas guardadas (no muestra ninguna contraseña)
ALTER SESSION SET CONTAINER = FREEPDB1;

SELECT ROWNUM AS fila,
       DBMS_LOB.GETLENGTH(password) AS longitud,
       CASE
         WHEN DBMS_LOB.SUBSTR(password, 8, 1) = 'eyJpdiI6' THEN 'Cifrada (formato Laravel Crypt)'
         WHEN DBMS_LOB.SUBSTR(password, 4, 1) IN ('$2y$','$2a$','$2b$') THEN 'Hash bcrypt'
         ELSE 'Posible texto plano: revisar'
       END AS formato
FROM   bases1.conexion_oracle;

SELECT CASE
         WHEN SUBSTR(password, 1, 4) IN ('$2y$','$2a$','$2b$') THEN 'Hash bcrypt'
         WHEN SUBSTR(password, 1, 9) = '$argon2id' THEN 'Hash argon2id'
         ELSE 'Revisar'
       END AS formato,
       COUNT(*) AS cuentas
FROM   bases1.users
GROUP  BY CASE
         WHEN SUBSTR(password, 1, 4) IN ('$2y$','$2a$','$2b$') THEN 'Hash bcrypt'
         WHEN SUBSTR(password, 1, 9) = '$argon2id' THEN 'Hash argon2id'
         ELSE 'Revisar'
       END;
