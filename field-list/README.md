# Database Field List & Key Specifications


### Field Specifications
| Field Name | Data Type  | Null Support | Required? | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `player_id` | `INT`  | No Nulls | Yes | None | PK, Auto-increment |
| `first_name` | `VARCHAR`  | No Nulls | Yes | None | Alphabetic characters only |
| `last_name` | `VARCHAR`  | No Nulls | Yes | None | Alphabetic characters only |
| `fargo_rating` | `INT`  | Nulls Allowed | No | `NULL` | Range: 100 to 900 |
| `phone_number`| `VARCHAR`  | Nulls Allowed | No | `NULL` | AK, Standard phone format |
| `email` | `VARCHAR` | Nulls Allowed | No | `NULL` | AK, Valid email format |

---


### Field Specifications
| Field Name | Data Type  | Null Support | Required? | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `format_id` | `INT`  | No Nulls | Yes | None | PK, Auto-increment |
| `format_name` | `VARCHAR`  | No Nulls | Yes | None | AK, Unique format title |
| `rules_summary`| `TEXT`  | Nulls Allowed | No | `NULL` | Descriptive text |

---


### Field Specifications
| Field Name | Data Type  | Null Support | Required? | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- | :--- | 
| `match_id` | `INT`  | No Nulls | Yes | None | PK, Auto-increment |
| `match_date` | `DATETIME` | No Nulls | Yes | CURRENT_TIMESTAMP | Valid timestamp |
| `format_id` | `INT`  | No Nulls | Yes | None | FK reference to Formats |
| `location` | `VARCHAR` | No Nulls | Yes | None | Venue name/address |

---


### Field Specifications
| Field Name | Data Type  | Null Support | Required? | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- | :--- | 
| `player_match_id`| `INT`  | No Nulls | Yes | None | PK, Auto-increment |
| `match_id` | `INT`  | No Nulls | Yes | None | FK reference to Matches |
| `player_id` | `INT`  | No Nulls | Yes | None | FK reference to Players |
| `handicap_at_match`| `INT`  | No Nulls | Yes | None | Range: 0 to 1000 |
| `games_won` | `INT`  | No Nulls | Yes | `0` | Range: >= 0 |
| `games_lost` | `INT`  | No Nulls | Yes | `0` | Range: >= 0 |
| `is_winner` | `BOOLEAN`  | No Nulls | Yes | `FALSE` | True/False (1 or 0) |
