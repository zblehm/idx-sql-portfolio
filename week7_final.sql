-- ============================================================ 
-- IDX Exchange — SQL Training
-- Week 7: Portfolio Completion & GitHub Presentation
-- Tables: rets_property, california_sold, rets_openhouse
-- Author: Zachary Blehm 
-- ============================================================ 

-- Summary
-- ============================================================
/* Week 7 Open-Ended Challenge
 * "I need one clean summary table I can put on a slide. For each major city: how many active 
 * listings, average active price, average historical sold price, sale-to-list ratio, and a label of 
 * either 'Competitive Market', 'Buyer Opportunity', or 'Balanced Market' based on the data." 
 * 
 * Top 25 cities based on total listings
 * market_type derived from dividing data in thirds based on sale_to_list_ratio
 * lowest third of ratios = Competative Market
 * middle third of ratios = Balanced Market
 * top third of ratios = Buyers Market
 * 
 * City				avg_active_price		avg_historical_sold_price	sale_to_list_ratio	market_type
 * ----				----------------		-------------------------	------------------	-----------
 * Los Angeles		$2,731,802					$1,687,553				0.62				Competative Market
 * San Diego		$1,133,479					$1,180,717				1.04				Buyers Market
 * San Jose			$1,391,519					$1,510,576				1.09				Buyers Market
 * Irvine			$2,011,706					$1,750,429				0.87				Balanced Market
 * Long Beach		$1,031,465					$994,719				0.96				Balanced Market
 * Palm Springs		$958,799					$916,637				0.96				Balanced Market
 * Palm Desert		$722,270					$783,903				1.09				Buyers Market
 * Riverside		$864,562					$737,546				0.85				Balanced Market
 * Temecula			$1,186,834					$875,742				0.74				Competative Market
 * Victorville		$472,787					$439,226				0.93				Balanced Market
 * Indio			$561,087					$562,677				1.0					Buyers Market
 * Lake Arrowhead	$1,041,650					$742,833				0.71				Competative Market
 * Oakland			$754,978					$1,046,807				1.39				Buyers Market
 * Lancaster		$523,513					$488,739				0.93				Balanced Market
 * Hemet			$463,458					$414,875				0.9					Balanced Market
 * Murrieta			$979,097					$726,103				0.74				Competative Market
 * Corona			$900,732					$805,639				0.89				Balanced Market
 * Palmdale			$592,087					$548,083				0.93				Balanced Market
 * Menifee			$657,967					$575,054				0.87				Balanced Market
 * Ontario			$712,508					$673,993				0.95				Balanced Market
 * Malibu			$9490,577					$6106,435				0.64				Competative Market
 * Apple Valley		$509,376					$458,605				0.9					Balanced Market
 * Escondido		$1,104,381					$941,695				0.85				Balanced Market
 * Huntington Beach	$1,885,511					$1,514,573				0.8					Balanced Market
 * La Quinta		$1,428,958					$1,341,495				0.94				Balanced Market
 */
-- ============================================================
-- Week 7 Open-ended Challenge

WITH current_listings AS (
    SELECT
        L_City AS City,
        COUNT(*) AS total_listings,
        AVG(L_SystemPrice) AS avg_active_price
    FROM rets_property
    WHERE L_City IS NOT NULL
    	AND L_Status = 'Active'
    GROUP BY L_City
),
historic_sales AS (
	SELECT
		City,
		AVG(ClosePrice) AS avg_historical_sold_price
	FROM california_sold_dedup
    WHERE City IS NOT NULL
    GROUP BY City
),
current_historic AS (
	SELECT 
		c.City,
		c.total_listings,
		c.avg_active_price,
		h.avg_historical_sold_price,
		ROUND(h.avg_historical_sold_price / c.avg_active_price, 2) AS sale_to_list_ratio,
		-- lower third = 'Competative Market', middle third = 'Balanced Market', upper third = 'Buyers Market'
		NTILE(3) OVER (ORDER BY avg_historical_sold_price / avg_active_price ASC) AS thirds
	FROM current_listings AS c
	JOIN historic_sales AS h
        ON c.City = h.City
)
SELECT
	City,
	ROUND(avg_active_price, 0) AS avg_active_price,
	ROUND(avg_historical_sold_price, 0) AS avg_historical_sold_price,
	sale_to_list_ratio,
	-- use the thirds for markety_type
	-- alternative would be to use a cutoff value for the sale_to_list_ratio
	CASE
		WHEN thirds = 1 THEN 'Competative Market'
		WHEN thirds = 2 THEN 'Balanced Market'
		ELSE 'Buyers Market'
	END AS market_type
FROM current_historic
ORDER BY total_listings DESC
-- Major cities = 25 cities with the most listings
LIMIT 25;