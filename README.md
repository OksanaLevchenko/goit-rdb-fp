# Final Project — Relational Databases

This is my PostgreSQL final project using the `infectious_cases.csv` dataset. I used PostgreSQL 17, pgAdmin 4 and Terminal on macOS.

## Project tasks

1. Created the `pandemic` schema and imported the CSV dataset (10,521 rows).
2. Normalized the data into `countries` (245 combinations of Entity and Code) and `disease_statistics` (10,521 records). The tables are connected using `country_id` as a foreign key.
3. Calculated average, minimum, maximum and total rabies cases for each country/region and showed the top 10 by average.
4. Converted each year to January 1 and calculated the difference from the current date in years.
5. Created and tested two SQL functions: `calculate_years()` and `average_cases()` using 12, 4 and 2 as divisors.

## Files

- `final_project.sql` — SQL commands for all five tasks.
- `infectious_cases.csv` — original dataset.
- `screenshots/` — screenshots of queries and actual results in pgAdmin and Terminal.

## How to run

1. Open the `postgres` database in pgAdmin Query Tool.
2. Execute the **Task 1** statements in `final_project.sql` to create the schema and empty `infectious_cases` table.
3. Import the CSV into that table. On macOS, I used Terminal because the pgAdmin import window did not finish. First connect:

   ```bash
   /Library/PostgreSQL/17/bin/psql -U postgres -d postgres
   ```

   Then, at the `postgres=#` prompt, run this command with **your own local file path**:

   ```sql
   \copy pandemic.infectious_cases FROM '/path/to/infectious_cases.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"');
   ```

   It should display `COPY 10521`. The `\copy` command works in **psql**, not in pgAdmin Query Tool.
4. In pgAdmin, run the remaining **Task 2–5** queries in order. The table creation and data insertion statements are meant for a fresh database; running Task 2 again without clearing the normalized tables will cause an error or duplicate rows.
5. Check the output with screenshots.

## Short conclusion

I learned how to import CSV data, normalize tables, connect tables with a foreign key, calculate statistics with SQL, use date functions and create my own SQL functions. The normalized data avoids repeating country names and codes in each disease statistics row.
