
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  

SELECT
    job_id,
    search_term,
    job_title,
    salary_min,
    salary_max,
    salary_period,
    salary_currency
FROM dev.staging.stg_job_postings
WHERE salary_period = 'year'
    AND salary_currency = 'USD'
    AND COALESCE(salary_max, salary_min) >= 1000000
  
  
      
    ) dbt_internal_test