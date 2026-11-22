
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    skill_id as unique_field,
    count(*) as n_records

from `dev`.`marts`.`dim_skill`
where skill_id is not null
group by skill_id
having count(*) > 1



  
  
      
    ) dbt_internal_test