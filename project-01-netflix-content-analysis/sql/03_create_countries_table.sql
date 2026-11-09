-- Countries: netflix_data.countries -> netflix_data.countries_released
-- Unpivots the wide table (one column per value) into a long table: one row per show_id + value.
-- UNION removes duplicates; the outer WHERE drops empty slots.
-- Expected result: 10,012 rows, 7,976 titles, 122 countries

create table netflix_data.countries_released as
(
select *
from
(
SELECT show_id, Country_1 as country FROM netflix_data.countries
union 
SELECT show_id, Country_2 as country FROM netflix_data.countries
union 
SELECT show_id, Country_3 as country FROM netflix_data.countries
union 
SELECT show_id, Country_4 as country FROM netflix_data.countries
union 
SELECT show_id, Country_5 as country FROM netflix_data.countries
union 
SELECT show_id, Country_6 as country FROM netflix_data.countries
union 
SELECT show_id, Country_7 as country FROM netflix_data.countries
union 
SELECT show_id, Country_8 as country FROM netflix_data.countries
union 
SELECT show_id, Country_9 as country FROM netflix_data.countries
union 
SELECT show_id, Country_10 as country FROM netflix_data.countries
union 
SELECT show_id, Country_11 as country FROM netflix_data.countries
union
SELECT show_id, Country_12 as country FROM netflix_data.countries
 )a
where country IS NOT NULL
) 
;
