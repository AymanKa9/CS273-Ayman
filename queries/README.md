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

## Phase 5B

| Query | Mission objective | Tables | Functions | Type |
| --- | --- | --- | --- | --- |
| Q6 | Manage formats and game types | Formats, Matches, Player_Matches | COUNT, AVG | GROUP BY, 3-table aggregate |
| Q7 | Track game total indicators | Players, Player_Matches | COUNT, SUM | GROUP BY + HAVING |
| Q8 | Track game total indicators | Players, Player_Matches | SUM, AVG | GROUP BY + HAVING with scalar subquery |
| Q9 | Record match schedules and table assignments | Tournaments, Matches | COUNT, MIN, MAX | LEFT JOIN + aggregate (zero counts) |
| Q10 | Log rating updates | Rating_History, Players (+ Player_Matches, Matches in subquery) | COUNT, MIN, MAX | GROUP BY + IN subquery |
| Q11 | Track player Fargo Ratings | Players | AVG | Scalar subquery in WHERE |
| Q12 | Maintain player records | Players, Player_Matches (subquery) | — | NOT IN subquery |

**Q6 — Activity per format.** GROUP BY turns every match into one row per format so COUNT and AVG can summarize each game type. 9-Ball is the most played format (5 of 8 matches) and has the longest average race (5.1 games).

**Q7 — Players with 2+ wins.** SUM counts each player's wins, and HAVING keeps players with at least 2. WHERE can't do this, because the win count only exists after grouping. Nadia Rahimi and Sara Bennett are undefeated (2–0).

**Q8 — Above-average game totals.** The subquery calculates the average total games won per player (8.9), so HAVING compares each player to the current average instead of a hard-coded number. Omar, Grace and Nadia win the most games.

**Q9 — Tournament workload.** A LEFT JOIN keeps tournaments with no matches, and COUNT(m.match_id) returns 0 for them instead of dropping them. The Fall 9-Ball Open used 4 matches on 2 tables, and the Halloween Classic has nothing scheduled yet.

**Q10 — Rating ranges of tournament players.** The IN subquery finds every player who played a tournament match, and GROUP BY summarizes their rating history. Grace Kim had the most updates (4) and has dropped from her 618 high, while Sara Bennett is at her highest rating (450).

**Q11 — Above-average ratings.** The inner query returns one value, the league's average rating (534, unrated players ignored), and the outer query keeps players above it. Nadia (700), Grace (610) and Omar (600) are the strongest players.

**Q12 — Players who never played.** The inner query lists every player_id that appears in Player_Matches, and NOT IN keeps the players who aren't in that list. Emma Cole signed up but hasn't played, so the league can contact her using the email and phone shown.

