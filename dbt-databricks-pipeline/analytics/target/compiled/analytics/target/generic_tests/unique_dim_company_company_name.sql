
    
    

select
    company_name as unique_field,
    count(*) as n_records

from `dev`.`marts`.`dim_company`
where company_name is not null
group by company_name
having count(*) > 1


