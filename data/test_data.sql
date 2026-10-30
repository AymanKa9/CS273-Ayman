-- =====================================================================
-- CS 273 · Test data for Phase 5A queries
-- Project: Pool League Fargo Rating Tracker · Ayman Kaouch
--
-- Run AFTER schema/schema.sql. Small but realistic data so every
-- query in queries/queries.sql returns rows. Phase 6 will expand it.
--
-- Built-in edge cases:
--   * Emma Cole has never played (shows up only with a LEFT JOIN)
--   * Jake Miller is not rated yet (fargo_rating NULL)
--   * Matches 5-8 are league nights with no tournament (tournament_id NULL)
--   * Some rating changes are manual adjustments (match_id NULL)
--   * Every race_to follows the Handicap_Chart for that format and gap
-- =====================================================================

USE FargoLeague;

INSERT INTO Formats (format_id, format_name, rules_summary) VALUES
(1, '8-Ball',  'Solids vs stripes; pocket the 8 last on a called shot.'),
(2, '9-Ball',  'Rotation game with balls 1-9; legally pocketing the 9 wins the rack.'),
(3, '10-Ball', 'Rotation game with balls 1-10; every shot must be called.');

INSERT INTO Players (player_id, first_name, last_name, fargo_rating, phone_number, email) VALUES
(1, 'Sara',  'Bennett', 450, '573-555-0141', 'sara.bennett@email.com'),
(2, 'Omar',  'Haddad',  600, '573-555-0142', 'omar.haddad@email.com'),
(3, 'Luis',  'Ortega',  520, '573-555-0143', 'luis.ortega@email.com'),
(4, 'Grace', 'Kim',     610, NULL,           'grace.kim@email.com'),
(5, 'Tom',   'Walsh',   380, '573-555-0145', NULL),
(6, 'Nadia', 'Rahimi',  700, '217-555-0146', 'nadia.rahimi@email.com'),
(7, 'Jake',  'Miller',  NULL, '573-555-0147', 'jake.miller@email.com'),
(8, 'Emma',  'Cole',    480, '573-555-0148', 'emma.cole@email.com');

INSERT INTO Tournaments (tournament_id, tournament_name, start_date, end_date, location) VALUES
(1, 'Fall 9-Ball Open',         '2026-10-03', '2026-10-04', 'Cue Masters, Hannibal MO'),
(2, 'Halloween 8-Ball Classic', '2026-10-31', NULL,         'Rack Room, Quincy IL');

-- Races by rating gap (higher-rated player / lower-rated player)
INSERT INTO Handicap_Chart (format_id, min_gap, max_gap, higher_race, lower_race) VALUES
(1,   0,  49, 4, 4), (1,  50,  99, 4, 3), (1, 100, 199, 5, 3), (1, 200, 800, 6, 3),
(2,   0,  49, 5, 5), (2,  50,  99, 5, 4), (2, 100, 149, 6, 4), (2, 150, 199, 7, 4), (2, 200, 800, 7, 3),
(3,   0,  99, 5, 5), (3, 100, 800, 6, 4);

INSERT INTO Matches (match_id, tournament_id, format_id, match_date, location, table_number) VALUES
(1, 1,    2, '2026-10-03 13:00:00', 'Cue Masters, Hannibal MO', 1),
(2, 1,    2, '2026-10-03 13:00:00', 'Cue Masters, Hannibal MO', 2),
(3, 1,    2, '2026-10-03 15:00:00', 'Cue Masters, Hannibal MO', 1),
(4, 1,    2, '2026-10-04 12:00:00', 'Cue Masters, Hannibal MO', 1),
(5, NULL, 1, '2026-10-14 19:00:00', 'Rack Room, Quincy IL',     3),
(6, NULL, 1, '2026-10-14 19:00:00', 'Rack Room, Quincy IL',     4),
(7, NULL, 3, '2026-10-21 19:30:00', 'Rack Room, Quincy IL',     2),
(8, NULL, 2, '2026-10-28 19:00:00', 'Cue Masters, Hannibal MO', 1);

-- One row per player per match. The winner is whoever reached their race.
INSERT INTO Player_Matches (match_id, player_id, race_to, games_won) VALUES
(1, 1, 4, 4), (1, 2, 7, 5),   -- Sara 450 vs Omar 600   (gap 150) Sara wins
(2, 4, 5, 5), (2, 3, 4, 2),   -- Grace 610 vs Luis 520  (gap 90)  Grace wins
(3, 6, 7, 7), (3, 5, 3, 1),   -- Nadia 700 vs Tom 380   (gap 320) Nadia wins
(4, 4, 7, 6), (4, 1, 4, 4),   -- Grace 610 vs Sara 450  (gap 160) Sara wins
(5, 2, 4, 4), (5, 3, 3, 2),   -- Omar 600 vs Luis 520   (gap 80)  Omar wins
(6, 5, 3, 2), (6, 7, 3, 3),   -- Tom 380 vs Jake (unrated)        Jake wins
(7, 6, 5, 5), (7, 4, 5, 3),   -- Nadia 700 vs Grace 610 (gap 90)  Nadia wins
(8, 2, 7, 6), (8, 5, 3, 3);   -- Omar 600 vs Tom 380    (gap 220) Tom wins

INSERT INTO Rating_History (player_id, match_id, old_rating, new_rating, changed_at) VALUES
(1, NULL, NULL, 430, '2026-09-01 10:00:00'),   -- first rating (manual)
(1, 1,    430,  442, '2026-10-03 15:00:00'),
(1, 4,    442,  450, '2026-10-04 14:00:00'),
(2, NULL, NULL, 612, '2026-09-01 10:00:00'),
(2, 1,    612,  604, '2026-10-03 15:00:00'),
(2, 8,    604,  600, '2026-10-28 21:00:00'),
(4, NULL, NULL, 615, '2026-09-01 10:00:00'),
(4, 2,    615,  618, '2026-10-03 15:00:00'),
(4, 4,    618,  612, '2026-10-04 14:00:00'),
(4, 7,    612,  610, '2026-10-21 21:30:00'),
(5, NULL, NULL, 370, '2026-09-01 10:00:00'),
(5, 8,    370,  380, '2026-10-28 21:00:00');
