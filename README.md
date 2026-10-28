# Controles ISO 27001:2022 para la confidencialidad del DBA

**EIF402 Administración de Bases de Datos · Universidad Nacional de Costa Rica · II Ciclo 2026**
**Estudiante:** Joseph Elías Ulate Aguilar

Marco de controles basado en el Anexo A de ISO/IEC 27001:2022 para proteger la confidencialidad de una base de datos Oracle desde el rol del DBA. Incluye la evaluación de una base real con un diagnóstico de solo lectura, la matriz de madurez 0-4 y un plan de mejora.

- **Artefacto interactivo:** `artefacto/index.html` (se abre con doble clic en cualquier navegador)
- **Informe:** `informe/` (PDF con marco teórico, uso de IA, declaración jurada y referencias APA 7)

## Entorno

| Elemento | Valor |
| --- | --- |
| Motor | Oracle AI Database 26ai Free 23.26.1 |
| Contenedor Docker | `oracle-eliasulate` |
| Base analizada | PDB `FREEPDB1` |
| Herramientas | SQL Developer, SQL*Plus, RMAN, PowerShell |
| Metodología | PHVA (Planificar, Hacer, Verificar, Actuar) |

## Estructura

```
├── README.md
├── diagnostico_confidencialidad.sql     Diagnóstico de solo lectura (bloques D00-D17)
├── demostracion_diagnostico.ps1         Ejecuta el diagnóstico y guarda la evidencia con fecha
├── artefacto/index.html                 Artefacto interactivo
├── evidencias/                          Salidas del diagnóstico (20 y 22 oct 2026)
├── informe/                             Informe en PDF
└── scripts/
    ├── pruebas/                         Batería de pruebas PT-00 a PT-17 y datos de prueba
    └── verificaciones/                  Verificaciones complementarias V-01 a V-03
```

## Reproducir el diagnóstico

El diagnóstico solo hace consultas y no modifica la base. Desde la raíz del repositorio, en PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\demostracion_diagnostico.ps1
```

El script enciende el contenedor si está apagado, espera a que `FREEPDB1` abra, ejecuta el diagnóstico y guarda las salidas en `evidencias\<fecha_hora>\`.

## Evidencias

| Corrida | Archivos | Resultado |
| --- | --- | --- |
| 20 oct 2026 | `evidencias/D-linea-base.txt`, `evidencias/D-red.txt` | Línea base: 18 de 18 filas de la matriz en No cumple |
| 22 oct 2026 | `evidencias/2026-10-22_1132/` | Mismos resultados; solo cambian la fecha y la hora |

## Batería de pruebas

Las pruebas de `scripts/pruebas/` forman la batería propuesta del plan de mejora; comprueban cada control una vez aplicado. Trabajan sobre un esquema de demostración (`APP_OWNER`) con datos ficticios.

1. Ejecutar primero `00_datos_prueba.sql` como SYS en `FREEPDB1`.
2. Ejecutar cada `PT-xx` y guardar su salida en `evidencias/`.

Advertencias:

- **PT-06** (TDE) reinicia la base.
- **PT-12** (red) puede requerir recrear el contenedor; antes, confirmar que el volumen de datos esté montado.
- **PT-13** (RMAN) y **PT-16** (clon) usan espacio en disco.
- Respaldar `FREEPDB1` antes de ejecutar cualquier prueba que modifique la configuración.

## Seguridad del repositorio

El repositorio no contiene contraseñas. Los scripts piden las claves al ejecutarse con variables de sustitución (`&clave_...`).

## Uso de inteligencia artificial

El uso de IA está declarado en la sección 7 del informe, junto con la declaración jurada.
