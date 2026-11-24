

SELECT
    *
FROM `dev`.`staging`.`stg_job_postings`
WHERE search_date <= CAST('2026-11-24 01:28:38.774926+00:00' AS DATE)
QUALIFY
    ROW_NUMBER() OVER(
        PARTITION BY job_id
        ORDER BY searched_at DESC
    ) = 1