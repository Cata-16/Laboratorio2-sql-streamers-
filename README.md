# Laboratorio Nº 2: Modelado y análisis de datos con SQL

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
├── Laboratorio 2 memo.sql        Script DDL (esquema de 5 tablas) y verificación de la carga
├── Consultas lab 2.sql           4 consultas básicas y 4 consultas de análisis
└── intento de laboratorio/       Programa de carga en Node.js
    ├── data/Streamers.csv        Conjunto de datos de origen
    ├── env/                      Configuración de la conexión a MySQL
    ├── services/mysql.service.js Conexión a MySQL
    └── load/                     Scripts de carga (uno por tabla)
```

## Requisitos
- Node.js
- MySQL 8.0 o superior (la consulta 2b usa funciones de ventana)

## Ejecución
1. Ejecutar `Laboratorio 2 memo.sql` en MySQL Workbench (hasta antes de la
   sección de verificación). Este script elimina y recrea la base
   `streamer_database`, por lo que debe ejecutarse **antes** de la carga y
   nunca después.
2. Entrar a la carpeta del proyecto: `cd "intento de laboratorio"`
3. Instalar dependencias: `npm install`
4. Configurar la conexión en `env/mysqlConfig.js` con el usuario y la
   contraseña de MySQL (`host`, `user`, `password` y `database:
   'streamer_database'`).
5. Ejecutar en este orden:
```
   node load/load.language.js
   node load/load.game.js
   node load/load.streamer.js
   node load/load.streamer_statistics.js
   node load/load.streamer_game.js
```
6. Verificar la carga con la consulta del final de `Laboratorio 2 memo.sql`.
   Resultado esperado: `language` 19, `game` 211, `streamer` 999,
   `streamer_statistics` 999 y `streamer_game` 1921.
7. Ejecutar las consultas de `Consultas lab 2.sql` en MySQL Workbench.

## Consultas
**Básicas (1.1 a 1.4):** filtrado con dos condiciones, JOIN de dos tablas,
JOIN de tres tablas y agregación con `GROUP BY`.

**Análisis (dataset Streamers.csv):**
1. Juego más frecuente como transmisión principal y como segunda opción
   (consultas 1A y 1B).
2. Idioma con mayor promedio de seguidores por streamer, con una consulta
   complementaria de mediana (consultas 2 y 2B).
3. Juegos que son principales de unos streamers y secundarios de otros.
4. Audiencia promedio por rango de días activos por semana, con y sin
   registros de audiencia cero (consultas 4A y 4B).

## Notas sobre los datos
- 77 streamers no tienen juego secundario.
- 120 streamers tienen audiencia promedio de cero (se tratan como datos
  faltantes).
- La tabla `game` tiene 211 registros y no 213, porque MySQL no distingue
  mayúsculas de minúsculas y unifica `VALORANT`/`Valorant` y
  `Trackmania`/`TrackMania`.
