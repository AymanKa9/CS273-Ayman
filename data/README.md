# data

`seed.sql` (Phase 6) fills every table with realistic rows. Run it after `schema/schema.sql`.

| Table | Rows |
| --- | --- |
| Players | 9 (8 + 1 added by Transaction 1) |
| Formats | 5 |
| Tournaments | 5 |
| HandicapChart | 11 |
| Matches | 8 |
| MatchResults | 16 |
| RatingHistory | 13 |

Edge cases included: a player with no rating, a player with no phone, a player with no email, players who never played, one-day tournaments with no end date, league matches with no tournament, and manual rating adjustments with no match.

**Transaction 1 (COMMIT):** registering a player inserts the player and their first RatingHistory row together, so a rating never exists without its history.

**Transaction 2 (ROLLBACK):** scheduling a tournament match inserts the match and both players' MatchResults rows. The player withdraws, so ROLLBACK undoes both inserts, and the SELECT after it returns 0.
