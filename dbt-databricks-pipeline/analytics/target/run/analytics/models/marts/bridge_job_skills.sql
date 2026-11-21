
  
    
        create or replace table `dev`.`marts`.`bridge_job_skills`
      
      
    
      using delta
    
  
      
      
      
      
      
      
      comment 'One row per (job_id, skill_keyword) for jobs present in fct_job_postings. A skill_id repeats on a job when the posting names it two ways (spark, pyspark). Referential integrity guaranteed by construction.
'
      
      as
      WITH job_skills AS (
    SELECT * FROM `dev`.`staging`.`stg_job_skills`
),

job_postings AS (
    SELECT * FROM `dev`.`marts`.`fct_job_postings`
)

-- inner join scopes pairs to jobs that made fct. on today's data it drops
-- zero rows — it's here so integrity holds by construction, not by luck,
-- when the data changes
SELECT
    job_id,
    skill_id,
    skill_keyword
FROM job_skills
INNER JOIN job_postings USING (job_id)
  