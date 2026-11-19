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