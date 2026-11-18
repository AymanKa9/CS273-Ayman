# app — Phase 7 PHP pages

| File | What it does |
| --- | --- |
| `db.php` | PDO connection (ERRMODE_EXCEPTION, FETCH_ASSOC, EMULATE_PREPARES = false). Every page requires it. |
| `read.php` | Match Results page (Objective 4). JOINs Matches, Formats, MatchResults and Players and shows every match, both players, their race, games won and the winner. |

**read.php follows the Phase 7a checklist:**
- Runs a 4-table JOIN with a prepared statement (`prepare` → `execute` → `fetchAll`).
- Shows results in a `<table>` with `<thead>` headers and one `<tr>` per row in `<tbody>`.
- Optional filter by game format. The value is a bound parameter (`:format_id`), and only whole numbers are accepted, so SQL injection isn't possible.
- Shows "No records found." when there are no rows (try the One Pocket filter).
- Every database value is wrapped in `htmlspecialchars()` to prevent XSS.
- Database errors are logged, and the user sees a generic message.

## Run it
1. Load the database: run `schema/schema.sql`, then `data/seed.sql` in MySQL Workbench.
2. Start the server from this folder and type your MySQL username and password when asked:
   ```
   cd app
   ./start.sh
   ```
   (The password is typed in, not saved, because this repo is public. You can also run `DB_USER=yourname DB_PASS=yourpassword php -S localhost:8080` directly.)
3. Open http://localhost:8080/read.php
