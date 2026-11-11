-- ════════════════════════════════════════════════════════════
-- Pool League Fargo Rating Tracker — Database Schema
-- CS 273 — Phase 4   Author: Ayman Kaouch   Date: Oct 2026
-- ════════════════════════════════════════════════════════════
DROP DATABASE IF EXISTS FargoLeague;
CREATE DATABASE FargoLeague
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
USE FargoLeague;

-- ── PARENT TABLES: no FK references ─────────────────────────
-- ──────────────────────────────────────────────────────────

-- ── PARENT TABLE 1: Players ─────────────────────────────────
CREATE TABLE Players (
  -- Primary key: surrogate, auto-assigned
  PlayerID     INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  -- Required fields
  FirstName    VARCHAR(50)   NOT NULL,
  LastName     VARCHAR(50)   NOT NULL,
  -- Optional fields
  FargoRating  SMALLINT          NULL,          -- NULL = not rated yet
  Phone        VARCHAR(20)   NULL,
  Email        VARCHAR(254)  NULL UNIQUE,
  -- Business rule constraints
  CONSTRAINT chk_fargo_rating CHECK (FargoRating BETWEEN 100 AND 900),
  CONSTRAINT chk_email        CHECK (Email LIKE '%@%')
);

-- ── PARENT TABLE 2: Formats ─────────────────────────────────
CREATE TABLE Formats (
  -- Primary key: surrogate, auto-assigned
  FormatID      INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  -- Required fields
  FormatName    VARCHAR(50)   NOT NULL UNIQUE,  -- 8-Ball, 9-Ball, 10-Ball...
  -- Optional fields
  RulesSummary  TEXT          NULL,
  -- Business rule constraints
  CONSTRAINT chk_format_name CHECK (FormatName != '')
);

-- ── PARENT TABLE 3: Tournaments ─────────────────────────────
CREATE TABLE Tournaments (
  -- Primary key: surrogate, auto-assigned
  TournamentID    INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  -- Required fields
  TournamentName  VARCHAR(100)  NOT NULL,
  StartDate       DATE          NOT NULL,
  Location        VARCHAR(100)  NOT NULL,
  -- Optional fields
  EndDate         DATE          NULL,           -- NULL = one-day event
  -- Business rule constraints
  CONSTRAINT chk_tournament_dates CHECK (EndDate IS NULL OR EndDate >= StartDate)
);

-- ── CHILD TABLES: reference the parent tables above ─────────
-- ──────────────────────────────────────────────────────────

-- ── CHILD TABLE: Matches ────────────────────────────────────
CREATE TABLE Matches (
  -- Primary key: surrogate, auto-assigned
  MatchID       INT UNSIGNED  AUTO_INCREMENT PRIMARY KEY,
  -- Required fields
  FormatID      INT UNSIGNED  NOT NULL,
  MatchDate     DATETIME      NOT NULL,
  Location      VARCHAR(100)  NOT NULL,
  -- Optional fields
  TournamentID  INT UNSIGNED  NULL,             -- NULL = regular league night
  TableNumber   TINYINT UNSIGNED NULL,          -- NULL = table not assigned yet
  -- Business rule constraints
  CONSTRAINT chk_table_number CHECK (TableNumber >= 1),
  -- FK constraints
  CONSTRAINT fk_matches_format
    FOREIGN KEY (FormatID)
    REFERENCES Formats(FormatID)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_matches_tournament
    FOREIGN KEY (TournamentID)
    REFERENCES Tournaments(TournamentID)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);

-- ── LINKING TABLE: MatchResults (Players ←→ Matches) ────────
-- One row = one player's result in one match.
CREATE TABLE MatchResults (
  -- Both FK columns first
  MatchID   INT UNSIGNED      NOT NULL,
  PlayerID  INT UNSIGNED      NOT NULL,
  -- Extra fields about the relationship
  RaceTo    TINYINT UNSIGNED  NOT NULL,         -- games this player needs (handicap)
  GamesWon  TINYINT UNSIGNED  NOT NULL DEFAULT 0,
  -- Composite PK: the pair must be unique
  PRIMARY KEY (MatchID, PlayerID),
  -- Business rule constraints
  CONSTRAINT chk_race_to   CHECK (RaceTo BETWEEN 1 AND 15),
  CONSTRAINT chk_games_won CHECK (GamesWon <= RaceTo),
  -- Both FKs still need FOREIGN KEY constraints
  CONSTRAINT fk_results_match
    FOREIGN KEY (MatchID)
    REFERENCES Matches(MatchID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_results_player
    FOREIGN KEY (PlayerID)
    REFERENCES Players(PlayerID)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);

-- ── CHILD TABLE: HandicapChart (lookup) ─────────────────────
-- For each format and rating-gap range: the race for each player.
CREATE TABLE HandicapChart (
  -- Primary key: surrogate, auto-assigned
  ChartID     INT UNSIGNED       AUTO_INCREMENT PRIMARY KEY,
  -- Required fields
  FormatID    INT UNSIGNED       NOT NULL,
  MinGap      SMALLINT UNSIGNED  NOT NULL,
  MaxGap      SMALLINT UNSIGNED  NOT NULL,
  HigherRace  TINYINT UNSIGNED   NOT NULL,      -- race for the higher-rated player
  LowerRace   TINYINT UNSIGNED   NOT NULL,      -- race for the lower-rated player
  -- Business rule constraints
  CONSTRAINT uq_chart_format_gap UNIQUE (FormatID, MinGap),
  CONSTRAINT chk_gap_order       CHECK (MaxGap >= MinGap),
  CONSTRAINT chk_higher_race     CHECK (HigherRace BETWEEN 1 AND 15),
  CONSTRAINT chk_lower_race      CHECK (LowerRace BETWEEN 1 AND 15),
  -- FK constraints
  CONSTRAINT fk_handicap_format
    FOREIGN KEY (FormatID)
    REFERENCES Formats(FormatID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
);

-- ── CHILD TABLE: RatingHistory ──────────────────────────────
-- One row each time a player's Fargo Rating changes.
CREATE TABLE RatingHistory (
  -- Primary key: surrogate, auto-assigned
  HistoryID  INT UNSIGNED       AUTO_INCREMENT PRIMARY KEY,
  -- Required fields
  PlayerID   INT UNSIGNED       NOT NULL,
  NewRating  SMALLINT           NOT NULL,
  ChangedAt  DATETIME           NOT NULL DEFAULT CURRENT_TIMESTAMP,
  -- Optional fields
  MatchID    INT UNSIGNED       NULL,           -- NULL = manual adjustment
  OldRating  SMALLINT           NULL,           -- NULL = first rating
  -- Business rule constraints
  CONSTRAINT chk_old_rating CHECK (OldRating BETWEEN 100 AND 900),
  CONSTRAINT chk_new_rating CHECK (NewRating BETWEEN 100 AND 900),
  -- FK constraints
  CONSTRAINT fk_history_player
    FOREIGN KEY (PlayerID)
    REFERENCES Players(PlayerID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_history_match
    FOREIGN KEY (MatchID)
    REFERENCES Matches(MatchID)
    ON DELETE SET NULL
    ON UPDATE CASCADE
);
