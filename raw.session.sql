SELECT
    search_term,
    COUNT(*)   AS job_postings
FROM raw.jobs.raw_job_postings
GROUP BY search_term
ORDER BY job_postings DESC