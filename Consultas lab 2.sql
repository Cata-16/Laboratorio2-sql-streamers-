-- CONSULTAS BÁSICAS

-- 1.1 FILTRADO (WHERE con dos condiciones)
-- Pregunta: ¿Qué streamers tienen más de 1 millón de seguidores y transmiten al menos 5 días por semana?

SELECT s.streamer_name,
       st.total_followers,
       st.active_days_per_week
FROM streamer s
JOIN streamer_statistics st ON s.streamer_id = st.streamer_id
WHERE st.total_followers > 1000000
  AND st.active_days_per_week >= 5
ORDER BY st.total_followers DESC;

-- 1.2 JOIN DE DOS ENTIDADES (streamer + language)
-- Pregunta: ¿En qué idioma transmite cada streamer?

SELECT s.streamer_name,
       l.language_name
FROM streamer s
JOIN language l ON s.language_id = l.language_id
ORDER BY l.language_name, s.streamer_name;


-- 1.3 JOIN DE TRES ENTIDADES (streamer + streamer_game + game)
-- Pregunta: ¿Cuál es el juego principal de cada streamer?

SELECT s.streamer_name,
       g.game_name
FROM streamer s
JOIN streamer_game sg ON s.streamer_id = sg.streamer_id
JOIN game g           ON sg.game_id = g.game_id
WHERE sg.game_role = 'main'
ORDER BY s.streamer_name;

-- 1.4 AGREGACIÓN Y GROUP BY
-- Pregunta: ¿Cuántos streamers hay por idioma?

SELECT l.language_name,
       COUNT(*) AS total_streamers
FROM streamer s
JOIN language l ON s.language_id = l.language_id
GROUP BY l.language_name
ORDER BY total_streamers DESC;

-- CONSULTAS DE ANÁLISIS

-- ANÁLISIS 1A: Juegos más frecuentes como transmisión PRINCIPAL
-- Pregunta: ¿Cuál es el juego que más streamers tienen como principal?

SELECT g.game_name,
       COUNT(*) AS streamers_main
FROM streamer_game sg
JOIN game g ON sg.game_id = g.game_id
WHERE sg.game_role = 'main'
GROUP BY g.game_name
ORDER BY streamers_main DESC
LIMIT 5;

-- ANÁLISIS 1B: Juegos más frecuentes como SEGUNDA opción
-- Pregunta: ¿Coincide con el juego que más aparece como secundario?

SELECT g.game_name,
       COUNT(*) AS streamers_secondary
FROM streamer_game sg
JOIN game g ON sg.game_id = g.game_id
WHERE sg.game_role = 'secondary'
GROUP BY g.game_name
ORDER BY streamers_secondary DESC
LIMIT 5;

-- ANÁLISIS 2: Idioma con mayor promedio de seguidores por streamer
-- Pregunta: ¿Es también el idioma con más streamers, o el liderazgo se sostiene con pocos streamers muy grandes?

SELECT l.language_name,
       COUNT(*)                          AS total_streamers,
       ROUND(AVG(st.total_followers), 0) AS avg_followers,
       MAX(st.total_followers)           AS max_followers,
       MIN(st.total_followers)           AS min_followers
FROM streamer s
JOIN language l             ON s.language_id = l.language_id
JOIN streamer_statistics st ON s.streamer_id = st.streamer_id
GROUP BY l.language_name
ORDER BY avg_followers DESC;

-- ANÁLISIS 3: Juegos que son principal de unos streamers
-- y secundario de otros, comparando seguidores y vistas totales

SELECT g.game_name,
       m.streamers_main,
       m.avg_followers_main,
       m.avg_views_main,
       sc.streamers_secondary,
       sc.avg_followers_secondary,
       sc.avg_views_secondary
FROM game g
JOIN (SELECT sg.game_id,
             COUNT(*)                         AS streamers_main,
             ROUND(AVG(st.total_followers),0) AS avg_followers_main,
             ROUND(AVG(st.total_views),0)     AS avg_views_main
      FROM streamer_game sg
      JOIN streamer_statistics st ON sg.streamer_id = st.streamer_id
      WHERE sg.game_role = 'main'
      GROUP BY sg.game_id) m ON g.game_id = m.game_id
JOIN (SELECT sg.game_id,
             COUNT(*)                         AS streamers_secondary,
             ROUND(AVG(st.total_followers),0) AS avg_followers_secondary,
             ROUND(AVG(st.total_views),0)     AS avg_views_secondary
      FROM streamer_game sg
      JOIN streamer_statistics st ON sg.streamer_id = st.streamer_id
      WHERE sg.game_role = 'secondary'
      GROUP BY sg.game_id) sc ON g.game_id = sc.game_id
ORDER BY m.streamers_main DESC;

-- ANÁLISIS 4A: Rango de días activos vs. audiencia promedio (todos los streamers)
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
USE streamer_database;
GROUP BY rango_dias_activos
ORDER BY rango_dias_activos;

-- ANÁLISIS 4B: Misma consulta excluyendo audiencia = 0 (registros que parecen datos faltantes)

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
