#!/usr/bin/env bash
# Starts the PHP built-in server for the app.
# Asks for your MySQL username and password so they are never saved in a file.
cd "$(dirname "$0")"
read -r -p "MySQL username: " DB_USER
read -r -s -p "MySQL password: " DB_PASS
echo
echo "Open http://localhost:8080/read.php in your browser. Press Ctrl+C to stop."
DB_USER="$DB_USER" DB_PASS="$DB_PASS" php -S localhost:8080
