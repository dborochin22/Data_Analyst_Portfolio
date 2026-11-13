-- Analysis: number of titles added to Netflix per year, split by Movie / TV Show
-- Feeds the "# of Shows Added by Date" chart in the Power BI dashboard.

SELECT YEAR(STR_TO_DATE(TRIM(date_added), '%M %e, %Y')) AS year_added,
       type, COUNT(*) AS titles
FROM netflix_data.netflix_titles
WHERE date_added IS NOT NULL
GROUP BY year_added, type
ORDER BY titles DESC, type;