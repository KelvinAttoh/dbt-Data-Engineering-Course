{% set roles = ['data analyst', 'data scientist', 'data engineer'] -%}

{% for role in  roles -%}
SELECT
    search_term,
    COUNT(*)    AS job_postings
FROM {{ ref('stg_job_postings') }}
WHERE search_term = '{{ role | title }}'
GROUP BY search_term
{{ 'UNION ALL' if not loop.last}}
{% endfor %}
