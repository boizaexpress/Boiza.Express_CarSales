--EDA
SELECT * 
    FROM car.sales.motor_discount;
------------------------------------------------------------------------------------------------------------------------------------------------

-- query of unique car model
SELECT DISTINCT model
    FROM car.sales.motor_discount
LIMIT 10;
------------------------------------------------------------------------------------------------------------------------------------------------

--inspect the composition of the inventory
SELECT make,
       model,
       year,
FROM car.sales.motor_discount;
------------------------------------------------------------------------------------------------------------------------------------------------

--data inspection to calculate a key business metric
SELECT model,
       SUM(sellingprice) AS total_price
FROM car.sales.motor_discount
GROUP BY model
LIMIT 10;
-------------------------------------------------------------------------------------------------------------------------------------------------
--specific models of Ford cars meet a very narrow set of criteria related to their condition, color, and transmission
SELECT model,
FROM car.sales.motor_discount
WHERE make = 'ford' AND color = 'white' AND condition BETWEEN 10 AND 35 AND transmission = 'automatic' 
-------------------------------------------------------------------------------------------------------------------------------------------------
--operation used to find the absolute minimum value within a numerical column
SELECT MIN(sellingprice) AS min_price
FROM car.sales.motor_discount;
-------------------------------------------------------------------------------------------------------------------------------------------------
--operation used to find the absolute maximum value within a numerical column
SELECT MAX(sellingprice) AS max_price
FROM car.sales.motor_discount;
-------------------------------------------------------------------------------------------------------------------------------------------------

SELECT DISTINCT(seller),
       make,
       model,
       year,
       saledate
FROM car.sales.motor_discount;
------------------------------------------------------------------------------------------------------------------------------------------------

-- SQL for SQL Server (T-SQL)
-- Must group by all non-aggregated columns in the SELECT list
-- Calculate the base timestamp once and use it in the main query
-- It's also critical to filter out nulls for the price and date calculations:
WITH SaleTimeData AS (
    -- 1. Base query: Filter nulls and include ALL necessary columns for the final SELECT
    SELECT
        year,
        make,
        model,
        trim,
        transmission,
        vin,
        state,
        condition,
        color,
        saledate,
        sellingprice,
        -- Calculate the FullTimestamp here.
        TRY_TO_TIMESTAMP(saledate, 'DY MON DD YYYY HH:MI:SS') AS FullTimestamp
    FROM
        car.sales.motor_discount
    WHERE 
        make IS NOT NULL
        AND sellingprice IS NOT NULL
        AND saledate IS NOT NULL
)

SELECT
    year,
    make,
    model,
    trim,
    transmission,
    vin,
    state,
    condition,
    color,
    saledate,
    
    FULLTIMESTAMP, 
    
    -- Extract the DATE and TIME parts
    CAST(FULLTIMESTAMP AS DATE) AS SaleDateOnly,
    CAST(FULLTIMESTAMP AS TIME) AS SaleTimeOnly,

    -- CASE Statement for Price Bucketing
    CASE
        WHEN sellingprice >= 150000 THEN 'Expensive'
        WHEN sellingprice >= 80000 AND sellingprice < 150000 THEN 'Reasonable'
        ELSE 'Cheap' 
    END AS price_bucket,

    -- Aggregation: Count and sum for each unique group 
    COUNT(*) AS total_sales_count,
    SUM(sellingprice) AS total_revenue

FROM
    SaleTimeData -- Querying the CTE is correct
    
-- Group by all non-aggregated columns using their unquoted names
GROUP BY
    year,
    make,
    model,
    trim,
    transmission,
    vin,
    state,
    condition,
    color,
    saledate,
    FULLTIMESTAMP,
    SaleDateOnly,
    SaleTimeOnly,
    price_bucket

LIMIT 20;
