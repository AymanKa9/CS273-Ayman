<?php
// read.php -- Phase 7a read page: match results
// CS 273 Phase 7   Ayman Kaouch   Pool League Fargo Rating Tracker
// Objective 4 — Record individual match schedules, table assignments, and final scores.
//
// JOIN query: Matches → Formats, Matches → MatchResults → Players (same as Phase 5A Q1).
// Optional filter by game format, passed as a bound parameter (never put into the SQL string).

// ── 1. Connect ──────────────────────────────────────────────
require __DIR__ . '/db.php';

$formats = [];
$results = [];

// ── 2. Filter ───────────────────────────────────────────────
// Format filter from the URL, e.g. read.php?format=2. Only a whole number is accepted.
$formatId = filter_input(INPUT_GET, 'format', FILTER_VALIDATE_INT);

try {
    // Formats for the dropdown
    $stmt = $pdo->prepare('SELECT FormatID, FormatName FROM Formats ORDER BY FormatName');
    $stmt->execute();
    $formats = $stmt->fetchAll();

    // ── 3. Query: Step 1, prepare the JOIN query (Phase 5A Q1) ──
    $sql = 'SELECT m.MatchID,
                   m.MatchDate,
                   f.FormatName,
                   m.TableNumber,
                   m.Location,
                   CONCAT(p.FirstName, \' \', p.LastName) AS Player,
                   mr.RaceTo,
                   mr.GamesWon,
                   CASE WHEN mr.GamesWon = mr.RaceTo THEN \'Won\' ELSE \'Lost\' END AS Result
            FROM Matches m
            INNER JOIN Formats f       ON m.FormatID  = f.FormatID
            INNER JOIN MatchResults mr ON m.MatchID   = mr.MatchID
            INNER JOIN Players p       ON mr.PlayerID = p.PlayerID';
    $params = [];
    if ($formatId) {
        $sql .= ' WHERE m.FormatID = :format_id';    // value is bound, not concatenated
        $params[':format_id'] = $formatId;
    }
    $sql .= ' ORDER BY m.MatchDate, m.MatchID, Result DESC';

    $stmt = $pdo->prepare($sql);
    // Step 2: Execute with parameter values
    $stmt->execute($params);
    // Step 3: Fetch all rows as associative arrays
    $results = $stmt->fetchAll();
} catch (PDOException $e) {
    // Log the real error (for me), show a generic message (for the user)
    error_log('DB error: ' . $e->getMessage());
    $error = 'A database error occurred. Please try again.';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Match Results | Pool League Fargo Tracker</title>
<style>
  body  { font-family: Arial, sans-serif; margin: 24px; color: #1a1a1a; }
  h1    { margin-bottom: 4px; }
  form  { margin: 16px 0; }
  table { border-collapse: collapse; width: 100%; max-width: 1100px; }
  th, td { border: 1px solid #ccc; padding: 8px 10px; text-align: left; }
  thead th { background: #1F3864; color: #fff; }
  tbody tr:nth-child(4n+1), tbody tr:nth-child(4n+2) { background: #f2f6fb; }
  .won  { color: #1E6B3C; font-weight: bold; }
  .lost { color: #7B1F1F; }
  .note { color: #555; }
  .no-results { color: #888; font-style: italic; margin-top: 1rem; }
  .error { color: #c0392b; background: #fdf2f2; padding: .75rem; }
</style>
</head>
<body>

<h1>Match Results</h1>
<p class="note">Every match, who played, the race each player had to reach, and who won.</p>

<form method="get" action="read.php">
  <label for="format">Game format:</label>
  <select name="format" id="format">
    <option value="">All formats</option>
    <?php foreach ($formats as $f): ?>
      <option value="<?= htmlspecialchars($f['FormatID']) ?>"
        <?= ((int)$f['FormatID'] === (int)$formatId) ? 'selected' : '' ?>>
        <?= htmlspecialchars($f['FormatName']) ?>
      </option>
    <?php endforeach; ?>
  </select>
  <button type="submit">Filter</button>
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
        <tr>
          <td><?= htmlspecialchars($row['MatchID']) ?></td>
          <td><?= htmlspecialchars((new DateTime($row['MatchDate']))->format('M d, Y g:i A')) ?></td>
          <td><?= htmlspecialchars($row['FormatName']) ?></td>
          <td><?= htmlspecialchars($row['TableNumber'] ?? '—') ?></td>
          <td><?= htmlspecialchars($row['Location']) ?></td>
          <td><?= htmlspecialchars($row['Player']) ?></td>
          <td><?= htmlspecialchars($row['RaceTo']) ?></td>
          <td><?= htmlspecialchars($row['GamesWon']) ?></td>
          <?php
            // Result badge: CSS class based on the value
            $class = match ($row['Result']) {
                'Won'   => 'won',
                'Lost'  => 'lost',
                default => '',
            };
          ?>
          <td class="<?= $class ?>"><?= htmlspecialchars($row['Result']) ?></td>
        </tr>
      <?php endforeach; ?>
    </tbody>
  </table>
<?php endif; ?>

</body>
</html>
