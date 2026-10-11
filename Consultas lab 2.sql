USE streamer_database;

-- CONSULTAS BÁSICAS

-- 1.1 FILTRADO (WHERE con dos condiciones)
-- Pregunta: ¿Qué streamers tienen más de 1 millón de seguidores y transmiten al menos 5 días por semana?

SELECT streamer.streamer_name,
       streamer_statistics.total_followers,
       streamer_statistics.active_days_per_week
FROM streamer
JOIN streamer_statistics
  ON streamer.streamer_id = streamer_statistics.streamer_id
WHERE streamer_statistics.total_followers > 1000000
  AND streamer_statistics.active_days_per_week >= 5
ORDER BY streamer_statistics.total_followers DESC;

-- 1.2 JOIN DE DOS ENTIDADES (streamer + language)
-- Pregunta: ¿En qué idioma transmite cada streamer?

SELECT streamer.streamer_name,
       language.language_name
FROM streamer
JOIN language
  ON streamer.language_id = language.language_id
ORDER BY language.language_name, streamer.streamer_name;

-- 1.3 JOIN DE TRES ENTIDADES (streamer + streamer_game + game)
-- Pregunta: ¿Cuál es el juego principal de cada streamer?

SELECT streamer.streamer_name,
       game.game_name
FROM streamer
JOIN streamer_game
  ON streamer.streamer_id = streamer_game.streamer_id
JOIN game
  ON streamer_game.game_id = game.game_id
WHERE streamer_game.game_role = 'main'
ORDER BY streamer.streamer_name;

-- 1.4 AGREGACIÓN Y GROUP BY
-- Pregunta: ¿Cuántos streamers hay por idioma?

SELECT language.language_name,
       COUNT(*) AS total_streamers
FROM streamer
JOIN language
  ON streamer.language_id = language.language_id
GROUP BY language.language_name
ORDER BY total_streamers DESC;

-- CONSULTAS DE ANÁLISIS

-- ANÁLISIS 1A: Juegos más frecuentes como transmisión principal
-- Pregunta: ¿Cuál es el juego que más streamers tienen como principal?

SELECT game.game_name,
       COUNT(*) AS streamers_main
FROM streamer_game
JOIN game
  ON streamer_game.game_id = game.game_id
WHERE streamer_game.game_role = 'main'
GROUP BY game.game_name
ORDER BY streamers_main DESC
LIMIT 5;

-- ANÁLISIS 1B: Juegos más frecuentes como SEGUNDA opción
-- Pregunta: ¿Coincide con el juego que más aparece como secundario?

SELECT game.game_name,
       COUNT(*) AS streamers_secondary
FROM streamer_game
JOIN game
  ON streamer_game.game_id = game.game_id
WHERE streamer_game.game_role = 'secondary'
GROUP BY game.game_name
ORDER BY streamers_secondary DESC
LIMIT 5;

-- ANÁLISIS 2: Idioma con mayor promedio de seguidores por streamer
-- Pregunta: ¿Es también el idioma con más streamers, o el liderazgo se sostiene con pocos streamers muy grandes?

SELECT language.language_name,
       COUNT(*) AS total_streamers,
       ROUND(AVG(streamer_statistics.total_followers), 0) AS avg_followers,
       MAX(streamer_statistics.total_followers) AS max_followers,
       MIN(streamer_statistics.total_followers) AS min_followers
FROM streamer
JOIN language
  ON streamer.language_id = language.language_id
JOIN streamer_statistics
  ON streamer.streamer_id = streamer_statistics.streamer_id
GROUP BY language.language_name
ORDER BY avg_followers DESC;

-- ANÁLISIS 2B (complementaria): mediana de seguidores por idioma
-- Contrasta el promedio del análisis 2 con una medida menos sensible a valores extremos. Requiere MySQL 8.0 o superior.

SELECT language_name,
       MAX(total_streamers_idioma) AS total_streamers,
       ROUND(AVG(total_followers), 0) AS mediana_followers
FROM (SELECT language.language_name,
             streamer_statistics.total_followers,
             ROW_NUMBER() OVER (
               PARTITION BY language.language_id
               ORDER BY streamer_statistics.total_followers) AS posicion,
             COUNT(*) OVER (
               PARTITION BY language.language_id) AS total_streamers_idioma
      FROM streamer
      JOIN language
        ON streamer.language_id = language.language_id
      JOIN streamer_statistics
        ON streamer.streamer_id = streamer_statistics.streamer_id)
     AS seguidores_ordenados
WHERE posicion IN ((total_streamers_idioma + 1) DIV 2,
                   (total_streamers_idioma + 2) DIV 2)
GROUP BY language_name
ORDER BY mediana_followers DESC;

-- ANÁLISIS 3: Juegos que son principal de unos streamers y secundario de otros, comparando seguidores y vistas totales

SELECT game.game_name,
       principal_por_juego.streamers_main,
       principal_por_juego.avg_followers_main,
       principal_por_juego.avg_views_main,
       secundario_por_juego.streamers_secondary,
       secundario_por_juego.avg_followers_secondary,
       secundario_por_juego.avg_views_secondary
FROM game
JOIN (SELECT streamer_game.game_id,
             COUNT(*) AS streamers_main,
             ROUND(AVG(streamer_statistics.total_followers), 0) AS avg_followers_main,
             ROUND(AVG(streamer_statistics.total_views), 0) AS avg_views_main
      FROM streamer_game
      JOIN streamer_statistics
        ON streamer_game.streamer_id = streamer_statistics.streamer_id
      WHERE streamer_game.game_role = 'main'
      GROUP BY streamer_game.game_id) AS principal_por_juego
  ON game.game_id = principal_por_juego.game_id
JOIN (SELECT streamer_game.game_id,
             COUNT(*) AS streamers_secondary,
             ROUND(AVG(streamer_statistics.total_followers), 0) AS avg_followers_secondary,
             ROUND(AVG(streamer_statistics.total_views), 0) AS avg_views_secondary
      FROM streamer_game
      JOIN streamer_statistics
        ON streamer_game.streamer_id = streamer_statistics.streamer_id
      WHERE streamer_game.game_role = 'secondary'
      GROUP BY streamer_game.game_id) AS secundario_por_juego
  ON game.game_id = secundario_por_juego.game_id
ORDER BY principal_por_juego.streamers_main DESC;

-- ANÁLISIS 4A: Rango de días activos vs. audiencia promedio(todos los streamers)
-- Pregunta: ¿Qué rango tiene el mejor promedio de vistas por transmisión? ¿Más días activos implica más audiencia?

SELECT CASE
           WHEN active_days_per_week < 3 THEN '1) Menos de 3 dias'
           WHEN active_days_per_week < 5 THEN '2) 3 a 4.9 dias'
           WHEN active_days_per_week < 7 THEN '3) 5 a 6.9 dias'
           ELSE '4) 7 dias'
       END AS rango_dias_activos,
       COUNT(*) AS total_streamers,
       ROUND(AVG(avg_viewers_per_stream), 0) AS avg_viewers_por_transmision
FROM streamer_statistics
GROUP BY rango_dias_activos
ORDER BY rango_dias_activos;

-- ANÁLISIS 4B: Misma consulta excluyendo audiencia = 0
-- (registros que parecen datos faltantes)

SELECT CASE
           WHEN active_days_per_week < 3 THEN '1) Menos de 3 dias'
           WHEN active_days_per_week < 5 THEN '2) 3 a 4.9 dias'
           WHEN active_days_per_week < 7 THEN '3) 5 a 6.9 dias'
           ELSE '4) 7 dias'
       END AS rango_dias_activos,
       COUNT(*) AS total_streamers,
       ROUND(AVG(avg_viewers_per_stream), 0) AS avg_viewers_por_transmision
FROM streamer_statistics
WHERE avg_viewers_per_stream > 0
GROUP BY rango_dias_activos
ORDER BY rango_dias_activos;
