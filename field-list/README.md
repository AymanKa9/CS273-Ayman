

| Field Name | Description |
| :--- | :--- |
| `user_id` | Unique identifier assigned to each registered user account. |
| `first_name` | The user's given first name. |
| `last_name` | The user's family or surname. |
| `email_address` | The primary contact and login email for the account. |
| `password_hash` | The securely hashed version of the user's account password. |
| `phone_number` | Contact phone number for the user or customer. |
| `created_at` | Timestamp indicating when the record was created in the system. |
| `updated_at` | Timestamp recording the last time the record was modified. |
| `is_active` | Boolean flag indicating whether the account/record is active or soft-deleted. |
| `street_address` | Physical street address line for billing or shipping. |
| `city` | City associated with the physical address. |
| `state_province` | State, province, or region associated with the address. |
| `postal_code` | ZIP or postal code for location routing. |
| `country` | Country code or name associated with the address. |
| `item_id` | Unique identifier assigned to a specific catalog item or product. |
| `item_name` | The title or short name of the product or service. |
| `item_description` | Detailed text describing the features or details of an item. |
| `unit_price` | Base cost charged per single unit of an item. |
| `quantity_in_stock` | Current physical count of units available in inventory. |
| `reorder_threshold` | Minimum inventory quantity that triggers a restock alert. |
| `order_id` | Unique identifier for a customer transaction or order. |
| `order_date` | Date and time when an order was placed. |
| `order_status` | Current stage of processing (e.g., Pending, Shipped, Delivered, Cancelled). |
| `quantity_ordered` | Number of units purchased for a given line item. |
| `discount_amount` | Fixed dollar amount or percentage deducted from a transaction. |

---

## Calculated Fields 

| Calculated Value | Derivation Formula / Description |
| :--- | :--- |
| **Line Item Total** | Calculated by multiplying `quantity_ordered` by `unit_price`. |
| **Order Subtotal** | Sum of all `Line Item Total` values associated with a specific `order_id`. |
| **Final Order Total** | Calculated as `Order Subtotal` minus `discount_amount` plus applicable taxes/shipping fees. |
| **Account Age** | Derived by subtracting `created_at` date from the current system date (`CURRENT_DATE - created_at`). |
