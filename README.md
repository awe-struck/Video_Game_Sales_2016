# Exploratory Data Analysis on Video Game Sales (1980-2016)

# Introduction

Video games have long been a source of entertainment with many factors leading to its success in sales and market growth. This project will use exploratory data analysis to examine these factors and uncover any insights found within the dataset. Specifically, the focus will be on the North American market and will
data=

This information will be used to find trends, understand why these sales are being made and give data based business recommendations so game companies can captialbi on it
to answer what has caused (genre , technology getting better, media and other campaigns like movies)the growth of sales and how can game companies captilize on it

```
fd
```

# Data Extraction and Cleaning

- Here is a direct link to the SQL cleaning file

This dataset was downloaded as a CSV file from [Kaggle](https://www.kaggle.com/datasets/rush4ratio/video-game-sales-with-ratings) which itself scraped data  
from vgchartz.com. Following the link to the dataset, the column headers provide a succint description of the type of information found within the dataset. This includes game titles, genres, publishers, sales, etc. The sales are listed in units of millions and the release years are from 1980-2016. Pre-cleaned this dataset contained 16719 rows.

The CSV file was converted  into a .xlss format and uploaded to Microsoft SSMS for analysis. I proceeded to create a copy table to store this information and filter for the columns relevant to the analysis. These dropped columns contained NULL values and was data that was not fully scrapped from metacritic. Thus, the columns critic score,critic count, user score, user count, developer and rating were dropped. 


```
DROP TABLE IF EXISTS video_game_sales.dbo.copygames
CREATE TABLE video_game_sales.dbo.copygames
(
	Name NVARCHAR(255),
	Platform_Producer NVARCHAR(255),
	Platform NVARCHAR(255),
	Year_of_Release float,
	Genre NVARCHAR(255),
	Publisher NVARCHAR(255),
	NA_Sales float,
	EU_Sales float,
	JP_Sales float,
	Other_Sales float,
	Global_Sales float
)
INSERT INTO video_game_sales.dbo.copygames
SELECT  
    Name,
    CASE 
			WHEN Platform IN ('PC') THEN 'Misc Computer Company'
			WHEN Platform IN ('NES', 'SNES', 'N64', 'GC', 'Wii', 'WiiU', 'GB', 'GBA', 'DS', '3DS') THEN 'Nintendo'
			WHEN Platform IN ('PS','PS2','PS3','PS4','PSP','PSV') THEN 'Sony'
			WHEN Platform IN ('XB', 'X360', 'XOne') THEN 'Microsoft'
			WHEN Platform IN ('2600') THEN 'Atari'
			WHEN Platform IN ('DC', 'SAT', 'GEN', 'GG', 'SCD') THEN 'Sega'
			WHEN Platform IN ('WS') THEN 'Bandai'
			WHEN Platform IN ('NG') THEN 'SNK'
			WHEN Platform IN ('TG16', 'PCFX') THEN 'Nec'
			WHEN Platform IN ('3DO') THEN 'Panasonic'
		END Platform_Producer,
		Platform,
		Year_of_Release,
		Genre,
		Publisher,
		NA_Sales,
		EU_Sales,
		JP_Sales,
		Other_Sales,
		Global_Sales
FROM video_game_sales.dbo.games_info


SELECT *
FROM video_game_sales.dbo.copygames 
ORDER BY Global_Sales DESC
```

![image](https://user-images.githubusercontent.com/115379520/197377996-3c8c469c-c063-4bfc-b17c-72f65945feca.png)






The next step was to check for NULLs. In the dataset, the Name column had two values with missing information. Thus, I went onto the [source website](https://www.vgchartz.com/),found the missing game titles then updated the table. Following that, the year_of_release column was cleaned and rows with NULL values were deleted. Also any fields with out of bounds were deleted. Thus, resulting in 16445 rows in the dataset.

```
SELECT *
FROM video_game_sales.dbo.copygames
WHERE Name IS NULL 
-- Name is missing two values, both are Mortal Kombat II and Mortal Kombat II (JP Sales) for Platform GEN


UPDATE video_game_sales.dbo.copygames 
SET 
	Name = 'Mortal Kombat II',
	Genre = 'Fighting',
	JP_Sales = 0.03,
	Global_sales = Global_Sales + 0.03
WHERE Name IS NULL AND Publisher = 'Acclaim Entertainment' AND Platform = 'GEN'


--SELECT *
DELETE FROM  video_game_sales.dbo.copygames 
WHERE Name ='Mortal Kombat II' AND Publisher = 'Acclaim Entertainment' AND Platform = 'GEN' AND NA_Sales = 0



SELECT *
FROM video_game_sales.dbo.copygames
WHERE Year_of_Release > 2016
--WHERE Year_of_Release IS NULL
ORDER BY publisher, Name


DELETE FROM video_game_sales.dbo.copygames
WHERE Year_of_Release IS NULL OR Year_of_Release > 2016
-- Deleted 273 rows which contained Year_of_Release fields that were NULL or contained values out of bounds

SELECT *
FROM video_game_sales.dbo.copygames 
-- COUNT 16445
```

The data was then checked for any duplicates, of which there were none. Same with the Distinct values.

```
-- Duplicate check

WITH cte_dupl AS 
(
	SELECT *, ROW_NUMBER() OVER(PARTITION BY Name, Platform, NA_Sales, JP_Sales, Global_Sales  ORDER BY Name) row_num
	FROM video_game_sales.dbo.copygames 
)

SELECT * 
FROM cte_dupl
WHERE row_num > 1




--------------------------------------------------------------------------------------------------------------------------

-- Check for Distinct Values

SELECT DISTINCT  Year_of_Release
FROM video_game_sales.dbo.copygames 
ORDER BY Year_of_Release
```



# Data Analysis

Did a quick check of the data and wanted to get a brief snapshot of the data beofre fully diving in. It turns out for top 10 games ever side are all nintendo  published and produced. With a max sales of 41.36 million, min of0, total sales of 4334.2 mioon and avg of 0.26 million
```
SELECT *
FROM video_game_sales.dbo.copygames 
ORDER BY Global_Sales DESC
```
![image](https://user-images.githubusercontent.com/115379520/197378547-344d1642-c4b5-479e-a33e-5853dd658a70.png)


If we dive in deeper, we can see that NA accounts for 49% of global says
```
SELECT *
FROM video_game_sales.dbo.copygames 
ORDER BY Global_Sales DESC
```

# insert pie/bar chart here of distriution





