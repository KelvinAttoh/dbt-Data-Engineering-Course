-- Build actual result given inputs
WITH
            	raw_jobs_raw_job_postings as (SELECT CAST(1 AS string) AS job_id, CAST(NULL AS string) AS job_title, CAST(NULL AS string) AS company_name, CAST(NULL AS string) AS job_location, CAST(NULL AS string) AS job_via, CAST(NULL AS string) AS job_posted_at, CAST('100K–186K a year' AS string) AS job_salary, CAST(NULL AS string) AS job_schedule_type, CAST(NULL AS boolean) AS job_work_from_home, CAST(NULL AS string) AS job_extensions_raw, CAST(NULL AS string) AS job_detected_extensions_raw, CAST(NULL AS timestamp) AS search_time, CAST(NULL AS date) AS search_date, CAST(NULL AS string) AS search_term, CAST(NULL AS string) AS search_location, CAST(NULL AS boolean) AS error, CAST(NULL AS string) AS error_message, CAST(NULL AS string) AS _rescued_data
UNION ALL
SELECT CAST(2 AS string) AS job_id, CAST(NULL AS string) AS job_title, CAST(NULL AS string) AS company_name, CAST(NULL AS string) AS job_location, CAST(NULL AS string) AS job_via, CAST(NULL AS string) AS job_posted_at, CAST('32.50 an hour' AS string) AS job_salary, CAST(NULL AS string) AS job_schedule_type, CAST(NULL AS boolean) AS job_work_from_home, CAST(NULL AS string) AS job_extensions_raw, CAST(NULL AS string) AS job_detected_extensions_raw, CAST(NULL AS timestamp) AS search_time, CAST(NULL AS date) AS search_date, CAST(NULL AS string) AS search_term, CAST(NULL AS string) AS search_location, CAST(NULL AS boolean) AS error, CAST(NULL AS string) AS error_message, CAST(NULL AS string) AS _rescued_data
UNION ALL
SELECT CAST(3 AS string) AS job_id, CAST(NULL AS string) AS job_title, CAST(NULL AS string) AS company_name, CAST(NULL AS string) AS job_location, CAST(NULL AS string) AS job_via, CAST(NULL AS string) AS job_posted_at, CAST(NULL AS string) AS job_salary, CAST(NULL AS string) AS job_schedule_type, CAST(NULL AS boolean) AS job_work_from_home, CAST(NULL AS string) AS job_extensions_raw, CAST(NULL AS string) AS job_detected_extensions_raw, CAST(NULL AS timestamp) AS search_time, CAST(NULL AS date) AS search_date, CAST(NULL AS string) AS search_term, CAST(NULL AS string) AS search_location, CAST(NULL AS boolean) AS error, CAST(NULL AS string) AS error_message, CAST(NULL AS string) AS _rescued_data),
  	dev_staging_stg_job_postings_expect as (SELECT CAST(1 AS string) AS job_id, CAST(NULL AS string) AS job_title, CAST(NULL AS string) AS company_name, CAST(NULL AS string) AS job_location, CAST(NULL AS string) AS source_platform, CAST(NULL AS string) AS job_posted_at, CAST(NULL AS string) AS job_schedule_type, CAST(NULL AS boolean) AS job_work_from_home, CAST(NULL AS timestamp) AS searched_at, CAST(NULL AS date) AS search_date, CAST(NULL AS string) AS search_term, CAST(NULL AS string) AS search_location, CAST(NULL AS string) AS job_salary, CAST(100000 AS decimal(26,2)) AS salary_min, CAST(186000 AS decimal(26,2)) AS salary_max, CAST(NULL AS decimal(31,6)) AS salary_avg, CAST(NULL AS string) AS salary_period, CAST(NULL AS string) AS salary_currency, CAST(NULL AS boolean) AS has_no_degree_mentioned, CAST(NULL AS boolean) AS has_health_insurance, CAST(NULL AS boolean) AS has_dental_insurance, CAST(NULL AS boolean) AS has_paid_time_off
UNION ALL
SELECT CAST(2 AS string) AS job_id, CAST(NULL AS string) AS job_title, CAST(NULL AS string) AS company_name, CAST(NULL AS string) AS job_location, CAST(NULL AS string) AS source_platform, CAST(NULL AS string) AS job_posted_at, CAST(NULL AS string) AS job_schedule_type, CAST(NULL AS boolean) AS job_work_from_home, CAST(NULL AS timestamp) AS searched_at, CAST(NULL AS date) AS search_date, CAST(NULL AS string) AS search_term, CAST(NULL AS string) AS search_location, CAST(NULL AS string) AS job_salary, CAST(32.5 AS decimal(26,2)) AS salary_min, CAST(32.5 AS decimal(26,2)) AS salary_max, CAST(NULL AS decimal(31,6)) AS salary_avg, CAST(NULL AS string) AS salary_period, CAST(NULL AS string) AS salary_currency, CAST(NULL AS boolean) AS has_no_degree_mentioned, CAST(NULL AS boolean) AS has_health_insurance, CAST(NULL AS boolean) AS has_dental_insurance, CAST(NULL AS boolean) AS has_paid_time_off
UNION ALL
SELECT CAST(3 AS string) AS job_id, CAST(NULL AS string) AS job_title, CAST(NULL AS string) AS company_name, CAST(NULL AS string) AS job_location, CAST(NULL AS string) AS source_platform, CAST(NULL AS string) AS job_posted_at, CAST(NULL AS string) AS job_schedule_type, CAST(NULL AS boolean) AS job_work_from_home, CAST(NULL AS timestamp) AS searched_at, CAST(NULL AS date) AS search_date, CAST(NULL AS string) AS search_term, CAST(NULL AS string) AS search_location, CAST(NULL AS string) AS job_salary, CAST(NULL AS decimal(26,2)) AS salary_min, CAST(NULL AS decimal(26,2)) AS salary_max, CAST(NULL AS decimal(31,6)) AS salary_avg, CAST(NULL AS string) AS salary_period, CAST(NULL AS string) AS salary_currency, CAST(NULL AS boolean) AS has_no_degree_mentioned, CAST(NULL AS boolean) AS has_health_insurance, CAST(NULL AS boolean) AS has_dental_insurance, CAST(NULL AS boolean) AS has_paid_time_off),
  	dev_staging_stg_job_postings_actual as (

WITH source AS (
    SELECT
        *
    FROM raw_jobs_raw_job_postings
    WHERE error IS NOT TRUE
        AND job_id IS NOT NULL
),
Cleaned AS (
    SELECT
        job_id,
        job_title,
        TRIM(company_name)  AS company_name,
        job_location,
        REGEXP_REPLACE(job_via, '^via', '')   AS source_platform,
        job_posted_at,
        job_schedule_type,
        job_work_from_home,
        search_time     AS searched_at,
        search_date,
        search_term,
        search_location,
        job_salary,
        -- lower bound: the number before the en-dash, times its K or M suffix
        TRY_CAST(REPLACE(REGEXP_EXTRACT(SPLIT(job_salary, '–')[0], '([0-9][0-9,.]*)', 1), ',', '') AS DECIMAL(15, 2))
            * CASE UPPER(REGEXP_EXTRACT(SPLIT(job_salary, '–')[0], '[0-9][0-9,.]*([KkMm])', 1))
                WHEN 'K' THEN 1000
                WHEN 'M' THEN 1000000
                ELSE 1
              END AS salary_min,
        -- upper bound: the same parse on the LAST segment, so a single value is its own range
        TRY_CAST(REPLACE(REGEXP_EXTRACT(ELEMENT_AT(SPLIT(job_salary, '–'), -1), '([0-9][0-9,.]*)', 1), ',', '') AS DECIMAL(15, 2))
            * CASE UPPER(REGEXP_EXTRACT(ELEMENT_AT(SPLIT(job_salary, '–'), -1), '[0-9][0-9,.]*([KkMm])', 1))
                WHEN 'K' THEN 1000
                WHEN 'M' THEN 1000000
                ELSE 1
              END AS salary_max,
        TRY_CAST(REPLACE(REGEXP_EXTRACT(SPLIT(job_salary, '–')[0], '([0-9][0-9,.]*)', 1), ',', '') AS DECIMAL(15, 2))
            * CASE UPPER(REGEXP_EXTRACT(SPLIT(job_salary, '–')[0], '[0-9][0-9,.]*([KkMm])', 1))
                WHEN 'K' THEN 1000
                WHEN 'M' THEN 1000000
                ELSE 1
              END + TRY_CAST(REPLACE(REGEXP_EXTRACT(ELEMENT_AT(SPLIT(job_salary, '–'), -1), '([0-9][0-9,.]*)', 1), ',', '') AS DECIMAL(15, 2))
            * CASE UPPER(REGEXP_EXTRACT(ELEMENT_AT(SPLIT(job_salary, '–'), -1), '[0-9][0-9,.]*([KkMm])', 1))
                WHEN 'K' THEN 1000
                WHEN 'M' THEN 1000000
                ELSE 1
              END/2 AS salary_avg,
        -- pay period, read off the end of the text: 'a year', 'an hour'
        NULLIF(REGEXP_EXTRACT(job_salary, 'an? (year|hour|month|day|week)$', 1), '') AS salary_period,
        -- currency marker; a salaried row with no marker is stamped USD on purpose
        CASE
            WHEN job_salary IS NOT NULL
            THEN COALESCE(NULLIF(TRIM(REGEXP_EXTRACT(job_salary, '^([^0-9]+)', 1)), ''), 'USD')
        END AS salary_currency,
        ARRAY_CONTAINS(
            FROM_JSON(job_extensions_raw, 'array<string>'),
            "No degree mentioned") AS has_no_degree_mentioned,ARRAY_CONTAINS(
            FROM_JSON(job_extensions_raw, 'array<string>'),
            "Health insurance") AS has_health_insurance,ARRAY_CONTAINS(
            FROM_JSON(job_extensions_raw, 'array<string>'),
            "Dental insurance") AS has_dental_insurance,ARRAY_CONTAINS(
            FROM_JSON(job_extensions_raw, 'array<string>'),
            "Paid time off") AS has_paid_time_off
    FROM source
)
SELECT
    *
FROM cleaned)
        SELECT * FROM (
        (SELECT job_id, salary_min, salary_max, 'actual' AS actual_or_expected FROM dev_staging_stg_job_postings_actual)
        UNION ALL
        (SELECT job_id, salary_min, salary_max, 'expected' AS actual_or_expected FROM dev_staging_stg_job_postings_expect)
        ) unit_test_diff
        ORDER BY job_id, salary_min, salary_max