# schema

`schema.sql` creates the **FargoLeague** database: all 7 tables from the ERD, with primary keys, foreign keys, UNIQUE and CHECK constraints.

Run it in MySQL Workbench (**File → Open SQL Script → schema.sql → Run All**) or from MySQL Shell:

```
\sql
\source path/to/schema.sql
```

It starts with `DROP DATABASE IF EXISTS FargoLeague;`, so it can be re-run at any time and always produces a fresh, empty database.
