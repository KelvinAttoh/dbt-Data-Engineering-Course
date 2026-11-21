

WITH source AS (
    SELECT
        *
    FROM `raw`.`jobs`.`raw_job_postings`
    WHERE error IS NOT TRUE
),
Cleaned AS (
    SELECT
        job_id,
        job_title,
        TRIM(company_name)  AS company_name,
        job_location,
        REGEXP_REPLACE(job_via, '^via', '')   AS job_via,
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
FROM cleaned