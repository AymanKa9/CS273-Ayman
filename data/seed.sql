-- ══════════════════════════════════════════════
-- Phase 6: Seed Data Script
-- Ayman Kaouch | CS273 | Nov 2026
-- Pool League Fargo Rating Tracker
-- Run AFTER schema/schema.sql, from a fresh session.
-- ══════════════════════════════════════════════
USE FargoLeague;

-- ── 1. Parent table: Players ───────────────────────────────
-- Edge cases: Grace has no phone, Tom has no email, Jake is not rated yet,
-- Emma has signed up but never played.
INSERT INTO Players (FirstName, LastName, FargoRating, Phone, Email)
VALUES
('Sara',  'Bennett', 450,  '573-555-0141', 'sara.bennett@email.com'),
('Omar',  'Haddad',  600,  '573-555-0142', 'omar.haddad@email.com'),
('Luis',  'Ortega',  520,  '573-555-0143', 'luis.ortega@email.com'),
('Grace', 'Kim',     610,  NULL,           'grace.kim@email.com'),
('Tom',   'Walsh',   380,  '573-555-0145', NULL),
('Nadia', 'Rahimi',  700,  '217-555-0146', 'nadia.rahimi@email.com'),
('Jake',  'Miller',  NULL, '573-555-0147', 'jake.miller@email.com'),
('Emma',  'Cole',    480,  '573-555-0148', 'emma.cole@email.com');

-- ── 2. Parent table: Formats ───────────────────────────────
INSERT INTO Formats (FormatName, RulesSummary)
VALUES
('8-Ball',        'Solids vs stripes; pocket the 8 last on a called shot.'),
('9-Ball',        'Rotation with balls 1-9; legally pocketing the 9 wins the rack.'),
('10-Ball',       'Rotation with balls 1-10; every shot must be called.'),
('One Pocket',    'Each player owns one corner pocket; first to 8 balls in it wins.'),
('Straight Pool', 'Call any ball, any pocket; play to an agreed point total.');

-- ── 3. Parent table: Tournaments ───────────────────────────
-- Edge cases: one-day events have no EndDate (NULL).
INSERT INTO Tournaments (TournamentName, StartDate, EndDate, Location)
VALUES
('Fall 9-Ball Open',               '2026-10-03', '2026-10-04', 'Cue Masters, Hannibal MO'),
('Halloween 8-Ball Classic',       '2026-10-31', NULL,         'Rack Room, Quincy IL'),
('Thanksgiving 10-Ball Shootout',  '2026-11-27', '2026-11-28', 'Cue Masters, Hannibal MO'),
('Winter One Pocket Invitational', '2026-12-12', NULL,         'Rack Room, Quincy IL'),
('New Year 9-Ball Championship',   '2027-01-09', '2027-01-10', 'Cue Masters, Hannibal MO');

-- ── 4. Child table: HandicapChart ──────────────────────────
-- (Formats must exist before this)
-- Races by rating gap: HigherRace = higher-rated player, LowerRace = lower-rated player.
INSERT INTO HandicapChart (FormatID, MinGap, MaxGap, HigherRace, LowerRace)
VALUES
(1,   0,  49, 4, 4), (1,  50,  99, 4, 3), (1, 100, 199, 5, 3), (1, 200, 800, 6, 3),
(2,   0,  49, 5, 5), (2,  50,  99, 5, 4), (2, 100, 149, 6, 4), (2, 150, 199, 7, 4), (2, 200, 800, 7, 3),
(3,   0,  99, 5, 5), (3, 100, 800, 6, 4);

-- ── 5. Child table: Matches ────────────────────────────────
-- (Formats and Tournaments must exist before this)
-- Matches 5-8 are league nights, so TournamentID is NULL.
INSERT INTO Matches (TournamentID, FormatID, MatchDate, Location, TableNumber)
VALUES
(1,    2, '2026-10-03 13:00:00', 'Cue Masters, Hannibal MO', 1),
(1,    2, '2026-10-03 13:00:00', 'Cue Masters, Hannibal MO', 2),
(1,    2, '2026-10-03 15:00:00', 'Cue Masters, Hannibal MO', 1),
(1,    2, '2026-10-04 12:00:00', 'Cue Masters, Hannibal MO', 1),
(NULL, 1, '2026-10-14 19:00:00', 'Rack Room, Quincy IL',     3),
(NULL, 1, '2026-10-14 19:00:00', 'Rack Room, Quincy IL',     4),
(NULL, 3, '2026-10-21 19:30:00', 'Rack Room, Quincy IL',     2),
(NULL, 2, '2026-10-28 19:00:00', 'Cue Masters, Hannibal MO', 1);

-- ── 6. Linking table: MatchResults ─────────────────────────
-- (Matches and Players must exist before this)
-- One row per player per match. The winner is whoever reached their race.
-- Every RaceTo follows the HandicapChart for that format and rating gap.
INSERT INTO MatchResults (MatchID, PlayerID, RaceTo, GamesWon)
VALUES
(1, 1, 4, 4), (1, 2, 7, 5),   -- Sara 450 vs Omar 600   (gap 150) Sara wins
(2, 4, 5, 5), (2, 3, 4, 2),   -- Grace 610 vs Luis 520  (gap 90)  Grace wins
(3, 6, 7, 7), (3, 5, 3, 1),   -- Nadia 700 vs Tom 380   (gap 320) Nadia wins
(4, 4, 7, 6), (4, 1, 4, 4),   -- Grace 610 vs Sara 450  (gap 160) Sara wins
(5, 2, 4, 4), (5, 3, 3, 2),   -- Omar 600 vs Luis 520   (gap 80)  Omar wins
(6, 5, 3, 2), (6, 7, 3, 3),   -- Tom 380 vs Jake (unrated)        Jake wins
(7, 6, 5, 5), (7, 4, 5, 3),   -- Nadia 700 vs Grace 610 (gap 90)  Nadia wins
(8, 2, 7, 6), (8, 5, 3, 3);   -- Omar 600 vs Tom 380    (gap 220) Tom wins

-- ── 7. Child table: RatingHistory ──────────────────────────
-- (Players and Matches must exist before this)
-- Rows with MatchID NULL are manual adjustments (a player's first rating).
INSERT INTO RatingHistory (PlayerID, MatchID, OldRating, NewRating, ChangedAt)
VALUES
(1, NULL, NULL, 430, '2026-09-01 10:00:00'),
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


-- ══════════════════════════════════════════════
-- TRANSACTION 1: Successful player registration
-- Registering a rated player takes two steps: add the player AND log their
-- starting rating in RatingHistory. Both must succeed or neither should
-- happen; otherwise a player could exist with a rating that has no history.
-- ══════════════════════════════════════════════
START TRANSACTION;
INSERT INTO Players (FirstName, LastName, FargoRating, Phone, Email)
VALUES ('Marcus', 'Reed', 500, '573-555-0149', 'marcus.reed@email.com');
INSERT INTO RatingHistory (PlayerID, MatchID, OldRating, NewRating, ChangedAt)
VALUES (LAST_INSERT_ID(), NULL, NULL, 500, '2026-11-09 18:00:00');
COMMIT;
SELECT 'Marcus Reed registered with a starting rating of 500' AS Result;

-- ══════════════════════════════════════════════
-- TRANSACTION 2: Intentional ROLLBACK
-- Scheduling a tournament match takes two steps: add the match AND add both
-- players' rows in MatchResults. Nadia withdrew from the Thanksgiving
-- Shootout before the draw was final, so the whole booking is undone.
-- ══════════════════════════════════════════════
START TRANSACTION;
INSERT INTO Matches (TournamentID, FormatID, MatchDate, Location, TableNumber)
VALUES (3, 3, '2026-11-27 12:00:00', 'Cue Masters, Hannibal MO', 1);
SET @NewMatchID = LAST_INSERT_ID();   -- the MatchID just created
INSERT INTO MatchResults (MatchID, PlayerID, RaceTo, GamesWon)
VALUES (@NewMatchID, 6, 6, 0),   -- Nadia 700 vs Tom 380 (10-Ball, gap 320)
       (@NewMatchID, 5, 4, 0);
-- Nadia withdrew. Don't keep a half-scheduled match.
ROLLBACK;
SELECT COUNT(*) AS ThanksgivingMatches   -- 0: the ROLLBACK undid both INSERTs
FROM Matches
WHERE TournamentID = 3;
