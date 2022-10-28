
--------------------------------------------------------------------------------------------------------------------------

-- Top Games Globally

SELECT
	*
FROM video_game_sales.dbo.copygames
ORDER BY Global_Sales DESC


-- Top Games NA

SELECT
	*
FROM video_game_sales.dbo.copygames
ORDER BY na_sales DESC


-- Global Sales by Region

SELECT
	SUM(Global_Sales) glb_sales
   ,SUM(na_sales) na_sales
   ,FORMAT(SUM(na_sales) / SUM(Global_Sales), 'p') na_pct
   ,SUM(eu_sales) eu_sales
   ,FORMAT(SUM(eu_sales) / SUM(Global_Sales), 'p') eu_pct
   ,SUM(jp_sales) jp_sales
   ,FORMAT(SUM(jp_sales) / SUM(Global_Sales), 'p') jp_pct
   ,SUM(Other_Sales) oth_sales
   ,FORMAT(SUM(Other_Sales) / SUM(Global_Sales), 'p') oth_pct
FROM video_game_sales.dbo.copygames


SELECT
	Year_of_Release
   ,SUM(Global_Sales) glb_sales
   ,SUM(na_sales) na_sales
   ,FORMAT(SUM(na_sales) / SUM(Global_Sales), 'p') na_pct
   ,SUM(eu_sales) eu_sales
   ,FORMAT(SUM(eu_sales) / SUM(Global_Sales), 'p') eu_pct
   ,SUM(jp_sales) jp_sales
   ,FORMAT(SUM(jp_sales) / SUM(Global_Sales), 'p') jp_pct
   ,SUM(Other_Sales) oth_sales
   ,FORMAT(SUM(Other_Sales) / SUM(Global_Sales), 'p') oth_pct
FROM video_game_sales.dbo.copygames
GROUP BY Year_of_Release
ORDER BY Year_of_Release




--------------------------------------------------------------------------------------------------------------------------


-- NA Sales by Genre

WITH cte_na_genre
AS
(SELECT
		genre
	   ,COUNT(na_sales) title_cnt
	   ,SUM(na_sales) na_sales
	FROM video_game_sales.dbo.copygames
	GROUP BY genre)

SELECT
	*
   ,AVG(na_sales) OVER () avg_sales_genre
FROM cte_na_genre
ORDER BY na_sales DESC




--------------------------------------------------------------------------------------------------------------------------

-- Top 5 NA Genre Sales over Time with YoY Growth Rate

DROP TABLE IF EXISTS #growth_YoY
CREATE TABLE #growth_YoY (
	genre NVARCHAR(255)
   ,release_year FLOAT
   ,na_sales FLOAT
   ,previous_year FLOAT
   ,previous_sales FLOAT
   ,YoY_Growth_rate FLOAT
)


WITH cte_growth_rate
AS
(SELECT
		genre
	   ,Year_of_Release
	   ,SUM(na_sales) na_sales
	FROM video_game_sales.dbo.copygames
	WHERE genre IN ('Action', 'Sports', 'Shooter', 'Platform', 'Misc')
	GROUP BY genre
			,Year_of_Release)


-- YoY = (current/previous) - 1 
INSERT INTO #growth_YoY
	SELECT
		*
	   ,LAG(Year_of_Release) OVER (PARTITION BY genre ORDER BY Year_of_Release) previous_year
	   ,LAG(na_sales) OVER (PARTITION BY genre ORDER BY Year_of_Release) previous_sales
	   ,((na_sales / NULLIF(LAG(na_sales) OVER (PARTITION BY genre ORDER BY Year_of_Release), 0)) - 1) * 100 growth_rate
	FROM cte_growth_rate
	ORDER BY genre, Year_of_Release


-- NA Genre Sales growth rate

SELECT
	release_year
   ,SUM(YoY_Growth_rate) growth_rate
FROM #growth_YoY
WHERE YoY_Growth_rate > 100
GROUP BY release_year
ORDER BY release_year


-- Segement via Genre and Release_years to view top performing games. Filter for years with highest YoY growth rates.

WITH cte_yoy
AS
(SELECT
		release_year
	FROM #growth_YoY
	WHERE YoY_Growth_rate > 100
	GROUP BY release_year)


SELECT
	Year_of_Release
   ,genre
   ,Name
   ,SUM(na_sales) OVER (PARTITION BY Year_of_Release) yearly_sales
   ,SUM(na_sales) OVER (PARTITION BY Year_of_Release, genre ORDER BY genre) yearly_genre_sales
   ,na_sales
FROM video_game_sales.dbo.copygames
	,cte_yoy
WHERE Year_of_Release IN (cte_yoy.release_year)
AND genre IN ('Action', 'Sports', 'Shooter', 'Platform', 'Misc')
ORDER BY Year_of_Release, yearly_genre_sales DESC, na_sales DESC




SELECT
	SUM(na_sales)
FROM video_game_sales.dbo.copygames
WHERE Year_of_Release = 2009
AND genre IN ('Action', 'Sports', 'Shooter', 'Platform', 'Misc')




--------------------------------------------------------------------------------------------------------------------------


-- Platform_Producer Analysis to see how sales are broken down by technological advances

SELECT
	Platform_Producer
   ,SUM(na_sales) na_sales
FROM video_game_sales.dbo.copygames
WHERE genre IN ('Action', 'Sports', 'Shooter', 'Platform', 'Misc')
GROUP BY Platform_Producer
ORDER BY na_sales DESC
-- since SNK and NEC had zero or negligibale sales  for NA market we will exclude these companies from our analysis,
-- panasonic an bandai did not release their console to NA


-- Platform_Producer sales over time

SELECT
	Year_of_Release
   ,Platform_Producer
   ,SUM(na_sales) na_sales
FROM video_game_sales.dbo.copygames
WHERE genre IN ('Action', 'Sports', 'Shooter', 'Platform', 'Misc')
GROUP BY Platform_Producer
		,Year_of_Release
ORDER BY Year_of_Release, na_sales DESC


-- Platform_Producer, Ordered by console sales

SELECT
	Platform_Producer
   ,Platform
   ,SUM(na_sales) na_sales
FROM video_game_sales.dbo.copygames
WHERE genre IN ('Action', 'Sports', 'Shooter', 'Platform', 'Misc')
GROUP BY Platform_Producer
		,Platform
ORDER BY na_sales DESC


-- Platform_Producer, Ordered by console sales OVER TIME

SELECT
	Platform_Producer
   ,Platform
   ,SUM(na_sales) na_sales
FROM video_game_sales.dbo.copygames
WHERE genre IN ('Action', 'Sports', 'Shooter', 'Platform', 'Misc')
GROUP BY Platform_Producer
		,Platform
ORDER BY na_sales DESC




-- YoY Growth for Platform Producers and Consoles

DROP TABLE IF EXISTS #growth_YoY_plat
CREATE TABLE #growth_YoY_plat (
	release_year FLOAT
   ,Platform_Producer NVARCHAR(255)
   ,na_sales FLOAT
   ,previous_year FLOAT
   ,previous_sales FLOAT
   ,YoY_Growth_rate FLOAT
)

WITH cte_growth_rate
AS
(SELECT
		Year_of_Release
	   ,Platform_Producer
	   ,SUM(na_sales) na_sales
	FROM video_game_sales.dbo.copygames
	WHERE genre IN ('Action', 'Sports', 'Shooter', 'Platform', 'Misc')
	GROUP BY Platform_Producer
			,Year_of_Release)


INSERT INTO #growth_YoY_plat
	SELECT
		*
	   ,LAG(Year_of_Release) OVER (PARTITION BY Platform_Producer ORDER BY Year_of_Release) previous_year
	   ,LAG(na_sales) OVER (PARTITION BY Platform_Producer ORDER BY Year_of_Release) previous_sales
	   ,((na_sales / NULLIF(LAG(na_sales) OVER (PARTITION BY Platform_Producer ORDER BY Year_of_Release), 0)) - 1) * 100 growth_rate
	FROM cte_growth_rate
	ORDER BY Platform_Producer, Year_of_Release



SELECT
	release_year
   ,Platform_Producer
   ,SUM(YoY_Growth_rate) growth_rate
FROM #growth_YoY_plat
WHERE YoY_Growth_rate > 100
GROUP BY release_year
		,Platform_Producer
ORDER BY release_year


-- Segement via Platform_Producer and Release_years to view top performing Consoles/Platforms. Filter for years with highest YoY growth rates.

WITH cte_yoy
AS
(SELECT
		release_year
	   ,SUM(YoY_Growth_rate) growth_rate
	FROM #growth_YoY_plat
	WHERE YoY_Growth_rate > 100
	GROUP BY release_year),

cte_console
AS
(SELECT
		Year_of_Release
	   ,Platform_Producer
	   ,Platform
	   ,SUM(na_sales) na_sales
	FROM video_game_sales.dbo.copygames
	WHERE genre IN ('Action', 'Sports', 'Shooter', 'Platform', 'Misc')
	GROUP BY Year_of_Release
			,Platform_Producer
			,Platform)


SELECT
	Year_of_Release
   ,Platform_Producer
   ,Platform
   ,SUM(na_sales) OVER (PARTITION BY Year_of_Release) yearly_sales
   ,SUM(na_sales) OVER (PARTITION BY Year_of_Release, Platform_Producer ORDER BY Platform_Producer) yearly_platform_producer_sales
   ,SUM(na_sales) OVER (PARTITION BY Year_of_Release, Platform_Producer, Platform ORDER BY Platform_Producer) Console_sales
FROM cte_console
	,cte_yoy
WHERE Year_of_Release IN (cte_yoy.release_year)
ORDER BY Year_of_Release, yearly_platform_producer_sales DESC, Console_sales DESC




--------------------------------------------------------------------------------------------------------------------------

-- Publishers Analysis: General Overview of Top 10 Publishers

SELECT
	Publisher
   ,SUM(na_sales) na_sales
FROM video_game_sales.dbo.copygames
WHERE genre IN ('Action', 'Sports', 'Shooter', 'Platform', 'Misc')
GROUP BY Publisher
ORDER BY na_sales DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY


-- Publishers Analysis by game title

WITH cte_pub
AS
(SELECT
		Publisher
	   ,Name
	   ,SUM(na_sales) na_sales
	FROM video_game_sales.dbo.copygames
	WHERE genre IN ('Action', 'Sports', 'Shooter', 'Platform', 'Misc')
	AND Publisher IN ('Nintendo', 'Electronic Arts', 'Activision')
	GROUP BY Publisher
			,Name)
SELECT
	*
   ,SUM(na_sales) OVER (PARTITION BY Publisher) pub_sale
FROM cte_pub
ORDER BY pub_sale DESC, na_sales DESC





