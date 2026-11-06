-- =====================================================================
-- CS 273 · Phase 5A — JOIN Queries
-- Project: Pool League Fargo Rating Tracker · Ayman Kaouch
--
-- Run order: schema/schema.sql -> data/test_data.sql -> this file.
-- The winner of a match is the player whose games_won = race_to.
-- =====================================================================

USE FargoLeague;


-- Q1: What was the final score of every match, who played, and who won?
--     Mission objective: Record individual match schedules, table assignments, and final scores.
--     (INNER JOIN · 4 tables)
SELECT m.match_id,
       m.match_date,
       f.format_name,
       m.table_number,
       CONCAT(p.first_name, ' ', p.last_name) AS player,
       pm.race_to,
       pm.games_won,
       CASE WHEN pm.games_won = pm.race_to THEN 'Won' ELSE 'Lost' END AS result
FROM Matches m
INNER JOIN Formats f         ON f.format_id = m.format_id
INNER JOIN Player_Matches pm ON pm.match_id = m.match_id
INNER JOIN Players p         ON p.player_id = pm.player_id
ORDER BY m.match_date, m.match_id, result DESC;


-- Q2: How has each player's Fargo Rating changed over time, and which
--     match (or manual adjustment) caused each change?
--     Mission objective: Log pre-match and post-match rating updates.
--     (INNER JOIN + LEFT JOIN · 4 tables)
SELECT CONCAT(p.first_name, ' ', p.last_name) AS player,
       rh.changed_at,
       rh.old_rating,
       rh.new_rating,
       rh.new_rating - rh.old_rating AS rating_change,
       CASE WHEN m.match_id IS NULL THEN 'Manual adjustment'
            ELSE CONCAT('Match #', m.match_id, ' (', f.format_name, ')') END AS source
FROM Rating_History rh
INNER JOIN Players p  ON p.player_id = rh.player_id
LEFT JOIN Matches m   ON m.match_id  = rh.match_id
LEFT JOIN Formats f   ON f.format_id = m.format_id
ORDER BY player, rh.changed_at;


-- Q3: How many matches and games has every player won, including
--     players who have not played yet?
--     Mission objective: Track player Fargo Ratings and game total indicators.
--     (LEFT JOIN)
SELECT CONCAT(p.first_name, ' ', p.last_name) AS player,
       p.fargo_rating,
       COUNT(pm.player_match_id)                               AS matches_played,
       SUM(CASE WHEN pm.games_won = pm.race_to THEN 1 ELSE 0 END) AS matches_won,
       COALESCE(SUM(pm.games_won), 0)                          AS total_games_won
FROM Players p
LEFT JOIN Player_Matches pm ON pm.player_id = p.player_id
GROUP BY p.player_id, p.first_name, p.last_name, p.fargo_rating
ORDER BY matches_won DESC, total_games_won DESC, player;


-- Q4: What is the schedule of every tournament: dates, game type and
--     table assignments?
--     Mission objective: Manage tournament parameters including formats and game types.
--     (INNER JOIN · 3 tables)
SELECT t.tournament_name,
       m.match_date,
       f.format_name,
       m.table_number,
       m.location
FROM Tournaments t
INNER JOIN Matches m ON m.tournament_id = t.tournament_id
INNER JOIN Formats f ON f.format_id     = m.format_id
ORDER BY t.tournament_name, m.match_date, m.table_number;


-- Q5: For every match between two rated players, does each player's race
--     match what the Handicap_Chart says for their rating gap?
--     Mission objective: Store handicap lookup thresholds based on rating differentials.
--     (INNER JOIN · 6 joins; Player_Matches and Players joined twice)
SELECT m.match_id,
       f.format_name,
       CONCAT(hp.first_name, ' ', hp.last_name) AS higher_rated,
       CONCAT(lp.first_name, ' ', lp.last_name) AS lower_rated,
       hp.fargo_rating - lp.fargo_rating        AS rating_gap,
       hpm.race_to  AS higher_race_played,
       hc.higher_race AS chart_higher_race,
       lpm.race_to  AS lower_race_played,
       hc.lower_race  AS chart_lower_race,
       CASE WHEN hpm.race_to = hc.higher_race AND lpm.race_to = hc.lower_race
            THEN 'OK' ELSE 'Check' END AS follows_chart
FROM Matches m
INNER JOIN Formats f          ON f.format_id = m.format_id
INNER JOIN Player_Matches hpm ON hpm.match_id = m.match_id
INNER JOIN Players hp         ON hp.player_id = hpm.player_id
INNER JOIN Player_Matches lpm ON lpm.match_id = m.match_id
                             AND lpm.player_id <> hpm.player_id
INNER JOIN Players lp         ON lp.player_id = lpm.player_id
                             AND lp.fargo_rating < hp.fargo_rating
INNER JOIN Handicap_Chart hc  ON hc.format_id = m.format_id
                             AND hp.fargo_rating - lp.fargo_rating BETWEEN hc.min_gap AND hc.max_gap
ORDER BY m.match_id;


-- =====================================================================
-- Phase 5B — Aggregate & Subquery Queries
-- Q6–Q10 use GROUP BY. Q7 and Q8 use HAVING. Q9 is a LEFT JOIN + aggregate
-- that shows zero counts. Q8, Q10, Q11 and Q12 use subqueries.
-- =====================================================================


-- Q6: For each game format, how many matches were played and what was
--     the average race and average games won?
--     Mission objective: Manage tournament parameters including formats and game types.
--     (3-table aggregate · GROUP BY · COUNT, AVG)
SELECT f.format_name,
       COUNT(DISTINCT m.match_id)  AS matches_played,
       ROUND(AVG(pm.race_to), 2)   AS avg_race,
       ROUND(AVG(pm.games_won), 2) AS avg_games_won
FROM Formats f
INNER JOIN Matches m         ON m.format_id = f.format_id
INNER JOIN Player_Matches pm ON pm.match_id = m.match_id
GROUP BY f.format_id, f.format_name
ORDER BY matches_played DESC;


-- Q7: Which players have won at least 2 matches?
--     Mission objective: Track player Fargo Ratings and game total indicators.
--     (GROUP BY · COUNT, SUM · HAVING)
SELECT CONCAT(p.first_name, ' ', p.last_name)                     AS player,
       COUNT(*)                                                   AS matches_played,
       SUM(CASE WHEN pm.games_won = pm.race_to THEN 1 ELSE 0 END) AS matches_won
FROM Players p
INNER JOIN Player_Matches pm ON pm.player_id = p.player_id
GROUP BY p.player_id, p.first_name, p.last_name
HAVING SUM(CASE WHEN pm.games_won = pm.race_to THEN 1 ELSE 0 END) >= 2
ORDER BY matches_won DESC, player;


-- Q8: Which players have won more total games than the average player?
--     Mission objective: Track player Fargo Ratings and game total indicators.
--     (GROUP BY · SUM, AVG · HAVING with a scalar subquery)
SELECT CONCAT(p.first_name, ' ', p.last_name) AS player,
       p.fargo_rating,
       SUM(pm.games_won)                       AS total_games_won
FROM Players p
INNER JOIN Player_Matches pm ON pm.player_id = p.player_id
GROUP BY p.player_id, p.first_name, p.last_name, p.fargo_rating
HAVING SUM(pm.games_won) > (
    SELECT AVG(player_total)
    FROM (SELECT SUM(games_won) AS player_total
          FROM Player_Matches
          GROUP BY player_id) AS totals
)
ORDER BY total_games_won DESC;


-- Q9: How many matches has each tournament scheduled, on how many tables,
--     including tournaments with no matches yet?
--     Mission objective: Record individual match schedules and table assignments.
--     (LEFT JOIN + aggregate · GROUP BY · COUNT, MIN, MAX · shows zero counts)
SELECT t.tournament_name,
       t.start_date,
       COUNT(m.match_id)              AS matches_scheduled,
       COUNT(DISTINCT m.table_number) AS tables_used,
       MIN(m.match_date)              AS first_match,
       MAX(m.match_date)              AS last_match
FROM Tournaments t
LEFT JOIN Matches m ON m.tournament_id = t.tournament_id
GROUP BY t.tournament_id, t.tournament_name, t.start_date
ORDER BY t.start_date;


-- Q10: For players who have competed in a tournament, how many rating
--      updates have they had, and what were their lowest and highest ratings?
--      Mission objective: Log pre-match and post-match rating updates.
--      (GROUP BY · COUNT, MIN, MAX · subquery with IN)
SELECT CONCAT(p.first_name, ' ', p.last_name) AS player,
       COUNT(*)           AS rating_updates,
       MIN(rh.new_rating) AS lowest_rating,
       MAX(rh.new_rating) AS highest_rating,
       p.fargo_rating     AS current_rating
FROM Rating_History rh
INNER JOIN Players p ON p.player_id = rh.player_id
WHERE rh.player_id IN (
    SELECT pm.player_id
    FROM Player_Matches pm
    INNER JOIN Matches m ON m.match_id = pm.match_id
    WHERE m.tournament_id IS NOT NULL
)
GROUP BY p.player_id, p.first_name, p.last_name, p.fargo_rating
ORDER BY rating_updates DESC, player;


-- Q11: Which players are rated above the league's average Fargo Rating?
--      Mission objective: Track player Fargo Ratings and game total indicators.
--      (scalar subquery in WHERE · AVG)
SELECT CONCAT(first_name, ' ', last_name) AS player,
       fargo_rating
FROM Players
WHERE fargo_rating > (SELECT AVG(fargo_rating) FROM Players)
ORDER BY fargo_rating DESC;


-- Q12: Which registered players have never played a match?
--      Mission objective: Maintain accurate player identity and contact records.
--      (NOT IN subquery)
SELECT CONCAT(first_name, ' ', last_name) AS player,
       email,
       phone_number
FROM Players
WHERE player_id NOT IN (SELECT player_id FROM Player_Matches)
ORDER BY last_name;
