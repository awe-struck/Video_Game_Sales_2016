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

### Top Performing Games

---

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


### Yearly Breakdown by Game Title Releases
---

To make it easier to view changes overtime, I calculated YoY growth rate to quantify changes and observe any noticable trends. Then I sorted by year and filtered for hight YoY rates to isolate for those high performing years.

```
Year over Year Growth = (Current Period Value ÷ Prior Period Value) – 1
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


-- Year over Year Growth = (Current Period Value ÷ Prior Period Value) – 1
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

<br>

![image](https://user-images.githubusercontent.com/115379520/197959005-6afa424e-e6ec-4ecb-958c-948b31b53eeb.png)

<br>

In 1984 and 1985, total sales were 30.29 and 32.4 million  units respectively.

- **Shooter** genre shattered 1984 sales records with the release of Duck Hunt which made 25.93 million sales. This was around 85% of the year's total sales

- **Platform** genre soon followed up and the shattered sales records once more. The gaming world was forever changed with the introduction of the Super Mario Bros in 1985. This game made with the release of Duck Hunt which made 29.08 million sales. This was around 90% of the year's total sales


<br>

![image](https://user-images.githubusercontent.com/115379520/197963637-8a399042-05ff-4496-81ff-1d34e95fbd28.png)

<br>

In 1988,1989 and 1994 total sales by genre were  19.33 million, 18.61 million and 23.15 million units respectively

- **Platform** genre released more games from the Donkey Kong and Mario franchise. This helped establish dominance in the platformer genre with a collective 10.39 million sales. This genre is the clear cut top performer in this era. This can be attributed to the success of the Mario franchise with their games being a sensational smash hit.

<br>

![image](https://user-images.githubusercontent.com/115379520/198145406-88921f24-b05f-42fc-9853-212eee486207.png)


<br>

In 1996-1998, total sales were 39.6, 59.04 and 73.04 million units. All the genres started to pick up traction as multiple well known and popular game IPs had been created or released. Overall, a higher quality and greater volume of game titles were being released during these years.



- **Platform** genre released multiple games that are considered famous in modern times. These include Crash Bandicoot, Donkey Kong, Megaman, Kirby and etc.

- **Sports** genre had a massive spike in sales with a higher quantity and volume of games. This lead to overtaking **platform** as the top performing in sales. In this period, games based on sports leagues started to come out. Some of these games include NBA Live, NHL Live and Madden NFL. These games drew in a new audience of sports fans who now had a gateway into the video game medium. Furhermore, the excitemnt and narritaves of real life sports also helped in driving sales. For instance, during this period Michael Jordan had come out of retirement and performed a three-peat. The extra attention from this historic sports moment spilled over to other mediums. With the end result of increasing sales of associated products. The key take away here is that there is value in associating games to other mediums and real life events. All of which has the benefit of promoting the products to a loyal fanbase and increasing general visablity. Additionally, this can serve as a method to ease someone in who is not familiar with the medium. 

- **Action** genre also had a massive sales increased that overtook the **platform** genre. Notable IPs include Tomb Raider, Resident Evil and Starwars

- **Shooter** genre had the smash hits Golden Eye: 007, Half-Life and Starfox come out in 1997. This lead to the genre matching **action** and **sports** in sales.

- **Misc** genre experienced huge growth in sales yet was still at the bottom of sales for genre. Digging into the data, there were was a higher volume of games causing the increase in sales.






<br>



<br>


<br>
<br>


<br>

<br>


### Yoy growth - platofrom and technoloy inducing growth and dips
---




### how do publishers impact sales: make tree map of the type of games the it publiehse
---

make note of popular game titles and franches


## Conclusions / Recommednations

it would be great if i had access to revnue/costs so i can see the profitabiliyu of the games. See how profitiable games are after intial sells
ie.) are they any upkeep costs associated with the game like server maintence and bug patches

likewise it would be interesting to see how profitable 'free-to play' games are despite not having any sales
- see how their games are monetized: cosmetics, gacha, lootboxes, subscriptions, etc


For future research, it would be interesting to consider how covid lockdown has boosted certain games like among us
as it encourages collaboration in a time where people cannot physically gather.

it would be interesting to see how pc game sales develop as platforms such as steam providing discounted games and esports being more prevalent now adays

also interesting in how handheld games change over time


paid sponsorship and infflunecrs
and more appeling to a general audience
can help expand reach and make game more appealing to srrat


## Future directions

## Limitations

## Footer/references



