# Phase 3 — ERD Design Narrative

**Project:** Pool League Fargo Rating Tracker
**Student:** Ayman Kaouch · CS 273 Database Systems · Fall 2026

The diagram is in [`diagram.drawio`](diagram.drawio) (open it at [app.diagrams.net](https://app.diagrams.net)). It uses crow's foot notation and shows every table, its primary key, its foreign keys, each relationship's type (1:1, 1:N, M:N) and the participation (mandatory / optional) on both ends.

---

## 1. What each table represents

| Table | Real-world concept |
| :--- | :--- |
| **Players** | A person registered in the league. Holds who they are (name, phone, email) and their current Fargo Rating, the number that measures their skill level. |
| **Formats** | A type of game that can be played, such as 8-Ball, 9-Ball or 10-Ball, with a short summary of its rules. It is a lookup table so the same format name is never typed two different ways. |
| **Matches** | One scheduled match: when it happened, where it was played, and which format it used. A match by itself does not say who played; that is stored in Player_Matches. |
| **Player_Matches** | One player's participation in one match. A normal match produces two rows here, one per player, each holding that player's handicap for the match, games won, games lost, and whether they won. This is the linking table that resolves the M:N relationship between Players and Matches. |

---

## 2. Relationships and why each has its type

### Players ⟷ Matches — **M:N**, resolved by `Player_Matches`
A player plays many matches over a season, and every match has more than one player (two in a normal match). Neither side can hold a single foreign key to the other, so the relationship is many-to-many. A relational database cannot store M:N directly, so it is split into two 1:N relationships through the linking table **Player_Matches**.

**If modeled differently:** Putting a `player_id` in Matches would only allow one player per match. Putting a `match_id` in Players would let a player play only one match ever. Both are wrong for a league.

### Players → Player_Matches — **1:N**
- **Players side: mandatory one.** Every Player_Matches row must belong to exactly one player (`player_id` is a NOT NULL FK). A result with no player is meaningless.
- **Player_Matches side: optional many.** A player can have zero rows here (someone who just signed up and has not played yet) or many.

**Why 1:N:** One player appears in many match rows, but each match row is about one player. **If modeled as 1:1**, a player could only ever have one match recorded and their win history would be lost. **If the participation were mandatory on the Player_Matches side**, the database could not add a new player until they had already played, which does not match how league signup works.

### Matches → Player_Matches — **1:N**
- **Matches side: mandatory one.** Every Player_Matches row belongs to exactly one match (`match_id` is a NOT NULL FK).
- **Player_Matches side: mandatory many (one or more).** A match has to have players; in practice it has exactly two rows.

**Why 1:N:** One match has several player rows, but each row is about a single match. **If modeled as 1:1**, a match could only store one player's score, so the opponent's score and handicap would have nowhere to go and you could never compare the two players. The `UNIQUE (match_id, player_id)` constraint stops the same player being entered twice in the same match.

### Formats → Matches — **1:N**
- **Formats side: mandatory one.** Every match is played under exactly one format (`format_id` is NOT NULL).
- **Matches side: optional many.** A format can exist with zero matches (for example 10-Ball added to the list before anyone plays it) or be used by many matches.

**Why 1:N:** A format like 9-Ball is reused across hundreds of matches, but a single match only uses one format. **If modeled as M:N**, a match could be "8-Ball and 9-Ball at the same time", which makes no sense for one match and would make race-to and handicap rules ambiguous. **If the format were stored as free text inside Matches** instead of a FK, typos like "9 ball" vs "9-Ball" would split the statistics.

---

## 3. Hardest relationship to figure out

The hardest one was **how players connect to matches**. My first idea was to give the Matches table two columns, `player1_id` and `player2_id`, because a pool match is usually two people. That looked simpler, but it caused problems:

- Each player has their *own* handicap, games won and games lost for that match. With two player columns I would need `player1_handicap`, `player2_handicap`, `player1_games_won`, and so on, which is a repeating group.
- Finding "all matches for player 7" would need `WHERE player1_id = 7 OR player2_id = 7` everywhere, and stats queries become awkward.
- It cannot handle formats with more than two players or a bye.

I resolved it by treating it as a true **M:N** relationship and moving everything that belongs to *one player in one match* into the linking table **Player_Matches**. Now every per-player value lives in one row, finding a player's history is one simple join, and the composite unique key `(match_id, player_id)` prevents duplicates.

---

## 4. Changes from the Phase 2 field list

1. **Named the tables.** The Phase 2 field list had four field tables without titles. In the ERD they are named **Players, Formats, Matches, Player_Matches** so the foreign keys clearly point somewhere.
2. **Added a composite unique constraint `UNIQUE (match_id, player_id)` to Player_Matches.** Drawing the linking table showed that nothing stopped the same player from being entered twice for one match. The surrogate key `player_match_id` stays as the PK, and the pair becomes an alternate key.
3. **Added VARCHAR lengths** (for example `first_name VARCHAR(50)`) so the diagram is ready to turn into SQL in Phase 4.
4. **Deferred for later phases:** my domain description also mentions tournaments, a handicap lookup table based on rating gaps, and a rating-history log. These are not in the Phase 2 field list, so they are not in this ERD yet. They would each connect as 1:N relationships (Tournaments → Matches, Players → Rating_History) and can be added when the schema is built.
