with __dbt__cte__stg_job_postings_current as (


SELECT
    *
FROM `dev`.`staging`.`stg_job_postings`
WHERE search_date <= CAST('2026-11-22 23:58:51.115326+00:00' AS DATE)
QUALIFY
    ROW_NUMBER() OVER(
        PARTITION BY job_id
        ORDER BY searched_at DESC
    ) = 1
)
--EPHEMERAL-SELECT-WRAPPER-START
select * from (
select * from __dbt__cte__stg_job_postings_current
--EPHEMERAL-SELECT-WRAPPER-END
)