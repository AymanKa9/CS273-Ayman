-- =====================================================================
-- CS 273 Database Systems · Phase 4 — MySQL Schema
-- Project: Pool League Fargo Rating Tracker
-- Student: Ayman Kaouch · Fall 2026
--
-- Creates an empty database with all 7 tables from the ERD (erd/erd.png).
-- Tables are created in dependency order: parents before children.
--
--   1. Players          (parent)
--   2. Formats          (parent)
--   3. Tournaments      (parent)
--   4. Matches          -> Formats, Tournaments
--   5. Player_Matches   -> Matches, Players        (M:N linking table)
--   6. Handicap_Chart   -> Formats                 (lookup table)
--   7. Rating_History   -> Players, Matches
-- =====================================================================

DROP DATABASE IF EXISTS FargoLeague;
CREATE DATABASE FargoLeague
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE FargoLeague;


-- ---------------------------------------------------------------------
-- 1. Players — a person registered in the league and their current rating
-- ---------------------------------------------------------------------
CREATE TABLE Players (
  player_id     INT           NOT NULL AUTO_INCREMENT,
  first_name    VARCHAR(50)   NOT NULL,
  last_name     VARCHAR(50)   NOT NULL,
  fargo_rating  SMALLINT      NULL DEFAULT NULL,   -- NULL = not yet rated
  phone_number  VARCHAR(20)   NULL DEFAULT NULL,
  email         VARCHAR(100)  NULL DEFAULT NULL,

  CONSTRAINT pk_players PRIMARY KEY (player_id),
  CONSTRAINT uq_players_email UNIQUE (email),
  CONSTRAINT chk_players_fargo_rating CHECK (fargo_rating BETWEEN 100 AND 900),
  CONSTRAINT chk_players_first_name   CHECK (first_name REGEXP '^[A-Za-z][A-Za-z '' -]*$'),
  CONSTRAINT chk_players_last_name    CHECK (last_name  REGEXP '^[A-Za-z][A-Za-z '' -]*$'),
  CONSTRAINT chk_players_email        CHECK (email LIKE '%_@_%._%'),
  CONSTRAINT chk_players_phone        CHECK (phone_number REGEXP '^[0-9+() .-]{7,20}$')
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- 2. Formats — a game type (8-Ball, 9-Ball, 10-Ball) and its rules
-- ---------------------------------------------------------------------
CREATE TABLE Formats (
  format_id      INT          NOT NULL AUTO_INCREMENT,
  format_name    VARCHAR(50)  NOT NULL,
  rules_summary  TEXT         NULL,

  CONSTRAINT pk_formats PRIMARY KEY (format_id),
  CONSTRAINT uq_formats_format_name UNIQUE (format_name)
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- 3. Tournaments — an event that groups a set of matches
-- ---------------------------------------------------------------------
CREATE TABLE Tournaments (
  tournament_id    INT           NOT NULL AUTO_INCREMENT,
  tournament_name  VARCHAR(100)  NOT NULL,
  start_date       DATE          NOT NULL,
  end_date         DATE          NULL DEFAULT NULL,   -- NULL = one-day or ongoing
  location         VARCHAR(100)  NOT NULL,

  CONSTRAINT pk_tournaments PRIMARY KEY (tournament_id),
  CONSTRAINT chk_tournaments_dates CHECK (end_date >= start_date)
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- 4. Matches — one scheduled match
--    Formats     1:N Matches  (every match has exactly one format)
--    Tournaments 1:N Matches  (optional: league nights have no tournament)
-- ---------------------------------------------------------------------
CREATE TABLE Matches (
  match_id       INT           NOT NULL AUTO_INCREMENT,
  tournament_id  INT           NULL DEFAULT NULL,   -- NULL = regular league match
  format_id      INT           NOT NULL,
  match_date     DATETIME      NOT NULL,
  location       VARCHAR(100)  NOT NULL,
  table_number   TINYINT UNSIGNED NULL DEFAULT NULL, -- NULL = not yet assigned

  CONSTRAINT pk_matches PRIMARY KEY (match_id),
  CONSTRAINT fk_matches_tournament_id
    FOREIGN KEY (tournament_id) REFERENCES Tournaments (tournament_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_matches_format_id
    FOREIGN KEY (format_id) REFERENCES Formats (format_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_matches_table_number CHECK (table_number >= 1)
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- 5. Player_Matches — linking table that resolves Players M:N Matches.
--    One row per player per match (two rows in a normal match).
-- ---------------------------------------------------------------------
CREATE TABLE Player_Matches (
  player_match_id  INT      NOT NULL AUTO_INCREMENT,
  match_id         INT      NOT NULL,
  player_id        INT      NOT NULL,
  race_to          TINYINT  NOT NULL,                 -- this player's handicap race
  games_won        TINYINT  NOT NULL DEFAULT 0,
  is_winner        BOOLEAN  NOT NULL DEFAULT FALSE,

  CONSTRAINT pk_player_matches PRIMARY KEY (player_match_id),
  CONSTRAINT uq_player_matches_match_player UNIQUE (match_id, player_id),
  CONSTRAINT fk_player_matches_match_id
    FOREIGN KEY (match_id) REFERENCES Matches (match_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_player_matches_player_id
    FOREIGN KEY (player_id) REFERENCES Players (player_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT chk_player_matches_race_to   CHECK (race_to BETWEEN 1 AND 15),
  CONSTRAINT chk_player_matches_games_won CHECK (games_won BETWEEN 0 AND race_to)
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- 6. Handicap_Chart — lookup table: for each format and rating-gap range,
--    the race for the higher- and lower-rated player.
-- ---------------------------------------------------------------------
CREATE TABLE Handicap_Chart (
  chart_id     INT       NOT NULL AUTO_INCREMENT,
  format_id    INT       NOT NULL,
  min_gap      SMALLINT  NOT NULL,
  max_gap      SMALLINT  NOT NULL,
  higher_race  TINYINT   NOT NULL,
  lower_race   TINYINT   NOT NULL,

  CONSTRAINT pk_handicap_chart PRIMARY KEY (chart_id),
  CONSTRAINT uq_handicap_chart_format_min_gap UNIQUE (format_id, min_gap),
  CONSTRAINT fk_handicap_chart_format_id
    FOREIGN KEY (format_id) REFERENCES Formats (format_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT chk_handicap_chart_min_gap     CHECK (min_gap >= 0),
  CONSTRAINT chk_handicap_chart_gap_order   CHECK (max_gap >= min_gap),
  CONSTRAINT chk_handicap_chart_higher_race CHECK (higher_race BETWEEN 1 AND 15),
  CONSTRAINT chk_handicap_chart_lower_race  CHECK (lower_race  BETWEEN 1 AND 15)
) ENGINE = InnoDB;


-- ---------------------------------------------------------------------
-- 7. Rating_History — one row each time a player's Fargo Rating changes
--    Players 1:N Rating_History (mandatory)
--    Matches 1:N Rating_History (optional: NULL = manual adjustment)
-- ---------------------------------------------------------------------
CREATE TABLE Rating_History (
  history_id  INT       NOT NULL AUTO_INCREMENT,
  player_id   INT       NOT NULL,
  match_id    INT       NULL DEFAULT NULL,
  old_rating  SMALLINT  NULL DEFAULT NULL,           -- NULL = first rating
  new_rating  SMALLINT  NOT NULL,
  changed_at  DATETIME  NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT pk_rating_history PRIMARY KEY (history_id),
  CONSTRAINT fk_rating_history_player_id
    FOREIGN KEY (player_id) REFERENCES Players (player_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_rating_history_match_id
    FOREIGN KEY (match_id) REFERENCES Matches (match_id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT chk_rating_history_old_rating CHECK (old_rating BETWEEN 100 AND 900),
  CONSTRAINT chk_rating_history_new_rating CHECK (new_rating BETWEEN 100 AND 900)
) ENGINE = InnoDB;
