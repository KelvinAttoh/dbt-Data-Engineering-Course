
  
    
        create or replace table `dev`.`marts`.`dim_skill`
      
      
    
      using delta
    
  
      
      
      
      
      
      
      comment 'One row per skill; the seed provides the taxonomy, the data provides the counts.'
      
      as
      WITH skill_categories AS (
    SELECT * FROM `dev`.`seeds`.`skill_categories`
),

observations AS (
    SELECT * FROM `dev`.`intermediate`.`int_skill_observations`
)

-- a pure SERVE model: intermediate did the counting, the seed brings the
-- taxonomy; every observed skill_id sits inside the 1,422-row seed, so the
-- seed is the spine
SELECT
    skill_id,
    display_name,
    category,
    subcategory,
    COALESCE(postings_with_skill, 0) AS postings_with_skill
FROM skill_categories
LEFT JOIN observations USING (skill_id)
  