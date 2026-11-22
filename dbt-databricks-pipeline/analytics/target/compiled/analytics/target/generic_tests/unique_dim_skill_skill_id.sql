
    
    

select
    skill_id as unique_field,
    count(*) as n_records

from `dev`.`marts`.`dim_skill`
where skill_id is not null
group by skill_id
having count(*) > 1


