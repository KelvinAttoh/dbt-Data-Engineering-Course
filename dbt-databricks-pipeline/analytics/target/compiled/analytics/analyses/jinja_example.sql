SELECT
    search_term,
    COUNT(*)    AS job_postings
FROM `dev`.`default_staging`.`stg_job_postings`
WHERE search_term = 'Data Analyst'
GROUP BY search_term
UNION ALL
SELECT
    search_term,
    COUNT(*)    AS job_postings
FROM `dev`.`default_staging`.`stg_job_postings`
WHERE search_term = 'Data Scientist'
GROUP BY search_term
UNION ALL
SELECT
    search_term,
    COUNT(*)    AS job_postings
FROM `dev`.`default_staging`.`stg_job_postings`
WHERE search_term = 'Data Engineer'
GROUP BY search_term

