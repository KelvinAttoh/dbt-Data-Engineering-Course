
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select job_id as from_field
    from `dev`.`marts`.`bridge_job_skills`
    where job_id is not null
),

parent as (
    select job_id as to_field
    from `dev`.`marts`.`fct_job_postings`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test