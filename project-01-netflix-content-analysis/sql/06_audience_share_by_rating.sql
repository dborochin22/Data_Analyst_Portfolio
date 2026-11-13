-- Analysis: share of the catalog by audience segment, grouped from content ratings
-- Adult = TV-MA/R/NC-17 | Teen = TV-14/PG-13 | Older kids/Family = TV-PG/PG/TV-Y7/TV-Y7-FV | All kids = TV-Y/TV-G/G

SELECT
  CASE WHEN rating IN ('TV-MA','R','NC-17')                THEN 'Adult'
       WHEN rating IN ('TV-14','PG-13')                    THEN 'Teen'
       WHEN rating IN ('TV-PG','PG','TV-Y7','TV-Y7-FV')    THEN 'Older kids/Family'
       WHEN rating IN ('TV-Y','TV-G','G')                  THEN 'All kids'
       ELSE 'Unrated' END AS audience,
  COUNT(*) AS titles,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct
FROM netflix_data.netflix_titles
GROUP BY audience
ORDER BY titles DESC;