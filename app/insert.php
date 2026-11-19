<?php
// insert.php -- Phase 7b: add a new player (Create)
// CS 273 Phase 7   Ayman Kaouch   Pool League Fargo Rating Tracker
// Objective 1 — Maintain accurate player identity and contact records.

// ── 1. Connect ──────────────────────────────────────────────
require __DIR__ . '/db.php';

$errors = [];

// ── 2. Handle the POST submission ───────────────────────────
if (isset($_POST['submit_form'])) {

    // Trim every input
    $first_name   = trim($_POST['first_name'] ?? '');
    $last_name    = trim($_POST['last_name'] ?? '');
    $fargo_rating = trim($_POST['fargo_rating'] ?? '');
    $phone        = trim($_POST['phone'] ?? '');
    $email        = trim($_POST['email'] ?? '');

    // Required fields
    if ($first_name === '') {
        $errors[] = 'First name is required.';
    }
    if ($last_name === '') {
        $errors[] = 'Last name is required.';
    }

    // Format rules
    // Fargo Rating is optional (new players may not be rated yet), but if given
    // it must be a whole number from 100 to 900.
    if ($fargo_rating !== '') {
        if (!ctype_digit($fargo_rating) || $fargo_rating < 100 || $fargo_rating > 900) {
            $errors[] = 'Fargo Rating must be a whole number from 100 to 900.';
        }
    }
    // Email is optional, but if given it must be a valid address.
    if ($email !== '' && !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = 'Please enter a valid email address.';
    }

    // ── 3. Insert only if there are no errors ──────────────────
    if (empty($errors)) {
        try {
            $stmt = $pdo->prepare(
                'INSERT INTO Players (FirstName, LastName, FargoRating, Phone, Email)
                 VALUES (:first_name, :last_name, :fargo_rating, :phone, :email)'
            );
            $stmt->execute([
                ':first_name'   => $first_name,
                ':last_name'    => $last_name,
                ':fargo_rating' => ($fargo_rating === '') ? null : $fargo_rating,  // empty → NULL (not rated)
                ':phone'        => ($phone === '') ? null : $phone,
                ':email'        => ($email === '') ? null : $email,
            ]);

            // ── 4. Post-Redirect-Get: stops a refresh from adding the player twice
            header('Location: read.php?added=1');
            exit;
        } catch (PDOException $e) {
            error_log($e->getMessage());
            // 23000 = constraint violation (here: the email is already used, it is UNIQUE)
            if ($e->getCode() == 23000) {
                $errors[] = 'That email is already used by another player.';
            } else {
                $errors[] = 'Could not add the player. Please try again.';
            }
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Add Player | Pool League Fargo Tracker</title>
<style>
  body   { font-family: Arial, sans-serif; margin: 2rem; color: #333; }
  h1     { color: #1F3864; }
  form   { max-width: 420px; }
  label  { display: block; margin-top: 1rem; font-weight: bold; }
  input  { width: 100%; padding: .5rem; margin-top: .25rem; box-sizing: border-box; }
  button { margin-top: 1.25rem; padding: .6rem 1.2rem; background: #065a82; color: white; border: 0; cursor: pointer; }
  .hint  { font-weight: normal; color: #777; font-size: .9rem; }
  .errors { color: #c0392b; background: #fdf2f2; padding: .75rem 1.5rem; max-width: 420px; }
</style>
</head>
<body>

<h1>Add a Player</h1>
<p><a href="read.php">← Back to Match Results</a></p>

<?php if (!empty($errors)): ?>
  <div class="errors">
    <p><strong>Please fix the following:</strong></p>
    <ul>
      <?php foreach ($errors as $error): ?>
        <li><?= htmlspecialchars($error) ?></li>
      <?php endforeach; ?>
    </ul>
  </div>
<?php endif; ?>

<!-- Values are re-filled from $_POST so the user doesn't retype after an error -->
<form method="POST" action="insert.php">
  <label for="first_name">First name *</label>
  <input type="text" id="first_name" name="first_name" maxlength="50" required
         value="<?= htmlspecialchars($_POST['first_name'] ?? '') ?>">

  <label for="last_name">Last name *</label>
  <input type="text" id="last_name" name="last_name" maxlength="50" required
         value="<?= htmlspecialchars($_POST['last_name'] ?? '') ?>">

  <label for="fargo_rating">Fargo Rating <span class="hint">(100–900, leave empty if not rated yet)</span></label>
  <input type="number" id="fargo_rating" name="fargo_rating" min="100" max="900" step="1"
         value="<?= htmlspecialchars($_POST['fargo_rating'] ?? '') ?>">

  <label for="phone">Phone <span class="hint">(optional)</span></label>
  <input type="text" id="phone" name="phone" maxlength="20"
         value="<?= htmlspecialchars($_POST['phone'] ?? '') ?>">

  <label for="email">Email <span class="hint">(optional)</span></label>
  <input type="email" id="email" name="email" maxlength="254"
         value="<?= htmlspecialchars($_POST['email'] ?? '') ?>">

  <button type="submit" name="submit_form">Add Player</button>
</form>

</body>
</html>
