<?php
// db.php -- PDO connection file. Every page does: require __DIR__ . '/db.php';
// CS 273 Phase 7   Ayman Kaouch   Pool League Fargo Rating Tracker

$host    = 'localhost';
$dbname  = 'FargoLeague';                     // database name from schema/schema.sql
$charset = 'utf8mb4';

// MySQL username and password.
// The password is NOT stored in this file (the repo is public).
// Set them when starting the server, for example:
//   DB_USER=yourname DB_PASS=yourpassword php -S localhost:8080
// If they are not set, the defaults below are used (root, no password).
$username = getenv('DB_USER') ?: 'root';
$password = getenv('DB_PASS') ?: '';

$dsn = "mysql:host=$host;dbname=$dbname;charset=$charset";

$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,  // throw exceptions on SQL errors
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,        // rows as $row['FirstName']
    PDO::ATTR_EMULATE_PREPARES   => false,                   // real prepared statements
];

try {
    $pdo = new PDO($dsn, $username, $password, $options);
} catch (\PDOException $e) {
    // Never show error details to users in production
    error_log($e->getMessage());
    die('Database connection failed. Please try again later.');
}
