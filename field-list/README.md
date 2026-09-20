### Players Table
Represents individual pool players participating in matches, separated to isolate player profile and contact data from match events.

| Field Name | Field Status / Type | Description |
| :--- | :--- | :--- |
| `player_id` | Clean | Primary key uniquely identifying each player |
| `first_name` | Multipart  | Split from `player_name` into distinct first name field |
| `last_name` | Multipart  | Split from `player_name` into distinct last name field |
| `fargo_rating` | Clean | Current Fargo rating score |
| `phone_number` | Clean | Primary contact phone number |
| `email` | Clean | Primary email address |

### Formats Table
Represents official game rulesets (e.g., 8-Ball, 9-Ball), separated so multiple matches can share rules without duplicating descriptions.

| Field Name | Field Status / Type | Description |
| :--- | :--- | :--- |
| `format_id` | Clean | Primary key for game format |
| `format_name` | Clean | Game format type |
| `rules_summary` | Clean | Brief overview of specific format rules |

### Matches Table
Represents the event details of a specific pool session, separated to isolate location and timing from player performance.

| Field Name | Field Status / Type | Description |
| :--- | :--- | :--- |
| `match_id` | Clean | Primary key for a played match |
| `match_date` | Clean | Date the match took place |
| `format_id` | Clean | Foreign key linking to the game format |
| `location` | Clean | Venue where the match occurred |

### Player_Matches Table
Represents a player's individual performance within a specific match, separated to resolve the relationship between players and matches.

| Field Name | Field Status / Type | Description |
| :--- | :--- | :--- |
| `player_match_id` | Clean | Primary key for player-match mapping |
| `match_id` | Clean | Foreign key linking to the match |
| `player_id` | Clean | Foreign key linking to the player |
| `handicap_at_match` | Clean | Player's handicap rating at time of match |
| `games_won` | Clean | Number of games won in the match |
| `games_lost` | Clean | Number of games lost in the match |
| `is_winner` | Clean | Indicates if player won the overall match |
