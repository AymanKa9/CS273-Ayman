-- =====================================================================
-- CS 273 · Phase 5A — JOIN Queries
-- Project: Pool League Fargo Rating Tracker · Ayman Kaouch
--
-- Run order: schema/schema.sql -> data/test_data.sql -> this file.
-- The winner of a match is the player whose games_won = race_to.
-- =====================================================================

USE FargoLeague;


-- Q1: What was the final score of every match, who played, and who won?
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
