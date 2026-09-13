-- ============================================================ 
-- IDX Exchange — SQL Training
-- Week 6: Queries 
-- Tables: rets_property, california_sold
-- Author: Zachary Blehm 
-- ============================================================ 

-- Summary
-- ============================================================
/* Week 6 Deliverables
 * 
 * Q1 Rank all cities with 10+ listings by average price using RANK()
 * Top 10 cities are:
 * City				avg_price		rank_by_avg_price
 * ----				---------		-----------------
 * Newport Coast	$21,571,898		1
 * Carpinteria		$18,331,058		2
 * Atherton			$14,313,187		3
 * Hidden Hills		$13,839,163		4
 * Montecito		$12,752,071		5
 * Hillsborough		$12,459,381		6
 * Beverly Hills	$11,536,705		7
 * Los Altos Hills	$11,105,181		8
 * Santa Ynez		$10,729,381		9
 * Rancho Santa Fe	$10,699,126		10
 * 
 * Q2 For each city, show only the single most expensive listing (RANK + CTE wrapper) 
 * Top 10 most expensive listing by city are:
 * City					most_expensive
 * ----					--------------
 * Los Angeles			$400,000,000
 * Beverly Hills		$135,000,000
 * Laguna Beach			$112,000,000
 * Malibu				$90,000,000
 * La Jolla				$87,500,000
 * La Quinta			$85,000,000
 * San Juan Capistrano	$85,000,000
 * Rancho Santa Fe		$84,950,000
 * West Hollywood		$76,000,000
 * Newport Beach		$69,998,000
 * 
 * Q3 Flag listings priced more than 2 standard deviations above their city mean
 * Top results is more than 146 times more expenive than the average L.A. listing
 * Address				City		L_SystemPrice	city_avg	pct_of_city_avg
 * -------				----		-------------	--------	---------------
 * 11201 Chalon Road	Los Angeles	400000000		2731802		14642.3
 * 
 * 
 * Q4 Which cities have the most consistent pricing? (lowest std deviation relative to mean) 
 * Top 10 results (lowest std deviation as a percent of city average)
 * City				city_avg		stddev_as_pct_of_mean	
 * ----				--------		---------------------
 * Avenal			$357,900		4.2
 * Lynwood			$734,393		6.8
 * Santa Fe Springs	$791,979		9.9
 * Pico Rivera		$745,668		15.7
 * South Gate		$734,804		17.2
 * Suisun City		$576,992		17.4
 * Compton			$660,895		18.9
 * Rio Vista		$470,624		19.6
 * Campo			$491,835		19.9
 * Rancho Cordova	$600,914		20.8
 * 
 * Q5 Final summary table: city, active listings, avg active price, avg historical sold, ratio
 * Limit to cities with 10 current listing and 10 historic sales
 * Top result:
 * City		Listing		avg_active_price	avg_historical_sold		ratio	
 * ----		-------		----------------	-------------------		-----
 * Gridley	13			$1,127,985			$363,000				3.11
 * 
 * 
 * Week 6 Open-Ended Challenge
 * "We're presenting to investors next week and they want to know: which cities are most 
 * competitive right now, and which represent the best opportunity for buyers?" 
 * 
 * We answer the question giving equal weight to three metrics:
 * current inventory vs. historic sales
 * close price vs. list price for historic sales
 * current list average vs. historic close average.
 * 
 * COMPETITIVE CITIES:
 * Cities are considered competitive when current inventory is low relative
 * to historical sales, current list average is above historic close average 
 * and homes tend to sell at or above to their list price. These conditions 
 * suggest stronger buyer demand and less negotiating power.
 * 
 * Results
 * City				inventory_sales_ratio	price_ratio		pct_sold_below_list		competative_rank
 * ----				---------------------	-----------		-------------------		-----------------
 * Salinas			0.51					1.47			33.95					1
 * Santa Maria		0.39					1.19			31.39					2
 * Jurupa Valley	0.52					1.3				28.50					3
 * Manhattan Beach	0.43					1.72			40.91					4
 * Whittier			0.49					1.16			27.47					5
 * 
 * 
 * BUYER OPPORTUNITIES:
 * Cities are considered buyer opportunities when current inventory is
 * relatively high compared with historical sales, current list average is 
 * below or near historic close average and homes have historically sold below list price.
 * These conditions suggest greater buyer choice and more negotiating power.
 * 
 * Results
 * City				inventory_sales_ratio	price_ratio		pct_sold_below_list		buyer_rank
 * ----				---------------------	-----------		-------------------		----------	
 * Palm Desert		0.88					0.92			74.58					1
 * Big Bear Lake	2.91					1.04			70.33					2
 * Marina Del Rey	1.61					1.05			77.50					3
 * Indio			1.10					1.0				65.90					3
 * Laguna Woods		0.87					0.83			55.75					5
 * 
 * The analysis combines current listings from rets_property with historical
 * sales from california_sold_dedup. Cities are limited to those with at least
 * 50 current listings and 50 historical sales to avoid drawing conclusions
 * from very small samples.
 * 
 * 
 */
-- ============================================================
-- Exercise 6.1 PARTITION BY
SELECT 
	L_DisplayId, 
	L_Address, 
	L_City, 
	L_SystemPrice,
	ROUND(AVG(L_SystemPrice) OVER (PARTITION BY L_City), 0) AS city_avg_price, 
    ROUND(L_SystemPrice - AVG(L_SystemPrice) OVER 
             (PARTITION BY L_City), 0) AS diff_from_city_avg, 
       RANK() OVER ( 
           PARTITION BY L_City ORDER BY L_SystemPrice DESC) AS rank_in_city 
FROM rets_property 
WHERE L_SystemPrice IS NOT NULL 
	AND L_City IS NOT NULL 
ORDER BY L_City, rank_in_city 
LIMIT 30; 

-- Exercise 6.2 Find Price Outliers
WITH city_stats AS ( 
    SELECT 
    	L_City,
    	AVG(L_SystemPrice) AS city_avg,
    	STDDEV(L_SystemPrice) AS city_stddev 
    FROM rets_property 
    WHERE L_SystemPrice IS NOT NULL 
    GROUP BY L_City HAVING COUNT(*) >= 5 
) 
SELECT
	p.L_DisplayId, 
	p.L_Address, 
	p.L_City, 
	p.L_SystemPrice,
	ROUND(cs.city_avg, 0) AS city_avg_price, 
    ROUND(p.L_SystemPrice / cs.city_avg * 100, 1) AS pct_of_city_avg 
FROM rets_property p 
JOIN city_stats cs ON p.L_City = cs.L_City 
WHERE p.L_SystemPrice > cs.city_avg * 1.5 
ORDER BY pct_of_city_avg DESC 
LIMIT 20;

-- Exercise 6.3 Sold Price Quartiles
WITH quartiles AS ( 
    SELECT 
    	ClosePrice, 
    	City,
    	NTILE(4) OVER (ORDER BY ClosePrice) AS price_quartile 
    FROM california_sold 
    WHERE ClosePrice IS NOT NULL 
) 
SELECT price_quartile, 
       COUNT(*) AS num_sold, 
       ROUND(MIN(ClosePrice), 0) AS min_price, 
       ROUND(MAX(ClosePrice), 0) AS max_price, 
       ROUND(AVG(ClosePrice), 0) AS avg_price 
FROM quartiles 
GROUP BY price_quartile 
ORDER BY price_quartile;

-- Exercise 6.4 Running Totals
WITH monthly AS ( 
    SELECT 
    	DATE_FORMAT(ListingContractDate, '%Y-%m') AS list_month,
    	COUNT(*) AS new_listings 
    FROM rets_property WHERE ListingContractDate IS NOT NULL 
    GROUP BY DATE_FORMAT(ListingContractDate, '%Y-%m') 
)
SELECT list_month, new_listings, 
       SUM(new_listings) OVER ( 
           ORDER BY list_month ROWS UNBOUNDED PRECEDING 
       ) AS running_total 
FROM monthly 
ORDER BY list_month; 


-- Week 6 Debugging Exercise
-- BROKEN: Most expensive listing in each city 
SELECT L_DisplayId, L_Address, City, ListPrice, 
       RANK() OVER ( 
           PARTITION BY City ORDER BY ListPrice DESC 
       ) AS rank_in_city 
FROM rets_property 
WHERE ListPrice IS NOT NULL 
  AND rank_in_city = 1
ORDER BY City; 

-- The WHERE clause executes before SELECT.
-- We cannot use the result of the window function in the WHERE clause.
-- Suggested Fix: Use a CTE to create the ranking, then filter by the ranking
WITH  most_expensive AS (
	SELECT 
		L_DisplayId, 
		L_Address, 
		L_City, 
		L_SystemPrice,
		RANK() OVER ( 
	           PARTITION BY L_City ORDER BY L_SystemPrice DESC 
	       		) AS rank_in_city
	FROM rets_property
	-- Add a NOT NULL filter for the cities
	WHERE L_City IS NOT NULL
) 
SELECT
	L_DisplayId, 
	L_Address, 
	L_City, 
	L_SystemPrice,
	rank_in_city
FROM most_expensive
WHERE rank_in_city = 1
ORDER BY L_City;


-- Week 6 Deliverables
-- Q1 Rank all cities with 10+ listings by average price using RANK()
SELECT
	L_City,
	ROUND(AVG(L_SystemPrice), 0) AS avg_price,
	RANK() OVER (ORDER BY AVG(L_SystemPrice) DESC) AS rank_by_avg_price
FROM rets_property
GROUP BY L_City
HAVING COUNT(*) >= 10
ORDER BY rank_by_avg_price;

-- Q2 For each city, show only the single most expensive listing (RANK + CTE wrapper)
WITH most_expensive AS (
	SELECT
		L_City,
		L_SystemPrice,
		RANK() OVER (PARTITION BY L_City ORDER BY L_SystemPrice DESC) AS rank_most_expensive_by_city
	FROM rets_property
	WHERE L_City IS NOT NULL
)
-- Use DISTTINCT to remove duplicates (different listing in same city with same max price)
SELECT DISTINCT
	L_City,
	L_SystemPrice,
	rank_most_expensive_by_city
FROM most_expensive
WHERE rank_most_expensive_by_city = 1
ORDER BY L_SystemPrice DESC;

-- Q3 Flag listings priced more than 2 standard deviations above their city mean 
WITH city_stats AS (
	SELECT
		L_City,
		AVG(L_SystemPrice) AS city_avg,
		STDDEV(L_SystemPrice) AS city_stddev
	FROM rets_property
	WHERE L_SystemPrice IS NOT NULL
		AND L_City IS NOT NULL
	GROUP BY L_City
)
SELECT
	r.L_DisplayId,
	r.L_Address,
	r.L_City,
	r.L_SystemPrice,
	ROUND(c.city_avg, 0) AS city_avg_price,
	ROUND(r.L_SystemPrice / c.city_avg *100, 1) as pct_of_city_avg
FROM rets_property AS r
JOIN city_stats AS c
	ON r.L_City = c.L_City
WHERE L_SystemPrice > city_avg + 2 * city_stddev
ORDER BY pct_of_city_avg DESC;
	

-- Q4 Which cities have the most consistent pricing? (lowest std deviation relative to mean) 
SELECT
	L_City,
	ROUND(AVG(L_SystemPrice),0) AS city_avg,
	ROUND(STDDEV(L_SystemPrice) / AVG(L_SystemPrice) *100, 1) as stddev_pct_of_mean
FROM rets_property
WHERE L_SystemPrice IS NOT NULL
	AND L_City IS NOT NULL
GROUP BY L_City
HAVING COUNT(*) >= 10
ORDER BY stddev_pct_of_mean ASC;


-- Q5 Final summary table: city, active listings, avg active price, avg historical sold, ratio
-- Limit to cities with both 10 current listings and historical sales
WITH current_listing AS (
	SELECT
		L_City,
		COUNT(*) AS active_listing,
		ROUND(AVG(L_SystemPrice),0) AS avg_active_price
	FROM rets_property
	WHERE L_City IS NOT NULL
	GROUP BY L_City
	HAVING COUNT(*) >= 10
), 
historic_sales AS (
	SELECT
		City,
		ROUND(AVG(ClosePrice), 0) as avg_historical_sold
	-- california_sold_dedup created removes duplicates and errant sale dates
		FROM california_sold_dedup
	WHERE City IS NOT NULL
	GROUP BY City
	HAVING COUNT(*) >= 10
)
SELECT
	c.L_City,
	c.active_listing,
	c.avg_active_price,
	h.avg_historical_sold,
	ROUND(c.avg_active_price / h.avg_historical_sold, 2) 
		AS ratio
FROM current_listing AS c
JOIN historic_sales AS h
	ON c.L_City = h.City
ORDER BY ratio DESC;
-- Result: Top result is Gridley with ratio > 3x


-- Week 6 Open-ended Challenge
-- "We're presenting to investors next week and they want to know: which cities are most 
-- competitive right now, and which represent the best opportunity for buyers?" 


-- Final Query for Competitive cities
WITH current_listings AS (
    SELECT
        L_City AS city,
        -- Current market
        COUNT(*) AS current_listings,
        AVG(L_SystemPrice) AS current_avg_list_price
    FROM rets_property
    WHERE L_City IS NOT NULL
    GROUP BY L_City
    HAVING COUNT(*) >= 50
),
historic_sales AS (
	SELECT
		City,
		COUNT(*) AS historic_sales,
		AVG(ClosePrice) AS avg_close_price,
		AVG(
			CASE
				WHEN ClosePrice < ListPrice THEN 1.0
				ELSE 0.0
			END
            ) * 100 AS pct_sold_below_list
    FROM california_sold_dedup
    WHERE City IS NOT NULL
    GROUP BY City
    HAVING COUNT(*) >= 50
),
current_historic AS (
	SELECT 
		c.City,
		ROUND(c.current_listings / h.historic_sales, 2) AS inventory_sales_ratio,
		ROUND(c.current_avg_list_price / h. avg_close_price, 2) AS price_ratio,
		ROUND(h.pct_sold_below_list, 2) AS pct_sold_below_list
	FROM current_listings AS c
	JOIN historic_sales AS h
        ON c.City = h.City
),
rankings AS (
	SELECT
		City,
        inventory_sales_ratio,
        RANK() OVER (
            ORDER BY inventory_sales_ratio ASC
        ) AS inventory_rank,
        price_ratio,
        RANK() OVER (
            ORDER BY price_ratio DESC
        ) AS price_ratio_rank,
        pct_sold_below_list,
        RANK() OVER (
            ORDER BY pct_sold_below_list ASC
        ) AS sold_below_list_rank
    FROM current_historic
)
SELECT
	City,
	inventory_sales_ratio,
	price_ratio,
	pct_sold_below_list,
	RANK() OVER (ORDER BY inventory_rank + price_ratio_rank + sold_below_list_rank ASC) AS competative_rank
FROM rankings;


-- Final Query for Buyers cities (Same as above but ordering reversed)
WITH current_listings AS (
    SELECT
        L_City AS City,
        COUNT(*) AS current_listings,
        AVG(L_SystemPrice) AS current_avg_list_price
    FROM rets_property
    WHERE L_City IS NOT NULL
    GROUP BY L_City
    HAVING COUNT(*) >= 50
),
historic_sales AS (
	SELECT
		City,
		COUNT(*) AS historic_sales,
		AVG(ClosePrice) AS avg_close_price,
		AVG(
			CASE
				WHEN ClosePrice < ListPrice THEN 1.0
				ELSE 0.0
			END
            ) * 100 AS pct_sold_below_list
    FROM california_sold_dedup
    WHERE City IS NOT NULL
    GROUP BY City
    HAVING COUNT(*) >= 50
),
current_historic AS (
	SELECT 
		c.City,
		ROUND(c.current_listings / h.historic_sales, 2) AS inventory_sales_ratio,
		ROUND(c.current_avg_list_price / h. avg_close_price, 2) AS price_ratio,
		ROUND(h.pct_sold_below_list, 2) AS pct_sold_below_list
	FROM current_listings AS c
	JOIN historic_sales AS h
        ON c.City = h.City
),
rankings AS (
	SELECT
		City,
        inventory_sales_ratio,
        RANK() OVER (
            ORDER BY inventory_sales_ratio DESC -- change to DESC high ratio good for buyers
        ) AS inventory_rank,
        price_ratio,
        RANK() OVER (
            ORDER BY price_ratio ASC -- change to ASC lower ratio good for buyers
        ) AS price_ratio_rank,
        pct_sold_below_list,
        RANK() OVER (
            ORDER BY pct_sold_below_list DESC -- change to DESC high pct good for buyers
        ) AS sold_below_list_rank
    FROM current_historic
)
SELECT
	City,
	inventory_sales_ratio,
	price_ratio,
	pct_sold_below_list,
	-- Same ranking as previous, but intermediate ranking has been reversed, also change alias buyer_rank 
	RANK() OVER (ORDER BY inventory_rank + price_ratio_rank + sold_below_list_rank ASC) AS buyer_rank
FROM rankings;