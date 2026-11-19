# data

`seed.sql` (Phase 6) fills every table with realistic rows. Run it after `schema/schema.sql`.

| Table | Rows |
| --- | --- |
| Players | 8 |
| Formats | 5 |
| Tournaments | 5 |
| HandicapChart | 11 |
| Matches | 12 (8 completed, 3 scheduled, 1 cancelled) |
| MatchResults | 16 |
| RatingHistory | 13 (12 + 1 added by Transaction 1) |

Edge cases included: a player with no rating, a player with no phone, a player with no email, players who never played, one-day tournaments with no end date, league matches with no tournament, upcoming scheduled matches with no players drawn yet, a cancelled match, and manual rating adjustments with no match.

**Transaction 1 (COMMIT):** after match 5, Luis Ortega's rating drops from 520 to 516. The transaction inserts the change into RatingHistory and updates Players together, so the history and the current rating always agree.

**Transaction 2 (ROLLBACK):** the director meant to change only Nadia's rating, but the WHERE clause (`PlayerID > 0`) matched every player. ROLLBACK undoes it, and the SELECT after it shows every rating unchanged.
