
    
    

with all_values as (

    select
        search_term as value_field,
        count(*) as n_records

    from `dev`.`staging`.`stg_job_postings`
    group by search_term

)

select *
from all_values
where value_field not in (
    'Data Engineer'
)


