# Laboratorio N.º 4: Modelado y análisis de datos con SQL

Universidad de San Buenaventura, Ingeniería Multimedia, Bogotá.

**Integrantes:** Rosa Catalina Acuña Ramírez y Claudia Lorena Cerquera Gonzalez

## Descripción
Se transformó el conjunto de datos `Streamers.csv` (999 streamers, 17 columnas)
en una base de datos relacional normalizada en MySQL. Se desarrolló un programa
de carga en Node.js y se resolvieron cuatro consultas básicas y cuatro consultas
de análisis sobre el dataset asignado.

## Modelo de datos
Cinco tablas en tercera forma normal:

| Tabla | Descripción |
|---|---|
| `language` | Idiomas de transmisión |
| `game` | Videojuegos |
| `streamer` | Streamers y referencia a su idioma |
| `streamer_game` | Tabla puente N:M entre streamer y juego; `game_role` distingue el juego principal (`main`) del secundario (`secondary`) |
| `streamer_statistics` | Métricas de audiencia y actividad (relación 1:1 con `streamer`) |

De las 17 columnas originales se usaron 8: `NAME`, `LANGUAGE`,
`MOST_STREAMED_GAME`, `2ND_MOST_STREAMED_GAME`, `AVG_VIEWERS_PER_STREAM`,
`TOTAL_FOLLOWERS`, `TOTAL_VIEWS` y `ACTIVE_DAYS_PER_WEEK`. La justificación
completa está en el informe.

## Estructura del repositorio
```
├── data/Streamers.csv               Conjunto de datos de origen
├── env/mysqlConfig.example.js       Plantilla de configuración
├── services/mysql.service.js        Conexión a MySQL
├── load/                            Scripts de carga (uno por tabla)
├── sql/01_schema.sql                Script DDL
├── sql/02_consultas_basicas.sql     4 consultas básicas
└── sql/03_consultas_analisis.sql    4 consultas de análisis
```

## Requisitos
- Node.js
- MySQL 8.0 o superior (la consulta 2b usa funciones de ventana)

## Ejecución
1. Instalar dependencias: `npm install`
2. Copiar `env/mysqlConfig.example.js` como `env/mysqlConfig.js` y escribir el
   usuario y la contraseña de MySQL.
3. Ejecutar `sql/01_schema.sql` en MySQL Workbench. Este script elimina y
   recrea la base `streamer_database`.
4. Desde la raíz del proyecto, ejecutar en este orden:
```
   node load/load.language.js
   node load/load.game.js
   node load/load.streamer.js
   node load/load.streamer_statistics.js
   node load/load.streamer_game.js
```
5. Verificar la carga. Resultado esperado: `language` 19, `game` 211,
   `streamer` 999, `streamer_statistics` 999 y `streamer_game` 1921.
6. Ejecutar las consultas de `sql/02_consultas_basicas.sql` y
   `sql/03_consultas_analisis.sql`.

## Consultas
**Básicas:** filtrado con dos condiciones, JOIN de dos tablas, JOIN de tres
tablas y agregación con `GROUP BY`.

**Análisis (dataset Streamers.csv):**
1. Juego más frecuente como transmisión principal y como segunda opción.
2. Idioma con mayor promedio de seguidores por streamer (con consulta
   complementaria de mediana).
3. Juegos que son principales de unos streamers y secundarios de otros.
4. Audiencia promedio por rango de días activos por semana.

## Notas sobre los datos
- 77 streamers no tienen juego secundario.
- 120 streamers tienen audiencia promedio de cero (se tratan como datos
  faltantes).
- La tabla `game` tiene 211 registros y no 213, porque MySQL no distingue
  mayúsculas de minúsculas y unifica `VALORANT`/`Valorant` y
  `Trackmania`/`TrackMania`.
