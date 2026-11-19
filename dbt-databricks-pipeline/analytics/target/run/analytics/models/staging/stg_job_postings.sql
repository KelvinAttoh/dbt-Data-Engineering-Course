
  
  
  
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
	`job_extensions_raw` comment 'Raw extensions JSON - the benefits flags live in here, unparsed for now.',
	`searched_at` comment 'Scrape timestamp (search_time renamed).',
	`search_date` comment 'Scrape day.',
	`search_term` comment 'The role the scraper searched for; three values by construction.',
	`search_location` comment 'Location parameter the scraper searched under.'
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
        job_extensions_raw,
        search_time     AS searched_at,
        search_date,
        search_term,
        search_location
    FROM source
)
SELECT
    *
FROM cleaned
  )
