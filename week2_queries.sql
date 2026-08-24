-- ============================================================ 
-- IDX Exchange — SQL Training
-- Week 2: Queries 
-- Tables: rets_property
-- Author: Zachary Blehm 
-- ============================================================ 

-- Summary
-- ============================================================
/* Week 2 Deliverables
 * Q1: How many total listings are in rets_property?
 * 54,438
 * 
 * Q2: Top 10 most expensive listing (address, city, price)
 * 
 * 11201 Chalon Road			Los Angeles		$400,000,000
 * 607 Siena Way				Los Angeles		$135,000,000
 * 1261 Angelo Drive			Beverly Hills	$135,000,000
 * 7661 Curson Terrace			Los Angeles		$125,000,000
 * 100 Rockledge Road			Laguna Beach	$112,000,000
 * 1200 Bel Air Road			Los Angeles		$99,950,000
 * 32229 Coast Hwy				Laguna Beach	$95,000,000
 * 729 Bel Air Road				Los Angeles		$95,000,000
 * 28824 Cliffside Drive		Malibu			$90,000,000
 * 26848 Pacific Coast Highway	Malibu			$88,000,000
 * 
 * Q3: All listings with 4+ bedrooms
 * Too many to list here, there are 20,764 listings with 4+ bedrooms in total
 * 
 * Q4: All listing in a Zip code of your choosing
 * These are all the listings for Zip code 96150 ordered by price descending
 * 2366 Highlands Drive			South Lake Tahoe	96150	$2,488,888
 * 644 Tata						South Lake Tahoe	96150	$1,899,000
 * 1528 Chippewa Street			South Lake Tahoe	96150	$1,428,000
 * 3535 Lake Tahoe 505			South Lake Tahoe	96150	$1,185,000
 * 1387 Matheson DR				South Lake Tahoe	96150	$685,000
 * 806 Tahoe Keys Boulevard		South Lake Tahoe	96150	$599,888
 * 
 * Q5: Properties over 3,000 sqft under $1M
 * There are 1,238 listings that are over 3,000 sqft and cost less than $1M
 * Selected results:
 * The cheapest property is 5000 sqft for $16,000 in Atherton
 * The most expensive is 3163 sqft for $999,999 in Bradley
 * The smallest is 3031 sqft for $999.999 in Rancho Cucamonga
 * The largest is 5350 sqft for $999,999 in Big River
 * 
 * Q6: Every distinct City - no duplicates
 * There are 986 distinct cities in ret_property
 * Alphabetically the cities go from 29 Palms to Yucca Valley
 * 
 * Week 2 Open-Ended Challenge
 * Question: "We're putting together a buyer's guide and need to know
 * where the most affordable options are. Can you pull something together?
 * 
 * Think about what 'affordable' means - lowest price? Best value per
 * bedroom? Most listings under a threshold?
 * 
 * This question can be answered in many ways. Below we have first considered a
 * very straightforward answer by finding the 100 cheapest (lowest L_SystemPrice)
 * listing in rets_property. We then consider 'affordable' based on
 * two different factors first price per sqft and second price per bedroom.
 * In each case we find the 100 cheapest homes. We then find the 50
 * cheapest homes by number of bedrooms, considering 1 to 6 bedrooms. This
 * would allow a buyer to see affordable listing with the number of bedrooms
 * that suits their requirements.
 * 
 * Next we notice that the original question asks "where" the most affordable 
 * options are. While we can provide a location for the result generated above, 
 * location information has not been used for grouping/filtering/aggregation. 
 * As the next step of the analysis we group results by different location data 
 * (city or zip level) and find the cheapest options in each location. This
 * is useful for showing one cheap option per city or zip code. However if
 * a buyer that wants to have multiple options in an affordable location further
 * analysis is needed. Therefore as the next step we consider locations that are
 * more affordable overall (lowest average listing price, limited to locations
 * with at least 10 listings) and then generate affordable results within these 
 * locations by considering the cheapest 25% of listings in these locations.
 * 
 * There are other ways to answer this question, but the results produced would
 * provide an initial result set for the sales team to consider and could either
 * be further refined by adding criteria or abandoned for an entirely
 * different interpretation.
 */
-- ============================================================


-- Exercise 2.1 Select Specific Columns
-- Select specific columns from rets_property
SELECT
	L_DisplayId,
	L_Address, 
	L_City,
	L_SystemPrice,
	L_Keyword2,
	LM_Dec_3
FROM rets_property
LIMIT 20;


-- Exercise 2.2 Filterwing with WHERE
-- Properties in a specific city
SELECT
	L_DisplayId,
	L_Address,
	L_SystemPrice,
	L_Keyword2
FROM rets_property
WHERE L_City = 'Irvine'
LIMIT 20;

-- 3+ bedroom homes under $700k
SELECT
	L_Address,
	L_City,
	L_SystemPrice,
	L_Keyword2
FROM rets_property
WHERE L_Keyword2  >= 3
	AND L_SystemPrice < 700000
ORDER BY L_SystemPrice ASC;


-- Exercise 2.3 BTWEEN and LIKE
-- Properties between $400k and $660k
SELECT
	L_DisplayId,
	L_Address,
	L_SystemPrice 
FROM rets_property
WHERE L_SystemPrice BETWEEN 400000 AND 600000
ORDER BY L_SystemPrice 

-- Cities starting with 'San'
SELECT DISTINCT L_City
FROM rets_property
WHERE L_City LIKE 'San%';


-- Exercise 2.4 NULL Handling
-- Listing missing square footage
SELECT
	L_DisplayId,
	L_Address,
	L_City
FROM rets_property
WHERE LM_Int2_3 IS NULL;

-- Listing with square footage, largest first
SELECT
	L_DisplayId,
	L_Address,
	L_City, 
	LM_Int2_3 
FROM rets_property
WHERE LM_Int2_3 IS NOT NULL
ORDER BY LM_Int2_3 DESC 
LIMIT 10;


-- Week 2 Deliverables
-- Q1: How many total listing are in rets_property?
SELECT COUNT(*)
FROM rets_property;
-- 54438 total litstings (rows)

-- Q2: Top 10 most expnsive listing (address, city, price)
SELECT 
	L_Address,
	L_City,
	L_SystemPrice
FROM rets_property
ORDER BY  L_SystemPrice DESC
LIMIT 10;
-- Most expensive is $400,000,000 in LA, 10th is $88,000,000 in Malibu

-- Q3: All listing with 4+ bedrooms
SELECT 
	L_Address,
	L_City,
	L_SystemPrice,
	L_keyword2 AS num_bedrooms
FROM rets_property
WHERE L_Keyword2  >= 4
ORDER BY  L_SystemPrice DESC;
-- Most expensive is $400,000,000 with 39 bedrooms in LA
-- Cheapest is $4399 with 4 bedrooms in Santa Clara

-- Number of listing with 4+ bedrooms
SELECT 
	COUNT(*)
FROM rets_property
WHERE L_Keyword2  >= 4;
-- 20,764 listings with 4+ bedrooms


-- Q4: All listings in a zip code of your choosing
-- The 10 largest zip codes in the table (because I don't know any CA zip codes)
SELECT DISTINCT L_Zip
FROM  rets_property
WHERE L_Zip IS NOT NULL
ORDER BY L_Zip DESC
LIMIT 10;
-- Zip code 96150 is the 10th in the list and seems like a valid zip

SELECT
	L_Address,
	L_City ,
	L_Zip,
	L_SystemPrice
FROM rets_property
WHERE L_Zip = '96150' -- L_Zip is type VARCHAR, so we use single quotes
ORDER BY L_SystemPrice DESC;
-- 6 listing returned. This zip code is in South Lake Tahoe

-- Q5: Properties over 3,000 sqft and under $1M
SELECT
	L_Address,
	L_City ,
	L_Zip,
	LM_Int2_3,
	L_SystemPrice
FROM rets_property
WHERE LM_Int2_3 > 3000
	AND L_SystemPrice < 1000000;
-- Omit an ORDER BY so the result set can be sort in different ways
-- The cheapest property is 5000 sqft for $16,000 in Atherton
-- The most expensive is 3163 sqft for $999,999 in Bradley
-- The smallest is 3031 sqft for $999.999 in Rancho Cucamonga
-- The largest is 5350 sqft for $999,999 in Big River

-- Number of listings over 3,000 sqft and under $1M
SELECT
	COUNT(*)
FROM rets_property
WHERE LM_Int2_3 > 3000
	AND L_SystemPrice < 1000000;
-- 1,238 listing with over 3,000 sqft costing less than $1M

-- Q6: Every distinct city - no duplicates
SELECT
	DISTINCT L_City
FROM rets_property
WHERE L_City IS NOT NULL;
-- Omit an ORDER BY sso the result set can be sort in different ways
-- 29 Palms to Yucca Valley alphabetically

SELECT
	COUNT(DISTINCT L_City)
FROM rets_property;
-- 986 cities


-- Week 2 Debugging Exercise
-- BROKEN: 10 cheapest listings in Irvine with valid price
SELECT 
	L_Address, 
	L_City, 
	L_SystemPrice 
FROM rets_property 
WHERE L_City = Irvine 
  AND L_SystemPrice IS NOT NULL 
ORDER BY L_SystemPrice ASC 
LIMIT '10'; -- Bug 2 there should not be single quotes here (number not text)

-- Corrected version: 10 cheapest listings in Irvine with valid price
SELECT 
	L_Address, 
	L_City, 
	L_SystemPrice 
FROM rets_property 
WHERE L_City = 'Irvine' -- Bug 1 need 'Irvine' in single quotes for string
  AND L_SystemPrice IS NOT NULL 
ORDER BY L_SystemPrice ASC 
LIMIT 10; -- Bug 2 there should not be single quotes for a number


-- Open-Ended Challenge
/* Question: "We're putting together a buyer's guide and need to know
 * where the most affordable options are. Can you pull something together?
 */

-- What are the 100 cheapest listing in rets_property?
SELECT
	L_DisplayId,
	L_SystemPrice,
	L_Address,
	L_City
FROM rets_property
ORDER BY L_SystemPrice ASC
LIMIT 100;
-- Min price is $795, 100th cheapest is $70,000

-- What are the 100 cheapest listing per sqft?
SELECT
	L_DisplayId,
	L_SystemPrice / LM_Int2_3 AS price_per_sqft,
	L_Address,
	L_City 
FROM rets_property
WHERE LM_Int2_3 IS NOT NULL 
	AND LM_Int2_3 > 0
ORDER BY price_per_sqft ASC
LIMIT 100;
-- Cheapest per sqft is in Plam Desert at $0.99 per sqft
-- 100th cheapest per sqft is in Trona at $75.76 per sqft

-- What are the 100 cheapest listing per bedroom?
SELECT
	L_DisplayId,
	L_SystemPrice / L_Keyword2  AS price_per_bedroom,
	L_Address,
	L_City 
FROM rets_property
WHERE L_Keyword2  IS NOT NULL 
	AND L_Keyword2  > 0
ORDER BY price_per_bedroom ASC
LIMIT 100;
-- Cheapest per bedroom is in Plam Desert at $397.50 per bedroom
-- 100th cheapest per bedroom is in Adelanto at $37,500.00 per bedroom

-- What are the 50 cheapest listings by number of bedrooms?
-- Consider only 1 to 6 bedrooms
WITH rank_by_num_beds AS (
    SELECT
        L_Keyword2 ,
        L_DisplayId,
        L_Address,
        L_City,
        L_SystemPrice,
        RANK() OVER (
            PARTITION BY L_Keyword2 
            ORDER BY L_SystemPrice ASC
        ) AS ranking
    FROM rets_property
    WHERE L_Keyword2  BETWEEN 1 AND 6
)
SELECT
    L_Keyword2,
    L_DisplayId,
    L_Address,
    L_City,
    L_SystemPrice,
    ranking
FROM rank_by_num_beds
WHERE ranking <= 50
ORDER BY L_Keyword2;


-- Now consdier location as a defining factor

-- What is the cheapest listing in each city (for cities with >= 10 listings)?
SELECT
	L_City,
	MIN(L_SystemPrice) AS min_price_by_city,
	COUNT(*) as num_listing_by_city
FROM rets_property
GROUP BY L_City
HAVING COUNT(*) > 10
ORDER BY min_price_by_city ASC;
-- 518 cities returned
-- Palm Desert has lowest min listing at $795 (of 576 listing in the city)
-- Montecito has highest min listing at $4,250,000 (of 14 listings in the city)

-- What is the cheapest listing in each ZIP with at least 10 Listings?
SELECT 
		L_Zip,
		L_City, 
		MIN(L_SystemPrice) AS min_price_by_zip,
		COUNT(*) as num_listing_by_zip
FROM rets_property
GROUP BY L_Zip, L_City -- assume each zip matches only 1 city
HAVING COUNT(*) >= 10
ORDER BY min_price_by_zip
LIMIT 100;
-- Zip 92211 (Palm Desert) has lowest min listing at $795 (351 listings)
-- Zip 92557 (Moreno Valley) has 100th min listing at $155,000 (55 listings)

-- Consider prices in the first quartile (cheapest 1/4 of listings) by location

-- What are the cheapest listings (lowest quartile price)
-- in the 10 cities with the lowest avgerage listing price
-- for cities with at least 10 listings?

-- CTE for 10 zip codes with the lowest avg listing price
WITH cheapest_cities AS (
    SELECT 
        L_City 
    FROM rets_property 
    GROUP BY L_City
    HAVING COUNT(*) >= 10
    ORDER BY AVG(L_SystemPrice) ASC
    LIMIT 10
),
-- CTE to add the quartile to the listing in the 10 cheapest cities
ranked_listings AS (
    SELECT
        L_City,
        L_SystemPrice,
        -- use NTILE(4) to approximate the quartiles
        NTILE(4) OVER (
            PARTITION BY L_Zip 
            ORDER BY L_SystemPrice ASC
        ) AS quartile
    FROM rets_property
    WHERE L_City IN (SELECT  L_City FROM cheapest_cities)
)
-- Select the first quartile from listing in the 10 cheapest cities
SELECT
    L_City,
    L_SystemPrice
FROM ranked_listings
WHERE quartile = 1
ORDER BY L_City, L_SystemPrice;
-- 126 listing total
-- Cheapest listing is in 29 Palms price $45,000
-- Most expensive listing is in Newberry springs price $240,000


-- What are the cheapest listings (lowest quartile price)
-- in the 10 zip codes with the lowest avgerage listing price
-- for ZIP codes with at least 10 listings?

-- CTE for 10 zip codes with the lowest avg listing price
WITH cheapest_zips AS (
    SELECT 
        L_Zip 
    FROM rets_property 
    GROUP BY L_Zip
    HAVING COUNT(*) >= 10
    ORDER BY AVG(L_SystemPrice) ASC
    LIMIT 10
),
-- CTE to add the quartile info to the listing in the 10 cheapest zip codes
ranked_listings AS (
    SELECT
        L_Zip,
        L_City,
        L_SystemPrice,
        -- use NTILE(4) to approximate the quartiles
        NTILE(4) OVER (
            PARTITION BY L_Zip 
            ORDER BY L_SystemPrice ASC
        ) AS quartile
    FROM rets_property
    WHERE L_Zip IN (SELECT L_Zip FROM cheapest_zips)
)
-- Select the first quartile from listing in the 10 cheapest zip codes
SELECT
    L_Zip,
    L_City,
    L_SystemPrice
FROM ranked_listings
WHERE quartile = 1
ORDER BY L_Zip, L_SystemPrice;
-- 78 listing total
-- Cheapest listing is in Zip 93562 (Trona) price $25,000
-- Most expensive listing is in Zip 93501 (Mojave) price $239,000







