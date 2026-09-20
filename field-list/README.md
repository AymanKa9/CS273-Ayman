# Phase 2 — Field List & Table Structures

## Refined Field List by Table

### Players Table
Represents individual pool players participating in matches; separated to isolate player profile and contact data from match events.

| Field Name | Data Type | Description |
| :--- | :--- | :--- |
| `player_id` | INT | Primary key uniquely identifying each player |
| `first_name` | VARCHAR(50) | Player's first name |
| `last_name` | VARCHAR(50) | Player's last name |
| `fargo_rating` | INT | Current Fargo rating score |
| `phone_number` | VARCHAR(15) | Primary contact phone number |
| `email` | VARCHAR(100) | Primary email address |

### Formats Table
* **Subject Description:** Represents official game rulesets (e.g., 8-Ball, 9-Ball); separated so multiple matches can share standardized rules without duplicating descriptions.

| Field Name | Data Type | Description |
| :--- | :--- | :--- |
| `format_id` | INT | Primary key for game format |
| `format_name` | VARCHAR(20) | Game format type |
| `rules_summary` | TEXT | Brief overview of specific format rules |

### Matches Table
* **Subject Description:** Represents the event details of a specific pool session; separated to isolate location and timing from player performance.

| Field Name | Data Type | Description |
| :--- | :--- | :--- |
| `match_id` | INT | Primary key for a played match |
| `match_date` | DATE | Date the match took place |
| `format_id` | INT | Foreign key linking to the game format |
| `location` | VARCHAR(100) | Venue where the match occurred |

### Player_Matches Table
* **Subject Description:** Represents a player's individual performance within a specific match; separated to resolve the many-to-many relationship between players and matches.

| Field Name | Data Type | Description |
| :--- | :--- | :--- |
| `player_match_id` | INT | Primary key for player-match mapping |
| `match_id` | INT | Foreign key linking to the match |
| `player_id` | INT | Foreign key linking to the player |
| `handicap_at_match` | INT | Player's handicap rating at time of match |
| `games_won` | INT | Number of games won in the match |
| `games_lost` | INT | Number of games lost in the match |
| `is_winner` | BOOLEAN | Indicates if player won the overall match |

