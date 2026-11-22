
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with child as (
    select company_name as from_field
    from `dev`.`marts`.`fct_job_postings`
    where company_name is not null
),

parent as (
    select company_name as to_field
    from `dev`.`marts`.`dim_company`
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



  
  
      
    ) dbt_internal_test