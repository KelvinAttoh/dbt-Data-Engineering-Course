
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    SELECT *
    FROM `dev`.`staging`.`stg_job_postings`
    WHERE salary_max < 0

  
  
      
    ) dbt_internal_test