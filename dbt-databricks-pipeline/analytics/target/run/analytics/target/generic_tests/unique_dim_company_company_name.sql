
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    company_name as unique_field,
    count(*) as n_records

from `dev`.`marts`.`dim_company`
where company_name is not null
group by company_name
having count(*) > 1



  
  
      
    ) dbt_internal_test