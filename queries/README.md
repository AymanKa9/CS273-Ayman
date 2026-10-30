# Phase 5A — JOIN Queries

Run order: `schema/schema.sql` → `data/test_data.sql` → `queries/queries.sql`.

| Query | JOIN type | Tables |
| --- | --- | --- |
| Q1 | INNER | Matches, Formats, Player_Matches, Players |
| Q2 | INNER + LEFT | Rating_History, Players, Matches, Formats |
| Q3 | LEFT | Players, Player_Matches |
| Q4 | INNER | Tournaments, Matches, Formats |
| Q5 | INNER | Matches, Formats, Player_Matches ×2, Players ×2, Handicap_Chart |

**Q1 — Match results.** Answers *"record match schedules, table assignments, and final scores."* A match's date and table live in Matches, but the players and scores live in Player_Matches, so the query joins them on `match_id`, then Players on `player_id` and Formats on `format_id`. The result is a scoreboard showing who beat whom, in which game, and on which table.

**Q2 — Rating history.** Answers *"log pre-match and post-match rating updates."* Rating_History only stores IDs, so it joins Players on `player_id` for names and uses a LEFT JOIN to Matches on `match_id`, because manual adjustments have no match. It shows each player's rating trend and which match moved it.

**Q3 — Player activity.** Answers *"track player Fargo Ratings and game total indicators."* Players joins Player_Matches on `player_id` with a LEFT JOIN, so players with no matches still appear with zeros (Emma Cole). It shows who is most active and successful, and who signed up but hasn't played.

**Q4 — Tournament schedule.** Answers *"manage tournament parameters including formats and game types."* Tournaments joins Matches on `tournament_id`, and Matches joins Formats on `format_id`. It gives a director the full schedule with times and table assignments. The Halloween Classic doesn't appear because it has no matches scheduled yet.

**Q5 — Handicap check.** Answers *"store handicap lookup thresholds based on rating differentials."* Player_Matches and Players are joined twice, once for each opponent, to compute the rating gap. Handicap_Chart is then joined on `format_id` and on the gap falling between `min_gap` and `max_gap`. It confirms every race followed the chart. Unrated players (match 6) are left out because there is no gap to look up, and the query uses current ratings rather than ratings at match time.
