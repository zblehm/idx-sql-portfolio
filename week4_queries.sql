-- ============================================================ 
-- IDX Exchange — SQL Training
-- Week 4: Queries 
-- Tables: rets_property, rets_openhouse
-- Author: Zachary Blehm 
-- ============================================================ 

-- Summary
-- ============================================================
/* Week 4 Deliverables
 * 
 * Q1 Top 10 cities by most open houses scheduled
 * City					total_open_houses
 * ----					-----------------
 * Los Angeles			993
 * San Diego			559
 * San Jose				413
 * Irvine				343
 * Long Beach			158
 * Oakland				141
 * Huntington Beach		134
 * Riverside			125
 * Temecula				113
 * Palm Springs			111
 * 
 * Q2 Most popular day of the week for open houses
 * Day			num_open_houses
 * ---			---------------
 * Saturday		7300
 * Sunday		6730
 * Friday		777
 * Tuesday		134
 * Wednesday	61
 * Thursday		48
 * Monday		38
 * 
 * Q3 Top 10 listings with the most open houses
 * There is no listing with more than 1 open house.
 * 
 * 
 * Q4 How many listings have zero open houses?
 * There are 41,010 listings without an open house.
 * 
 * Q5 Do higher-priced listings have more open houses on average?
 * Yes, we see a higher percentage of open houses for listings
 * with higher prices based on price quartiles.
 * 
 * price quartile		% with open house
 * --------------		-----------------
 * 1					10.4
 * 2					23.2
 * 3					32.5
 * 4					32.5
 * 
 * Week 4 Open-Ended Challenge
 * "We're thinking about hosting our own open house events on 
 * weekends but only in cities where open house activity is 
 * already high. Which cities and days should we target?"
 * 
 * I would recommend Los Angeles, San Diego and San Jose.
 * 
 * This recommendation is based on considering open house activity
 * both in terms of total number of open houses per city and also
 * in terms of percent of listing with an open house per city. The results
 * suggested that the former (total listings) was the proper metric
 * given that a city with a much higher percentage could have far fewer
 * listings.
 * 
 * Additionally the data for each city was grouped in two ways, first by
 * home price quartiles (e.g. quartile 1 are the 25% cheapest homes
 * and quartile 4 are the 25% most expensive homes in rets_property) and
 * second by number of bedrooms (1 to 5 bedrooms considered). 
 * These two groupings allowed for insight into the total number of 
 * listings and helps to ensure a high open house activity at different
 * price levels and for different number of bedrooms.
 * 
 * The results for each city are:
 * 
 * Los Angeles
 * Ranked 2nd for quartile 1, and 1st for quartiles 2, 3, & 4
 * Ranked 1st for total number of listings for all (1-5) number of bedrooms 
 * 
 * San Diego
 * Ranked 1st for quartile 1, 2nd for quartiles 2 & 3 and 4th for quartile 4
 * Ranked 2nd for 1 -3 bedrooms, 4th for 4 bedrooms and 3rd for 5 bedrooms
 * 
 * San Jose
 * Ranked 3rd for quartiles 3 and 4
 * Ranked 3rd for 1-3 bedrooms, 2nd for 4 bedrooms and 4th for 4 & 5 bedrooms
 */
-- ============================================================
-- Exercise 4.1 Listings with Open Houses
SELECT
	p.L_DisplayId,
	p.L_Address,
	p.L_City,
	p.L_SystemPrice,
	o.OpenHouseDate,
	o.OH_StartTime,
	o.OH_EndTime
FROM rets_property AS p
INNER JOIN rets_openhouse AS o
	ON p.L_DisplayId = o.L_DisplayId
ORDER BY o.OpenHouseDate
LIMIT 20;

-- Exercise 4.2 Count Open Houses per Listing
SELECT
	p.L_DisplayId,
	p.L_Address,
	p.L_City,
	p.L_SystemPrice,
	COUNT(o.openHouseDate) AS num_open_houses
FROM rets_property AS p
INNER JOIN rets_openhouse AS o
	ON p.L_DisplayId = o.L_DisplayId
GROUP BY p.L_DisplayId, p.L_Address, p.L_City, p.L_SystemPrice
ORDER BY num_open_houses DESC
LIMIT 20;
-- Results: Duplicated L_DisplayId give 2 openhouses (erroneous) 
-- otherwise num_open_houses = 1 for all rows

-- Exercise 4.3 What Percentage Have Open Houses?
SELECT
	COUNT(DISTINCT p.L_DisplayId) AS total_listings,
	COUNT(DISTINCT o.L_DisplayId) AS listings_with_openhouse,
	ROUND(100.0 * COUNT(DISTINCT o.L_DisplayId) 
			/ COUNT(DISTINCT p.L_DisplayId), 1) AS pct_with_openhouse
FROM rets_property AS p
LEFT JOIN rets_openhouse AS o
	ON p.L_DisplayId = o.L_DisplayId;
-- 24.7% of listings in rets_property have an openhouse listing in rets_openhouse

-- Exercise 4.4 Open House Activity by City
SELECT 
	p.L_City,
	COUNT(DISTINCT p.L_DisplayId) AS total_listings,
	COUNT(o.OpenHouseDate) AS total_open_houses,
	ROUND(100.0 * COUNT(DISTINCT o.L_DisplayId)
			/ COUNT(DISTINCT p.L_DisplayId), 1) AS pct_with_openhouse 
FROM rets_property p 
LEFT JOIN rets_openhouse o 
	ON p.L_DisplayId = o.L_DisplayId 
GROUP BY p.L_City 
HAVING COUNT(DISTINCT p.L_DisplayId) >= 10 
ORDER BY total_open_houses DESC 
LIMIT 20;
-- Top 3 by total_open_house are LA (993), San Diego (559) and San Jose (413)
-- Top 3 by pct_with_openhouse are Arcadia (48.9), Fremont (43.3) and Irvine (43.1)

-- Exercise 4.5 Most Popular Open House Days
SELECT 
	DAYNAME(OpenHouseDate) AS day_of_week,
	COUNT(*) AS num_open_houses 
FROM rets_openhouse 
WHERE OpenHouseDate IS NOT NULL 
GROUP BY DAYNAME(OpenHouseDate), DAYOFWEEK(OpenHouseDate) 
ORDER BY DAYOFWEEK(OpenHouseDate);
-- Top 3 days are Sat (7300), Sun (6730) and Fri (777)


-- Week 4 Debugging Exercise
-- BROKEN: Average list price by city for listings with open houses 
-- Results are higher than expected — why? 
SELECT p.L_City, 
       COUNT(*) AS listing_count, 
       ROUND(AVG(p.L_SystemPrice), 0) AS avg_price 
FROM rets_property p 
INNER JOIN rets_openhouse o 
	ON p.L_DisplayId = o.L_DisplayId 
GROUP BY p.L_City 
ORDER BY avg_price DESC 
LIMIT 15; 

-- Suggested fixed: use COUNT(DISTINCT )
-- But this does not affect the avg_price calculation
-- We expect avg. price to be higher based on the results of Q5 below 
SELECT p.L_City, 
       COUNT(DISTINCT p.L_DisplayId) AS listing_count, 
       ROUND(AVG(p.L_SystemPrice), 0) AS avg_price 
FROM rets_property p 
INNER JOIN rets_openhouse o 
	ON p.L_DisplayId = o.L_DisplayId 
GROUP BY p.L_City 
ORDER BY avg_price DESC 
LIMIT 15; 


-- Week 4 Deliverables
-- Q1 Top 10 cities by most open houses scheduled
SELECT
	p.L_City,
	COUNT(*) AS total_open_houses
FROM rets_property AS p
INNER JOIN rets_openhouse AS o
ON p.L_DisplayId = o.L_DisplayId
GROUP BY L_City
ORDER BY total_open_houses DESC
LIMIT 10;
-- Results: LA (993) to Palm Springs (111)

-- Q2 Most popular day of the week for open houses
SELECT 
	DAYNAME(OpenHouseDate) AS day_of_week,
	COUNT(*) AS num_open_houses,
	ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS percent_of_openhouses
FROM rets_openhouse 
WHERE OpenHouseDate IS NOT NULL 
GROUP BY DAYNAME(OpenHouseDate), DAYOFWEEK(OpenHouseDate) 
ORDER BY num_open_houses DESC;
-- Results: Saturday is the most popular (7300 listings / 48.38% of all open houses)
-- Results: Monday is the least popular (38 listings / 0.25% of all open houses)


-- Q3 Top 10 listings with the most open houses
SELECT
	L_DisplayId,
	COUNT(*) AS total_open_houses
FROM rets_openhouse
GROUP BY L_DisplayId
ORDER BY total_open_houses DESC
LIMIT 10;
-- Results: No more than one open house per listings

-- Q4 How many listings have zero open houses?
SELECT
	COUNT(DISTINCT p.L_DisplayId) AS total_listings_without_openhouse
FROM rets_property AS p
LEFT JOIN rets_openhouse AS o
ON p.L_DisplayId = o.L_DisplayId
WHERE o.L_DisplayId IS NULL
ORDER BY total_listings_without_openhouse DESC;
-- Results: 41,010 listings without an open house 

-- Q5 Do higher-priced listings have more open houses on average?
-- First we look at the approximate quartiles
WITH price_quartiles AS (
	SELECT 
		L_DisplayID,
		NTILE(4) OVER (ORDER BY L_SystemPrice ASC) AS quartile
	FROM rets_property
)
-- Calculate % w/ open house by quartile
SELECT
	quartile,
	ROUND(100.0 * COUNT(DISTINCT o.L_DisplayId)
			/ COUNT(DISTINCT p.L_DisplayId), 1) AS pct_with_open_house
FROM price_quartiles AS p
LEFT JOIN rets_openhouse AS o
ON p.L_DisplayId = o.L_DisplayId
GROUP BY quartile
ORDER BY quartile ASC;
-- Results: Yes, higher priced homes have more open houses (on average)
-- 1st quartile 10.4% openhouse, 
-- 2nd quartile 23.2%, 
-- 3rd and 4th quartiles 32.5%


-- Week 4 Open-ended Challenge
/*
 * "We're thinking about hosting our own open house events on 
 * weekends but only in cities where open house activity is 
 * already high. Which cities and days should we target?"
*/
-- First we look at the approximate quartiles
WITH price_quartiles AS (
	SELECT 
		L_DisplayId,
		L_City,
		NTILE(4) OVER (ORDER BY L_SystemPrice ASC) AS quartile
	FROM rets_property
),
-- Calculate % with open house and total open house by city and quartile
total_open_house_by_city_and_quartile AS (
	SELECT
		p.L_City,
		quartile,
		COUNT(DISTINCT o.L_DisplayId) AS total_open_houses,
		ROUND(100.0 * COUNT(DISTINCT o.L_DisplayId)
				/ COUNT(DISTINCT p.L_DisplayId), 1) AS pct_with_open_house
	FROM price_quartiles AS p
	LEFT JOIN rets_openhouse AS o
	ON p.L_DisplayId = o.L_DisplayId
	GROUP BY p.L_City, p.quartile
	ORDER BY total_open_houses DESC
),
-- Add a ranking for total open house for each quartile
rankings AS (
	SELECT
		L_City,
		quartile,
		total_open_houses,
		pct_with_open_house,
		RANK() OVER 
			(PARTITION BY quartile 
			ORDER BY total_open_houses DESC) AS quartile_rank
	FROM total_open_house_by_city_and_quartile
)
-- Find the top 5 cities for number of open houses for each quartile
SELECT
	L_City,
	quartile,
	total_open_houses,
	pct_with_open_house,
	quartile_rank
FROM rankings
WHERE quartile_rank <= 5
ORDER BY quartile ASC, quartile_rank ASC;
-- LA, San Diego in top 5 for all quartiles
-- San Jose in the top 5 for 3rd and 4th quartile

-- Calculate % with open house and total open house by city and bedrooms 
WITH total_open_house_by_city_and_bedrooms AS (
SELECT
	p.L_City,
	p.L_Keyword2 AS bedrooms,
	COUNT(DISTINCT o.L_DisplayId) AS total_open_houses,
	ROUND(100.0 * COUNT(DISTINCT o.L_DisplayId)
			/ COUNT(DISTINCT p.L_DisplayId), 1) AS pct_with_open_house
FROM rets_property AS p
LEFT JOIN rets_openhouse AS o
ON p.L_DisplayId = o.L_DisplayId
WHERE p.L_Keyword2 BETWEEN 1 AND 5
GROUP BY p.L_City, p.L_Keyword2
),
-- Add a ranking for total open house for each number of bedrooms
rankings AS (
	SELECT
		L_City,
		bedrooms,
		total_open_houses,
		pct_with_open_house,
		RANK() OVER 
			(PARTITION BY bedrooms 
			ORDER BY total_open_houses DESC) AS bedrooms_rank
	FROM total_open_house_by_city_and_bedrooms
)
-- Find the top 5 cities for number of open houses for each number of bedrooms
SELECT
	L_City,
	bedrooms,
	total_open_houses,
	pct_with_open_house,
	bedrooms_rank
FROM rankings
WHERE bedrooms_rank <= 5
ORDER BY bedrooms ASC, bedrooms_rank ASC;
-- LA, San Diego and San Jose are all in top 5 for each of 1-5 bedrooms
