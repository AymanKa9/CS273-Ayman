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
One scheduled match: when, where, on which table, and in which format.

| Field Name | Data Type | Null Support | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- |
| `match_id` | `INT` | Not Null | None | PK, auto-increment |
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
| `rating_at_match` | `INT` | Null | `NULL` | Range 100–900; player's Fargo Rating when the match started |
| `race_to` | `INT` | Not Null | None | Range 1–15; games this player needs to win (their handicap) |
| `games_won` | `INT` | Not Null | `0` | Range 0 to `race_to` |
| `is_winner` | `BOOLEAN` | Not Null | `FALSE` | True/False (1 or 0) |
| — | — | — | — | UQ (`match_id`, `player_id`): a player appears once per match |

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
| Added `rating_at_match` | Mission objectives promise pre-match rating history; the current rating in `Players` is overwritten after every match |
| Removed `games_lost` | It is always the opponent's `games_won`, so storing it twice risks the two values disagreeing |
| Added UQ (`match_id`, `player_id`) | Stops the same player from being entered twice in one match |
