-- back compat for old kwarg name
  
  
  
  
  
  
      
  

    merge
    into
        `dev`.`marts`.`fct_job_postings` as DBT_INTERNAL_DEST
    using
        `fct_job_postings__dbt_tmp` as DBT_INTERNAL_SOURCE
    on
        FALSE
    when matched
        then update set
            *
    when not matched
        then insert
            *
