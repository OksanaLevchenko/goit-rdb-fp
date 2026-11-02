-- Final Project: Relational Databases (PostgreSQL)
-- Dataset: infectious_cases.csv
-- Run in order in the postgres database.
-- The original CSV must be imported after Task 1, before Task 2.
-- The SQL below does not automatically import a local Mac file.

-- TASK 1: Create the pandemic schema and original table
CREATE SCHEMA IF NOT EXISTS pandemic;
SET search_path TO pandemic;

CREATE TABLE IF NOT EXISTS pandemic.infectious_cases (
    "Entity" TEXT,
    "Code" TEXT,
    "Year" INTEGER,
    "Number_yaws" TEXT,
    polio_cases TEXT,
    cases_guinea_worm TEXT,
    "Number_rabies" TEXT,
    "Number_malaria" TEXT,
    "Number_hiv" TEXT,
    "Number_tuberculosis" TEXT,
    "Number_smallpox" TEXT,
    "Number_cholera_cases" TEXT
);

-- Import infectious_cases.csv using psql (instructions in README).
-- Once imported, these queries should show 10521 records.
SELECT * FROM pandemic.infectious_cases LIMIT 10;
SELECT COUNT(*) AS imported_rows FROM pandemic.infectious_cases;

-- TASK 2: Normalize into countries and disease_statistics
-- Run the next statements once after the CSV import.
CREATE TABLE pandemic.countries (
    id SERIAL PRIMARY KEY,
    entity TEXT,
    code TEXT
);

INSERT INTO pandemic.countries (entity, code)
SELECT DISTINCT "Entity", "Code"
FROM pandemic.infectious_cases;

CREATE TABLE pandemic.disease_statistics (
    id SERIAL PRIMARY KEY,
    country_id INTEGER REFERENCES pandemic.countries(id),
    year INTEGER,
    number_yaws TEXT,
    polio_cases TEXT,
    cases_guinea_worm TEXT,
    number_rabies TEXT,
    number_malaria TEXT,
    number_hiv TEXT,
    number_tuberculosis TEXT,
    number_smallpox TEXT,
    number_cholera_cases TEXT
);

INSERT INTO pandemic.disease_statistics (
    country_id, year, number_yaws, polio_cases, cases_guinea_worm,
    number_rabies, number_malaria, number_hiv, number_tuberculosis,
    number_smallpox, number_cholera_cases
)
SELECT
    c.id, i."Year", i."Number_yaws", i.polio_cases, i.cases_guinea_worm,
    i."Number_rabies", i."Number_malaria", i."Number_hiv",
    i."Number_tuberculosis", i."Number_smallpox", i."Number_cholera_cases"
FROM pandemic.infectious_cases i
JOIN pandemic.countries c
    ON i."Entity" = c.entity
   AND i."Code" IS NOT DISTINCT FROM c.code;

-- Check normalized tables: 245 unique entity/code pairs, 10521 data rows
SELECT COUNT(*) AS countries_count FROM pandemic.countries;
SELECT * FROM pandemic.countries LIMIT 10;
SELECT COUNT(*) AS statistics_count FROM pandemic.disease_statistics;
SELECT id, country_id, year, number_rabies, number_malaria, number_hiv
FROM pandemic.disease_statistics
WHERE number_rabies IS NOT NULL
LIMIT 10;

-- TASK 3: Analyze rabies cases, top 10 by average
-- Rabies values came from CSV as text; convert nonempty values to NUMERIC.
SELECT
    c.entity,
    c.code,
    AVG(NULLIF(d.number_rabies, '')::NUMERIC) AS avg_rabies,
    MIN(NULLIF(d.number_rabies, '')::NUMERIC) AS min_rabies,
    MAX(NULLIF(d.number_rabies, '')::NUMERIC) AS max_rabies,
    SUM(NULLIF(d.number_rabies, '')::NUMERIC) AS total_rabies
FROM pandemic.disease_statistics d
JOIN pandemic.countries c ON d.country_id = c.id
WHERE NULLIF(d.number_rabies, '') IS NOT NULL
GROUP BY c.id, c.entity, c.code
ORDER BY avg_rabies DESC
LIMIT 10;

-- TASK 4: Calculate difference between January 1 of each year and today
SELECT
    year,
    MAKE_DATE(year, 1, 1) AS start_date,
    CURRENT_DATE AS today,
    EXTRACT(YEAR FROM AGE(CURRENT_DATE, MAKE_DATE(year, 1, 1))) AS years_difference
FROM pandemic.disease_statistics
WHERE year IS NOT NULL
LIMIT 10;

-- TASK 5: Create and use two functions
CREATE OR REPLACE FUNCTION pandemic.calculate_years(input_year INTEGER)
RETURNS INTEGER
LANGUAGE SQL
AS $$
    SELECT EXTRACT(
        YEAR FROM AGE(CURRENT_DATE, MAKE_DATE(input_year, 1, 1))
    )::INTEGER;
$$;

CREATE OR REPLACE FUNCTION pandemic.average_cases(
    cases NUMERIC,
    divisor NUMERIC
)
RETURNS NUMERIC
LANGUAGE SQL
AS $$
    SELECT cases / NULLIF(divisor, 0);
$$;

-- Test function 1
SELECT
    year,
    pandemic.calculate_years(year) AS years_difference
FROM pandemic.disease_statistics
WHERE year IS NOT NULL
LIMIT 10;

-- Test function 2: monthly, quarterly and half-year averages
SELECT
    number_rabies,
    pandemic.average_cases(number_rabies::NUMERIC, 12) AS monthly_average,
    pandemic.average_cases(number_rabies::NUMERIC, 4) AS quarterly_average,
    pandemic.average_cases(number_rabies::NUMERIC, 2) AS half_year_average
FROM pandemic.disease_statistics
WHERE number_rabies IS NOT NULL
  AND TRIM(number_rabies) ~ '^[0-9]+(\.[0-9]+)?$'
LIMIT 10;
