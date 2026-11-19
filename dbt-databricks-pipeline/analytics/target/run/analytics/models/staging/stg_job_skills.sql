
  
  
  
  create or replace view `dev`.`default_staging`.`stg_job_skills`
  (
    `job_id` comment 'Every row\'s parent exists in stg_job_postings - the export\'s join guarantees it.',
	`skill_id` comment 'Skill key; the human-readable text rides in skill_keyword.',
	`skill_keyword` comment 'Skill text as extracted, trimmed.'
  )
  comment 'One row per (job_id, skill_keyword), straight off the raw table. A skill_id repeats on a job when the posting names it two ways (spark, pyspark). Deliberately boring; rename, order, trim is the discipline working.
'
  as (
    WITH source AS (
    SELECT
        *
    FROM `raw`.`jobs`.`raw_job_skills`

),
Cleaned AS (
    SELECT
        job_id,
        skill_id,
        TRIM(skill_keyword)   AS skill_keyword
    FROM source
)
SELECT
    *
FROM Cleaned
  )
