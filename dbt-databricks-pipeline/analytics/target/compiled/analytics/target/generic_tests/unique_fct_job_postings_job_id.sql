
    
    

select
    job_id as unique_field,
    count(*) as n_records

from `dev`.`marts`.`fct_job_postings`
where job_id is not null
group by job_id
having count(*) > 1


