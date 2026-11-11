# Phase 5 — Queries

Run order: `schema/schema.sql` → `data/seed.sql` → `queries/queries.sql`.
Objective numbers refer to the Mission Objectives in `domain/README.md`.

## Phase 5A — JOIN queries

| Query | Objective | Tables | JOIN type |
| --- | --- | --- | --- |
| Q1 | 4 — Record match schedules, table assignments and final scores | Matches, Formats, MatchResults, Players | INNER (4 tables) |
| Q2 | 6 — Log pre-match and post-match rating updates | RatingHistory, Players, Matches, Formats | INNER + LEFT |
| Q3 | 2 — Track Fargo Ratings and game total indicators | Players, MatchResults | LEFT (zero counts) |
| Q4 | 3 — Manage tournament parameters, formats and game types | Tournaments, Matches, Formats | INNER (3 tables) |
| Q5 | 5 — Store handicap thresholds based on rating differentials | Matches, Formats, MatchResults ×2, Players ×2, HandicapChart | INNER (self-join pattern) |

**Q1 — Match scoreboard.** A match's date and table are in Matches, but the players and scores are in MatchResults, so the query joins them on `MatchID`, then Players on `PlayerID`. It shows who beat whom, in which game and on which table.

**Q2 — Rating history.** RatingHistory only stores IDs, so it joins Players on `PlayerID` for names. It uses a LEFT JOIN to Matches because manual adjustments have no match (`MatchID` is NULL). It shows which match moved each rating up or down.

**Q3 — Player activity.** A LEFT JOIN from Players to MatchResults on `PlayerID` keeps players with no matches, and they show 0. Emma Cole and Marcus Reed have signed up but haven't played.

**Q4 — Tournament schedule.** Tournaments joins Matches on `TournamentID`, and Matches joins Formats on `FormatID`. It gives a director the full schedule of the Fall 9-Ball Open with times and table assignments.

**Q5 — Handicap check.** MatchResults and Players are joined twice, once per opponent, so both ratings are on the same row. HandicapChart is joined on `FormatID` and on the rating gap falling between `MinGap` and `MaxGap`. All 7 matches between rated players followed the chart.

## Phase 5B — Aggregate & subquery queries

| Query | Objective | Tables | Functions | Type |
| --- | --- | --- | --- | --- |
| Q6 | 3 — Formats and game types | Formats, Matches, MatchResults | COUNT, AVG | GROUP BY, 3-table aggregate |
| Q7 | 2 — Game total indicators | Players, MatchResults | COUNT, SUM | GROUP BY + HAVING |
| Q8 | 2 — Game total indicators | Players, MatchResults | SUM, AVG | GROUP BY + HAVING with scalar subquery |
| Q9 | 4 — Match schedules and table assignments | Tournaments, Matches | COUNT, MIN, MAX | LEFT JOIN + aggregate (zero counts) |
| Q10 | 6 — Rating updates | RatingHistory, Players (MatchResults, Matches in subquery) | COUNT, MIN, MAX | GROUP BY + IN subquery |
| Q11 | 2 — Fargo Ratings | Players | AVG | Scalar subquery in WHERE |
| Q12 | 1 — Player identity and contact records | Players, MatchResults (subquery) | — | NOT IN subquery |

**Q6 — Activity per format.** GROUP BY gives one row per format, so COUNT and AVG summarize each game type. 9-Ball is the most played (5 of 8 matches) with the longest average race (5.1).

**Q7 — Players with 2+ wins.** SUM counts each player's wins, and HAVING keeps players with at least 2. WHERE can't do this because the win count only exists after GROUP BY. Nadia Rahimi and Sara Bennett are undefeated (2–0).

**Q8 — Above-average game totals.** The subquery calculates the average games won per player (8.9), and HAVING compares each player to it instead of a hard-coded number. Omar, Grace and Nadia win the most games.

**Q9 — Tournament workload.** The LEFT JOIN keeps tournaments with no matches, and `COUNT(m.MatchID)` returns 0 for them. Only the Fall 9-Ball Open has matches (4, on 2 tables). The other 4 tournaments have none scheduled yet.

**Q10 — Rating ranges of tournament players.** The IN subquery finds every player who played a tournament match, and GROUP BY summarizes their rating history. Grace Kim had the most updates (4). Sara Bennett is at her highest rating (450).

**Q11 — Above-average ratings.** The inner query returns one value, the league average (530). The outer query keeps players above it: Nadia (700), Grace (610) and Omar (600).

**Q12 — Players who never played.** The inner query lists every `PlayerID` in MatchResults, and NOT IN keeps players who aren't in that list. Emma Cole and Marcus Reed haven't played, so the league can contact them using the email and phone shown.
