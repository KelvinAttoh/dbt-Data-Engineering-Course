
  
  
  
  create or replace view `dev`.`staging`.`stg_job_postings`
  (
    `job_id` comment 'The scraper\'s posting id. Not unique at this grain - one row per posting per scrape day.',
	`job_title` comment 'Posting title as scraped.',
	`company_name` comment 'Employer name, trimmed.',
	`job_location` comment 'Posting location as scraped.',
	`source_platform` comment 'Posting platform (job_via with the \'via \' scraper artifact stripped, ~6.3k rows).',
	`job_posted_at` comment 'Raw relative posted time (\'10 hours ago\'), kept unparsed - search_date carries the time axis; parsing it is a supporter exercise.',
	`job_schedule_type` comment 'As scraped; 12,252 nulls stay null - documented, not fixed.',
	`job_work_from_home` comment 'True when the posting is flagged remote.',
	`searched_at` comment 'Scrape timestamp (search_time renamed).',
	`search_date` comment 'Scrape day.',
	`search_term` comment 'The role the scraper searched for; three values by construction.',
	`search_location` comment 'Location parameter the scraper searched under.',
	`job_salary` comment 'Raw salary text, unparsed for now.',
	`salary_min` comment 'Lower bound parsed from the salary text; the single value when no range is given.',
	`salary_max` comment 'Upper bound parsed from the salary text; the single value when no range is given.',
	`salary_avg` comment 'THE standard salary measure: midpoint of the parsed range (a single value is its own range). Deliberately unit-agnostic - always pair it with salary_period and salary_currency filters; averaging across periods or currencies is mixing units.
',
	`salary_period` comment 'Pay period parsed from the salary text: year, hour, month, day, or week.',
	`salary_currency` comment 'Currency of the salary columns. Leading marker when present (\'PKR\', \'CA$\', \'₱\'); a salaried row with no marker is stamped \'USD\' - an explicit, documented assumption. Null only when the row has no salary at all.
',
	`has_no_degree_mentioned` comment 'Posting lists No degree mentioned among its enxtensions',
	`has_health_insurance` comment 'Posting lists Health insurance among its enxtensions',
	`has_dental_insurance` comment 'Posting lists Dental insurance among its enxtensions',
	`has_paid_time_off` comment 'Posting lists Paid time off among its enxtensions'
  )
  comment 'One row per posting per scrape day - a job re-scraped across days keeps every row. 691,950 rows after the door-drop (the scraper\'s own error flag).
'
  as (
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
FROM cleaned
  )
