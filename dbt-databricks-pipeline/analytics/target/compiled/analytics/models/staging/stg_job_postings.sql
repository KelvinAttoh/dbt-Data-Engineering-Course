

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
        job_salary,
        job_schedule_type,
        job_work_from_home,
        search_time     AS searched_at,
        search_date,
        search_term,
        search_location,
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