
-- ============================================================ 
-- IDX Exchange — SQL Training
-- Week 1: Schema Exploration 
-- Tables: rets_property, rets_openhouse, california_sold (all 3)
-- Author: Zachary Blehm 
-- ============================================================ 


-- Summary
-- ============================================================
/* Week 1 Deliverables
 * #1 Columns w/ unexpected data types
 * In rets_property
 * LM_Dec_3 (Number of bathrooms) is a DECIMAL(4,1) should be INT
 * 
 * In rets_openhouse
 * OH_StartTime & OH_EndTime are TIME type (reference sheet has VARCHAR)
 * TIME type matches the data, suggest updating reference sheet
 * 
 * In california_sold (many incorrect datatypes)
 * ListingKey is BIGINT (reference sheet has VARCHAR) <-- problem for join w/ L_DisplayId (VARCHAR)
 * CloseDate is VARCHAR(255) (reference sheet has DATE)
 * ListPrice & ClosePrice are DOUBLE (reference sheet has DECIMAL)
 * LivingArea & BedroomsTotal are DOUBLE (reference sheet has INT)
 * YearBuild is DOUBLE (should be INT)
 * Stories is DOUBLE (should be INT)
 * ParkingTotal is DOUBLE (should be INT)
 * MainLevelBedrooms is DOUBLE (should be INT)
 * GarageSpaces is DOUBLE (should be INT)
 * Levels is VARCHAR(255) (should be INT?)
 * PurchaseContractDate & ListingContractDate are VARCHAR(255) (should be DATE?)
 * BathroomsTotal & BathroomsTotalInteger are DOUBLE (should be INT)
 * 
 * 
 * #2 NULL check rate for rets_property for select columns
 * price nulls = 0
 * bed nulls = 91
 * sqft nulls = 85
 * city nulls = 89
 * zip null = 7
 * city and zip both null = 6
 * address null = 143 <-- how can we have a listing w/o an address?
 * 
 * 
 * #3 Distribution of rets_property.L_Status
 * All rows have L_Status of Active (no NULLS)
 * 
 * 
 * #4 Sanity Check - Columns w/ impossible values
 * In rets_property we have min/max values that don't seem realistic
 * L_SystemPrice: min price 795, max 400,000,000
 * L_keyword2: min beds 0, max beds 52
 * LM_Int2_3: min sqft 0, max sqft 236,022
 * 
 * In rets_openhouse we have max year in the future and min time format issue
 * OpenHouseDate MAX is incorrect (year 4202) 
 * OH_StartDate MAX is incorrect (year 4202) 
 * OH_EndDate MAX is incorrect (year 4202)
 * OH_EndTime MIN is 07:00:00 (should be in 24-hr format e.g. 19:00:00?)
 * 
 * In california_sold has a question min ClosePrice and max year in the future
 * ClosePrice: min is 0 (sold for $0)
 * CloseDate: max is year 2072
 * 
 * 
 * #5 Duplicate check on L_DisplayId
 * There are 4 duplicated L_DisplayId values. 
 * 1178234327
 * 1178478543
 * 1178585070
 * 1178691980.
 * Each of the above L_DisplayId value is repeated twice.
 * Examining the rows shows all non-NULL attributes (except id) are identical.
 * The duplicated rows should be dropped (id: 319906, 319904, 319899, 319894)
 * 
 * 
 * #6 Cardinality check between rets_propery and rets_openhouse
 * For rets_openhouse.L_DisplayId distinct and total rows are equal.
 * This means there are no repeated or missing (null) values in the column.
 * 
 * There are:
 * 41,012 listings w/o an openhouse
 * 1,664 openhouse w/o a listing
 * 13,426 matching listing/openhouse counting dupicates from listing
 * 13,424 matching openhouse/listing (unique openhouse)
 * 
 * 41,012 + 13,426 = 54,438 total listings - CORRECT
 * 1,664 + 13,424 = 15,088 total openhouse - CORRECT
 * 
 * There are duplicated rows in rets_property, but after dropping these
 * duplicates, this relationship will be 1 (optional) to 1 (optional).
 * 
 * 
 * #7 City name mismatch check between rets_property and rets_openhouse
 * There are 82 cities in california_sold that do not appear in rets_property.
 * We conclude there are cities where houses are being sold, but not listed.
 * 
 * Below are the SQL queries which give these results
 * 
 * 
 * Week 1 Open-Ended Challenge
 * Question: "Before we start any analysis on this database I want to know: 
 * How trustworthy is the data?
 * What should analysts be aware of before drawing conclusions?"
 * 
 * Analysists should be aware of several possible corrupting factors in the data.
 * As an example NULL (missing values) may exist within a column.
 * Also the data may contain incorrect values. Some incorrect values we may be
 * able to identify for example a date that is in the future, a negative or
 * fractional value when we expect a positive integer, or an outlier that is
 * simply too small or too big. The data may also contain duplicated data, 
 * which can skew results if not eliminated from the dataset. Finally there may
 * be inconsistencies in the data for example if data is duplicated across 
 * multiple tables, but the values (or type) across the tables do not match 
 * then we have inconsistencies in our data.
 * 
 * As for the given dataset, we see many of these issues and provide just 
 * a few examples as follows:
 * There are NULLS in columns of importance such as california_sold.ClosingPrice
 * and rets_property.L_Address. Additionally there are outliers, such as maximum
 * L_SystemPrice of $400,000,000 which is about 2x more than the most expensive
 * house in California, so this may be an incorrect value or not a home but
 * commercial real estate. There are also some duplicated rows in rets_property
 * which should be dropped. Finally there are some inconsistencies for example
 * the datatype of rets_property.L_Display (VARCHAR) and 
 * california_sold.ListingKey (BIGINT but should be VARCHAR) which needs to be
 * accounted for before joining this data. 
 * 
 * Additional results are explained below in more detail.
 */
-- ============================================================


-- Exercise 1.1 Discover What Tables Exist
-- List all tables 
SHOW TABLES; 

  -- More detail: table sizes and row counts via INFORMATION_SCHEMA  
SELECT 
	table_name,
	table_rows,
  	ROUND(data_length / (1024*1024), 2) AS size_mb
FROM information_schema.tables
WHERE table_schema = 'rets'
ORDER BY table_rows DESC; 


-- Exercise 1.2 Understand a Table's Structure
-- Quick column overview
DESCRIBE rets_property;
-- Results: LM_Dec_3 (Number of bathrooms) is a DECIMAL(4,1) should be INT


-- Full detail via INFORMATION_SCHEMA
SELECT 
	column_name,
	data_type,
	is_nullable,
	character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'rets'
	AND table_name = 'rets_property'
ORDER BY ordinal_position;

-- What is the difference between L_DispalyId and L_Listingkey?
SELECT 
	rp.L_DisplayId, 
	rp.L_ListingID 
FROM rets_property rp
LIMIT 10;
-- Results: These seem identical, investigate further

-- How many rows haev different L_DispalyId and L_Listingkey values?
SELECT 
	COUNT(*)
FROM rets_property rp
WHERE rp.L_DisplayId != rp.L_ListingID;
-- Results: Count is 0, these columns are the same

-- Quick column overview
DESCRIBE rets_openhouse;
-- Results: OH_StartTime & OH_EndTime are TIME type (reference sheet has VARCHAR)

-- Full detail via INFORMATION_SCHEMA
SELECT 
	column_name,
	data_type,
	is_nullable,
	character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'rets'
	AND table_name = 'rets_openhouse'
ORDER BY ordinal_position;


-- Exercise 1.3 Profile Column Quality
-- NULL rate check across key columns of rets_property
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN L_SystemPrice IS NULL THEN 1 ELSE 0 END) AS price_nulls,
	SUM(CASE WHEN L_Keyword2 IS NULL THEN 1 ELSE 0 END) AS bed_nulls,
	SUM(CASE WHEN LM_Int2_3 IS NULL THEN 1 ELSE 0 END) AS sqft_nulls,
	SUM(CASE WHEN L_City IS NULL THEN 1 ELSE 0 END) AS city_nulls,
	SUM(CASE WHEN L_Zip IS NULL THEN 1 ELSE 0 END) AS zip_nulls,
	SUM(CASE WHEN L_City IS NULL 
		AND L_Zip IS NULL THEN 1 ELSE 0 END) AS city_and_zip_nulls,
	SUM(CASE WHEN L_Address IS NULL THEN 1 ELSE 0 END) AS address_nulls
FROM rets_property;
/* Results:
 * price nulls = 0
 * bed nulls = 91
 * sqft nulls = 85
 * city nulls = 89
 * zip null = 7
 * city and zip both null = 6
 * address null = 143 <-- how can we have a listing w/o an address?
 */

-- Distribution check: what values does L_Status actually contain?
SELECT 
	L_Status,
	COUNT(*) AS total
FROM rets_property
GROUP BY L_Status
ORDER BY total DESC;
-- Results: L_Status = "Active" for all rows

-- Sanity check: are numeric columns within realistic ranges?
SELECT
	MIN(L_SystemPrice) AS min_price,
	MAX(L_SystemPrice) AS max_price,
	MIN(L_keyword2) AS min_beds,
	MAX(L_keyword2) AS max_beds,
	MIN(LM_Int2_3) AS min_sqft,
	MAX(LM_Int2_3) AS max_sqfts
FROM rets_property
WHERE L_SystemPrice IS NOT NULL;
/* Results: mins are too low, maxs are too high
 * min price 795, max 400,000,000
 * min beds 0, max beds 52
 * min sqft 0, max sqft 236,022
 */

-- NULL rate check across key columns of rets_openhouse
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN OpenHouseDate IS NULL THEN 1 ELSE 0 END) AS date_nulls,
	SUM(CASE WHEN OH_StartDate IS NULL THEN 1 ELSE 0 END) AS start_time_nulls,
	SUM(CASE WHEN OH_EndTime IS NULL THEN 1 ELSE 0 END) AS end_time_nulls
FROM rets_openhouse;
-- Results: No NULLs for these columns

-- Sanity check: are date columns within realistic ranges?
SELECT
	MIN(OpenHouseDate) AS min_oh_date,
	MAX(OpenHouseDate) AS max_oh_date,
	MIN(OH_StartTime ) AS min_oh_start_time,
	MAX(OH_StartTime ) AS max_oh_start_time,
	MIN(OH_EndTime) AS min_oh_end_time,
	MAX(OH_EndTime) AS max_oh_end_time,
	MIN(OH_StartDate) AS min_oh_start_date,
	MAX(OH_StartDate) AS max_oh_start_date,
	MIN(OH_EndDate) AS min_oh_end_date,
	MAX(OH_EndDate) AS max_oh_end_date
FROM rets_openhouse;
/* 
 * Results: 
 * OpenHouseDate MAX is incorrect (year 4202) 
 * OH_StartDate MAX is incorrect (year 4202) 
 * OH_EndDate MAX is incorrect (year 4202)
 * OH_EndTime MIN is 07:00:00 (should be in 24-hr format e.g. 19:00:00?)
 * MIN and MAX agree between the date columns
 */

-- Exerciese 1.4 Check for Duplicates
-- Quick summary: total rows vs distinct L_DisplayIds
SELECT
	COUNT(*) AS total_rows,
	COUNT(DISTINCT L_DisplayId) AS distinct_ids,
	COUNT(*) - COUNT(DISTINCT L_DisplayId) AS duplicates
FROM rets_property;
-- Results: 4 duplicates found

-- Detail: which L_DisplayIds appear more than once?
SELECT 
	L_DisplayId,
	COUNT(*) AS occurences
FROM rets_property
GROUP BY L_DisplayId
HAVING COUNT(*) > 1
ORDER BY occurences DESC;
-- Results: 4 L_DisplayId returned as expected

-- Are the duplicate L_DisplayId from the previous query full duplicate rows?
SELECT *
FROM rets_property
WHERE L_DisplayId IN (
	-- Use the previous query to get the duplicate L_DisplayId
	SELECT 
		L_DisplayId
	FROM rets_property
	GROUP BY L_DisplayId
	HAVING COUNT(*) > 1)
ORDER BY L_ListingId;
/* Results: Duplicated L_DisplayId are indentical for all non-NULL columns except id
 * These duplicates should be removed.
 */

-- Quick summary: total rows vs distinct L_DisplayIds
SELECT
	COUNT(*) AS total_rows,
	COUNT(DISTINCT L_DisplayId) AS distinct_ids,
	COUNT(*) - COUNT(DISTINCT L_DisplayId) AS duplicates
FROM rets_openhouse;
-- Results: No duplicates found in the above query


-- 1.5 Cardinality Check Between Tables
-- How many open house rows exist per listing? (expect one-to-many)
SELECT
	COUNT(DISTINCT L_DisplayId) AS distinct_listings,
	COUNT(*) AS total_rows,
	ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT L_DisplayId), 1) AS avg_rows_per_listing
FROM rets_openhouse;
-- Results: distinct and total rows are equal, average of 1.0 row per listing

-- How many rets_property listing have NO match in rets_openhouse?
SELECT
	COUNT(*) AS listing_without_openhouse
FROM rets_property AS p
WHERE NOT EXISTS (
	SELECT 1 
	FROM rets_openhouse AS o 
	WHERE o.L_DisplayId = p.L_DisplayId
);
-- Results: 41012 listings without an openhouse

-- How many rets_openhouse listing have NO match in rets_property?
SELECT
	COUNT(*) AS openhouse_without_listing
FROM rets_openhouse AS o
WHERE NOT EXISTS (
	SELECT 1 
	FROM rets_property AS p 
	WHERE o.L_DisplayId = p.L_DisplayId
);
-- Results: 1664 openhouse without a matching listing 

-- How many listing in rets_property have a match in rets_openhouse?
SELECT 
	COUNT(*) AS num_rows_match
FROM rets_property AS p
INNER JOIN rets_openhouse AS o
	ON o.L_DisplayId = p.L_DisplayId;
-- Results: 13426 listings with a matching openhouse 
-- NOTE: This result includes duplicate p.L_DisplayId

-- How many rets_openhouse listing have a match in rets_property?
SELECT 
	COUNT(DISTINCT o.L_DisplayId ) AS num_rows_match
FROM rets_property AS p
INNER JOIN rets_openhouse AS o
	ON o.L_DisplayId = p.L_DisplayId;
-- Results: 13424 openhouse with a matching listing
-- NOTE: This result is unique matches, no duplicates


-- 1.6 Repeat for california_sold
-- Quick column overview
DESCRIBE california_sold;
/* 
 * Results: 
 * ListingKey is BIGINT (reference sheet has VARCHAR) <-- problem for join w/ L_DisplayId (VARCHAR)
 * CloseDate is VARCHAR(255) (reference sheet has DATE)
 * ListPrice & ClosePrice are DOUBLE (reference sheet has DECIMAL)
 * LivingArea & BedroomsTotal are DOUBLE (reference sheet has INT)
 * YearBuild is DOUBLE (should be INT)
 * Stories is DOUBLE (should be INT)
 * ParkingTotal is DOUBLE (should be INT)
 * MainLevelBedrooms is DOUBLE (should be INT)
 * GarageSpaces is DOUBLE (should be INT)
 * Levels is VARCHAR(255) (should be INT?)
 * PurchaseContractDate & ListingContractDate are VARCHAR(255) (should be DATE?)
 * BathroomsTotal & BathroomsTotalInteger are DOUBLE (should be INT)
 */

-- Full detail via INFORMATION_SCHEMA
SELECT 
	column_name,
	data_type,
	is_nullable,
	character_maximum_length
FROM information_schema.columns
WHERE table_schema = 'rets'
	AND table_name = 'california_sold'
ORDER BY ordinal_position;

-- NULL rate check across key columns for california_sold
SELECT
	COUNT(*) AS total_rows,
	SUM(CASE WHEN ListingKey IS NULL THEN 1 ELSE 0 END) AS listing_key_nulls,
	SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS city_nulls,
	SUM(CASE WHEN PostalCode IS NULL THEN 1 ELSE 0 END) AS zip_nulls,
	SUM(CASE WHEN ListPrice IS NULL THEN 1 ELSE 0 END) AS list_price_nulls,
	SUM(CASE WHEN ClosePrice IS NULL THEN 1 ELSE 0 END) AS close_price_nulls,
	SUM(CASE WHEN BedroomsTotal IS NULL THEN 1 ELSE 0 END) AS bedroom_nulls,
	SUM(CASE WHEN LivingArea IS NULL THEN 1 ELSE 0 END) AS living_area_nulls,
	SUM(CASE WHEN CloseDate IS NULL THEN 1 ELSE 0 END) AS close_date_nulls
FROM california_sold;
/*Result: number of nulls
 * ListingKey - 0
 * City - 10
 * PostalCode - 2
 * ListPrice - 0
 * ClosePrice - 2 <--
 * BedroomsTotal - 1
 * LivingArea - 39
 * CloseDate - 0
 */

-- Sanity check: are numeric columns within realistic ranges?
SELECT
	MIN(ListPrice) AS min_list_price,
	MAX(ListPrice) AS max_list_price,
	MIN(ClosePrice) AS min_close_price,
	MAX(ClosePrice) AS max_close_price,
	MIN(BedroomsTotal) AS min_bedrooms,
	MAX(BedroomsTotal) AS max_bedrooms,
	MIN(LivingArea) AS min_area,
	MAX(LivingArea) AS max_area,
	MIN(CloseDate) AS min_date,
	MAX(CloseDate) AS max_date
FROM california_sold
WHERE ClosePrice IS NOT NULL;
/* Results: some questionable values 
 * min list price = 1.0
 * min close price = 0
 * min bedrooms = 0
 * max bedrooms = 36
 * min area = 0.0
 * max date = 2072-06-29 <--
 */

-- Do city names match between the listing and sold tables?
-- Cities in california_sold but NOT in rets_property
SELECT DISTINCT City
FROM california_sold
WHERE City NOT IN (
	SELECT DISTINCT L_City
	FROM rets_property
	WHERE L_City IS NOT NULL
)
ORDER BY City;

SELECT COUNT(DISTINCT City)
FROM california_sold
WHERE City NOT IN (
	SELECT DISTINCT L_City
	FROM rets_property
	WHERE L_City IS NOT NULL
)
ORDER BY City;
/* Results: 82 cities returned.
 * There are many cities in the sold data not in the listing data.
 */


-- Week 1 Debugging Exercise
-- BROKEN: Count listing with missing price
SELECT COUNT(*) AS missing_prices
FROM rets_property
WHERE L_SystemPrice = NULL; -- Bug: this will never match anything

-- Corrected version
SELECT COUNT(*) AS missing_prices
FROM rets_property
WHERE L_SystemPrice IS NULL; -- Fix: change = NULL to IS NULL
-- Explanation: NULL is not a value and cannot be compared with = or !=

-- Compare total listing with non-null price listings
SELECT
	COUNT(*) AS total_listings,
	COUNT(L_SystemPrice) AS not_null_prices
FROM rets_property;
-- Results: values match, confirms there are no listing with NULL price


-- Other Analysis

SELECT 
	rp.L_DisplayId, 
	rp.L_ListingID 
FROM rets_property rp
LIMIT 10;
-- Identical resulsts, it seems like these two columns are identical


