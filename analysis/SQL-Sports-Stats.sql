/* 
 * This SQL script processes Olympic Games data to create various insights and tables.
 * It includes cleaning the data, aggregating athlete demographics, medal counts, and team performances.
 */

/* Creating a new table with cleaned data */
CREATE TABLE olympic_games AS 
-- CTE used to combine the regions and the notes column of the noc_region table 
WITH team_name AS 
(
    SELECT
        noc_region.noc,
        CASE 
            WHEN noc_region.notes IS NOT NULL AND noc_region.notes != 'NULL'
                THEN CONCAT(noc_region.region, ' (', noc_region.notes, ')')
            ELSE noc_region.region
        END AS country
    FROM noc_region
)

-- Cleaning the team column to ensure the appropriate name with no numbers, the correct country from the CTE adjusted noc_region table, appropriate null values for age/height/weight to allow for appropriate aggregation
SELECT
    REGEXP_REPLACE(ae.team, '-[0-9]+', '') AS cleaned_team,
    tn.country,
    ae.id,
    CASE WHEN ae.sex != 'NA' THEN ae.sex ELSE 'NULL' END AS sex,
    CASE WHEN ae.age != 'NA' THEN ae.age ELSE 'NULL' END AS age,
    CASE WHEN ae.height != 'NA' THEN ae.height ELSE 'NULL' END AS height,
    CASE WHEN ae.weight != 'NA' THEN ae.weight ELSE 'NULL' END AS weight,
    ae.games,
    ae.sport,
    ae.event,
    ae.medal
FROM athlete_events ae
INNER JOIN team_name tn 
ON ae.noc = tn.noc;

/* QUESTION 1: Creating a new table to show which teams have the most athlete representation by games */
CREATE TABLE team_by_games AS
SELECT
    country, 
    games, 
    COUNT(DISTINCT id) AS athlete_count,
FROM olympic_games
GROUP BY 
    country, 
    games
ORDER BY games DESC, athlete_count DESC;

/* QUESTION 2A: Creating a new table to show which teams have the most medals over the entire reporting years of the dataset */
CREATE TABLE medals_total AS
SELECT
    country, 
    COUNT_IF(medal != 'NA') as total_medal_count,
    COUNT_IF(medal = 'Gold') as gold_medal_count,
    COUNT_IF(medal = 'Silver') as silver_medal_count,
    COUNT_IF(medal = 'Bronze') as bronze_medal_count
FROM olympic_games
GROUP BY 
    country
ORDER BY total_medal_count DESC;

/* QUESTION 2B: Creating a new table to show which teams have the most medals broken down by the games */
CREATE TABLE medals_by_games AS
SELECT
    country, 
    games,
    COUNT_IF(medal != 'NA') as total_medal_count,
    COUNT_IF(medal = 'Gold') as gold_medal_count,
    COUNT_IF(medal = 'Silver') as silver_medal_count,
    COUNT_IF(medal = 'Bronze') as bronze_medal_count
FROM olympic_games
GROUP BY 
    country,
    games
ORDER BY total_medal_count DESC;

/* QUESTION 3A: Creating a new table to show the average demographics for each year of the games */
CREATE TABLE demo_by_games AS
SELECT
    games,
    TRUNC(AVG(CASE WHEN sex = 'M' AND age NOT IN ('NULL', '') THEN CAST(age AS FLOAT) END),1) AS mean_age_male,
    TRUNC(AVG(CASE WHEN sex = 'F' AND age NOT IN ('NULL', '') THEN CAST(age AS FLOAT) END),1) AS mean_age_female,
    TRUNC(AVG(CASE WHEN sex = 'M' AND height NOT IN ('NULL', '') THEN CAST(height AS FLOAT) END),1) AS mean_height_male,
    TRUNC(AVG(CASE WHEN sex = 'F' AND height NOT IN ('NULL', '') THEN CAST(height AS FLOAT) END),1) AS mean_height_female,
    TRUNC(AVG(CASE WHEN sex = 'M' AND weight NOT IN ('NULL', '') THEN CAST(weight AS FLOAT) END),1) AS mean_weight_male,
    TRUNC(AVG(CASE WHEN sex = 'F' AND weight NOT IN ('NULL', '') THEN CAST(weight AS FLOAT) END),1) AS mean_weight_female
FROM olympic_games
GROUP BY games
ORDER BY games DESC;

/* QUESTION 3B: Creating a new table to show the average demographics for each year of the games by team*/
CREATE TABLE demo_by_team_by_games AS
SELECT
    country,
    games,
    TRUNC(AVG(CASE WHEN sex = 'M' AND age NOT IN ('NULL', '') THEN CAST(age AS FLOAT) END),1) AS mean_age_male,
    TRUNC(AVG(CASE WHEN sex = 'F' AND age NOT IN ('NULL', '') THEN CAST(age AS FLOAT) END),1) AS mean_age_female,
    TRUNC(AVG(CASE WHEN sex = 'M' AND height NOT IN ('NULL', '') THEN CAST(height AS FLOAT) END),1) AS mean_height_male,
    TRUNC(AVG(CASE WHEN sex = 'F' AND height NOT IN ('NULL', '') THEN CAST(height AS FLOAT) END),1) AS mean_height_female,
    TRUNC(AVG(CASE WHEN sex = 'M' AND weight NOT IN ('NULL', '') THEN CAST(weight AS FLOAT) END),1) AS mean_weight_male,
    TRUNC(AVG(CASE WHEN sex = 'F' AND weight NOT IN ('NULL', '') THEN CAST(weight AS FLOAT) END),1) AS mean_weight_female
FROM olympic_games
GROUP BY 
    country,
    games
ORDER BY games DESC, country ASC;

/* QUESTION 4A: Creating a new table to show which teams is the top performers in each event with total medal count over the years of the dataset, excluding countries where no medals were won, as well as a medal breakdown */
--CREATE TABLE event_top_performers AS
WITH medal_counts AS
(
SELECT
    event,
    country,
    COUNT_IF(medal != 'NA') as total_medal_count,
    COUNT_IF(medal = 'Gold') as gold_medal_count,
    COUNT_IF(medal = 'Silver') as silver_medal_count,
    COUNT_IF(medal = 'Bronze') as bronze_medal_count
FROM olympic_games
GROUP BY 
    event,
    country
)

SELECT *
FROM medal_counts
WHERE total_medal_count > 0
ORDER BY event, total_medal_count DESC;

/* QUESTION 4B: Creating a new table to show which teams is the top 3 performer in each event with total medal count over the years of the dataset, as well as a medal breakdown */
CREATE TABLE event_top_performers_top_3 AS
SELECT
    event,
    country,
    COUNT_IF(medal != 'NA') as total_medal_count,
    COUNT_IF(medal = 'Gold') as gold_medal_count,
    COUNT_IF(medal = 'Silver') as silver_medal_count,
    COUNT_IF(medal = 'Bronze') as bronze_medal_count
FROM olympic_games
GROUP BY 
    event,
    country
QUALIFY RANK() OVER (PARTITION BY event ORDER BY COUNT_IF(medal !='NA') DESC) <= 3
ORDER BY event, total_medal_count DESC;

/*Creating a new metric, BMI, calculated as (weight/(height/100)^2)*/
WITH BMI_calculator AS
(
SELECT 
    id,
    games,
    year,
    sex,
    TRUNC(CASE WHEN sex = 'M' AND height NOT IN ('NA', '') THEN CAST(height AS FLOAT) END,1) as male_height,
    TRUNC(CASE WHEN sex = 'M' AND weight NOT IN ('NA', '') THEN CAST(weight AS FLOAT) END,1) as male_weight,
    ROUND(male_weight/(SQUARE(male_height/100)), 1) as male_BMI,
    TRUNC(CASE WHEN sex = 'F' AND height NOT IN ('NA', '') THEN CAST(height AS FLOAT) END,1) as female_height,
    TRUNC(CASE WHEN sex = 'F' AND weight NOT IN ('NA', '') THEN CAST(weight AS FLOAT) END,1) as female_weight,
    ROUND(female_weight/(SQUARE(female_height/100)), 1) as female_BMI
FROM
    athlete_events
ORDER BY id
)

/* Statement examining the correlation between the year of the games and the BMI to determine relationship 
SELECT
  CORR(year, male_BMI) AS games_male_BMI_corr,
  CORR(year, female_BMI) AS games_female_BMI_corr
FROM BMI_calculator
WHERE male_BMI IS NOT NULL OR female_BMI IS NOT NULL;*/

/*Statement shows the average BMI for male and female olympians for each game*/
SELECT 
    games,
    ROUND(AVG(CASE WHEN male_BMI IS NOT NULL THEN CAST(male_BMI AS FLOAT) END),1) as average_male_BMI,
    ROUND(AVG(CASE WHEN female_BMI IS NOT NULL THEN CAST(female_BMI AS FLOAT) END),1) as average_female_BMI
FROM
    BMI_CALCULATOR
GROUP BY
    games
ORDER BY
    games;

/* Statement examining the correlation between age and medals during the entire games */
SELECT
  CORR(CAST(age AS FLOAT), CASE
    WHEN medal = 'Gold' THEN 3
    WHEN medal = 'Silver' THEN 2
    WHEN medal = 'Bronze' THEN 1
    ELSE 0 END
  ) AS age_medal_corr
FROM olympic_games
WHERE age IS NOT NULL
  AND age NOT IN ('NULL', 'NA', '')
  AND TRY_CAST(age AS FLOAT) IS NOT NULL;

/* Statement examining the relationship between medal count and team size */
WITH country_stats AS (
  SELECT
    country,
    games,
    COUNT(DISTINCT id) AS team_size,
    COUNT_IF(medal IS NOT NULL AND medal NOT IN ('NA', '')) AS total_medals
  FROM olympic_games
  WHERE country IS NOT NULL 
  GROUP BY country, games
)

SELECT
  *,
  CORR(team_size, total_medals) OVER () AS team_size_medal_corr
FROM country_stats
ORDER BY total_medals DESC;

/* Showing the top 3 performers in each sport with total medal count over the years of the dataset, as well as a medal breakdown */
CREATE TABLE top_3_sport_performance AS
SELECT
    sport,
    country,
    COUNT_IF(medal != 'NA') as total_medal_count,
    COUNT_IF(medal = 'Gold') as gold_medal_count,
    COUNT_IF(medal = 'Silver') as silver_medal_count,
    COUNT_IF(medal = 'Bronze') as bronze_medal_count
FROM olympic_games
GROUP BY 
    sport,
    country
QUALIFY RANK() OVER (PARTITION BY sport ORDER BY COUNT_IF(medal !='NA') DESC) <= 3
ORDER BY sport, total_medal_count DESC;

/* Showing which team has the most top 3 appearances over the years*/
WITH top_3_performers AS
(
SELECT
    sport,
    country,
    COUNT_IF(medal != 'NA') as total_medal_count,
    COUNT_IF(medal = 'Gold') as gold_medal_count,
    COUNT_IF(medal = 'Silver') as silver_medal_count,
    COUNT_IF(medal = 'Bronze') as bronze_medal_count,
    RANK() OVER (PARTITION BY sport ORDER BY COUNT_IF(medal IS NOT NULL) DESC) AS country_rank
FROM 
    olympic_games
GROUP BY 
    sport, 
    country
)

SELECT
  country,
  COUNT(*) AS times_in_top_3
FROM 
    top_3_performers
WHERE 
    country_rank <= 3
GROUP BY 
    country
ORDER BY times_in_top_3 DESC;

SELECT * FROM demo_by_team_by_games;