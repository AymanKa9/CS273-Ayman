# Phase 4 — Schema

`schema.sql` creates the **FargoLeague** database: 7 tables with primary keys, foreign keys, UNIQUE and CHECK constraints. Tables are created parents first: Players, Formats, Tournaments, then Matches, MatchResults, HandicapChart, RatingHistory.

Run it in MySQL Workbench with **Ctrl+Shift+Enter**. It starts with `DROP DATABASE IF EXISTS`, so it can be re-run any time and always gives a fresh, empty database. Then run `data/seed.sql`.

## Foreign keys — ON DELETE choices

| Constraint | ON DELETE | Why |
| :--- | :--- | :--- |
| `fk_matches_format` | RESTRICT | A format that matches were played in can't be deleted, or those matches would lose their game type. |
| `fk_matches_tournament` | SET NULL | If a tournament is deleted, its matches still happened. They become league matches instead of disappearing. |
| `fk_results_match` | CASCADE | A result has no meaning without its match. Deleting a match deletes both players' results. |
| `fk_results_player` | RESTRICT | A player with match results can't be deleted, or the opponents' results would point at nobody. |
| `fk_handicap_format` | CASCADE | Chart rows only exist for their format. Deleting a format removes its handicap chart. |
| `fk_history_player` | CASCADE | Rating history belongs to one player. If the player is removed, their history goes too. |
| `fk_history_match` | SET NULL | If a match is deleted, the rating change still happened. It is kept as a manual adjustment. |

All FKs use **ON UPDATE CASCADE**, so if an ID ever changes, every reference follows it.

## CHECK constraints — business rules

| Constraint | Rule it enforces |
| :--- | :--- |
| `chk_fargo_rating`, `chk_old_rating`, `chk_new_rating` | Fargo Ratings must be between 100 and 900, the real Fargo scale. |
| `chk_email` | An email must contain `@`, which stops obvious typos. |
| `chk_format_name` | A format name can't be empty. |
| `chk_tournament_dates` | A tournament can't end before it starts. |
| `chk_table_number` | Table numbers start at 1. |
| `chk_race_to`, `chk_higher_race`, `chk_lower_race` | A race must be 1–15 games, a real pool race. |
| `chk_games_won` | A player can't win more games than their race. Once they reach it, the match is over. |
| `chk_gap_order` | A handicap gap range can't be backwards (`MaxGap ≥ MinGap`). |

## UNIQUE constraints
- `Players.Email`: two players can't share an email.
- `Formats.FormatName`: each game type is listed once, so stats are never split between "9 ball" and "9-Ball".
- `uq_chart_format_gap (FormatID, MinGap)`: each format has only one chart row starting at a given gap.
- MatchResults' composite PK `(MatchID, PlayerID)`: a player can appear only once in a match.

Rating columns are `SMALLINT`, not `UNSIGNED`, so a rating *change* (`NewRating - OldRating`) can be negative without a MySQL error.
