<?php
// read.php -- Phase 7a read page: match results
// CS 273 Phase 7   Ayman Kaouch   Pool League Fargo Rating Tracker
// Objective 4 — Record individual match schedules, table assignments, and final scores.
// JOIN query: Matches → Formats, Matches → MatchResults → Players (Phase 5A Q1).

// ── 1. Connect ──────────────────────────────────────────────
require __DIR__ . '/db.php';

// ── 2. Query ────────────────────────────────────────────────
// Use one of my Phase 5A JOIN queries (Q1)
$select = 'SELECT m.MatchID,
                  m.MatchDate,
                  f.FormatName,
                  m.TableNumber,
                  m.Location,
                  p.FirstName,
                  p.LastName,
                  mr.RaceTo,
                  mr.GamesWon,
                  mr.GamesWon = mr.RaceTo AS Won
           FROM Matches m
           INNER JOIN Formats f       ON m.FormatID  = f.FormatID
           INNER JOIN MatchResults mr ON m.MatchID   = mr.MatchID
           INNER JOIN Players p       ON mr.PlayerID = p.PlayerID';
$order = ' ORDER BY m.MatchDate, m.MatchID, Won DESC';

try {
    // Formats for the dropdown, and the list of allowed filter values
    $stmt = $pdo->prepare('SELECT FormatID, FormatName FROM Formats ORDER BY FormatName');
    $stmt->execute();
    $formats = $stmt->fetchAll();

    $allowed_formats = [];
    foreach ($formats as $f) {
        $allowed_formats[] = $f['FormatID'];
    }

    // Get filter from query string, default to 'all'
    // NEVER concatenate the filter into the SQL: it is passed as a ? parameter
    $filter = $_GET['format'] ?? 'all';
    if ($filter === 'all' || !in_array($filter, $allowed_formats)) {
        $filter = 'all';
        $sql    = $select . $order;
        $params = [];
    } else {
        $sql    = $select . ' WHERE m.FormatID = ?' . $order;
        $params = [$filter];
    }

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $results = $stmt->fetchAll();

    // Player roster (newest first), so a player added on insert.php shows up here
    $stmt = $pdo->prepare('SELECT PlayerID, FirstName, LastName, FargoRating, Phone, Email
                           FROM Players
                           ORDER BY PlayerID DESC');
    $stmt->execute();
    $players = $stmt->fetchAll();
} catch (PDOException $e) {
    error_log($e->getMessage());
    $formats = [];
    $results = [];
    $players = [];
    $error   = 'Could not load match results. Please try again.';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Match Results | Pool League Fargo Tracker</title>
<style>
  body  { font-family: Arial, sans-serif; margin: 2rem; color: #333; }
  h1    { color: #1F3864; }
  table { border-collapse: collapse; width: 100%; margin-top: 1rem; }
  th    { background: #065a82; color: white; padding: .5rem 1rem; text-align: left; }
  td    { padding: .5rem 1rem; border-bottom: 1px solid #ddd; }
  tr:nth-child(even) { background: #f5f5f5; }
  .won  { color: #1E6B3C; font-weight: bold; }
  .lost { color: #7B1F1F; }
  .no-results { color: #888; font-style: italic; margin-top: 1rem; }
  .error      { color: #c0392b; background: #fdf2f2; padding: .75rem; }
  .success    { color: #1E6B3C; background: #eafaf1; padding: .75rem; }
  h2          { color: #1F3864; margin-top: 2.5rem; }
</style>
</head>
<body>

<h1>Match Results</h1>
<p>Every match, who played, the race each player had to reach, and who won.</p>

<?php if (isset($_GET['added']) && $_GET['added'] === '1'): ?>
  <p class="success">Record added.</p>
<?php endif; ?>

<p><a href="insert.php">+ Add a player</a></p>

<!-- HTML form for the filter -->
<form method="GET">
  <label>Game format:
    <select name="format" onchange="this.form.submit()">
      <option value="all">All formats</option>
      <?php foreach ($formats as $f): ?>
        <option value="<?= htmlspecialchars($f['FormatID']) ?>"
          <?= ($f['FormatID'] == $filter) ? 'selected' : '' ?>>
          <?= htmlspecialchars($f['FormatName']) ?>
        </option>
      <?php endforeach; ?>
    </select>
  </label>
</form>

<?php if (isset($error)): ?>
  <p class="error"><?= htmlspecialchars($error) ?></p>
<?php elseif (empty($results)): ?>
  <p class="no-results">No records found.</p>
<?php else: ?>
  <p><?= count($results) ?> record(s) found.</p>
  <table>
    <thead>
      <tr>
        <th>Match</th>
        <th>Date</th>
        <th>Format</th>
        <th>Table</th>
        <th>Location</th>
        <th>Player</th>
        <th>Race To</th>
        <th>Games Won</th>
        <th>Result</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($results as $row): ?>
        <?php
          // Date formatting: '2026-10-03 13:00:00' -> 'Oct 03, 2026 1:00 PM'
          $dt = new DateTime($row['MatchDate']);
          $nice_date = $dt->format('M d, Y g:i A');

          // Result: the winner is the player who reached their race
          $result = $row['Won'] ? 'Won' : 'Lost';
          $class  = match ($result) {
              'Won'   => 'won',
              'Lost'  => 'lost',
              default => '',
          };
        ?>
        <tr>
          <td><?= htmlspecialchars($row['MatchID']) ?></td>
          <td><?= htmlspecialchars($nice_date) ?></td>
          <td><?= htmlspecialchars($row['FormatName']) ?></td>
          <td><?= htmlspecialchars($row['TableNumber'] ?? '—') ?></td>
          <td><?= htmlspecialchars($row['Location']) ?></td>
          <td><?= htmlspecialchars($row['FirstName'] . ' ' . $row['LastName']) ?></td>
          <td><?= htmlspecialchars($row['RaceTo']) ?></td>
          <td><?= htmlspecialchars($row['GamesWon']) ?></td>
          <td class="<?= $class ?>"><?= htmlspecialchars($result) ?></td>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
<?php endif; ?>

<h2>Players</h2>
<?php if (empty($players)): ?>
  <p class="no-results">No records found.</p>
<?php else: ?>
  <table>
    <thead>
      <tr>
        <th>ID</th>
        <th>Name</th>
        <th>Fargo Rating</th>
        <th>Phone</th>
        <th>Email</th>
      </tr>
    </thead>
    <tbody>
      <?php foreach ($players as $pl): ?>
        <tr>
          <td><?= htmlspecialchars($pl['PlayerID']) ?></td>
          <td><?= htmlspecialchars($pl['FirstName'] . ' ' . $pl['LastName']) ?></td>
          <td><?= htmlspecialchars($pl['FargoRating'] ?? 'Not rated') ?></td>
          <td><?= htmlspecialchars($pl['Phone'] ?? '—') ?></td>
          <td><?= htmlspecialchars($pl['Email'] ?? '—') ?></td>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
<?php endif; ?>

</body>
</html>
