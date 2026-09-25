# Database Field List & Key Specifications


### Field Specifications
| Field Name | Data Type  | Null Support  | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- | 
| `player_id` | `INT`  | Not Null  | None | PK, Auto-increment |
| `first_name` | `VARCHAR`  | Not Null  | None | Alphabetic characters only |
| `last_name` | `VARCHAR`  | Not Null  | None | Alphabetic characters only |
| `fargo_rating` | `INT`  | Null | `NULL` | Range: 100 to 900 |
| `phone_number`| `VARCHAR`  | Null   | `NULL` | AK, Standard phone format |
| `email` | `VARCHAR` | Null  | `NULL` | AK, Valid email format |

---


### Field Specifications
| Field Name | Data Type  | Null Support  | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- | 
| `format_id` | `INT`  | Not Null  | None | PK, Auto-increment |
| `format_name` | `VARCHAR`  | Not Null  | None | AK, Unique format title |
| `rules_summary`| `TEXT`  | Null  | `NULL` | Descriptive text |

---


### Field Specifications
| Field Name | Data Type  | Null Support  | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- |  
| `match_id` | `INT`  | Not Null  | None | PK, Auto-increment |
| `match_date` | `DATETIME` | Not Null  | CURRENT_TIMESTAMP | Valid timestamp |
| `format_id` | `INT`  | Not Null  | None | FK reference to Formats |
| `location` | `VARCHAR` | Not Null  | None | Venue name/address |

---


### Field Specifications
| Field Name | Data Type  | Null Support  | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- | 
| `player_match_id`| `INT`  | Not Null  | None | PK, Auto-increment |
| `match_id` | `INT`  | Not Null  | None | FK reference to Matches |
| `player_id` | `INT`  | Not Null  | None | FK reference to Players |
| `handicap_at_match`| `INT`  | Not Null  | None | Range: 0 to 1000 |
| `games_won` | `INT`  | Not Null  | `0` | Range: >= 0 |
| `games_lost` | `INT`  | Not Null  | `0` | Range: >= 0 |
| `is_winner` | `BOOLEAN`  | Not Null  | `FALSE` | True/False (1 or 0) |
