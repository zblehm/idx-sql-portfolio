-- ============================================================ 
-- IDX Exchange — SQL Training
-- Week 3: Queries 
-- Tables: rets_property
-- Author: Zachary Blehm 
-- ============================================================ 

-- Summary
-- ============================================================
/* Week 3 Deliverables
 * 
 * Q1 Top 10 Cities by highest average list price (min 10 listings each)
 * City				total_listings		avg_price
 * ----				--------------		---------
 * Newport Coast		44				$ 21,571,898
 * Carpinteria			17				$ 18,331,058
 * Atherton				10				$ 14,313,187
 * Hidden Hills			43				$ 13,839,163
 * Montecito			14				$ 12,752,071
 * Hillsborough			21				$ 12,459,381
 * Beverly Hills		277				$ 11,536,705
 * Los Altos Hills		16				$ 11,105,181
 * Santa Ynez			21				$ 10,729,381
 * Rancho Santa Fe		103				$ 10,699,126
 * 
 * 
 * Q2 Top 10 cities by most active inventory
 * City				total_listings
 * ----				--------------
 * Los Angeles		3747
 * San Diego		2283
 * San Jose			985
 * Irvine			795
 * Long Beach		612
 * Palm Springs		601
 * Palm Desert		576
 * Riverside		543
 * Temecula			457
 * Victorville		447
 * 
 * 
 * Q3 Average price per sqft by city - top 15 cities
 * City				avg_price_per_sqft
 * ----				------------------
 * Novato			1500488.24			<-- Skewed by a listing w/ 1 sqft area
 * East Palo Alto	93605.22
 * Mountain View	13673.58
 * Summerland		4558.89
 * La Grange		4153.22
 * Oak Glen			4133.97
 * Carpinteria		3874.53
 * Isla Vista		3063.73
 * Big Sur			2773.65
 * Newport Coast	2746.04
 * Laguna Beach		2700.64
 * Corona Del Mar	2448.51
 * Malibu			2262.80
 * Manhattan Beach	2163.18
 * Montecito		2122.50
 * 
 * 
 * Q4 Listing count at each bedroom count 1 through 6
 * bedrooms		total_listings
 * --------		--------------
 * 1			2858
 * 2			12072
 * 3			18298
 * 4			13182
 * 5			5198
 * 6			1470
 * 
 * 
 * Q5 ZIP codes with average price above $800,000 
 * There are 875 ZIP codes with an average price above $800,000
 * The top 10 most expensive ZIP codes (on average) are:
 * ZIP		avg__price		total_listings
 * -----	----------		--------------
 * 93067	$23,111,250		4
 * 92657	$21,571,898		44
 * 29660	$18,999,999		1
 * 93013	$18,331,058		17
 * 88888	$18,000,000		1
 * 90077	$17,031,289		107
 * 98775	$16,000,000		1
 * 94574	$15,500,000		1
 * 63734	$14,995,000		1
 * 94027	$14,313,187		10
 * 
 * 
 * Week 3 Open-Ended Challenge
 * "We're launching a new ad campaign and want to focus on the three 
 * cities that represent the best opportunity for first-time buyers. 
 * Which cities would you recommend and why?" 
 * 
 * I would recommend 29 Palms, Barstow and Magalia. This recommendation is
 * not based on one specific query, but rather the results of multiple
 * queries that focus on affordability, value and availability 
 * in different ways and seeing these three cities consistently among the 
 * top results. Additionally the three cities together provide affordable
 * options for listings with different number of beds (1, 2, 3 or 4 beds).
 * The specific reason for recommending each city is:
 * 
 * 29 Palms: 
 * 3rd lowest average price for cities with at least 50 listings
 * 8th lowest average price per bedroom for cities with at least 50 listings.
 * Most listings under $300,000 and 3rd most listing under $400,000.
 * Ranked in the top 10 lowest avg price for 1, 2, 3 and 4 bedroom listings
 * (for cities w/ a minimum of 10 listings for each number of bedrooms).
 * 
 * Barstow:
 * 4th lowest average price for cities with at least 50 listings.
 * 5th lowest average price per sqft for cities with at least 50 listings.
 * 2nd lowest average price per bedroom for cities with at least 50 listings.
 * 7th most listings under $300,000 and 10th most listing under $400,000.
 * Ranked in the top 10 lowest avg price for 2, 3 and 4 bedroom listings 
 * (for cities w/ a minimum of 10 listings for each number of bedrooms).
 * 
 * Magalia
 * Lowest average price for cities with at least 50 listings and the
 * only city with at least 50 listing that has an average price < $300,000.
 * Lowest average price per sqft for cities with at least 50 listings.
 * 3rd lowest average price per bedroom for cities with at least 50 listings.
 * Ranked in top 10 lowest avg price for 2 and 3 bedroom listings
 * (for cities w/ a minimum of 10 listings for each number of bedrooms).
 */
-- ============================================================

-- Exercise 3.1 Group BY L_City
SELECT
	L_City,
	COUNT(*) AS total_listings,
	ROUND(AVG(L_SystemPrice), 0) AS avg_price,
	MIN(L_SystemPrice) AS min_price,
	MAX(L_SystemPrice) AS max_price
FROM rets_property
WHERE L_SystemPrice IS NOT NULL
GROUP BY L_City 
ORDER BY avg_price DESC;
-- Summerland has the highest avg list price ($23,111,250) for 4 listings
-- Markleevill has the lowest avg list price ($12,999) for 1 listing

-- Exercise 3.2 Price Per Square Foot
SELECT
	L_City,
	COUNT(*) AS total_listings,
	ROUND(AVG(L_SystemPrice), 0) AS avg_price,
	ROUND(AVG(LM_Int2_3), 0) AS avg_sqft,
	ROUND(AVG(L_SystemPrice / LM_Int2_3 ), 2) AS avg_price_per_sqft
FROM rets_property
WHERE LM_Int2_3 > 0 
	AND L_SystemPrice IS NOT NULL
GROUP BY L_City 
ORDER BY avg_price DESC
LIMIT 20;
-- Newporat Coast has the high avg price per sqft ($2,746.06) for 44 listings
-- Pebble Peach has the 20th highest avg price per sqft ($1,582.87) for 45 listings

-- Exercise 3.3 Having
SELECT
	L_City,
	COUNT(*) AS total_listings,
	ROUND(AVG(L_SystemPrice), 0) AS avg_price
FROM rets_property
WHERE L_SystemPrice IS NOT NULL
GROUP BY L_City
HAVING COUNT(*) >= 10
ORDER BY avg_price DESC
LIMIT 20;
-- Newporat Coast has the high avg price ($21,571,898) for cities w/ >= 10 listings
-- Sanata Barbar hs the 20th highest avg price ($7,159,048) for cities w/ >= 10 listings

-- Exercise 3.4 Inventory by Bedroom Count
SELECT 
	L_Keyword2 AS bedrooms,
	COUNT(*) AS total_listings,
	ROUND(AVG(L_SystemPrice),0) AS avg_price
FROM rets_property
WHERE L_Keyword2 IS NOT NULL 
	AND L_Keyword2 BETWEEN 1 AND 8
GROUP BY L_Keyword2
ORDER BY L_Keyword2 ASC;
-- 1 bedroom homes, 2,858 listings with average price $516,393
-- 8 bedroom homes, 201 listings with average price $10,167,460

-- Week 3 Debugging Exercise
-- BROKEN: Cities with average price above $600k (min 5 listings)
SELECT L_City, 
       COUNT(*) AS total_listings, 
       ROUND(AVG(L_SystemPrice), 0) AS avg_price 
FROM rets_property 
WHERE AVG(L_SystemPrice) > 600000 
  AND L_SystemPrice IS NOT NULL 
GROUP BY L_City 
HAVING COUNT(*) >= 5 
ORDER BY avg_price DESC; 

-- Fixed: moved AVG filter from WHERE to HAVING
SELECT L_City, 
       COUNT(*) AS total_listings, 
       ROUND(AVG(L_SystemPrice), 0) AS avg_price 
FROM rets_property 
-- remove the AVG(L_SystyemPrice) > 600000 from the WHERE clause 
-- Aggregates can't be use in the WHERE (WHERE is before the GROUP BY)
WHERE L_SystemPrice IS NOT NULL 
GROUP BY L_City 
-- use the ACG(L_SystyemPrice) > 600000 in the HAVING clause
HAVING COUNT(*) >= 5 AND AVG(L_SystemPrice) > 600000 
ORDER BY avg_price DESC; 


-- Week 3 Deliverables
-- Q1 Top 10 Cities by highest average list price (min 10 listings each)
SELECT
	L_City,
	COUNT(*) AS total_listings,
	ROUND(AVG(L_SystemPrice),0) AS avg_price
FROM rets_property
WHERE L_SystemPrice IS NOT NULL
GROUP BY L_City 
HAVING COUNT(*) >= 10
ORDER BY avg_price DESC
LIMIT 10;

-- Q2 Top 10 cities by most active inventory
SELECT
	L_City,
	COUNT(*) AS total_listings
FROM rets_property
GROUP BY L_City 
HAVING COUNT(*) >= 10
ORDER BY total_listings DESC
LIMIT 10;

-- Q3 Average price per sqft by city - top 15 cities
SELECT
	L_City,
	ROUND(AVG(L_SystemPrice / LM_Int2_3 ), 0) AS avg_price_per_sqft
FROM rets_property
WHERE LM_Int2_3 > 0 
	AND L_SystemPrice IS NOT NULL
GROUP BY L_City 
ORDER BY avg_price_per_sqft DESC
LIMIT 15;
-- The top result is $1,500,488 per sqft. This is > 10x the second result
-- Investigate the top result further

SELECT
	L_DisplayId,
	L_City,
	L_SystemPrice AS price,
	LM_Int2_3 AS total_sqft,
	ROUND(L_SystemPrice / LM_Int2_3, 0) AS avg_price_per_sqft
FROM rets_property
WHERE L_City = "Novato"
ORDER BY total_sqft DESC;
-- L_DisplayId 1108289005 is listed for $12,000,000 but as 1 sqft for LM_Int2_3
-- This incorrect listing is throwing off the query result from above


-- Q4 Listing count at each bedroom count 1 through 6
SELECT 
	L_Keyword2 AS bedrooms,
	COUNT(*) AS total_listings
FROM rets_property
WHERE L_Keyword2 IS NOT NULL 
	AND L_Keyword2 BETWEEN 1 AND 6
GROUP BY L_Keyword2
ORDER BY L_Keyword2 ASC;


-- Q5 ZIP codes with average price above $800.000
SELECT
	L_Zip,
	ROUND(AVG(L_SystemPrice),0) As avg_price,
	COUNT(*) as total_listing
FROM rets_property
GROUP BY L_Zip 
HAVING AVG(L_SystemPrice) > 800000
ORDER BY avg_price DESC;

-- Count the number of ZIP codes with average price above $800,000
WITH expensive_zips AS (
    SELECT
        L_Zip
    FROM rets_property
    GROUP BY L_Zip
    HAVING AVG(L_SystemPrice) > 800000
)
SELECT COUNT(*) AS num_expensive_zips
FROM expensive_zips;
-- 875 matching ZIP codes


-- Week 3 Open-ended Challenge
-- Ten cities with the lowest avg price and at least 50 listings.
SELECT
	L_City,
	ROUND(AVG(L_SystemPrice),0) AS avg_price
FROM rets_property
GROUP BY L_City
HAVING COUNT(*) >= 50
ORDER BY avg_price ASC
LIMIT 10;
-- Results: Magalia, Clearlake Oaks and 29 Palms in order from lowest.

-- Ten cities with the lowest avg price per sqft and at least 50 listings.
SELECT 
	L_City,
	ROUND(AVG(L_SystemPrice / LM_Int2_3), 0) AS avg_price_per_sqft
FROM rets_property
WHERE LM_Int2_3 > 0
GROUP BY L_City
HAVING COUNT(*) >= 50
ORDER BY avg_price_per_sqft ASC
LIMIT 10;
-- Results: Magalia, California City and Blythe in order from lowest.

-- Ten cities with the lowest avg price per bedroom and at least 50 listings.
SELECT 
	L_City,
	ROUND(AVG(L_SystemPrice / L_Keyword2), 0) AS avg_price_per_bedroom
FROM rets_property
WHERE L_Keyword2 > 0
GROUP BY L_City
HAVING COUNT(*) >= 50
ORDER BY avg_price_per_bedroom ASC
LIMIT 10;
-- Results: California City, Barstow and Magalia in order from lowest.

-- Ten cities with the most listing under $400,000
SELECT
	L_City,
	COUNT(*) AS total_listings
FROM rets_property
WHERE L_SystemPrice < 400000
GROUP BY L_City 
ORDER BY total_listings DESC
LIMIT 10;
-- Results: Hemet, San Diego and 29 Palms in order from most.

-- Ten cities with the most listing under $300,000
SELECT
	L_City,
	COUNT(*) AS total_listings
FROM rets_property
WHERE L_SystemPrice < 300000
GROUP BY L_City 
ORDER BY total_listings DESC
LIMIT 10;
-- Results: 29 Palms, Hemet and Palm Springs in order from most.


-- Cities with the lowest average price for 1, 2, 3 or 4 bedrooms
-- Average price for 1, 2, 3 or 4 bedrooms in each city.
WITH city_averages AS (
    SELECT
        L_City,
        L_Keyword2,
        ROUND(AVG(L_SystemPrice),0) AS avg_price
    FROM rets_property
    WHERE L_Keyword2 IN (1, 2, 3, 4)
    GROUP BY L_City, L_Keyword2
    HAVING COUNT(*) >= 10
),
-- Rank the cities for 1, 2, 3 or 4 bedrooms based on lowest avg. price
ranked_cities AS (
    SELECT
        L_City,
        L_Keyword2,
        avg_price,
        ROW_NUMBER() OVER (
            PARTITION BY L_Keyword2
            ORDER BY avg_price ASC
        ) AS city_rank
    FROM city_averages
)
-- The 10 citites w/ lowest avg. price for 1, 2, 3 or 4 bedrooms
SELECT
    L_Keyword2 AS bedrooms,
    L_City,
    avg_price
FROM ranked_cities
WHERE city_rank <= 10
ORDER BY bedrooms, avg_price;
-- Good information, but very difficult to interpret.
-- 29 Palms in top 10 for 1, 2, 3 and 4 bedrooms
-- Barstow in the top 10 for 2, 3 and 4 bedrooms
-- Maglia, Needles, Clearlake, Clearlake Oaks in top 10 for 2 and 3 bedrooms
-- California City in the top 10 for 3 and 4 bedrooms