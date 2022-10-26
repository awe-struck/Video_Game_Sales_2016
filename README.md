# Exploratory Data Analysis on Video Game Sales (1980-2016)

## Introduction

Video games have long been a source of entertainment with many factors leading to its success in sales and market growth. This project will use exploratory data analysis to examine those factors and uncover any insights found within the dataset. Specifically, the focus of the analysis will be on the North American market.

The goal of this analysis is to gain insight into the factors that incluence video game sales in the North American market and to use that information to give data based business recommendations.

(to answer what has caused (genre , technology getting better, media and other campaigns like movies)the growth of sales and how can game companies captilize on it)

<br />

## Dataset Information

This dataset was downloaded as a CSV file from [Kaggle](https://www.kaggle.com/datasets/rush4ratio/video-game-sales-with-ratings) which itself scraped data  from vgchartz.com. Following the link to the dataset, the column headers provide a succint description of the type of information found within the dataset.
This file contains video game sales data from 1980 to 2016 and has its sales fields in units of millions.

Below is a brief summary of the columns from the cleaned dataset used in the analysis:

![image](https://user-images.githubusercontent.com/115379520/197462826-95244c11-947d-4851-a656-be4b2787a790.png)

<br />

## Data Extraction and Cleaning

- Here is a direct link to the SQL cleaning file:

Pre-cleaned, the CSV file contained 16719 rows. The file was then converted into a .xlss format and uploaded to Microsoft SSMS for analysis. I proceeded to create a copy table to store this information and filter for the columns relevant to the analysis. These dropped columns contained NULL values and was data that was not fully scrapped from metacritic. Thus, the columns critic score,critic count, user score, user count, developer and rating were dropped. 

To gain an general understanding of how consoles influenced the growth of sales, I included the column Platform_Producer. This column contains information on the producer of video game consoles. This will be used as a general guage to see how technology growth has influenced sales in the NA market.


<details>
<summary>SQL Code: Filtered Table</summary>
<pre>
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
</pre>
</details>

![image](https://user-images.githubusercontent.com/115379520/197377996-3c8c469c-c063-4bfc-b17c-72f65945feca.png)

<br />

The next step involved checking for NULL values. In the dataset, the Name column had two values with missing information which was updated using information from the [source website.](https://www.vgchartz.com/) Following that, the year_of_release column was cleaned. Any rows with values that were NULL or were greater than 2016 were deleted. Thus, resulting in 16445 rows in the cleaned dataset.


<details>
<summary>SQL Code: Cleaned Table</summary>
<pre>
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
WHERE 
	Name IS NULL AND 
	Publisher = 'Acclaim Entertainment' AND Platform = 'GEN'


--SELECT *
DELETE FROM video_game_sales.dbo.copygames 
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

</pre>
</details>



<br />

The final step was to check for duplicants and distinct values. There were no outliers or erroneous values, so nothing was deleted.

<details>
<summary>SQL Code: Duplicate Check</summary>
<pre>
-- Duplicate check

WITH cte_dupl AS 
(
	SELECT 
		*, 
		ROW_NUMBER() OVER(PARTITION BY Name, Platform, NA_Sales, JP_Sales, Global_Sales
				  ORDER BY Name) 
		row_num
	FROM video_game_sales.dbo.copygames 
)

SELECT * 
FROM cte_dupl
WHERE row_num > 1


-- Check for Distinct Values

SELECT DISTINCT  Year_of_Release
FROM video_game_sales.dbo.copygames 
ORDER BY Year_of_Release
</pre>
</details>

<br />

## Data Analysis

Before diving into the NA sales data, I pulled up a brief overview of the top level sales data. So I made a simple query and gathered a few descriptive statistics. Some summary statistics for global and NA sales are as listed in the image below. At a brief glance, I noticed that the sum of all NA sales (4.34 billion) was half of the global sales (8.84 billion). This shows how dominate the NA market is in terms of sales and its influence on the global market.

Inspecting the top level data, the top 10 global game sales are all Nintendo published and produced. Similarily, 9 out of 10 of the top games for NA are also from Nintendo. Given the precentage of sales from the NA market, it makes sense why the top 10 games of both the global and NA were nearly identical. However, this immediately raises several questions: is being a game from the Nintendo brand the top video game company, the most important factor in sales? Why does Nintendo have the most sales in NA? How does its competition compare? How did this change over time? 

Keeping these questions in mind, I proceeded to explore the rest of the data to answer these questions.

<details>
<summary>SQL Code: Best Selling Games</summary>
<pre>

SELECT *
FROM video_game_sales.dbo.copygames 
ORDER BY Global_Sales DESC

SELECT *
FROM video_game_sales.dbo.copygames 
ORDER BY NA_Sales DESC 

</pre>
</details>

<br />

**Top 10 Games Ordered by Global Sales**

![image](https://user-images.githubusercontent.com/115379520/197653853-81f5694c-ddc0-449f-9146-9a3a7b37757a.png)



<br />

**Top 10 Games Ordered by NA Sales**


![image](https://user-images.githubusercontent.com/115379520/197653913-d721ca6d-a05a-4633-850a-98d8d1de2320.png)

<br />

With how similar the top 10 categories in both the global and NA market, I checked how NA performed relative to the rest of the regions. The SQL query revealed that from 8.82 billion global sales, the North American market is responsible for 49.24% of it with 4.34 billion sales. Trailing behind, EU composes 27.21% of it with 2.4 billion sales. Folllowing that, JP is 14.64% of the total with 1.29 billion sales. Finally, Other regions accounts for the final 8.87% with 782 million sales. Over time, distribution of the regionally sales has been fairly consistent with NA being the leading figure in the global market.



<details>
<summary>SQL Code: Global Sales by Region </summary>
<pre>

SELECT 
	SUM(Global_Sales) glb_sales, 
	SUM(NA_Sales) na_sales,
	FORMAT(SUM(NA_Sales)/SUM(Global_Sales), 'p') na_pct, 
	SUM(EU_Sales) eu_sales,
	format(SUM(EU_Sales)/SUM(Global_Sales),'p') eu_pct, 
	SUM(JP_Sales) jp_sales,
	format(SUM(JP_Sales)/SUM(Global_Sales),'p') jp_pct, 
	SUM(Other_Sales) oth_sales,
	format(SUM(Other_Sales)/SUM(Global_Sales), 'p') oth_pct
FROM video_game_sales.dbo.copygames 

SELECT 
	Year_of_Release,
	SUM(Global_Sales) glb_sales, 
	SUM(NA_Sales) na_sales,
	FORMAT(SUM(NA_Sales)/SUM(Global_Sales), 'p') na_pct, 
	SUM(EU_Sales) eu_sales,
	format(SUM(EU_Sales)/SUM(Global_Sales),'p') eu_pct, 
	SUM(JP_Sales) jp_sales,
	format(SUM(JP_Sales)/SUM(Global_Sales),'p') jp_pct, 
	SUM(Other_Sales) oth_sales,
	format(SUM(Other_Sales)/SUM(Global_Sales), 'p') oth_pct
FROM video_game_sales.dbo.copygames 
GROUP BY Year_of_Release
ORDER BY Year_of_Release

</pre>
</details>

<br />

![image](https://user-images.githubusercontent.com/115379520/197441930-9dc5c304-9695-4123-b717-bb0192d6d2bc.png)




<br />

To better understand how sales are distributed, I segemented the sales based on genre. From this data, the top 5 genres in terms of sales are Action, Sports, Shooters, Platformers and Misc. All of these categories exceed the average genre sales value of 361.9 million sales. Since these 5 categories compose a majority of the genre sales, I decided to focuse on these particular subtypes and filter out the other genres. 

The overall count of titles revealed an interesting resullt for the top 5 genres in terms of NA sales:

**Action** genre has the highest NA sales and count of games. Being at the top of sales makes sense as this genre is easier to play than other genres. Compared to genres like puzzle and strategy, there is no such bottleneck as the learning curve is easier. Furthermore, there are more options to choose from as this genre has the most amount of games by far. Thus, boosting the sales numbers. Other factors such as blockbuster game titles, console impact and social influence will be further explored in a later section.

**Sports** has the second highest NA sales and count of games. Some possible reasons why this genre is so popular includes social influences suchs Olympics, NBA or NFL historic seasons, etc. These factors will be further explored in a later section.

**Shooters** genre has the third most NA sales yet has less games than the Misc and Role-Playing genres. Going back to the ease of learning point and  barriers of entry, shooters tend to have simplier game mechanics. Point and click mechanics make the game easier to pick up while mitigating any gameplay confusion. However, a possible reason for the lower game title could also stem from the same design choice. Due to the simplicity of the gameplay, it is hard to innovate and justify an entirely new game. Thus, leading to lower game sales.

**Platformers** genre has the fourth most NA sales yet is lagging behind in number of game titles. A possible explanation for this might be that this genre was more prevalent in the past. This is may be due to how easy platformers were to implement relative to other genres. With advancements in technology, it became possible to implement more features for other genres. Thus, leading to decrease in sales over time. This theory will be further explored in a later section

**Misc** genre has the fifth most NA sales and the third most game titles. Since the Misc genre contains all games not inluced in the other genres, it is understandable why the volume of game titles is so high. Furthermore,  this genre probably contains game titles with highly popular gaming sub-cultures and niches. Thus, leading to the high sales.


![image](https://user-images.githubusercontent.com/115379520/197688773-32a327bf-cb11-4b20-885e-a9e60b73f2d5.png)

<br />

![image](https://user-images.githubusercontent.com/115379520/197453795-195a744a-341b-4a9c-935a-f6daf25efae8.png)


# yoy growth - cause games
To make it easier to view changes overtime, I calculated YoY growth rate to quantify changes and observe any noticable trends. Following that, I filtered for years with YoY rates > 100 and segemented based on those years. Wrote queries pulling information on why those years were succesfful



# Yoy growth - platofrom and technoloy inducing growth and dips


# how do publishers impact sales: make tree map of the type of games the it publiehse
make note of popular game titles and franches


# Conclusions / Recommednations

# Limitations

# Footer/references



