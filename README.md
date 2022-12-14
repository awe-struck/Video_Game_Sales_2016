# Exploratory Data Analysis on Video Game Sales (1980-2016)

## Introduction

Video games have long been a source of entertainment with many factors leading to its success in sales and market growth. This project will use exploratory data analysis to examine those factors and uncover any insights found within the dataset. Specifically, the focus of the analysis will be on the North American market.

The goal of this analysis is to gain insight into the factors that influence video game sales in the North American market and to use that information to give data based business recommendations.


<br />

## Dataset Information

This dataset was downloaded as a CSV file from [Kaggle](https://www.kaggle.com/datasets/rush4ratio/video-game-sales-with-ratings) which itself scraped data  from vgchartz.com. Following the link to the dataset, the column headers provide a succint description of the type of information found within the dataset.
This file contains video game sales data from 1980 to 2016 and has its sales fields in units of millions.

Below is a brief summary of the columns from the cleaned dataset used in the analysis:

![image](https://user-images.githubusercontent.com/115379520/197462826-95244c11-947d-4851-a656-be4b2787a790.png)

<br />

## Data Extraction and Cleaning

- Link to [SQL Cleaning file](https://github.com/awe-struck/Video_Game_Sales_2016/blob/main/Data_Cleaning/vg_sales_clean.sql)

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

- Link to [SQL Data Analysis file](https://github.com/awe-struck/Video_Game_Sales_2016/blob/main/Data_Analysis/sales_analysis.sql)

The analysis of the data involved writing SQL queries to breakdown and segement based on categories. Visualizations were from screenshots of SQL query outputs and Tableau generated graphs of that output.


<br />

### Top Performing Games

---

Before diving into the NA sales data, I pulled up a brief overview of the top level sales data. So I made a simple query and gathered a few descriptive statistics. Some summary statistics for global and NA sales are as listed in the image below. At a brief glance, I noticed that the sum of all NA sales (4.34 billion) was half of the global sales (8.84 billion). This shows how dominate the NA market is in terms of sales and its influence on the global market.

Inspecting the top level data, the top 10 global game sales are all Nintendo published and produced. Similarily, 9 out of 10 of the top games for NA are also from Nintendo. Given the precentage of sales from the NA market, it makes sense why the top 10 games of both the global and NA were nearly identical. However, this immediately raises several questions: 

- Why does Nintendo have the best individual performing game sales in NA?
- Is it due to console specific game franchises?
- Is it due to technological advances?
- How do the sales change over time?
- What other factors influenced sales?
- How does its competition compare? 

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

### Top Performing Regions

---

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

### Top Performing Genres

---

To better understand how sales are distributed, I segemented the sales based on genre. From this data, the top 5 genres in terms of sales are Action, Sports, Shooters, Platformers and Misc. All of these categories exceed the average genre sales value of 361.9 million sales. Since these 5 categories compose a majority of the genre sales, I decided to focus on these particular subtypes and filter out the other genres. 

The overall count of titles revealed an interesting resullt for the top 5 genres in terms of NA sales:

**Action** genre has the highest NA sales (863 million units) and count of games (3307). Being at the top of sales makes sense as this genre is easier to play than other genres. Compared to genres like puzzle and strategy, there is no such bottleneck as the learning curve is easier. Furthermore, there are more options to choose from as this genre has the most amount of games by far. Thus, boosting the sales numbers. Other factors such as blockbuster game titles, console impact and social influence will be further explored in a later section.

**Sports** has the second highest NA sales (671 million units) and count of games (2306). Some possible reasons why this genre is so popular includes social influences suchs Olympics, NBA or NFL historic seasons, etc. These factors will be further explored in a later section.

**Shooters** genre has the third most NA sales (584 million units) yet has less games (1296) than the Misc and Role-Playing genres. Going back to the ease of learning point and  barriers of entry, shooters tend to have simplier game mechanics. Point and click mechanics make the game easier to pick up while mitigating any gameplay confusion. However, a possible reason for the lower game title could also stem from the same design choice. Due to the simplicity of the gameplay, it is hard to innovate and justify an entirely new game. Thus, leading to lower game sales.

**Platformers** genre has the fourth most NA sales (444 million units) yet is lagging behind (878) in number of game titles. A possible explanation for this might be that this genre was more prevalent in the past. This is may be due to how easy platformers were to implement relative to other genres. With advancements in technology, it became possible to implement more features for other genres. Thus, leading to decrease in sales over time. This theory will be further explored in a later section

**Misc** genre has the fifth most NA sales (399 million units) and the third most game titles (1721). Since the Misc genre contains all games not inluced in the other genres, it is understandable why the volume of game titles is so high. Furthermore,  this genre probably contains game titles with highly popular gaming sub-cultures and niches. Thus, leading to the high sales.


<details>
<summary>SQL Code: NA Sales by Genre</summary>
<pre>

WITH cte_na_genre AS (
SELECT Genre, COUNT(NA_sales) title_cnt, SUM(NA_Sales) na_sales
FROM video_game_sales.dbo.copygames 
GROUP BY Genre
)

SELECT  *, AVG(na_sales) OVER() avg_sales_genre
FROM cte_na_genre
ORDER BY na_sales DESC

</pre>
</details>


![image](https://user-images.githubusercontent.com/115379520/197940377-efadcbf3-0d3f-40c2-947e-4ed6869da652.png)

<br />

![image](https://user-images.githubusercontent.com/115379520/197453795-195a744a-341b-4a9c-935a-f6daf25efae8.png)


### Yearly Breakdown of Sales by Game Title Releases
---

To make it easier to view changes overtime, I calculated YoY growth rate to quantify changes and observe any noticable trends. Then I sorted by year and filtered for hight YoY rates to isolate for those high performing years. In this section, I will breakdown the data Year by Year growth and observe the best selling game releases

```
Year over Year Growth = (Current Period Value ?? Prior Period Value) ??? 1
```

At first glance, the data seemse a bit overwhelming. However, as we iterate through the data and the years; we will see how specific game titles influenced the sales in North America.


<br/>



<details>
<summary>SQL Code: Top 5 genre sales with YoY growth</summary>
<pre>


-- Top 5 NA Genre Sales Over Time with YoY Growth Rate

DROP TABLE IF EXISTS #growth_YoY
CREATE TABLE #growth_YoY
	(
	genre NVARCHAR(255),
	release_year FLOAT,
	na_sales FLOAT,
	previous_year FLOAT, 
	previous_sales FLOAT,
	YoY_Growth_rate FLOAT
	)


WITH cte_growth_rate AS 
	(
	SELECT Genre, Year_of_Release, SUM(NA_Sales) na_sales
	FROM video_game_sales.dbo.copygames 
	WHERE Genre IN ('Action', 'Sports', 'Shooter','Platform', 'Misc')
	GROUP BY Genre, Year_of_Release
    )


-- Year over Year Growth = (Current Period Value ?? Prior Period Value) ??? 1
INSERT INTO #growth_YoY
SELECT 
	*,
	LAG(Year_of_Release) OVER(PARTITION BY genre ORDER BY Year_of_Release) previous_year,
	LAG(na_sales) OVER(PARTITION BY genre ORDER BY Year_of_Release) previous_sales,
	((na_sales/NULLIF(LAG(na_sales) OVER(PARTITION BY genre ORDER BY Year_of_Release),0) ) - 1 ) * 100  growth_rate
FROM cte_growth_rate
ORDER BY Genre, Year_of_Release   


-- NA Genre Sales Over Time, Filtered for YoY > 100%

SELECT release_year, SUM(YoY_Growth_rate) growth_rate
FROM #growth_YoY 
WHERE YoY_Growth_rate > 100
GROUP BY release_year
ORDER BY  release_year

</pre>
</details>


<details>
<summary>SQL Code: Years with high YoY growth</summary>
<pre>

-- Segement via Genre and Release_years to view top performing games. Filter for years with highest YoY growth rates.

WITH cte_yoy AS (
		SELECT release_year
		FROM #growth_YoY 
		WHERE YoY_Growth_rate > 100
		GROUP BY release_year
)


SELECT 
	Year_of_Release, 
	genre, 
	Name, 
	SUM(NA_Sales) OVER(PARTITION BY Year_of_Release ) yearly_sales,
	SUM(NA_Sales) OVER(PARTITION BY Year_of_Release, genre ORDER BY Genre) yearly_genre_sales,
	NA_Sales 
FROM video_game_sales.dbo.copygames, cte_yoy
WHERE Year_of_Release IN (cte_yoy.release_year) AND Genre IN ('Action', 'Sports', 'Shooter','Platform', 'Misc')
ORDER BY Year_of_Release,  yearly_genre_sales DESC, NA_Sales DESC

</pre>
</details>



<br>

![image](https://user-images.githubusercontent.com/115379520/197947517-c9292020-2cd7-46e6-87f4-b4a57ead5150.png)


<br>

In 1981, total sales by filtered genre was 30.44 million units.

- **Action** genre did the best with games like Frogger and E.T. boosting their sales. From E.T. there is a direct influence for other media as this was close to year E.T. was released in theathers. With the popularity of the film, it drove people to buy the game. Therefore, boosting sales numbers.

- **Shooter** genre also had decent sales, though no notable game IPs were released 

- **Platform** genre performed fairly well with its release of the Donkey Kong game IP


![image](https://user-images.githubusercontent.com/115379520/197959005-6afa424e-e6ec-4ecb-958c-948b31b53eeb.png)

<br>

In 1984 and 1985, total sales were 30.29 and 32.4 million  units respectively.

- **Shooter** genre shattered 1984 sales records with the release of Duck Hunt which made 25.93 million sales. This was around 85% of the year's total sales

- **Platform** genre soon followed up and the shattered sales records once more. The gaming world was forever changed with the introduction of the Super Mario Bros in 1985. This game made with the release of Duck Hunt which made 29.08 million sales. This was around 90% of the year's total sales




![image](https://user-images.githubusercontent.com/115379520/197963637-8a399042-05ff-4496-81ff-1d34e95fbd28.png)

<br>

In 1988,1989 and 1994 total sales by genre were  19.33 million, 18.61 million and 23.15 million units respectively

- **Platform** genre released more games from the Donkey Kong and Mario franchise. This helped establish dominance in the platformer genre with a collective 10.39 million sales. This genre is the clear cut top performer in this era. This can be attributed to the success of the Mario franchise with their games being a sensational smash hit.



![image](https://user-images.githubusercontent.com/115379520/198145406-88921f24-b05f-42fc-9853-212eee486207.png)


<br>

In 1996-1998, total sales were 39.6, 59.04 and 73.04 million units. All the genres started to pick up traction as multiple well known and popular game IPs had been created or released. Overall, a higher quality and greater volume of game titles were being released during these years.

- **Platform** genre released multiple games that are considered famous in modern times. These include Crash Bandicoot, Donkey Kong, Megaman, Kirby and etc.

- **Sports** genre had a massive spike in sales with a higher quantity and volume of games. This lead to overtaking **platform** as the top performing in sales. In this period, games based on sports leagues started to come out. Some of these games include NBA Live, NHL Live and Madden NFL. These games drew in a new audience of sports fans who now had a gateway into the video game medium. Furhermore, the excitemnt and narritaves of real life sports also helped in driving sales. For instance, during this period Michael Jordan had come out of retirement and performed a three-peat. The extra attention from this historic sports moment spilled over to other mediums. With the end result of increasing sales of associated products. The key take away here is that there is value in associating games to other mediums and real life events. All of which has the benefit of promoting the products to a loyal fanbase and increasing general visablity. Additionally, this can serve as a method to ease someone in who is not familiar with the medium. 

- **Action** genre also had a massive sales increased that overtook the **platform** genre. Notable IPs include Tomb Raider, Resident Evil and Starwars

- **Shooter** genre had the smash hits Golden Eye: 007, Half-Life and Starfox come out in 1997. This lead to the genre matching **action** and **sports** in sales.

- **Misc** genre experienced huge growth in sales yet was still at the bottom of sales for genre. Digging into the data, there were was a higher volume of games causing the increase in sales.


![image](https://user-images.githubusercontent.com/115379520/198161634-9c2aa199-78e2-4fcd-9fa6-9b5151ea8f22.png)

<br>

In 2000 - 2001, the  video game sales explodesd with 105.29 and 146.89 million units sold respectively. All genres have increased with notable IPs such as Halo, GTA and Metal Gear being released.

![image](https://user-images.githubusercontent.com/115379520/198162869-995bb41a-f9d7-4225-b495-d9a704da9aa1.png)

<br>

In 2006, total sales were 183.08 million units. 

 **Sports** genre released Wii Sports which dominated the gaming market at  41.36 million units sold. This is one of many Wii games that performed well. An analysis of platform and technology evolution will be covered in a later section.


![image](https://user-images.githubusercontent.com/115379520/198163823-d8b4822e-305e-4de0-a1d5-214209559eae.png)

<br>


In 2008/2009, video game sales hit its peak with 241.46 million units sold. Unfortunately, the US housing crisis tanked the ecomony causing all sales to drop dramitically. The result of financial hardship caused consumers to prioritze their spending on economic recovery and survival. Thus, leading to less sales in entertainemnt products such as video games.

![image](https://user-images.githubusercontent.com/115379520/198164149-4abe08fd-e260-4de5-bd20-929f1c7010da.png)

<br>

### Top Performing Consoles by Platform Producers
---

Upon viewing top level data of Platform Producers, there are three clear cut performers: Nintendo, Sony, and Microsoft with 1.11 billion
1.050 billion and  680.44 million sales respectively. A possible reason why Nintendo and Sony have the highest cumulative sales could be a result from their long history in the video game industry. Obviously the longer a company is in an industry, the more sales it is expected to have.

When segmenting the data and viewing the top perfoming consoles overall; the top three werethe  Microsoft XBOX 360, Nintendo Wii and Sony Playstation were 470.1, 392.5 and 390.2 million respectively. Now the sales could be a result of advancement in technoloy, peripherals and console exclusive games. For instance, the Wii was the first console to integrate motion and physically activity into gameplay. On the other hand the XBOX360 optimized its controller making it a better and more optimized gaming experince for the consumer. Lastly for console exclusive games, franchise cornerstones like Halo and Mario heavily contribute to the decision of which console to purchase. This will be explored as I iterate through the data over time.


Note, this data was gathered by quering and filtering for the top 5 performing genres. 

<details>
<summary>SQL Code: NA Sales by Platform Producer</summary>
<pre>

-- Platform_Producer Analysis to see how sales are broken down by technological advances

SELECT Platform_Producer, SUM(NA_Sales) na_sales
FROM video_game_sales.dbo.copygames
WHERE Genre IN ('Action', 'Sports', 'Shooter','Platform', 'Misc')
GROUP BY Platform_Producer
ORDER BY na_sales DESC
-- since SNK and NEC had zero or negligibale sales  for NA market we will exclude these companies from our analysis,
-- panasonic an bandai did not release their console to NA


-- Platform_Producer sales over time

SELECT  Year_of_Release, Platform_Producer, SUM(NA_Sales) na_sales
FROM video_game_sales.dbo.copygames
WHERE Genre IN ('Action', 'Sports', 'Shooter','Platform', 'Misc')
GROUP BY Platform_Producer, Year_of_Release
ORDER BY Year_of_Release, na_sales DESC


-- Platform_Producer, Ordered by console sales

SELECT  Platform_producer, Platform, SUM(NA_Sales) na_sales
FROM video_game_sales.dbo.copygames
WHERE Genre IN ('Action', 'Sports', 'Shooter','Platform', 'Misc')
GROUP BY Platform_producer, Platform
ORDER BY na_sales DESC


-- Platform_Producer, Ordered by console sales OVER TIME

SELECT  Platform_producer, Platform, SUM(NA_Sales) na_sales
FROM video_game_sales.dbo.copygames
WHERE Genre IN ('Action', 'Sports', 'Shooter','Platform', 'Misc')
GROUP BY Platform_producer, Platform
ORDER BY na_sales DESC

</pre>
</details>

![image](https://user-images.githubusercontent.com/115379520/198402506-cd1becd4-3bd6-4165-8d3f-5639972ea573.png)


<br>

### Yearly Breakdown of Sales by Platform Producers
---

<br>

In this section, I will organize the data based on Platform Producer and see how console releases influenced NA sales over time. This will guage how the advancement of technology influenced sells.

Below is a brief snapshot of how games sales over time. From the diagram, Sony, Mircosoft and Nintendo are the clear leaders in Console producers. As I drive deeper into this data, I will show how these companies became the top console producers in terms of sales.

<details>
<summary>SQL Code: Platform Producer Growth Rate</summary>
<pre>

DROP TABLE IF EXISTS #growth_YoY_plat
CREATE TABLE #growth_YoY_plat
	(
	release_year FLOAT,
	Platform_Producer NVARCHAR(255),
	na_sales FLOAT,
	previous_year FLOAT, 
	previous_sales FLOAT,
	YoY_Growth_rate FLOAT
	)

WITH cte_growth_rate AS 
	(
	SELECT Year_of_Release, Platform_Producer,  SUM(NA_Sales) na_sales
	FROM video_game_sales.dbo.copygames 
	WHERE genre IN ('Action', 'Sports', 'Shooter','Platform', 'Misc')
	GROUP BY Platform_Producer, Year_of_Release
    )


INSERT INTO #growth_YoY_plat
SELECT 
	*,
	LAG(Year_of_Release) OVER(PARTITION BY Platform_Producer ORDER BY Year_of_Release) previous_year,
	LAG(na_sales) OVER(PARTITION BY Platform_Producer ORDER BY Year_of_Release) previous_sales,
	((na_sales/NULLIF(LAG(na_sales) OVER(PARTITION BY Platform_Producer ORDER BY Year_of_Release),0) ) - 1 ) * 100  growth_rate
FROM cte_growth_rate
ORDER BY Platform_Producer, Year_of_Release   



SELECT release_year, Platform_Producer, SUM(YoY_Growth_rate) growth_rate
FROM #growth_YoY_plat
WHERE YoY_Growth_rate > 100
GROUP BY release_year, Platform_Producer
ORDER BY release_year


</pre>
</details>


<details>
<summary>SQL Code: Console Sales Over Time</summary>
<pre>

WITH cte_yoy AS (
		SELECT release_year, SUM(YoY_Growth_rate) growth_rate
		FROM #growth_YoY_plat  
		WHERE YoY_Growth_rate > 100
		GROUP BY release_year
),

cte_console AS (
	SELECT
	Year_of_Release, 
	Platform_Producer,
	Platform, 
	SUM(NA_Sales) na_sales
FROM video_game_sales.dbo.copygames
WHERE  Genre IN ('Action', 'Sports', 'Shooter','Platform', 'Misc')
GROUP BY
	Year_of_Release, 
	Platform_Producer,
	Platform
)


SELECT 
	Year_of_Release, 
	Platform_Producer,
	Platform, 
	SUM(na_Sales) OVER(PARTITION BY Year_of_Release ) yearly_sales,
	SUM(na_Sales) OVER(PARTITION BY Year_of_Release, Platform_Producer ORDER BY Platform_Producer) yearly_platform_producer_sales,
	SUM(na_Sales) OVER(PARTITION BY Year_of_Release, Platform_Producer, Platform ORDER BY Platform_Producer) Console_sales
FROM cte_console, cte_yoy
WHERE Year_of_Release IN (cte_yoy.release_year) 
ORDER BY Year_of_Release, yearly_platform_producer_sales DESC, Console_sales DESC

</pre>
</details>

<br>

![image](https://user-images.githubusercontent.com/115379520/198195600-8f81842e-e064-4c7e-8aec-bdf6b7b2e6a6.png)

<br>

In 1981, Atari sales peaked at 30.44 million from the console Atari 2600. The Atari 2600 was realeased in 1977 which popularized microprocessor-based hardware and games stored on swappable ROM cartridge. This advancement in technology allowed for more advanced gameplay and graphics compared to older generation consoles

![image](https://user-images.githubusercontent.com/115379520/198205333-e0c84d12-af30-4496-b3de-dbc978bd5121.png)

<br>


In 1984, Nintendo reached 30.3 million  sales. This is due to the release of the Nintendo Entertainment System (NES)/ Famicom. This console is an 8-bit system which is a substantial upgrade over its competitor, the Atari 2600. Thus, allowing Nintendo to take the 'crown' as  the king of platform producers 

In 1990, Nintendo  made 16.8 million sales and released both the SNES concole and the handheld Game Boy. These new innovations in a portable system and new 16-bit console helped maintain its complete dominance in the gaming space until 1992.

In 1992, the Sega Genesis had 6.2 million games sold compared to 8.3 million games sold for Nintendo. This was developed in 1988 as a competitor to Nintendo gaming systems. Thus, causing the dip in sales.

![image](https://user-images.githubusercontent.com/115379520/198210592-c38236eb-b937-4854-92f2-d0a809c10881.png)

<br>

In 1998, the total game sales in NA were 71.8. With the release of the Playstation Station in 1994, Sony entered into the video game market eventually overtaking Nintendo in game sales. This lead to a fierce competition between the two comnpanies with each trying to develop the better system to control market share. Another point to note is that many games on Sony and Nintendo consoles are platform exclusive. Thus, forcing the consumer to pick between consoles.

In 2002, there was a total of 146.8 million sales. Though Sony remained 'king', a new contender came in the form of Mircosoft's XBOX. This system experienced rapid growth and popularity in part due to the advanced console and the console exclusive release of Halo


![image](https://user-images.githubusercontent.com/115379520/198214712-83ea7823-1088-4072-a452-854cc4410c01.png)


<br>


In 2007, the total sales were 211.2 million. Nintendo reclaimed its crown as 'king' and dominated the market with a cumilative NA sales of 107 million.
This was followed by Sony who released the PS3 in 2006 with NA sales of 58.8 million. Then finally Microsoft who released the XBOX360 in 2005 wih NA sales of 45.4 million.

![image](https://user-images.githubusercontent.com/115379520/198217275-ae52da9a-043a-4aae-9134-49b84e31d0d5.png)


<br>

In 2008/2009, the housing crisis occured which tanked the economy causing NA sales to plummet overall. The exception to this was Mircosoft's XBOX360 which  overtook Nintendo in 2010 as the new 'king' of the consoles.

In 2013, the total sales in NA was 125.8 million. In the very same year, both Microsoft and Sony released the XBOX ONE and PS3 respectively. While Nintendo released the Wii U in 2012, which was considered to be a commercial flop.



![image](https://user-images.githubusercontent.com/115379520/198219507-f0227c3f-1d06-44f3-84a4-f786d9efbc60.png)


<br>


### Top 3 Publishers by Game Titles
---

From exploring the data, there are three publishers that have the highest game sales by far. These are Nintendo, Electronic Arts (EA) and Activision with
492.8, 418.05, and 373.5 million sales units respectively.

When inspecting the data, these publishers all had one thing in common; they all published notable game franchises. These game franchises include Mario for Nintendo, Madden NFL for EA and Call of Duty for Blizzard. With the brand power each game has and the loyal fanbase, it was easier to market and generate sales per release of an associated title.


<details>
<summary>SQL Code: Top 3 Publishers in NA Sales</summary>
<pre>

-- Publishers Analysis: General Overview of Top 10 Publishers

SELECT Publisher, SUM(NA_Sales) na_sales
FROM video_game_sales.dbo.copygames 
WHERE  Genre IN ('Action', 'Sports', 'Shooter','Platform', 'Misc')
GROUP BY Publisher 
ORDER BY  na_sales DESC
OFFSET 0 ROWS
FETCH NEXT 10 ROWS ONLY


-- Publishers Analysis by game title

WITH cte_pub AS 
(
	SELECT Publisher, Name , SUM(NA_Sales) na_sales
	FROM video_game_sales.dbo.copygames 
	WHERE  Genre IN ('Action', 'Sports', 'Shooter','Platform', 'Misc') AND Publisher IN ('Nintendo', 'Electronic Arts','Activision')
	GROUP BY Publisher, Name    
)
SELECT * , SUM(na_sales) OVER(PARTITION BY Publisher) pub_sale
FROM cte_pub
ORDER BY pub_sale DESC, na_sales desc


</pre>
</details>


![image](https://user-images.githubusercontent.com/115379520/198417958-42cd6756-d4b5-444c-823b-79d69e3ea92a.png)


![image](https://user-images.githubusercontent.com/115379520/198417878-b8709b16-93ac-4bcd-a021-5bbfc15a6459.png)

<br>

## Conclusions 

<br>

### Insights Summary ###
---

Overall, there are many factors that are involved in the success and growth of video game sales. To answer this, recall the list of questions directly below which were mentioned in a previous section.

- Why does Nintendo have the best individual performing game sales in NA?
- Is it due to technological advances?
- Is it due to console specific game franchises?
- How do the sales change over time?
- What other factors influences sales?
- How does its competition compare? 

Using these questions as a guideline, I will explain the factors involved with growth in game sales in NA. The top performing plaform producers were Nintendo, Sony and Microsoft at 1.11 billion, 1.050 billion and 680.44 million sales repectively. This order is due to the difference in initial presense in the video game industry. Being the earliest, Nintendo debuted its first console as the NES in 1983. While Sony debuted the PlayStation in 1994 and Microsoft debuted the XBOX in 2000. Given that Nintendo had more time in the video game market, it stands to reason why it has the highest cumulative video game sales compared the to other platforms producers. 

While Nintendo has the most sales out of all the console producers, it would be remiss not to mention the growth of its competitors. Specifically, how these companies grew their sales to the point where it contends wilth Nintendo. These two factors are the release of notable game IPs and the advancement of technology for consoles. 

Regarding the release of game titles, the overall volume and quality of video games increased dramatically over the years. This of course, boosted sales in the NA region. From 1980 - 2016, many well known game franchises were created and released. These franchises built up a reputation and a loyal fanbase leading to repeated sales over time.  Nintendo, EA and Activison became the top 3 game publishers in NA due having released the most games from well known IPs. From viewing the games sales based on genre,  it revealed how the preference for game type changed over time. Platform games were intially the best selling genre, but started to lose its status as top performing as time progressed. The sports genre in particular used real life events to help promote and market their product. By making games based on actual people or events, it drew in a new audience of consumers and provided an easy gateway into the gaming space. Ultimately, each genre did grow in sales by releasing a greater varity of game titles which have now become staple franchies. Furthermore, an advancement in platform technology allowed for better and more options.

Over time, the competition of console producers incentivized the development of better gaming systems. This increased games sales as the improvements resulted in better gameplay and graphics. From 8-bit systems to full on computer like hardware, consoles have come a long way in its efforts to become the primary source of entertainment. Introducing new technology can change the way games can be experienced and expand upon a wider audience. With the creation of the Game Boy in 1989, handheld gaming became possible which allowed consumers to play on the go. Another example of innovation driving sales is the Wii which involved the implementaion of motion into gameplay. This console allowed for different kinds of games to be produced while providing a unique gaming experince for the consumer. Aside from the obvious ways of how technology improvement boosts sales, minute details suchs as peripherals came greatly enhance consumer satisfaction; the XBOX 360 achieved this with its ergonomic controller.


<br>

### Reccomendations ###
---

To boost the amount sales in the NA market, it is imperative to increase the quality of game titles and the technology of the consoles.

- For game titles, other than the obvious answers like making more games or improving gameplay and graphics; there are other avenues in which companies can improve in. As seen with the success in the sports genre, there is merit to collaborating and involving live events and famous people. **My reccomendation** is that game companies should collaborate more with people who produce content related to the released games. For instance, twitch and youtube streamers 
already have a large following of fans. Giving them a free copy of a game or a beta version will expand audience reach and act to promote the game. Thus, potentially converting an entire community into potential consumers. 

- For improving console technology, research and development will act to expand on the type of games that can be played. **My reccomedation** is to put more resources into innovative technology that is not readily used by current consumers; an example of this is Virtual Reality (VR). Aside from the lack of games in the VR genre, there is a huge barrier to engaging in this genre. That is the fact that a VR headset is expensive and uncomfortable to wear. Improvements in such peripherals will act to enhance customer satisfaction and loyalty.

- As we enter the digital age, more and more is done online. **My reccomedation** is to improve connectively in games and provide a way for consumers to communicate with each other. This helps build a sense of community in the games which can boost gaming retention time and customer loyalty.

<br>

## Future Considertaions 

There are many other areas that I could explore or analyze from here:

- Since this data stops at 2016, it would be interesting to see how game sales how changed over time. For example, how events like COVID-19 lockdowns affected the sales of games.

- From the early 2010s, smartphones have become increasingly more prevalent with more people playing mobile games. Thus, another point of research would be to see how the sales of handheld gaming consoles have changed.

- Due to the limitations of the dataset, there is no data on age. So doing an analysis on sales by consumer age will give insight into the target demongraphic

- Another limitation is that there are no profit,revenue or costs measures, making it harder to see the value of a game. Despite a game having low sales, it could very well be more profitable than a game with higher sales. To expand on that, certain games may have upkeep costs associated with the game such as server maintenance and bug patches. Likewise, it would be interesting to see how profitable 'free-to play' games are despite having no sales. This would be research into how the games are monetized and the impact of their various methods: cosmetics, gacha, lootboxes, subscriptions, etc.





