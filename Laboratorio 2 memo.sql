DROP DATABASE IF EXISTS streamer_database;
CREATE DATABASE streamer_database;

USE streamer_database;


CREATE TABLE language (
    language_id VARCHAR(45) NOT NULL,
    language_name VARCHAR(45) NOT NULL,
    PRIMARY KEY (language_id)
);


CREATE TABLE game (
    game_id VARCHAR(45) NOT NULL,
    game_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (game_id)
);


CREATE TABLE streamer (
    streamer_id VARCHAR(45) NOT NULL,
    streamer_name VARCHAR(45) NOT NULL,
    language_id VARCHAR(45) NOT NULL,
    PRIMARY KEY (streamer_id),
    FOREIGN KEY (language_id) REFERENCES language(language_id)
);


CREATE TABLE streamer_game (
    streamer_game_id VARCHAR(45) NOT NULL,
    streamer_id VARCHAR(45) NOT NULL,
    game_id VARCHAR(45) NOT NULL,
    game_role VARCHAR(45) NOT NULL,
    PRIMARY KEY (streamer_game_id),
    UNIQUE (streamer_id, game_role),
    FOREIGN KEY (streamer_id) REFERENCES streamer(streamer_id),
    FOREIGN KEY (game_id) REFERENCES game(game_id)
);


CREATE TABLE streamer_statistics (
    statistics_id VARCHAR(45) NOT NULL,
    streamer_id VARCHAR(45) NOT NULL,
    avg_viewers_per_stream INT NOT NULL,
    total_followers INT NOT NULL,
    total_views INT NOT NULL,
    active_days_per_week DECIMAL(3,1) NOT NULL,
    PRIMARY KEY (statistics_id),
    UNIQUE (streamer_id),
    FOREIGN KEY (streamer_id) REFERENCES streamer(streamer_id)
);

-- Verificacion datos cargados 
USE streamer_database;

SELECT 'language' AS tabla, COUNT(*) AS filas FROM language
UNION ALL SELECT 'game', COUNT(*) FROM game
UNION ALL SELECT 'streamer', COUNT(*) FROM streamer
UNION ALL SELECT 'streamer_game', COUNT(*) FROM streamer_game
UNION ALL SELECT 'streamer_statistics', COUNT(*) FROM streamer_statistics;


