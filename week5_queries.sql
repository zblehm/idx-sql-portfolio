-- ============================================================ 
-- IDX Exchange — SQL Training
-- Week 5: Queries 
-- Tables: rets_property, california_sold
-- Author: Zachary Blehm 
-- ============================================================ 

-- Summary
-- ============================================================
/* Week 5 Deliverables
 * 
 * Q1 Top 10 cities by sale-to-list ratio (sold above asking most often)
 * City					total_sales		close_to_list_percent
 * ----					-----------		---------------------
 * Berkeley				278				129%
 * Kensington			30				128%
 * Albany				38				127%
 * El Cerrito			66				124%
 * Piedmont				54				123%
 * Oakland				928				117%
 * Alameda				198				110%
 * San Francisco		156				110%
 * South Pasadena		58				108%
 * South San Francisco	50				108%
 *  
 * Q2 Cities where active listings are priced significantly above historical norms
 * Limit the results to cities with at least 50 historic and current listings
 * City					current_to_historic_ratio
 * ----					-------------------------
 * Pacific Palisades	2.32 (current list more than double historic sale)
 * Rancho Santa Fe		2.07
 * Santa Paula			1.97
 * Laguna Beach			1.95
 * La Jolla				1.93
 * Ojai					1.74
 * Dana Point			1.73
 * Manhattan Beach		1.72
 * Rancho Palos Verdes	1.71
 * Tarzana				1.66
 * 
 * Q3 Which month has the highest average historical sale price?
 * March has the highest average historical sales price
 * 
 * Q4 How does the average discount from list price vary by bedroom count?
 * Numer of Bedrooms	Average discount percent
 * -----------------	------------------------
 * 1					8.0
 * 6					8.0
 * 2					7.0
 * 3					6.0
 * 4					6.0
 * 5					6.0
 * 
 * Q5 Cities where homes typically sell within 2% of asking price
 * Consider cities based on averages sell w/in 2% of average list
 * Top result is San Diego, with 3,506 total sales
 * 
 * Consider cities based on individual sales w/in 2% of asking (at least 50 sales)
 * Hollister 140 sales w/ 80% of sales within 2% of ListPrice
 * 
 * 
 * Week 5 Open-Ended Challenge
 * "A seller just asked us whether right now is a good time to list their 
 * home in Sacramento. What does the data say?"
 * 
 * Historically homes in Sacramento sell for the list value on average.
 * The current average list value for homes in Sacramento is slightly below the historic
 * average list value. Based on these two factors we conclude that it is NOT a good time
 * to sell a home in Sacremento. But it is also not a terrible time as the market
 * is only slightly below historic prices.
 * 
 *  
 */
-- ============================================================

-- First note that california_sold contains duplicate rows
-- How many rows are duplicated?
WITH duplicates AS (
	SELECT
		COUNT(*) AS count
	FROM california_sold
	WHERE ListingKey IS NOT NULL
	GROUP BY ListingKey, City, ListPrice, ClosePrice, CloseDate
	HAVING COUNT(*) > 1
	ORDER BY count DESC
)
SELECT
	COUNT(*)
FROM duplicates;
-- This gives 326 duplicated rows.


-- Create a new view without the duplicates for the following analysis
CREATE VIEW california_sold_dedup AS
SELECT DISTINCT *
FROM california_sold
-- Additionally some date are incorrect, remove the errant close dates
WHERE CloseDate LIKE '2026%';

-- Verify the deduplication
WITH duplicates AS (
	SELECT
		COUNT(*) AS count
	FROM california_sold_dedup
	WHERE ListingKey IS NOT NULL
	GROUP BY ListingKey, City, ListPrice, ClosePrice, CloseDate
	HAVING COUNT(*) > 1
	ORDER BY count DESC
)
SELECT
	COUNT(*)
FROM duplicates;
-- This gives 0 duplicated rows.
-- We use california_sold_dedup going forward


-- Exercise 5.1 Explore california_sold
SELECT 
	City,
	COUNT(*) AS total_sold,
	ROUND(AVG(ClosePrice), 0) AS avg_sold_price,
	ROUND(AVG(ListPrice), 0) AS avg_list_price,
	ROUND(AVG(ClosePrice / ListPrice) * 100, 1) AS avg_sale_to_list_pct 
FROM california_sold_dedup 
WHERE ClosePrice IS NOT NULL 
	AND ListPrice > 0 
GROUP BY City
HAVING COUNT(*) >= 10 
ORDER BY avg_sale_to_list_pct DESC
LIMIT 20;
-- Top results is erroneous, need to investigate sales in Sonora
-- Kensington is top city avg_sale_to_list_pct of 130.6%

-- Which listing in Sonora has an extreme ClosePrice/ListPrice value?
SELECT
	ListingKey,
	City,
	ListPrice,
	ClosePrice
FROM california_sold_dedup
WHERE City = 'Sonora'
ORDER BY ListPrice ASC;
-- Listing 1168684489 has a list price of $1, close price $200,200.
-- This is skewing the results in the query above

-- Exercise 5.2 Seasonal Trends
-- How many homes were sold in each month contained in the data?
SELECT 
	YEAR(CloseDate)           AS sale_year,
	MONTH(CloseDate)          AS sale_month,
	COUNT(*)                  AS homes_sold,
	ROUND(AVG(ClosePrice), 0) AS avg_sold_price 
FROM california_sold_dedup 
WHERE CloseDate IS NOT NULL 
GROUP BY YEAR(CloseDate), MONTH(CloseDate) 
ORDER BY sale_year, sale_month;
-- Low counts for March and August (partial data? verify below)

-- What are the start end dates for sales data?
SELECT 
	YEAR(CloseDate)			AS sale_year,
	MONTH(CloseDate)		AS sale_month,
	MIN(DAY(CloseDate))		AS min_day,
	MAX(DAY(CloseDate))		AS max_day 
FROM california_sold_dedup
WHERE CloseDate IS NOT NULL
-- limit to valid year
	AND YEAR(CloseDate) = 2026
GROUP BY YEAR(CloseDate), MONTH(CloseDate) 
ORDER BY sale_year, sale_month;
-- Sales data spans 2026-03-31 to 2026-8-14.
-- Only 1 day of sales data in March 2026 (the 31t)
-- Only 14 days fo sales data in August 2026 (1st - 14th)

-- Rerun with first query with consideration for the shortened months
SELECT 
	YEAR(CloseDate) AS sale_year,
	MONTH(CloseDate) AS sale_month,
	COUNT(*) / (MAX(DAY(CloseDate)) - MIN(DAY(CloseDate))+1) AS avg_homes_sold,
	ROUND(AVG(ClosePrice), 0) AS avg_sold_price 
FROM california_sold_dedup 
WHERE CloseDate IS NOT NULL 
	AND YEAR(CloseDate) = 2026
GROUP BY YEAR(CloseDate), MONTH(CloseDate) 
ORDER BY sale_year, sale_month;
-- Hard to see season trends for just 4 complete months
-- Average homes sales higher in the full months
-- Average sold price higher in March, within $3,000 other months

-- Week 5 Debugging Exercise
-- BROKEN: Compare active prices to historical sold prices 
WITH historical AS ( 
    SELECT 
    	City, 
    	ROUND(AVG(ClosePrice), 0) AS avg_sold 
    FROM california_sold_dedup 
    WHERE ClosePrice IS NOT NULL 
    GROUP BY City 
) 
SELECT 
	p.L_City,
	ROUND(AVG(p.L_SystemPrice), 0) AS avg_active_price,
	h.avg_sold,
	ROUND((AVG(p.L_SystemPrice) - h.avg_sold) 
             / h.avg_sold * 100, 1) 
             	AS pct_diff_from_historical 
FROM rets_property p 
LEFT JOIN historical h 
	ON p.L_City = h.City 
GROUP BY p.L_City, h.avg_sold 
ORDER BY avg_active_price DESC; 
-- Gives many NULL values for avg_sold and pct_diff_from_historical

-- Suggested Fix: Use inner join because many non matching cities
-- Suggested Fix: clean the city names to provide better matching
WITH historical AS ( 
    SELECT 
    	City, 
    	ROUND(AVG(ClosePrice), 0) AS avg_sold 
    FROM california_sold_dedup 
    WHERE ClosePrice IS NOT NULL 
    GROUP BY City 
) 
SELECT 
	p.L_City,
	ROUND(AVG(p.L_SystemPrice), 0) AS avg_active_price,
	h.avg_sold,
	ROUND((AVG(p.L_SystemPrice) - h.avg_sold) 
             / h.avg_sold * 100, 1) 
             	AS pct_diff_from_historical 
FROM rets_property p 
INNER JOIN historical h 
	ON LOWER(TRIM(p.L_City)) = LOWER(TRIM(h.City)) 
GROUP BY p.L_City, h.avg_sold 
ORDER BY avg_active_price DESC;


-- Week 5 Deliverables
-- IMPORTANT NOTE - rets_property and california_sold do not intersect
-- How many listings in rets_property are in california_sold?
SELECT
	COUNT(*)
FROM rets_property AS r
JOIN california_sold_dedup AS c
	ON L_DisplayId = c.ListingKey;
-- Result: 0, meaning listed houses and sold houses are completely different
-- This affects the interpretation of the results below

-- Q1 Top 10 cities by sale-to-list ratio (sold above asking most often)
-- Consider as a direct ratio of close to list price
SELECT
	City,
	COUNT(*) AS total_sold,
	ROUND(AVG(ClosePrice)/AVG(ListPrice) * 100, 0) AS close_to_list_percent
FROM california_sold_dedup
GROUP BY City
HAVING COUNT(DISTINCT ListingKey) >= 25
ORDER BY close_to_list_percent DESC
LIMIT 10;
-- Top result is Berkeley 278 sales with close price 129% list on average

-- As a ratio of sold above list to total sales
SELECT
	City,
	COUNT(*) AS total_sold,
	ROUND(COUNT(DISTINCT 
			CASE
				WHEN ClosePrice > ListPrice Then ListingKey
			END) 
		/ COUNT(DISTINCT ListingKey) * 100, 0) AS perc_sold_above_list
FROM california_sold_dedup
GROUP BY City
ORDER BY perc_sold_above_list DESC
LIMIT 10;
-- Top 10 results all have ratio of 1 (all listings sold above list price)
-- However, max sales is 3.

-- Rerun the above, for cities with at least 25 sales
-- Top 10 cities by sale-to-list ratio with at least 25 sales
SELECT
	City,
	COUNT(*) AS total_sold,
	ROUND(COUNT(DISTINCT 
			CASE
				WHEN ClosePrice > ListPrice Then ListingKey
			END) / 
		COUNT(DISTINCT ListingKey) * 100, 0) AS perc_sold_above_list
FROM california_sold_dedup
GROUP BY City
HAVING COUNT(DISTINCT ListingKey) >= 25
ORDER BY perc_sold_above_list DESC
LIMIT 10;
-- Top result El Cerrito with 66 sales and 89%
-- 10th is San Marino with 43 sales and ratio 72%


-- Q2 Cities where active listings are priced significantly above historical norms
-- Based on the examples we use california_sold as "historical"
WITH avg_price_by_city AS (
	SELECT
		L_City,
		COUNT(*) AS total_current,
		AVG(L_SystemPrice) AS current_avg
	FROM rets_property
	GROUP BY L_City
),
avg_price_historic AS (
	SELECT
		City,
		COUNT(*) AS total_historic,
		AVG(ClosePrice) AS historic_avg
	FROM california_sold_dedup
	GROUP BY City
)
SELECT
	City,
	total_current,
	total_historic,
	ROUND((current_avg / historic_avg), 2) AS current_to_historic_ratio 
FROM avg_price_by_city as c
JOIN avg_price_historic as h
	ON c.L_City = h.City
-- use 50% higher as threshold for "signficantly" above historic	
WHERE current_avg >= (1.25 * historic_avg)
ORDER BY current_to_historic_ratio DESC;
-- Top results are > 10 ratio, meaning current > 10 x historic price
-- Low number of listing and sales skew results

-- Redo above for cities with at least 50 listings and 50 sales
WITH avg_price_by_city AS (
	SELECT
		L_City,
		COUNT(*) AS total_current,
		AVG(L_SystemPrice) AS current_avg
	FROM rets_property
	GROUP BY L_City
	HAVING COUNT(*) >= 50
),
avg_price_historic AS (
	SELECT
		City,
		COUNT(*) AS total_historic,
		AVG(ClosePrice) AS historic_avg
	FROM california_sold_dedup
	GROUP BY City
	HAVING COUNT(*) >= 50
)
SELECT
	City,
	total_current,
	total_historic,
	ROUND((current_avg / historic_avg), 2) AS current_to_historic_ratio
FROM avg_price_by_city as c
JOIN avg_price_historic as h
	ON c.L_City = h.City
-- use 50% higher as threshold for "signficantly" above historic	
WHERE current_avg >= (1.5 * historic_avg)
ORDER BY current_to_historic_ratio DESC;
-- Results are more believeable
-- Top Result: Pacific Palisades 2.32 ratio (current more than double)
-- In total 16 cities with ratio > 1.5

-- Q3 Which month has the highest average historical sale price?
SELECT
	MONTH(CloseDate) AS sale_month,
	ROUND(AVG(ClosePrice), 0) AS monthly_avg
FROM california_sold_dedup
GROUP BY MONTH(CloseDate)
ORDER BY monthly_avg DESC
LIMIT 1;
-- March has the highest average historical sales price

-- Q4 How does the average discount from list price vary by bedroom count?
-- First we investigate discounted properties

-- How man sold properties had no change in price?
SELECT
	COUNT(*)
FROM california_sold_dedup
WHERE OriginalListPrice = ListPrice;
-- 512,000 sold properties with NO discounted price

-- How man sold properties had in increase in price?
SELECT
	COUNT(*)
FROM california_sold_dedup
WHERE OriginalListPrice < ListPrice;
-- 2,481 sold properties with a price increase

-- How many sold properties had a discount?
SELECT
	COUNT(*)
FROM california_sold_dedup
WHERE OriginalListPrice > ListPrice;
-- 19,851 sold properties with a discounted price

SELECT
	BedroomsTotal,
	ROUND(AVG(OriginalListPrice - ListPrice),0) AS avg_discount
FROM california_sold_dedup
WHERE OriginalListPrice > ListPrice
GROUP BY BedroomsTotal
ORDER BY avg_discount DESC;
-- Results include very high bedroom numbers
-- Top Result 11 bedrooms, with avg_discount 8,515,333 (single listing?)

-- Rerun the query considering 1-6 bedrooms
-- How does the average discount from list price vary for 1-6 bedrooms
SELECT
	BedroomsTotal,
	ROUND(AVG(OriginalListPrice - ListPrice),0) AS avg_discount
FROM california_sold_dedup
WHERE OriginalListPrice > ListPrice
	AND BedroomsTotal BETWEEN 1 AND 6
GROUP BY BedroomsTotal
ORDER BY avg_discount DESC;
-- Top result is 4 bedrooms w/ avg_discount $430,769
-- Bottom result is 1 bedroom w/ avg_discount $87,644

-- Rerun the query considering 1-6 bedrooms as a percentage
-- How does the average discount from list price vary for 1-6 bedrooms
SELECT
	BedroomsTotal,
	ROUND(AVG((OriginalListPrice - ListPrice)/OriginalListPrice) *100, 0) 
		AS avg_discount_percent
FROM california_sold_dedup
WHERE OriginalListPrice > ListPrice
	AND BedroomsTotal BETWEEN 1 AND 6
GROUP BY BedroomsTotal
ORDER BY avg_discount_percent DESC;
-- Top results are 1 and 6 bedrooms with 8% discount
-- Bottom results are 3, 4 and 5 bedrooms with 6% discount

-- Q5 Cities where homes typically sell within 2% of asking price
SELECT 
	City,
	COUNT(*) as total_sales,
	ROUND(AVG(ClosePrice),0) AS avg_close,
	ROUND(AVG(ListPrice),0) AS avg_list
FROM california_sold_dedup
WHERE City IS NOT NULL
GROUP BY City
HAVING AVG(ClosePrice) 
	BETWEEN (0.98 * AVG(ListPrice)) AND (1.02 * AVG(ListPrice))
ORDER BY total_sales DESC;
-- Top result is San Diego, with 3,506 total sales

WITH sales_within_2percent AS (
SELECT 
	City,
	COUNT(*) as num_within_2percent
FROM california_sold_dedup
WHERE City IS NOT NULL
	AND ClosePrice BETWEEN (0.98 * ListPrice) AND (1.02 * ListPrice)
GROUP BY City
),
total_sales AS (
SELECT 
	City,
	COUNT(*) as total_sales
FROM california_sold_dedup
WHERE City IS NOT NULL
GROUP BY City
)
SELECT
	s.City,
	total_sales,
	ROUND((s.num_within_2percent / t.total_sales) * 100,0) 
		AS sell_within_2percent_of_asking
FROM sales_within_2percent AS s
JOIN total_sales AS t
	ON s.City = t.City
ORDER BY sell_within_2percent_of_asking DESC, total_sales DESC;
-- Top 65 results have 100% of homes selling w/in 2% of ListPrice
-- Skewed by few sales, max 9 sales in cities with 100%
	
-- Rerun the above only condiering cities with 50+ sales
-- Cities where homes typically sell within 2% of asking price
-- having at least 50 sales
WITH sales_within_2percent AS (
SELECT 
	City,
	COUNT(*) as num_within_2percent
FROM california_sold_dedup
WHERE City IS NOT NULL
	AND ClosePrice BETWEEN (0.98 * ListPrice) AND (1.02 * ListPrice)
GROUP BY City
),
total_sales AS (
SELECT 
	City,
	COUNT(*) as total_sales
FROM california_sold_dedup
WHERE City IS NOT NULL
GROUP BY City
HAVING COUNT(*) >= 50
)
SELECT
	s.City,
	total_sales,
	ROUND((s.num_within_2percent / t.total_sales) * 100,0) 
		AS sell_within_2percent_of_asking
FROM sales_within_2percent AS s
JOIN total_sales AS t
	ON s.City = t.City
ORDER BY sell_within_2percent_of_asking DESC, total_sales DESC;
-- Top Result: Hollister 140 sales w/ 80% of sales within 2% of ListPrice
-- 142 Cities with at least 50% of sales within 2% of ListPrice


-- Week 5 Open-ended Challenge
-- "A seller just asked us whether right now is a good time to list their 
-- home in Sacramento. What does the data say?" 

-- What is the historic close to list percent in Sacramento?
SELECT
	City,
	COUNT(*) AS total_sold,
	ROUND(AVG(ClosePrice)/AVG(ListPrice) * 100, 0) AS close_to_list_percent
FROM california_sold_dedup
WHERE City = 'Sacramento'
GROUP BY City;
-- Historic close ot list is 101%, so home usually sell for approximate list price

-- What is the historic close to original list percent in Sacramento
SELECT
	City,
	COUNT(*) AS total_sold,
	ROUND(AVG(ClosePrice)/AVG(OriginalListPrice) * 100, 0) AS close_to_list_percent
FROM california_sold_dedup
WHERE City = 'Sacramento'
GROUP BY City;
-- Historic close ot list is 100%, so home usually sell for the original list price

-- Next look at discounting in Sacramento
-- Percent of properties with NO discount in Sacramento historically
SELECT
    ROUND(
        100.0 * SUM(OriginalListPrice = ListPrice) / COUNT(*),
        0
    ) AS percent_no_discount
FROM california_sold_dedup
WHERE City = 'Sacramento';
-- 62% of historic sacremento sales had no discount
	
-- Percent of properties with discount in Sacramento historically
SELECT
    ROUND(
        100.0 * SUM(OriginalListPrice > ListPrice) / COUNT(*),
        0
    ) AS percent_no_discount
FROM california_sold_dedup
WHERE City = 'Sacramento';
-- 32% of historic sacremento sales had a discount

-- Percent of properties with increase in list in Sacramento historically
SELECT
    ROUND(
        100.0 * SUM(OriginalListPrice < ListPrice) / COUNT(*),
        0
    ) AS percent_no_discount
FROM california_sold_dedup
WHERE City = 'Sacramento';
-- 5% of historic sacremento sales had a price increase

-- What is the current list price to historic sale price ratio?
WITH avg_price_by_city AS (
	SELECT
		L_City,
		COUNT(*) AS total_current,
		AVG(L_SystemPrice) AS current_avg
	FROM rets_property
	WHERE L_City = 'Sacramento'
	GROUP BY L_City
),
avg_price_historic AS (
	SELECT
		City,
		COUNT(*) AS total_historic,
		AVG(ClosePrice) AS historic_avg
	FROM california_sold_dedup
	WHERE City = 'Sacramento'
	GROUP BY City
)
SELECT
	City,
	total_current,
	total_historic,
	ROUND((current_avg / historic_avg), 2) AS current_to_historic_ratio 
FROM avg_price_by_city as c
JOIN avg_price_historic as h
	ON c.L_City = h.City
ORDER BY current_to_historic_ratio DESC;
-- Current to historic ratio is 0.97.
-- Meaning current list prices are less than historic close prices 

-- What is the current list price to historic list price ratio?
WITH avg_price_by_city AS (
	SELECT
		L_City,
		COUNT(*) AS total_current,
		AVG(L_SystemPrice) AS current_list
	FROM rets_property
	WHERE L_City = 'Sacramento'
	GROUP BY L_City
),
avg_price_historic AS (
	SELECT
		City,
		COUNT(*) AS total_historic,
		AVG(ListPrice) AS historic_list
	FROM california_sold_dedup
	WHERE City = 'Sacramento'
	GROUP BY City
)
SELECT
	City,
	total_current,
	total_historic,
	ROUND((current_list / historic_list), 2) AS current_to_historic_ratio 
FROM avg_price_by_city as c
JOIN avg_price_historic as h
	ON c.L_City = h.City
ORDER BY current_to_historic_ratio DESC;
-- Ratio is the same as above 0.97
-- Meaning current list prices are slightly les than historic list prices
