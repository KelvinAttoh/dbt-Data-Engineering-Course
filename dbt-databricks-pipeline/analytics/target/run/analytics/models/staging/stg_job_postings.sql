
  
  
  
  create or replace view `dev`.`default_staging`.`stg_job_postings`
  (
    `job_id` comment 'The scraper\'s posting id. Not unique at this grain - one row per posting per scrape day.',
	`job_title` comment 'Posting title as scraped.',
	`company_name` comment 'Employer name, trimmed.',
	`job_location` comment 'Posting location as scraped.',
	`job_via`,
	`job_posted_at` comment 'Raw relative posted time (\'10 hours ago\'), kept unparsed - search_date carries the time axis; parsing it is a supporter exercise.',
	`job_salary` comment 'Raw salary text, unparsed for now.',
	`job_schedule_type` comment 'As scraped; 12,252 nulls stay null - documented, not fixed.',
	`job_work_from_home` comment 'True when the posting is flagged remote.',
	`searched_at` comment 'Scrape timestamp (search_time renamed).',
	`search_date` comment 'Scrape day.',
	`search_term` comment 'The role the scraper searched for; three values by construction.',
	`search_location` comment 'Location parameter the scraper searched under.',
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
  )
