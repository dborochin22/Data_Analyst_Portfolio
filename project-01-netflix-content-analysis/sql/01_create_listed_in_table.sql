-- Genres: netflix_data.listed in -> netflix_data.netflix_listed_in
-- Unpivots the wide table (one column per value) into a long table: one row per show_id + value.
-- UNION removes duplicates; the outer WHERE drops empty slots.
-- Expected result: 19,323 rows, 8,807 titles, 42 genres

create table netflix_data.netflix_listed_in as
(
select *
from
(
SELECT show_id, listed_in_1 as category FROM netflix_data.`listed in` 
union 
SELECT show_id, listed_in_2 as category FROM netflix_data.`listed in`
union 
SELECT show_id, listed_in_3 as category FROM Netflix_data.`listed in`

 )a
where category IS NOT NULL
);
