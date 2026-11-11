# Phase 3 — ERD Design Narrative

**Project:** Pool League Fargo Rating Tracker
**Student:** Ayman Kaouch · CS 273 Database Systems · Fall 2026

![ERD](erd.png)

The draw.io source is [`erd.drawio`](erd.drawio) (open it at [app.diagrams.net](https://app.diagrams.net)). It uses crow's foot notation and shows all 7 tables, every primary and foreign key, the type of every relationship, and the participation (mandatory / optional) on both ends.

---

## 1. What each table represents

| Table | Real-world concept |
| :--- | :--- |
| **Players** | A person registered in the league: name, contact info, and their *current* Fargo Rating (the number that measures skill). |
| **Formats** | A game type the league plays, such as 8-Ball, 9-Ball or 10-Ball, with a summary of its rules. |
| **Tournaments** | A tournament event (name, dates, venue) that groups a set of matches. |
| **Matches** | One scheduled match: when and where it is played, the table number, the format, and the tournament it belongs to (if any). |
| **MatchResults** | One player's result in one match: the race they had to reach (their handicap) and the games they won. The winner is whoever reached their race (`GamesWon = RaceTo`). A normal match has two rows. This is the linking table for Players ⟷ Matches. |
| **HandicapChart** | The league's handicap chart. For each format and each range of rating gaps, it says how many games the higher-rated and the lower-rated player must win. |
| **RatingHistory** | A log entry every time a player's Fargo Rating changes, with the old and new rating and the match that caused it. |

---

## 2. Relationships and why each has its type

### Players ⟷ Matches — **M:N**, resolved by `MatchResults`
A player plays many matches over a season, and every match has more than one player (two in a normal match). Neither table can hold a single FK to the other, so this is many-to-many, which a relational database cannot store directly. It is split into two 1:N relationships through **MatchResults**.
**If modeled differently:** a `PlayerID` in Matches would allow only one player per match, and a `MatchID` in Players would let a player play only one match ever.

### Players → MatchResults — **1:N** (Players mandatory one · MatchResults optional many)
Each MatchResults row is about exactly one player (`PlayerID` NOT NULL), but one player has many match rows. A player can have zero rows if they just signed up.
**If modeled differently:** as 1:1, a player could only ever record one match. If MatchResults were mandatory, a new player could not be added until they had already played.

### Matches → MatchResults — **1:N** (Matches mandatory one · MatchResults mandatory many)
Each row belongs to exactly one match (`MatchID` NOT NULL), and one match has several player rows (two in practice). A match without players makes no sense, so both sides are mandatory.
**If modeled differently:** as 1:1, a match could store only one player's score, so the opponent's race and result would have nowhere to go. The composite primary key `(MatchID, PlayerID)` stops the same player being entered twice in one match.

### Formats → Matches — **1:N** (Formats mandatory one · Matches optional many)
A format like 9-Ball is used by many matches, but one match is played under exactly one format (`FormatID` NOT NULL). A format can exist before anyone plays it.
**If modeled differently:** as M:N, one match could be "8-Ball and 9-Ball at once", which makes the race and handicap meaningless. Storing the format as free text in Matches would let typos like "9 ball" vs "9-Ball" split the statistics.

### Tournaments → Matches — **1:N** (Tournaments optional one · Matches optional many)
A tournament contains many matches, but a match belongs to at most one tournament. The FK `TournamentID` is **nullable** because regular weekly league matches are not part of any tournament, and a tournament can be created before its matches are scheduled.
**If modeled differently:** making `TournamentID` NOT NULL would force fake tournaments for every league night. Making it M:N would let one match count in two tournaments, double-counting results.

### Formats → HandicapChart — **1:N** (Formats mandatory one · HandicapChart optional many)
Each chart row belongs to one format, because races differ between games (a 9-Ball race is not the same as an 8-Ball race). One format has many rows, one per rating-gap range.
**If modeled differently:** without the `FormatID` FK there could only be one chart for every game type. `UNIQUE (FormatID, MinGap)` stops two overlapping rows from giving two different races for the same gap.
HandicapChart is not linked to Matches or Players by a FK. It is a **lookup table**: the app computes the gap between the two players' ratings and selects the row where the gap falls between `MinGap` and `MaxGap`. That race is then saved into `MatchResults.RaceTo`, so changing the chart later does not rewrite old matches.

### Players → RatingHistory — **1:N** (Players mandatory one · RatingHistory optional many)
A player's rating changes many times, and each change is about one player (`PlayerID` NOT NULL). A new player has no history yet.
**If modeled differently:** storing only `Players.FargoRating` (as in Phase 2) overwrites the old value after every match, so growth over time is lost. As 1:1, only one change could ever be stored.

### Matches → RatingHistory — **1:N** (Matches optional one · RatingHistory optional many)
A completed match causes rating changes for both players, so one match can have several history rows. The FK `MatchID` is **nullable** because a director can also adjust a rating manually (for example, a player's first established rating), with no match involved.
**If modeled differently:** making `MatchID` NOT NULL would block manual adjustments. Leaving out the FK entirely would make it impossible to tell which match caused a rating to rise or fall.

---

## 3. Hardest relationship to figure out

The hardest one was **how players connect to matches**. Because a pool match is usually two people, the obvious idea is to give Matches two columns, `Player1ID` and `Player2ID`. That causes problems:

- Each player has their *own* race and games won, so the table would need `Player1Race`, `Player2Race`, `Player1GamesWon`, and so on, which is a repeating group.
- Finding all matches for one player would need `WHERE Player1ID = 7 OR Player2ID = 7` in every query.

I resolved it by treating it as a true **M:N** relationship and moving everything that belongs to *one player in one match* into the linking table **MatchResults**. A player's full history is now one simple join, and the composite primary key `(MatchID, PlayerID)` prevents duplicates.

A close second was the **handicap**. Phase 2 had a `handicap_at_match` number from 0 to 1000, but in Fargo leagues the handicap *is* the race to a number of games. It became `RaceTo` in MatchResults, with the rules stored separately in the HandicapChart lookup table.

---

## 4. Changes from the Phase 2 field list

1. **Named every table** (Players, Formats, Matches, MatchResults) and added `VARCHAR` lengths so the ERD is ready for SQL in Phase 4.
2. **Added three tables** my mission statement already promised but the field list did not have: **Tournaments**, **HandicapChart** and **RatingHistory**. Drawing the ERD made it obvious that objectives like "manage tournament parameters," "handicap lookup thresholds" and "log pre-match and post-match rating updates" had no tables behind them.
3. **Added `TournamentID` (nullable FK) to Matches** to connect matches to tournaments, and **`TableNumber`** to cover the "table assignments" objective.
4. **Replaced `handicap_at_match` (0–1000) with `RaceTo` (1–15)**, as explained above.
5. **Removed `games_lost`** from MatchResults. It always equals the opponent's `GamesWon`, so storing it twice could make the two values disagree.
6. **Made `(MatchID, PlayerID)` unique** in MatchResults so a player cannot appear twice in one match. It is now the table's composite primary key.
7. **Smaller field fixes:** names now allow spaces, hyphens and apostrophes; phone is no longer a unique key (family members can share one); `MatchDate` no longer defaults to the current time, because matches are scheduled ahead.

---

## 5. What I would add or change with more time

1. **Enforce exactly two players per match.** Crow's foot can show "one or many" MatchResults per match, but not "exactly two." I would add a check (a trigger or a rule in the PHP app) that blocks a match from being completed without two MatchResults rows, and that only one player reaches their race.
2. **A `Venues` table.** `Location` is free text in both Matches and Tournaments, so "Joe's Billiards" and "Joes Billiards" would count as two places. A Venues table with a FK from both would fix that and let me store how many tables each venue has.
3. **Teams and Seasons.** Real pool leagues are usually played by teams over a season. That would add Teams, Seasons, and a linking table for Players ⟷ Teams (a player can change teams between seasons), which is another M:N to resolve.
4. **Check that `GamesWon` never exceeds `RaceTo`.** This is a cross-column rule that belongs in the Phase 4 schema as a `CHECK` constraint (done in `schema/schema.sql` as `chk_games_won`).

---

## Changes after Phase 3 feedback

- **Removed `is_winner` from MatchResults.** The winner can be worked out from the data (`GamesWon = RaceTo`), so storing it could disagree with the score. This is the same reason `games_lost` was removed.
- **Added relationship verb labels** to every line in the ERD (for example, Players *plays in* MatchResults).
- **Renamed to match the course naming conventions (Week 5–7 lectures).** Fields are now TableName + ID / PascalCase (`PlayerID`, `FargoRating`). The linking table Player_Matches is now **MatchResults**, named after what the relationship represents, with the composite primary key `(MatchID, PlayerID)` instead of its own ID column.

