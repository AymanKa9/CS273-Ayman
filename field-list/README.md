# Database Field List & Key Specifications


### Field Specifications
| Field Name | Data Type | Length | Null Support | Required? | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `player_id` | `INT` | 11 | No Nulls | Yes | None | PK, Auto-increment |
| `first_name` | `VARCHAR` | 50 | No Nulls | Yes | None | Alphabetic characters only |
| `last_name` | `VARCHAR` | 50 | No Nulls | Yes | None | Alphabetic characters only |
| `fargo_rating` | `INT` | 11 | Nulls Allowed | No | `NULL` | Range: 100 to 900 |
| `phone_number`| `VARCHAR` | 20 | Nulls Allowed | No | `NULL` | AK, Standard phone format |
| `email` | `VARCHAR` | 100| Nulls Allowed | No | `NULL` | AK, Valid email format |

---


### Field Specifications
| Field Name | Data Type | Length | Null Support | Required? | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `format_id` | `INT` | 11 | No Nulls | Yes | None | PK, Auto-increment |
| `format_name` | `VARCHAR` | 50 | No Nulls | Yes | None | AK, Unique format title |
| `rules_summary`| `TEXT` | N/A | Nulls Allowed | No | `NULL` | Descriptive text |

---


### Field Specifications
| Field Name | Data Type | Length | Null Support | Required? | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `match_id` | `INT` | 11 | No Nulls | Yes | None | PK, Auto-increment |
| `match_date` | `DATETIME`| N/A | No Nulls | Yes | CURRENT_TIMESTAMP | Valid timestamp |
| `format_id` | `INT` | 11 | No Nulls | Yes | None | FK reference to Formats |
| `location` | `VARCHAR` | 100| No Nulls | Yes | None | Venue name/address |

---


### Field Specifications
| Field Name | Data Type | Length | Null Support | Required? | Default Value | Constraints / Range |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `player_match_id`| `INT` | 11 | No Nulls | Yes | None | PK, Auto-increment |
| `match_id` | `INT` | 11 | No Nulls | Yes | None | FK reference to Matches |
| `player_id` | `INT` | 11 | No Nulls | Yes | None | FK reference to Players |
| `handicap_at_match`| `INT` | 11 | No Nulls | Yes | None | Range: 0 to 1000 |
| `games_won` | `INT` | 11 | No Nulls | Yes | `0` | Range: >= 0 |
| `games_lost` | `INT` | 11 | No Nulls | Yes | `0` | Range: >= 0 |
| `is_winner` | `BOOLEAN` | N/A | No Nulls | Yes | `FALSE` | True/False (1 or 0) |
