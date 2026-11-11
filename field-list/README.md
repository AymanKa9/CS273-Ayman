# Database Field List & Key Specifications

**Project:** Pool League Fargo Rating Tracker
**Student:** Ayman Kaouch · CS 273 Database Systems · Fall 2026

**Key legend:** PK = primary key · FK = foreign key · AK = alternate key (unique) · UQ = composite unique constraint
**Naming:** every primary key is TableName + ID (`PlayerID`, `MatchID`, ...). Every table has a surrogate `INT UNSIGNED AUTO_INCREMENT` PK, except the linking table MatchResults, which uses a composite PK of its two FKs.

---

## Table 1: `Players`
A person registered in the league and their current Fargo Rating.

| Field | MySQL Type | NULL | Default | Constraints / Notes |
| :--- | :--- | :--- | :--- | :--- |
| `PlayerID` | `INT UNSIGNED` | NOT NULL | AUTO_INCREMENT | PK |
| `FirstName` | `VARCHAR(50)` | NOT NULL | — | |
| `LastName` | `VARCHAR(50)` | NOT NULL | — | |
| `FargoRating` | `SMALLINT` | NULL | NULL | CHECK 100–900; NULL = not rated yet |
| `Phone` | `VARCHAR(20)` | NULL | NULL | |
| `Email` | `VARCHAR(254)` | NULL | NULL | AK (UNIQUE); CHECK contains `@` |

## Table 2: `Formats`
A game type the league plays (8-Ball, 9-Ball, 10-Ball...).

| Field | MySQL Type | NULL | Default | Constraints / Notes |
| :--- | :--- | :--- | :--- | :--- |
| `FormatID` | `INT UNSIGNED` | NOT NULL | AUTO_INCREMENT | PK |
| `FormatName` | `VARCHAR(50)` | NOT NULL | — | AK (UNIQUE); CHECK not empty |
| `RulesSummary` | `TEXT` | NULL | NULL | |

## Table 3: `Tournaments`
A tournament event that groups a set of matches.

| Field | MySQL Type | NULL | Default | Constraints / Notes |
| :--- | :--- | :--- | :--- | :--- |
| `TournamentID` | `INT UNSIGNED` | NOT NULL | AUTO_INCREMENT | PK |
| `TournamentName` | `VARCHAR(100)` | NOT NULL | — | |
| `StartDate` | `DATE` | NOT NULL | — | |
| `EndDate` | `DATE` | NULL | NULL | CHECK EndDate ≥ StartDate; NULL = one-day event |
| `Location` | `VARCHAR(100)` | NOT NULL | — | |

## Table 4: `Matches`
One scheduled match: when, where, on which table, in which format and tournament.

| Field | MySQL Type | NULL | Default | Constraints / Notes |
| :--- | :--- | :--- | :--- | :--- |
| `MatchID` | `INT UNSIGNED` | NOT NULL | AUTO_INCREMENT | PK |
| `TournamentID` | `INT UNSIGNED` | NULL | NULL | FK → `Tournaments.TournamentID`; NULL = league night |
| `FormatID` | `INT UNSIGNED` | NOT NULL | — | FK → `Formats.FormatID` |
| `MatchDate` | `DATETIME` | NOT NULL | — | |
| `Location` | `VARCHAR(100)` | NOT NULL | — | |
| `TableNumber` | `TINYINT UNSIGNED` | NULL | NULL | CHECK ≥ 1; NULL = not assigned yet |

## Table 5: `MatchResults` (linking table, Players ⟷ Matches)
One player's result in one match. A normal match has two rows. Named after what the relationship represents (a match result), not the two tables it connects.

| Field | MySQL Type | NULL | Default | Constraints / Notes |
| :--- | :--- | :--- | :--- | :--- |
| `MatchID` | `INT UNSIGNED` | NOT NULL | — | PK (composite), FK → `Matches.MatchID` |
| `PlayerID` | `INT UNSIGNED` | NOT NULL | — | PK (composite), FK → `Players.PlayerID` |
| `RaceTo` | `TINYINT UNSIGNED` | NOT NULL | — | CHECK 1–15; the player's handicap race |
| `GamesWon` | `TINYINT UNSIGNED` | NOT NULL | 0 | CHECK GamesWon ≤ RaceTo |

## Table 6: `HandicapChart` (lookup table)
For each format and rating-gap range, the race for the higher- and lower-rated player.

| Field | MySQL Type | NULL | Default | Constraints / Notes |
| :--- | :--- | :--- | :--- | :--- |
| `ChartID` | `INT UNSIGNED` | NOT NULL | AUTO_INCREMENT | PK |
| `FormatID` | `INT UNSIGNED` | NOT NULL | — | FK → `Formats.FormatID`; UQ (FormatID, MinGap) |
| `MinGap` | `SMALLINT UNSIGNED` | NOT NULL | — | |
| `MaxGap` | `SMALLINT UNSIGNED` | NOT NULL | — | CHECK MaxGap ≥ MinGap |
| `HigherRace` | `TINYINT UNSIGNED` | NOT NULL | — | CHECK 1–15 |
| `LowerRace` | `TINYINT UNSIGNED` | NOT NULL | — | CHECK 1–15 |

## Table 7: `RatingHistory`
One row each time a player's Fargo Rating changes.

| Field | MySQL Type | NULL | Default | Constraints / Notes |
| :--- | :--- | :--- | :--- | :--- |
| `HistoryID` | `INT UNSIGNED` | NOT NULL | AUTO_INCREMENT | PK |
| `PlayerID` | `INT UNSIGNED` | NOT NULL | — | FK → `Players.PlayerID` |
| `MatchID` | `INT UNSIGNED` | NULL | NULL | FK → `Matches.MatchID`; NULL = manual adjustment |
| `OldRating` | `SMALLINT` | NULL | NULL | CHECK 100–900; NULL = first rating |
| `NewRating` | `SMALLINT` | NOT NULL | — | CHECK 100–900 |
| `ChangedAt` | `DATETIME` | NOT NULL | CURRENT_TIMESTAMP | |

---

## FK type confirmation
Every FK has exactly the same type as the PK it references: all IDs are `INT UNSIGNED`.

| FK | References | Type match |
| :--- | :--- | :--- |
| `Matches.TournamentID` | `Tournaments.TournamentID` | INT UNSIGNED = INT UNSIGNED ✓ |
| `Matches.FormatID` | `Formats.FormatID` | INT UNSIGNED = INT UNSIGNED ✓ |
| `MatchResults.MatchID` | `Matches.MatchID` | INT UNSIGNED = INT UNSIGNED ✓ |
| `MatchResults.PlayerID` | `Players.PlayerID` | INT UNSIGNED = INT UNSIGNED ✓ |
| `HandicapChart.FormatID` | `Formats.FormatID` | INT UNSIGNED = INT UNSIGNED ✓ |
| `RatingHistory.PlayerID` | `Players.PlayerID` | INT UNSIGNED = INT UNSIGNED ✓ |
| `RatingHistory.MatchID` | `Matches.MatchID` | INT UNSIGNED = INT UNSIGNED ✓ |

## CHECK constraint candidates
| Field | Rule | Why |
| :--- | :--- | :--- |
| `FargoRating`, `OldRating`, `NewRating` | 100–900 | The Fargo scale doesn't go outside this range |
| `RaceTo`, `HigherRace`, `LowerRace` | 1–15 | A race of 0 or more than 15 games is not a real pool race |
| `GamesWon` | ≤ `RaceTo` | A player stops winning games once they reach their race |
| `EndDate` | ≥ `StartDate` | A tournament can't end before it starts |
| `MaxGap` | ≥ `MinGap` | A gap range must not be backwards |
| `TableNumber` | ≥ 1 | Pool halls number tables starting at 1 |
| `Email` | contains `@` | Catches obviously invalid addresses |

---

## Changes from the original field list
| Change | Why |
| :--- | :--- |
| Gave every table a name and a one-line purpose | The original tables had no titles, so FKs did not clearly point anywhere |
| Added `VARCHAR` lengths | Needed to write the SQL schema in Phase 4 |
| Phone is not a unique key | Two players (family members) can share a phone; email stays unique |
| No `CURRENT_TIMESTAMP` default on `MatchDate` | Matches are scheduled ahead of time, so "now" is the wrong default |
| Added `TableNumber` to `Matches` | Mission objectives promise table assignments, but no field stored them |
| Replaced `handicap_at_match` (0–1000) with `RaceTo` (1–15) | In Fargo handicapping the handicap *is* the race: a lower-rated player races to fewer games |
| Removed `games_lost` | It is always the opponent's games won, so storing it twice risks the two values disagreeing |
| Added `Tournaments` table and `Matches.TournamentID` | Mission objectives promise tournament management, but there was no table for it |
| Added `HandicapChart` lookup table | The domain says races are set from a lookup table based on rating gaps |
| Added `RatingHistory` table | The current rating in `Players` is overwritten after every match; the mission promises historical rating tracking |
| Removed `is_winner` (after Phase 3 feedback) | The winner is the player whose `GamesWon = RaceTo`, so storing it could disagree with the score |
| Renamed all fields to TableName + ID / PascalCase (Week 5 Keys lecture) | Matches the course naming convention: `PlayerID`, `FirstName`, ... |
| Renamed `Player_Matches` to `MatchResults` and gave it a composite PK `(MatchID, PlayerID)` (Week 6–7 lectures) | Linking tables are named after the relationship and use a composite PK of their two FKs |
| All IDs are `INT UNSIGNED` (Week 7 lab) | IDs are never negative, and every FK must match its PK's type |
