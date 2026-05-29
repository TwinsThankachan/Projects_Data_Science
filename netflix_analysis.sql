
SELECT *
FROM dbo.netflix

--checking data types of columns and modify the data types if necessary

EXEC 
	sp_help 'dbo.netflix'
ALTER TABLE dbo.netflix 
ALTER COLUMN release_year INT

--EXPLORATORY DATA ANALYSIS

--Movies vs TV Shows Distribution

SELECT 
	type, COUNT(*) AS count
FROM dbo.netflix
	GROUP BY type

--shows that there are more movies than TV shows in the dataset.--


--Top 10 Content Producing Countries

SELECT 
	TOP 10 country, COUNT(*) AS total_content
FROM dbo.netflix
	GROUP BY country
	ORDER BY total_content DESC

--shows that the United States produces the most content on Netflix, followed by India and the United Kingdom.--


--Most popular genres 

SELECT 
	listed_in, COUNT(*) AS genre_count
FROM dbo.netflix
	GROUP BY listed_in
	ORDER BY genre_count DESC

--shows that the most popular genres on Netflix are Dramas, Comedies, and Action & Adventure.--


--Content added over time

SELECT 
	YEAR(date_added) AS year_added, COUNT(*) AS total_content_added
FROM dbo.netflix
	GROUP BY YEAR(date_added)
	ORDER BY total_content_added DESC

--shows that there was a significant increase in content added to Netflix in recent years, with the highest number of additions in 2020 and 2021.--


--Movies vs TV Shows Over Time

SELECT
	YEAR (date_added) AS year_added, type, COUNT(*) AS total_content
FROM dbo.netflix
	GROUP BY YEAR(date_added), type
	ORDER BY year_added

--shows that both movies and TV shows have seen an increase in additions over time, with movies consistently having a higher count than TV shows.--


--Top Directors

SELECT
	TOP 10 director, COUNT(*) AS total_content
FROM dbo.netflix
	WHERE director IS NOT NULL
	GROUP BY director
	ORDER BY total_content DESC

--shows that the top directors with the most content on Netflix was Rajiv Chilaka.--

--Growth over the years by country Using CTE and LAG function

WITH CountryGrowth AS (
SELECT 
    YEAR(date_added) AS year,
    COUNT(*) AS total_content
FROM dbo.netflix
	GROUP BY YEAR(date_added)
)
SELECT 
year,total_content,LAG(total_content) OVER (ORDER BY year) AS prev_year, (total_content - LAG(total_content) OVER (ORDER BY year)) AS growth
FROM CountryGrowth
ORDER BY year

--shows the growth of content added to Netflix over the years, with a significant increase in recent years. The growth is calculated by comparing the total content added in each year to the previous year.--


--Computing the total during each year and the percentage growth compared to the previous year

WITH CountryGrowth AS (
SELECT 
    YEAR(date_added) AS year,
    COUNT(*) AS total_content
FROM dbo.netflix
	GROUP BY YEAR(date_added)
)
SELECT 
 YEAR,total_content,LAG(total_content) OVER (ORDER BY year) AS prev_year, (total_content - LAG(total_content) OVER (ORDER BY year)) AS growth,
CASE 
	WHEN LAG(total_content) OVER (ORDER BY year) IS NULL THEN NULL
	ELSE ((total_content - LAG(total_content) OVER (ORDER BY year)) * 100.0 / LAG(total_content) OVER (ORDER BY year))
END AS percentage_growth
FROM CountryGrowth
ORDER BY year

--shows the total content added to Netflix each year, the growth compared to the previous year, and the percentage growth. The percentage growth is calculated by dividing the growth by the total content of the previous year and multiplying by 100. This allows us to see not only the absolute increase in content but also how significant that increase is relative to the previous year's total.--


--Content distribution by country using STRING_SPLIT to handle multiple countries in the 'country' column 

SELECT 
    TRIM(value) AS country,
    COUNT(*) AS total_content
FROM dbo.netflix
CROSS APPLY STRING_SPLIT(country, ',')
WHERE country IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_content DESC

--shows the distribution of content by country, accounting for entries that may have multiple countries listed. The STRING_SPLIT function is used to split the 'country' column into individual country entries, and the TRIM function is applied to remove any leading or trailing spaces. The results are grouped by country and ordered by the total content count in descending order.--

--Genre distribution by country using STRING_SPLIT to handle multiple genres in the 'listed_in' column

SELECT 
	TRIM(value) AS genre,
	COUNT(*) AS total_content
FROM dbo.netflix
CROSS APPLY STRING_SPLIT(listed_in, ',')
WHERE listed_in IS NOT NULL
GROUP BY TRIM(value)
ORDER BY total_content DESC

--shows the distribution of genres across the content on Netflix, accounting for entries that may have multiple genres listed. The STRING_SPLIT function is used to split the 'listed_in' column into individual genre entries, and the TRIM function is applied to remove any leading or trailing spaces. The results are grouped by genre and ordered by the total content count in descending order.--
