/*
Cleaning Data in SQL Queries
*/




--------------------------------------------------------------------------------------------------------------------------

-- Creating a copy table to store data, and to keep a spare just in case I need the raw_file again
-- Only selecting for certain columns as needed for analysis

SELECT
	*
FROM video_game_sales.dbo.games_info
ORDER BY Global_Sales DESC;


DROP TABLE IF EXISTS video_game_sales.dbo.copygames;
CREATE TABLE video_game_sales.dbo.copygames (
    Name NVARCHAR(255) PRIMARY KEY
   ,Platform_Producer NVARCHAR(255)
   ,Platform NVARCHAR(255)
   ,Year_of_Release FLOAT
   ,Genre NVARCHAR(255)
   ,Publisher NVARCHAR(255)
   ,NA_Sales FLOAT
   ,EU_Sales FLOAT
   ,JP_Sales FLOAT
   ,Other_Sales FLOAT
   ,Global_Sales FLOAT
);


INSERT INTO video_game_sales.dbo.copygames
	SELECT
	    Name
	   ,CASE
		WHEN Platform IN ('PC') THEN 'Misc Computer Company'
		WHEN Platform IN ('NES', 'SNES', 'N64', 'GC', 'Wii', 'WiiU', 'GB', 'GBA', 'DS', '3DS') THEN 'Nintendo'
		WHEN Platform IN ('PS', 'PS2', 'PS3', 'PS4', 'PSP', 'PSV') THEN 'Sony'
		WHEN Platform IN ('XB', 'X360', 'XOne') THEN 'Microsoft'
		WHEN Platform IN ('2600') THEN 'Atari'
		WHEN Platform IN ('DC', 'SAT', 'GEN', 'GG', 'SCD') THEN 'Sega'
		WHEN Platform IN ('WS') THEN 'Bandai'
		WHEN Platform IN ('NG') THEN 'SNK'
		WHEN Platform IN ('TG16', 'PCFX') THEN 'Nec'
		WHEN Platform IN ('3DO') THEN 'Panasonic'
	    END Platform_Producer
	   ,Platform
	   ,Year_of_Release
	   ,Genre
	   ,Publisher
	   ,NA_Sales
	   ,EU_Sales
	   ,JP_Sales
	   ,Other_Sales
	   ,Global_Sales
	FROM video_game_sales.dbo.games_info;


SELECT
	*
FROM video_game_sales.dbo.copygames
ORDER BY Global_Sales DESC;




--------------------------------------------------------------------------------------------------------------------------

-- Check for Nulls

SELECT
	*
FROM video_game_sales.dbo.copygames
WHERE Name IS NULL;
-- Name is missing two values both are Mortal Kombat II and Mortal Kombat II (JP Sales) for gen
-- from data source VGchartz.com


UPDATE video_game_sales.dbo.copygames
SET Name = 'Mortal Kombat II'
   ,Genre = 'Fighting'
   ,JP_Sales = 0.03
   ,Global_Sales = Global_Sales + 0.03
WHERE Name IS NULL
AND Publisher = 'Acclaim Entertainment'
AND Platform = 'GEN';


--SELECT *
DELETE FROM video_game_sales.dbo.copygames
WHERE Name = 'Mortal Kombat II'
	AND Publisher = 'Acclaim Entertainment'
	AND Platform = 'GEN'
	AND NA_Sales = 0;


-- Over 200 games without year of realse so remove, also for some realses after 2016 so remove  273 rows total
SELECT
	*
FROM video_game_sales.dbo.copygames
WHERE Year_of_Release > 2016
--WHERE Year_of_Release IS NULL
ORDER BY Publisher, Name;

DELETE FROM video_game_sales.dbo.copygames
WHERE Year_of_Release IS NULL
	OR Year_of_Release > 2016;
	

SELECT
	*
FROM video_game_sales.dbo.copygames;



--------------------------------------------------------------------------------------------------------------------------

-- Duplicate check

WITH cte_dupl
AS
(SELECT
		*
	   ,ROW_NUMBER() OVER (PARTITION BY Name, Platform, NA_Sales, JP_Sales, Global_Sales ORDER BY Name) row_num
	FROM video_game_sales.dbo.copygames)

SELECT
	*
FROM cte_dupl
WHERE row_num > 1;




--------------------------------------------------------------------------------------------------------------------------

-- Check for Distinct Values

SELECT DISTINCT
	Year_of_Release
FROM video_game_sales.dbo.copygames
ORDER BY Year_of_Release;







