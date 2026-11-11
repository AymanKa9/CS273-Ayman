-- ═══════════════════════════════════════════════════════
-- CS273 Phase 5 — All Queries
-- Ayman Kaouch | Pool League Fargo Rating Tracker | Nov 2026
-- Run order: schema/schema.sql → data/seed.sql → this file
-- ═══════════════════════════════════════════════════════
USE FargoLeague;

-- ── PHASE 5A: JOIN Queries ──────────────────────────────

-- Q1: Objective 4 — Show the final score of every match, who played, and who won
--     (INNER JOIN, 4 tables)
SELECT m.MatchID,
       m.MatchDate,
       f.FormatName,
       m.TableNumber,
       CONCAT(p.FirstName, ' ', p.LastName) AS Player,
       mr.RaceTo,
       mr.GamesWon,
       CASE WHEN mr.GamesWon = mr.RaceTo THEN 'Won' ELSE 'Lost' END AS Result
FROM Matches m
INNER JOIN Formats f       ON m.FormatID = f.FormatID
INNER JOIN MatchResults mr ON m.MatchID  = mr.MatchID
INNER JOIN Players p       ON mr.PlayerID = p.PlayerID
ORDER BY m.MatchDate, m.MatchID, Result DESC;

-- Q2: Objective 6 — Show every rating change and the match (or manual adjustment) that caused it
--     (INNER JOIN + LEFT JOIN)
SELECT CONCAT(p.FirstName, ' ', p.LastName) AS Player,
       rh.ChangedAt,
       rh.OldRating,
       rh.NewRating,
       rh.NewRating - rh.OldRating AS RatingChange,
       CASE WHEN m.MatchID IS NULL THEN 'Manual adjustment'
            ELSE CONCAT('Match #', m.MatchID, ' (', f.FormatName, ')') END AS Source
FROM RatingHistory rh
INNER JOIN Players p ON rh.PlayerID = p.PlayerID
LEFT  JOIN Matches m ON rh.MatchID  = m.MatchID
LEFT  JOIN Formats f ON m.FormatID  = f.FormatID
ORDER BY Player, rh.ChangedAt;

-- Q3: Objective 2 — Show matches played, matches won and games won for every player, including players who haven't played
--     (LEFT JOIN, zero counts)
SELECT CONCAT(p.FirstName, ' ', p.LastName) AS Player,
       p.FargoRating,
       COUNT(mr.MatchID)                                          AS MatchesPlayed,
       SUM(CASE WHEN mr.GamesWon = mr.RaceTo THEN 1 ELSE 0 END)   AS MatchesWon,
       COALESCE(SUM(mr.GamesWon), 0)                              AS TotalGamesWon
FROM Players p
LEFT JOIN MatchResults mr ON p.PlayerID = mr.PlayerID
GROUP BY p.PlayerID, p.FirstName, p.LastName, p.FargoRating
ORDER BY MatchesWon DESC, TotalGamesWon DESC, Player;

-- Q4: Objective 3 — Show each tournament's schedule with game type and table assignments
--     (INNER JOIN, 3 tables)
SELECT t.TournamentName,
       m.MatchDate,
       f.FormatName,
       m.TableNumber,
       m.Location
FROM Tournaments t
INNER JOIN Matches m ON t.TournamentID = m.TournamentID
INNER JOIN Formats f ON m.FormatID     = f.FormatID
ORDER BY t.TournamentName, m.MatchDate, m.TableNumber;

-- Q5: Objective 5 — Check that each player's race followed the HandicapChart for their rating gap
--     (INNER JOIN; MatchResults and Players joined twice, once per opponent)
SELECT m.MatchID,
       f.FormatName,
       CONCAT(hp.FirstName, ' ', hp.LastName) AS HigherRated,
       CONCAT(lp.FirstName, ' ', lp.LastName) AS LowerRated,
       hp.FargoRating - lp.FargoRating        AS RatingGap,
       hr.RaceTo      AS HigherRacePlayed,
       hc.HigherRace  AS ChartHigherRace,
       lr.RaceTo      AS LowerRacePlayed,
       hc.LowerRace   AS ChartLowerRace,
       CASE WHEN hr.RaceTo = hc.HigherRace AND lr.RaceTo = hc.LowerRace
            THEN 'OK' ELSE 'Check' END AS FollowsChart
FROM Matches m
INNER JOIN Formats f       ON m.FormatID  = f.FormatID
INNER JOIN MatchResults hr ON m.MatchID   = hr.MatchID
INNER JOIN Players hp      ON hr.PlayerID = hp.PlayerID
INNER JOIN MatchResults lr ON m.MatchID   = lr.MatchID
                          AND lr.PlayerID <> hr.PlayerID
INNER JOIN Players lp      ON lr.PlayerID = lp.PlayerID
                          AND lp.FargoRating < hp.FargoRating
INNER JOIN HandicapChart hc ON m.FormatID = hc.FormatID
                           AND hp.FargoRating - lp.FargoRating BETWEEN hc.MinGap AND hc.MaxGap
ORDER BY m.MatchID;

-- ── PHASE 5B: Aggregate & Subquery Queries ──────────────

-- Q6: Objective 3 — Show matches played, average race and average games won per game format
--     (3-table aggregate · GROUP BY · COUNT, AVG)
SELECT f.FormatName,
       COUNT(DISTINCT m.MatchID)   AS MatchesPlayed,
       ROUND(AVG(mr.RaceTo), 2)    AS AvgRace,
       ROUND(AVG(mr.GamesWon), 2)  AS AvgGamesWon
FROM Formats f
INNER JOIN Matches m       ON f.FormatID = m.FormatID
INNER JOIN MatchResults mr ON m.MatchID  = mr.MatchID
GROUP BY f.FormatID, f.FormatName
ORDER BY MatchesPlayed DESC;

-- Q7: Objective 2 — Show players who have won at least 2 matches
--     (GROUP BY · COUNT, SUM · HAVING)
SELECT CONCAT(p.FirstName, ' ', p.LastName)                     AS Player,
       COUNT(mr.MatchID)                                        AS MatchesPlayed,
       SUM(CASE WHEN mr.GamesWon = mr.RaceTo THEN 1 ELSE 0 END) AS MatchesWon
FROM Players p
INNER JOIN MatchResults mr ON p.PlayerID = mr.PlayerID
GROUP BY p.PlayerID, p.FirstName, p.LastName
HAVING SUM(CASE WHEN mr.GamesWon = mr.RaceTo THEN 1 ELSE 0 END) >= 2
ORDER BY MatchesWon DESC, Player;

-- Q8: Objective 2 — Show players who have won more total games than the average player
--     (GROUP BY · SUM, AVG · HAVING with a scalar subquery and a derived table) can u look at this please, Thank you 
SELECT CONCAT(p.FirstName, ' ', p.LastName) AS Player,
       p.FargoRating,
       SUM(mr.GamesWon)                     AS TotalGamesWon
FROM Players p
INNER JOIN MatchResults mr ON p.PlayerID = mr.PlayerID
GROUP BY p.PlayerID, p.FirstName, p.LastName, p.FargoRating
HAVING SUM(mr.GamesWon) > (
    SELECT AVG(PlayerTotal)
    FROM (SELECT SUM(GamesWon) AS PlayerTotal
          FROM MatchResults
          GROUP BY PlayerID) AS Totals
)
ORDER BY TotalGamesWon DESC;

-- Q9: Objective 4 — Show how many matches and tables each tournament has, including tournaments with no matches
--     (LEFT JOIN + aggregate · GROUP BY · COUNT, MIN, MAX · zero counts)
SELECT t.TournamentName,
       t.StartDate,
       COUNT(m.MatchID)              AS MatchesScheduled,
       COUNT(DISTINCT m.TableNumber) AS TablesUsed,
       MIN(m.MatchDate)              AS FirstMatch,
       MAX(m.MatchDate)              AS LastMatch
FROM Tournaments t
LEFT JOIN Matches m ON t.TournamentID = m.TournamentID
GROUP BY t.TournamentID, t.TournamentName, t.StartDate
ORDER BY t.StartDate;

-- Q10: Objective 6 — Show rating updates and lowest/highest rating for every player who has played in a tournament
--      (GROUP BY · COUNT, MIN, MAX · IN subquery)
SELECT CONCAT(p.FirstName, ' ', p.LastName) AS Player,
       COUNT(rh.HistoryID) AS RatingUpdates,
       MIN(rh.NewRating)   AS LowestRating,
       MAX(rh.NewRating)   AS HighestRating,
       p.FargoRating       AS CurrentRating
FROM RatingHistory rh
INNER JOIN Players p ON rh.PlayerID = p.PlayerID
WHERE rh.PlayerID IN (
    SELECT mr.PlayerID
    FROM MatchResults mr
    INNER JOIN Matches m ON mr.MatchID = m.MatchID
    WHERE m.TournamentID IS NOT NULL
)
GROUP BY p.PlayerID, p.FirstName, p.LastName, p.FargoRating
ORDER BY RatingUpdates DESC, Player;

-- Q11: Objective 2 — Show players rated above the league's average Fargo Rating
--      (scalar subquery in WHERE · AVG)
SELECT CONCAT(FirstName, ' ', LastName) AS Player,
       FargoRating
FROM Players
WHERE FargoRating > (SELECT AVG(FargoRating) FROM Players)
ORDER BY FargoRating DESC;

-- Q12: Objective 1 — Show registered players who have never played a match, with their contact info
--      (NOT IN subquery)
SELECT CONCAT(FirstName, ' ', LastName) AS Player,
       Email,
       Phone
FROM Players
WHERE PlayerID NOT IN (SELECT PlayerID FROM MatchResults)
ORDER BY LastName;
