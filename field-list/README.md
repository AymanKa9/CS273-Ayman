# Database Field List & Key Specifications

**Project:** Pool League Fargo Rating Tracker
**Student:** Ayman Kaouch · CS 273 Database Systems · Fall 2026

**Key legend:** PK = primary key · FK = foreign key · AK = alternate key (unique) · UQ = composite unique constraint

---

## Table 1: `Players`
A person registered in the league and their current Fargo Rating.

| Field Name | Data Type | Null Support | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- |
| `player_id` | `INT` | Not Null | None | PK, auto-increment |
| `first_name` | `VARCHAR(50)` | Not Null | None | Letters, spaces, hyphens and apostrophes |
| `last_name` | `VARCHAR(50)` | Not Null | None | Letters, spaces, hyphens and apostrophes |
| `fargo_rating` | `INT` | Null | `NULL` | Range 100–900; `NULL` = not yet rated |
| `phone_number` | `VARCHAR(20)` | Null | `NULL` | Standard phone format |
| `email` | `VARCHAR(100)` | Null | `NULL` | AK, valid email format |

---

## Table 2: `Formats`
A game type the league plays (8-Ball, 9-Ball, 10-Ball) and its rules.

| Field Name | Data Type | Null Support | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- |
| `format_id` | `INT` | Not Null | None | PK, auto-increment |
| `format_name` | `VARCHAR(50)` | Not Null | None | AK, unique format title |
| `rules_summary` | `TEXT` | Null | `NULL` | Descriptive text |

---

## Table 3: `Matches`
One scheduled match: when, where, on which table, in which format, and (optionally) in which tournament.

| Field Name | Data Type | Null Support | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- |
| `match_id` | `INT` | Not Null | None | PK, auto-increment |
| `tournament_id` | `INT` | Null | `NULL` | FK → `Tournaments.tournament_id`; `NULL` = regular league match |
| `format_id` | `INT` | Not Null | None | FK → `Formats.format_id` |
| `match_date` | `DATETIME` | Not Null | None | Valid date and time of the match |
| `location` | `VARCHAR(100)` | Not Null | None | Venue name/address |
| `table_number` | `INT` | Null | `NULL` | Range ≥ 1; `NULL` = not yet assigned |

---

## Table 4: `Player_Matches` (linking table)
One player's participation and result in one match. A normal match has two rows here.

| Field Name | Data Type | Null Support | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- |
| `player_match_id` | `INT` | Not Null | None | PK, auto-increment |
| `match_id` | `INT` | Not Null | None | FK → `Matches.match_id` |
| `player_id` | `INT` | Not Null | None | FK → `Players.player_id` |
| `race_to` | `INT` | Not Null | None | Range 1–15; games this player needs to win (their handicap) |
| `games_won` | `INT` | Not Null | `0` | Range 0 to `race_to` |
| `is_winner` | `BOOLEAN` | Not Null | `FALSE` | True/False (1 or 0) |
| — | — | — | — | UQ (`match_id`, `player_id`): a player appears once per match |

---

## Table 5: `Tournaments`
A tournament event that groups a set of matches.

| Field Name | Data Type | Null Support | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- |
| `tournament_id` | `INT` | Not Null | None | PK, auto-increment |
| `tournament_name` | `VARCHAR(100)` | Not Null | None | Event title |
| `start_date` | `DATE` | Not Null | None | Valid date |
| `end_date` | `DATE` | Null | `NULL` | ≥ `start_date`; `NULL` = one-day or ongoing |
| `location` | `VARCHAR(100)` | Not Null | None | Venue name/address |

---

## Table 6: `Handicap_Chart` (lookup table)
The race each player gets, based on the rating gap between two opponents, for each format.

| Field Name | Data Type | Null Support | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- |
| `chart_id` | `INT` | Not Null | None | PK, auto-increment |
| `format_id` | `INT` | Not Null | None | FK → `Formats.format_id` |
| `min_gap` | `INT` | Not Null | None | Range ≥ 0 |
| `max_gap` | `INT` | Not Null | None | ≥ `min_gap` |
| `higher_race` | `INT` | Not Null | None | Range 1–15; race for the higher-rated player |
| `lower_race` | `INT` | Not Null | None | Range 1–15; race for the lower-rated player |
| — | — | — | — | UQ (`format_id`, `min_gap`): no overlapping rows per format |

---

## Table 7: `Rating_History`
One row each time a player's Fargo Rating changes, so growth can be tracked over time.

| Field Name | Data Type | Null Support | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- |
| `history_id` | `INT` | Not Null | None | PK, auto-increment |
| `player_id` | `INT` | Not Null | None | FK → `Players.player_id` |
| `match_id` | `INT` | Null | `NULL` | FK → `Matches.match_id`; `NULL` = manual adjustment |
| `old_rating` | `INT` | Null | `NULL` | Range 100–900; `NULL` = first rating |
| `new_rating` | `INT` | Not Null | None | Range 100–900 |
| `changed_at` | `DATETIME` | Not Null | `CURRENT_TIMESTAMP` | Valid timestamp |

---

## Changes from the original field list
| Change | Why |
| :--- | :--- |
| Gave every table a name and a one-line purpose | The original tables had no titles, so FKs did not clearly point anywhere |
| Added `VARCHAR` lengths | Needed to write the SQL schema in Phase 4 |
| Names allow spaces, hyphens, apostrophes | "Alphabetic only" would reject real names like O'Brien or Ben-Ali |
| Removed AK from `phone_number` | Two players (family members) can share a phone; email stays unique |
| Removed `CURRENT_TIMESTAMP` default on `match_date` | Matches are scheduled ahead of time, so "now" is the wrong default |
| Added `table_number` to `Matches` | Mission objectives promise table assignments, but no field stored them |
| Replaced `handicap_at_match` (0–1000) with `race_to` (1–15) | In Fargo handicapping the handicap *is* the race: a lower-rated player races to fewer games. A 0–1000 number has no clear meaning |
| Removed `games_lost` | It is always the opponent's `games_won`, so storing it twice risks the two values disagreeing |
| Added UQ (`match_id`, `player_id`) | Stops the same player from being entered twice in one match |
| Added `Tournaments` table and `Matches.tournament_id` | Mission objectives promise tournament management, but there was no table for it |
| Added `Handicap_Chart` lookup table | The domain says races are set from a lookup table based on rating gaps |
| Added `Rating_History` table | The current rating in `Players` is overwritten after every match, so past ratings were lost; the mission promises historical rating tracking |
