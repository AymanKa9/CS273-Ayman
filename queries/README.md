# Queries — Phase 5A (JOINs) and Phase 5B (Aggregates & Subqueries)

Run order: `schema/schema.sql` → `data/test_data.sql` → `queries/queries.sql`.

| Query | JOIN type | Tables |
| --- | --- | --- |
| Q1 | INNER | Matches, Formats, Player_Matches, Players |
| Q2 | INNER + LEFT | Rating_History, Players, Matches, Formats |
| Q3 | LEFT | Players, Player_Matches |
| Q4 | INNER | Tournaments, Matches, Formats |
| Q5 | INNER | Matches, Formats, Player_Matches ×2, Players ×2, Handicap_Chart |

## Phase 5A — JOIN queries

**Q1 — Match results.** Answers *"record match schedules, table assignments, and final scores."* A match's date and table live in Matches, but the players and scores live in Player_Matches, so the query joins them on `match_id`, then Players on `player_id` and Formats on `format_id`. The result is a scoreboard showing who beat whom, in which game, and on which table.

**Q2 — Rating history.** Answers *"log pre-match and post-match rating updates."* Rating_History only stores IDs, so it joins Players on `player_id` for names and uses a LEFT JOIN to Matches on `match_id`, because manual adjustments have no match. It shows each player's rating trend and which match moved it.

**Q3 — Player activity.** Answers *"track player Fargo Ratings and game total indicators."* Players joins Player_Matches on `player_id` with a LEFT JOIN, so players with no matches still appear with zeros (Emma Cole). It shows who is most active and successful, and who signed up but hasn't played.

**Q4 — Tournament schedule.** Answers *"manage tournament parameters including formats and game types."* Tournaments joins Matches on `tournament_id`, and Matches joins Formats on `format_id`. It gives a director the full schedule with times and table assignments. The Halloween Classic doesn't appear because it has no matches scheduled yet.

**Q5 — Handicap check.** Answers *"store handicap lookup thresholds based on rating differentials."* Player_Matches and Players are joined twice, once for each opponent, to compute the rating gap. Handicap_Chart is then joined on `format_id` and on the gap falling between `min_gap` and `max_gap`. It confirms every race followed the chart. Unrated players (match 6) are left out because there is no gap to look up, and the query uses current ratings rather than ratings at match time.

## Phase 5B — Aggregate & subquery queries

| Query | Technique |
| --- | --- |
| Q6 | GROUP BY + COUNT, AVG |
| Q7 | GROUP BY + SUM + HAVING |
| Q8 | Subquery in WHERE + AVG |
| Q9 | GROUP BY + COUNT, MIN, MAX |
| Q10 | Correlated subquery in SELECT + subquery in WHERE |

**Q6 — Activity per format.** Answers *"manage tournament parameters including formats and game types."* GROUP BY collapses every match into one row per format, so COUNT and AVG can summarize each game type. 9-Ball is by far the most played format (5 of 8 matches) and has the longest average race (5.1 games).

**Q7 — Winning players.** Answers *"track player Fargo Ratings and game total indicators."* SUM counts wins per player, and HAVING keeps only players with 2 or more wins. WHERE can't do this, because the win count only exists after grouping. Nadia Rahimi and Sara Bennett are undefeated (2–0).

**Q8 — Above-average players.** Answers *"maintain accurate player identity and contact records"* by ranking the roster. The subquery calculates the league average (534, unrated players ignored) so the outer query can compare each player against it without hard-coding a number. Nadia, Grace and Omar are the strongest players in the league.

**Q9 — Venue usage.** Answers *"record individual match schedules, table assignments."* GROUP BY location with COUNT, MIN and MAX shows how busy each venue is and its date range. Cue Masters hosts most matches (5) on only 2 tables, while Rack Room spreads 3 matches over 3 tables.

**Q10 — Rating growth.** Answers *"log pre-match and post-match rating updates to preserve historical rating accuracy."* A correlated subquery finds each player's first recorded rating, and a WHERE subquery keeps only players with history. Sara Bennett improved the most (+20), while Omar Haddad dropped 12 points.

