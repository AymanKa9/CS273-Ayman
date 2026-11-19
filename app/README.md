# app — Phase 7 PHP pages

| File | What it does |
| --- | --- |
| `db.php` | PDO connection (ERRMODE_EXCEPTION, FETCH_ASSOC, EMULATE_PREPARES = false). Every page requires it. |
| `insert.php` | Add Player form (Objective 1). Validates the input, runs a prepared INSERT into Players, then redirects to `read.php?added=1`. |
| `read.php` | Match Results page (Objective 4). JOINs Matches, Formats, MatchResults and Players and shows every match, both players, their race, games won and the winner. |

**read.php follows the Phase 7a checklist:**
- Runs a 4-table JOIN with a prepared statement (`prepare` → `execute` → `fetchAll`).
- Shows results in a `<table>` with `<thead>` headers and one `<tr>` per row in `<tbody>`.
- Optional filter by game format: the value must be in the whitelist of real FormatIDs, and it is passed as a `?` parameter, never concatenated into the SQL.
- Shows "No records found." when there are no rows (try the One Pocket filter).
- Every database value is wrapped in `htmlspecialchars()` to prevent XSS.
- Database errors are logged, and the user sees a generic message.

**insert.php follows the Phase 7b checklist:**
- Form fields match the Players table: `text` (names, phone), `number` (Fargo Rating, 100–900), `email`.
- Detects the submission with `isset($_POST['submit_form'])` and `trim()`s every input.
- Validation: first and last name are required; Fargo Rating must be a whole number from 100 to 900 (or empty for a new, unrated player); email must be a valid address if given; a duplicate email is caught and reported.
- Errors are listed at the top of the form, and every field is re-filled from `$_POST`.
- Prepared `INSERT` with named parameters (`:first_name`, ...), with no user input concatenated into the SQL.
- Post-Redirect-Get: `header('Location: read.php?added=1'); exit;` so refreshing the page can't add the player twice.
- `read.php` shows **"Record added."** when `?added=1` is in the URL, links to `insert.php`, and lists all players (newest first) so the new player is visible.

## Run it
1. Load the database: run `schema/schema.sql`, then `data/seed.sql` in MySQL Workbench.
2. Start PHP's built-in server from the `app` folder, with your MySQL username and password:
   ```
   cd app
   DB_USER=yourname DB_PASS=yourpassword php -S localhost:8080
   ```
   (`db.php` reads them with `getenv()`, so the password is never saved in this public repo. Without them it uses `root` with no password, like the class template.)
3. Open http://localhost:8080/read.php
