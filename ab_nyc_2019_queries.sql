/*
Internship Project 2 Proposal - Level 1 Data Analytics
Idea: Data Cleaning on Dataset
   
Key Concepts and Challenges:
- Data Integrity: Ensuring accuracy, consistency, and reliability
- Missing Data Handling: Imputing or handling gaps in the dataset
- Duplicate Removal: Identifying and eliminating duplicate records
- Standardization: Consistent formatting and units across columns
- Outlier Detection: Identifying and addressing extreme values
*/
   
-- 1. Data Integrity – Completeness & Validity
-- Check NULLs + invalid ranges across all columns
SELECT COUNT(*) AS invalid_rows
FROM listings
WHERE id IS NULL OR id <= 0
   OR name IS NULL OR TRIM(name)=''
   OR host_id IS NULL OR host_id <= 0
   OR host_name IS NULL OR TRIM(host_name)=''
   OR neighbourhood_group IS NULL OR TRIM(neighbourhood_group)=''
   OR neighbourhood IS NULL OR TRIM(neighbourhood)=''
   OR latitude NOT BETWEEN -90 AND 90
   OR longitude NOT BETWEEN -180 AND 180
   OR room_type IS NULL OR TRIM(room_type)=''
   OR price IS NULL OR price < 0
   OR minimum_nights IS NULL OR minimum_nights < 0
   OR number_of_reviews IS NULL OR number_of_reviews < 0
   OR last_review IS NULL OR last_review > CURDATE()
   OR reviews_per_month IS NULL OR reviews_per_month < 0
   OR calculated_host_listings_count IS NULL OR calculated_host_listings_count < 0
   OR availability_365 IS NULL OR availability_365 NOT BETWEEN 0 AND 365;
   
-- 2. Missing Data Handling – Imputation
-- Fill defaults for numeric, text, geo, and date columns.alter
   
-- Disable safe update mode temporarily
SET SQL_SAFE_UPDATES = 0;

-- Handle missing values across all 16 columns
UPDATE listings
SET id = COALESCE(id, 999999),  -- placeholder for missing IDs
    name = COALESCE(name, 'Unknown'),
    host_id = COALESCE(host_id, 0),
    host_name = COALESCE(host_name, 'Unknown'),
    neighbourhood_group = COALESCE(neighbourhood_group, 'Unknown'),
    neighbourhood = COALESCE(neighbourhood, 'Unknown'),
    latitude = COALESCE(latitude, 0),
    longitude = COALESCE(longitude, 0),
    room_type = COALESCE(room_type, 'Unknown'),
    price = COALESCE(price, 0),
    minimum_nights = COALESCE(minimum_nights, 1),
    number_of_reviews = COALESCE(number_of_reviews, 0),
    last_review = COALESCE(last_review, '2000-01-01'),
    reviews_per_month = COALESCE(reviews_per_month, 0),
    calculated_host_listings_count = COALESCE(calculated_host_listings_count, 0),
    availability_365 = COALESCE(availability_365, 0);

-- Re-enable safe update mode
SET SQL_SAFE_UPDATES = 1;

/*
3. Data Cleaning – Full Column Correction
Purpose: Handle missing values, normalize invalid ranges,
and standardize text, numeric, geo, and date columns
across all 16 attributes in the listings dataset.
*/

SET SQL_SAFE_UPDATES = 0;

UPDATE listings
SET 
-- ID columns
id = COALESCE(id, 999999),
host_id = COALESCE(host_id, 0),
-- Text columns (missing + standardization)
name = CASE 
WHEN name IS NULL OR TRIM(name) = '' THEN 'Unknown'
ELSE TRIM(CONCAT(UCASE(LEFT(name,1)), LCASE(SUBSTRING(name,2))))
END,
host_name = CASE 
WHEN host_name IS NULL OR TRIM(host_name) = '' THEN 'Unknown'
ELSE TRIM(CONCAT(UCASE(LEFT(host_name,1)), LCASE(SUBSTRING(host_name,2))))
END,
neighbourhood_group = CASE 
WHEN neighbourhood_group IS NULL OR TRIM(neighbourhood_group) = '' THEN 'Unknown'
ELSE UPPER(TRIM(neighbourhood_group))
END,
neighbourhood = CASE 
WHEN neighbourhood IS NULL OR TRIM(neighbourhood) = '' THEN 'Unknown'
ELSE TRIM(CONCAT(UCASE(LEFT(neighbourhood,1)), LCASE(SUBSTRING(neighbourhood,2))))
END,
room_type = CASE 
WHEN room_type IS NULL OR TRIM(room_type) = '' THEN 'Unknown'
ELSE TRIM(CONCAT(UCASE(LEFT(room_type,1)), LCASE(SUBSTRING(room_type,2))))
END,
-- Numeric columns (missing + invalid correction)
price = CASE WHEN price IS NULL THEN 0 ELSE ABS(price) END,
minimum_nights = CASE 
WHEN minimum_nights IS NULL THEN 1
WHEN minimum_nights < 0 THEN 1
WHEN minimum_nights > 365 THEN 365
ELSE minimum_nights END,
number_of_reviews = CASE WHEN number_of_reviews IS NULL THEN 0 ELSE ABS(number_of_reviews) END,
reviews_per_month = CASE 
WHEN reviews_per_month IS NULL THEN 0
WHEN reviews_per_month < 0 THEN 0
ELSE reviews_per_month END,
calculated_host_listings_count = CASE 
WHEN calculated_host_listings_count IS NULL THEN 0
ELSE ABS(calculated_host_listings_count) END,
availability_365 = CASE 
WHEN availability_365 IS NULL THEN 0
WHEN availability_365 < 0 THEN 0
WHEN availability_365 > 365 THEN 365
ELSE availability_365 END,
-- Geo columns
latitude = CASE 
WHEN latitude IS NULL THEN 0
WHEN latitude NOT BETWEEN -90 AND 90 THEN 0
ELSE latitude END,
longitude = CASE 
WHEN longitude IS NULL THEN 0
WHEN longitude NOT BETWEEN -180 AND 180 THEN 0
ELSE longitude END,
-- Date column
last_review = CASE 
WHEN last_review IS NULL THEN '2000-01-01'
WHEN last_review > CURDATE() THEN CURDATE()
ELSE last_review END;

-- 4. Duplicate Removal – Listing IDs + Full Row
-- Remove duplicate IDs and exact row duplicates

-- Duplicate listing IDs
DELETE l1 FROM listings l1
JOIN listings l2
ON l1.id = l2.id AND l1.id > l2.id;

-- Full row duplicates across all 16 columns
DELETE l1 FROM listings l1
JOIN listings l2
ON l1.id = l2.id
AND l1.name = l2.name
AND l1.host_id = l2.host_id
AND l1.host_name = l2.host_name
AND l1.neighbourhood_group = l2.neighbourhood_group
AND l1.neighbourhood = l2.neighbourhood
AND l1.latitude = l2.latitude
AND l1.longitude = l2.longitude
AND l1.room_type = l2.room_type
AND l1.price = l2.price
AND l1.minimum_nights = l2.minimum_nights
AND l1.number_of_reviews = l2.number_of_reviews
AND l1.last_review = l2.last_review
AND l1.reviews_per_month = l2.reviews_per_month
AND l1.calculated_host_listings_count = l2.calculated_host_listings_count
AND l1.availability_365 = l2.availability_365
AND l1.id > l2.id;

-- 5.Standardization – Text, Numeric, Date
-- Fix casing, trim spaces, enforce ranges
UPDATE listings
SET name = TRIM(CONCAT(UCASE(LEFT(name,1)), LCASE(SUBSTRING(name,2)))),
    host_name = TRIM(CONCAT(UCASE(LEFT(host_name,1)), LCASE(SUBSTRING(host_name,2)))),
    neighbourhood_group = UPPER(TRIM(neighbourhood_group)),
    neighbourhood = TRIM(CONCAT(UCASE(LEFT(neighbourhood,1)), LCASE(SUBSTRING(neighbourhood,2)))),
    room_type = TRIM(CONCAT(UCASE(LEFT(room_type,1)), LCASE(SUBSTRING(room_type,2)))),
    price = ABS(price),
    minimum_nights = ABS(minimum_nights),
    number_of_reviews = ABS(number_of_reviews),
    reviews_per_month = ABS(reviews_per_month),
    calculated_host_listings_count = ABS(calculated_host_listings_count),
    availability_365 = LEAST(GREATEST(availability_365,0),365),
    last_review = STR_TO_DATE(last_review,'%Y-%m-%d');
    
-- 6.Outlier Detection – Price, Nights, Reviews
-- Identify unrealistic values across numeric columns
SELECT id, price, minimum_nights, number_of_reviews, reviews_per_month,
       calculated_host_listings_count, availability_365
FROM listings
WHERE price > 1000
   OR minimum_nights > 365
   OR number_of_reviews > 1000
   OR reviews_per_month > 30
   OR calculated_host_listings_count > 100
   OR availability_365 > 365;

-- 7. Outlier Capping – Numeric Columns
-- Cap extreme values to realistic limits
UPDATE listings
SET price = LEAST(price,1000),
    minimum_nights = LEAST(minimum_nights,365),
    number_of_reviews = LEAST(number_of_reviews,1000),
    reviews_per_month = LEAST(reviews_per_month,30),
    calculated_host_listings_count = LEAST(calculated_host_listings_count,100),
    availability_365 = LEAST(availability_365,365);




   
   