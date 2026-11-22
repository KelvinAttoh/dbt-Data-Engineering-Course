
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        job_schedule_type as value_field,
        count(*) as n_records

    from `dev`.`staging`.`stg_job_postings`
    group by job_schedule_type

)

select *
from all_values
where value_field not in (
    'Part-time','Full-time','Contractor','Internship'
)



  
  
      
    ) dbt_internal_test