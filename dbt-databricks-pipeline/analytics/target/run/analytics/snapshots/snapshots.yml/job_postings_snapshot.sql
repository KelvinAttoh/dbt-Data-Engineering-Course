
      merge into `dev`.`snapshots`.`job_postings_snapshot` as DBT_INTERNAL_DEST
        using `job_postings_snapshot__dbt_tmp` as DBT_INTERNAL_SOURCE
    on DBT_INTERNAL_SOURCE.`dbt_scd_id` = DBT_INTERNAL_DEST.`dbt_scd_id`
    when matched
        and DBT_INTERNAL_DEST.`dbt_valid_to` is null
        and DBT_INTERNAL_SOURCE.`dbt_change_type` in ('update', 'delete')
        then update
        set `dbt_valid_to` = DBT_INTERNAL_SOURCE.`dbt_valid_to`

    when not matched
        and DBT_INTERNAL_SOURCE.`dbt_change_type` = 'insert'
        then insert (`job_id`, `job_title`, `company_name`, `job_location`, `source_platform`, `job_posted_at`, `job_schedule_type`, `job_work_from_home`, `searched_at`, `search_date`, `search_term`, `search_location`, `job_salary`, `salary_min`, `salary_max`, `salary_avg`, `salary_period`, `salary_currency`, `has_no_degree_mentioned`, `has_health_insurance`, `has_dental_insurance`, `has_paid_time_off`, `dbt_updated_at`, `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`)
        values (`job_id`, `job_title`, `company_name`, `job_location`, `source_platform`, `job_posted_at`, `job_schedule_type`, `job_work_from_home`, `searched_at`, `search_date`, `search_term`, `search_location`, `job_salary`, `salary_min`, `salary_max`, `salary_avg`, `salary_period`, `salary_currency`, `has_no_degree_mentioned`, `has_health_insurance`, `has_dental_insurance`, `has_paid_time_off`, `dbt_updated_at`, `dbt_valid_from`, `dbt_valid_to`, `dbt_scd_id`)
    ;

  