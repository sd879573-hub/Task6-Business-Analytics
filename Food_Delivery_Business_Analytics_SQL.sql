/*
===========================================================
TASK 6 - BUSINESS ANALYTICS
Food Delivery Analytics - MySQL Implementation
===========================================================

Database: Task6_Business_Analytics

Dataset:
- Source: food_delivery_dataset.csv
- Imported rows: 20,000
- Unique orders: 20,000
- Unique customers: 20,000
- Restaurants: 100
- Food items: 21

Important data note:
The source dataset does not contain a true accounting Profit column.
Therefore, this implementation reports Revenue using order_value.
No field is labelled as actual Profit/Margin.
If an estimated contribution/profit metric is required later, it should be
defined explicitly as an assumption rather than presented as actual profit.

The raw CSV data was imported into raw_food_delivery using MySQL Workbench's
Table Data Import Wizard.
===========================================================
*/


/* =========================================================
   1. DATABASE
   ========================================================= */

CREATE DATABASE IF NOT EXISTS Task6_Business_Analytics;
USE Task6_Business_Analytics;


/* =========================================================
   2. RAW STAGING TABLE
   ========================================================= */

CREATE TABLE IF NOT EXISTS raw_food_delivery (
    order_id VARCHAR(20),
    restaurant_id INT,
    food_item VARCHAR(100),
    order_time DATE,
    delivery_time DATE,
    delivery_distance DECIMAL(10,2),
    order_value DECIMAL(12,2),
    delivery_method VARCHAR(30),
    traffic_condition VARCHAR(30),
    weather_condition VARCHAR(30),
    delivery_delay DECIMAL(10,2),
    route_taken VARCHAR(30),
    customer_id VARCHAR(30),
    age INT,
    gender VARCHAR(20),
    location VARCHAR(50),
    order_history INT,
    customer_rating INT,
    preferred_cuisine VARCHAR(50),
    order_frequency VARCHAR(30),
    loyalty_program VARCHAR(10),
    food_temperature VARCHAR(20),
    food_freshness INT,
    packaging_quality INT,
    food_condition VARCHAR(30),
    customer_satisfaction INT,
    small_route VARCHAR(5),
    bike_friendly_route VARCHAR(5),
    route_type VARCHAR(30),
    route_efficiency DECIMAL(10,6),
    traffic_avoidance VARCHAR(10)
);


/* =========================================================
   3. NORMALIZED TABLES
   ========================================================= */

CREATE TABLE IF NOT EXISTS Customers (
    customer_id VARCHAR(30) PRIMARY KEY,
    age INT,
    gender VARCHAR(20),
    location VARCHAR(50),
    preferred_cuisine VARCHAR(50),
    order_frequency VARCHAR(30),
    loyalty_program VARCHAR(10),
    customer_rating INT,
    customer_satisfaction INT
);


CREATE TABLE IF NOT EXISTS Products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    food_item VARCHAR(100) NOT NULL UNIQUE
);


CREATE TABLE IF NOT EXISTS Restaurants (
    restaurant_id INT PRIMARY KEY
);


CREATE TABLE IF NOT EXISTS Sales (
    order_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(30),
    product_id INT,
    restaurant_id INT,
    order_date DATE,
    delivery_date DATE,
    delivery_distance DECIMAL(10,2),
    order_value DECIMAL(12,2),
    delivery_method VARCHAR(30),
    traffic_condition VARCHAR(30),
    weather_condition VARCHAR(30),
    delivery_delay DECIMAL(10,2),
    route_taken VARCHAR(30),
    order_history INT,
    food_temperature VARCHAR(20),
    food_freshness INT,
    packaging_quality INT,
    food_condition VARCHAR(30),
    small_route VARCHAR(5),
    bike_friendly_route VARCHAR(5),
    route_type VARCHAR(30),
    route_efficiency DECIMAL(10,6),
    traffic_avoidance VARCHAR(10),

    FOREIGN KEY (customer_id)
        REFERENCES Customers(customer_id),

    FOREIGN KEY (product_id)
        REFERENCES Products(product_id),

    FOREIGN KEY (restaurant_id)
        REFERENCES Restaurants(restaurant_id)
);


/*
NOTE:
The following population statements were used during the project after
the CSV was imported into raw_food_delivery.

They are included as reference transformation logic.
If rerunning from an empty database, import the CSV into the raw staging
table first, then execute these statements.
*/


/* Customers */
INSERT INTO Customers (
    customer_id,
    age,
    gender,
    location,
    preferred_cuisine,
    order_frequency,
    loyalty_program,
    customer_rating,
    customer_satisfaction
)
SELECT DISTINCT
    customer_id,
    age,
    gender,
    location,
    preferred_cuisine,
    order_frequency,
    loyalty_program,
    customer_rating,
    customer_satisfaction
FROM raw_food_delivery
WHERE customer_id IS NOT NULL;


/* Products */
INSERT IGNORE INTO Products (food_item)
SELECT DISTINCT food_item
FROM raw_food_delivery
WHERE food_item IS NOT NULL;


/* Restaurants */
INSERT IGNORE INTO Restaurants (restaurant_id)
SELECT DISTINCT restaurant_id
FROM raw_food_delivery
WHERE restaurant_id IS NOT NULL;


/* Sales */
INSERT INTO Sales (
    order_id,
    customer_id,
    product_id,
    restaurant_id,
    order_date,
    delivery_date,
    delivery_distance,
    order_value,
    delivery_method,
    traffic_condition,
    weather_condition,
    delivery_delay,
    route_taken,
    order_history,
    food_temperature,
    food_freshness,
    packaging_quality,
    food_condition,
    small_route,
    bike_friendly_route,
    route_type,
    route_efficiency,
    traffic_avoidance
)
SELECT
    r.order_id,
    r.customer_id,
    p.product_id,
    r.restaurant_id,
    r.order_time,
    r.delivery_time,
    r.delivery_distance,
    r.order_value,
    r.delivery_method,
    r.traffic_condition,
    r.weather_condition,
    r.delivery_delay,
    r.route_taken,
    r.order_history,
    r.food_temperature,
    r.food_freshness,
    r.packaging_quality,
    r.food_condition,
    r.small_route,
    r.bike_friendly_route,
    r.route_type,
    r.route_efficiency,
    r.traffic_avoidance
FROM raw_food_delivery r
JOIN Products p
    ON r.food_item = p.food_item;


/* =========================================================
   4. DATA VALIDATION
   ========================================================= */

SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT order_id) AS UniqueOrders,
    COUNT(DISTINCT customer_id) AS UniqueCustomers,
    COUNT(DISTINCT restaurant_id) AS UniqueRestaurants,
    COUNT(DISTINCT food_item) AS UniqueFoodItems
FROM raw_food_delivery;


SELECT
    COUNT(*) AS TotalSales,
    COUNT(DISTINCT order_id) AS UniqueOrders,
    COUNT(DISTINCT customer_id) AS UniqueCustomers,
    COUNT(DISTINCT product_id) AS UniqueProducts,
    COUNT(DISTINCT restaurant_id) AS UniqueRestaurants
FROM Sales;


/* =========================================================
   5. ADVANCED SQL - RANK
   Top customers nationally
   ========================================================= */

SELECT
    customer_id,
    SUM(order_value) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(order_value) DESC
    ) AS revenue_rank
FROM Sales
GROUP BY customer_id
ORDER BY revenue_rank;


/* Top 10 customers nationally */
SELECT
    customer_id,
    SUM(order_value) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(order_value) DESC
    ) AS revenue_rank
FROM Sales
GROUP BY customer_id
ORDER BY revenue_rank
LIMIT 10;


/* =========================================================
   6. ADVANCED SQL - DENSE_RANK
   ========================================================= */

SELECT
    product_id,
    SUM(order_value) AS total_revenue,
    DENSE_RANK() OVER (
        ORDER BY SUM(order_value) DESC
    ) AS revenue_rank
FROM Sales
GROUP BY product_id
ORDER BY revenue_rank;


/* =========================================================
   7. TOP 3 CUSTOMERS PER REGION
   ========================================================= */

WITH RegionalCustomers AS (
    SELECT
        c.location AS region,
        c.customer_id,
        SUM(s.order_value) AS total_revenue,
        RANK() OVER (
            PARTITION BY c.location
            ORDER BY SUM(s.order_value) DESC
        ) AS regional_rank
    FROM Customers c
    JOIN Sales s
        ON c.customer_id = s.customer_id
    GROUP BY
        c.location,
        c.customer_id
)
SELECT
    region,
    customer_id,
    total_revenue,
    regional_rank
FROM RegionalCustomers
WHERE regional_rank <= 3
ORDER BY
    region,
    regional_rank;


/* =========================================================
   8. LAG - PREVIOUS MONTH
   ========================================================= */

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(order_value) AS monthly_revenue
    FROM Sales
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    sales_month,
    monthly_revenue,
    LAG(monthly_revenue) OVER (
        ORDER BY sales_month
    ) AS previous_month_revenue
FROM MonthlySales
ORDER BY sales_month;


/* =========================================================
   9. LEAD - NEXT MONTH
   ========================================================= */

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(order_value) AS monthly_revenue
    FROM Sales
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
    sales_month,
    monthly_revenue,
    LEAD(monthly_revenue) OVER (
        ORDER BY sales_month
    ) AS next_month_revenue
FROM MonthlySales
ORDER BY sales_month;


/* =========================================================
   10. CTE + MONTH-OVER-MONTH GROWTH
   ========================================================= */

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
        SUM(order_value) AS monthly_revenue
    FROM Sales
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
),
MonthlyComparison AS (
    SELECT
        sales_month,
        monthly_revenue,
        LAG(monthly_revenue) OVER (
            ORDER BY sales_month
        ) AS previous_month_revenue
    FROM MonthlySales
)
SELECT
    sales_month,
    monthly_revenue,
    previous_month_revenue,
    ROUND(
        (
            (monthly_revenue - previous_month_revenue)
            / NULLIF(previous_month_revenue, 0)
        ) * 100,
        2
    ) AS mom_growth_percent
FROM MonthlyComparison
ORDER BY sales_month;


/* =========================================================
   11. SUBQUERY
   Orders above the overall average order value
   ========================================================= */

SELECT
    customer_id,
    order_value,
    order_date
FROM Sales
WHERE order_value > (
    SELECT AVG(order_value)
    FROM Sales
)
ORDER BY order_value DESC;


/* =========================================================
   12. REPORTING VIEW - CUSTOMER KPIs
   ========================================================= */

CREATE OR REPLACE VIEW vw_CustomerKPIs AS
SELECT
    c.customer_id,
    c.age,
    c.gender,
    c.location,
    c.loyalty_program,
    c.customer_rating,
    c.customer_satisfaction,
    COUNT(s.order_id) AS total_orders,
    ROUND(SUM(s.order_value), 2) AS total_revenue,
    ROUND(AVG(s.order_value), 2) AS average_order_value,
    MAX(s.order_date) AS last_order_date
FROM Customers c
LEFT JOIN Sales s
    ON c.customer_id = s.customer_id
GROUP BY
    c.customer_id,
    c.age,
    c.gender,
    c.location,
    c.loyalty_program,
    c.customer_rating,
    c.customer_satisfaction;


/* =========================================================
   13. REPORTING VIEW - MONTHLY TREND
   ========================================================= */

CREATE OR REPLACE VIEW vw_MonthlyTrend AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    COUNT(order_id) AS total_orders,
    ROUND(SUM(order_value), 2) AS total_revenue,
    ROUND(AVG(order_value), 2) AS average_order_value
FROM Sales
GROUP BY DATE_FORMAT(order_date, '%Y-%m');


/* =========================================================
   14. REPORTING VIEW - PRODUCT PERFORMANCE
   ========================================================= */

CREATE OR REPLACE VIEW vw_ProductPerformance AS
SELECT
    p.product_id,
    p.food_item,
    COUNT(s.order_id) AS total_orders,
    ROUND(SUM(s.order_value), 2) AS total_revenue,
    ROUND(AVG(s.order_value), 2) AS average_order_value,
    ROUND(AVG(c.customer_satisfaction), 2) AS average_satisfaction,
    ROUND(AVG(s.food_freshness), 2) AS average_food_freshness
FROM Products p
LEFT JOIN Sales s
    ON p.product_id = s.product_id
LEFT JOIN Customers c
    ON s.customer_id = c.customer_id
GROUP BY
    p.product_id,
    p.food_item;


/* =========================================================
   15. REPORTING VIEW - REGIONAL SUMMARY
   ========================================================= */

CREATE OR REPLACE VIEW vw_RegionalSummary AS
SELECT
    c.location AS region,
    COUNT(s.order_id) AS total_orders,
    ROUND(SUM(s.order_value), 2) AS total_revenue,
    ROUND(AVG(s.order_value), 2) AS average_order_value,
    ROUND(AVG(c.customer_satisfaction), 2) AS average_satisfaction,
    ROUND(AVG(s.delivery_delay), 2) AS average_delivery_delay
FROM Customers c
JOIN Sales s
    ON c.customer_id = s.customer_id
GROUP BY c.location;


/* =========================================================
   16. STORED PROCEDURE - MONTHLY SUMMARY
   ========================================================= */

DELIMITER $$

CREATE PROCEDURE sp_MonthlySummary(IN p_report_month VARCHAR(7))
BEGIN

    SELECT
        p_report_month AS report_month,
        COUNT(s.order_id) AS total_orders,
        ROUND(SUM(s.order_value), 2) AS total_revenue,
        ROUND(AVG(s.order_value), 2) AS average_order_value,
        ROUND(AVG(s.delivery_delay), 2) AS average_delivery_delay,
        ROUND(AVG(c.customer_satisfaction), 2)
            AS average_customer_satisfaction
    FROM Sales s
    JOIN Customers c
        ON s.customer_id = c.customer_id
    WHERE DATE_FORMAT(s.order_date, '%Y-%m') = p_report_month;

END$$

DELIMITER ;


/* Example:
CALL sp_MonthlySummary('2024-01');
*/


/* =========================================================
   17. PERFORMANCE OPTIMIZATION / INDEXING
   ========================================================= */

CREATE INDEX idx_sales_order_date
ON Sales(order_date);

CREATE INDEX idx_sales_customer_id
ON Sales(customer_id);

CREATE INDEX idx_customers_location
ON Customers(location);


/* Verify indexes */
SHOW INDEX FROM Sales;
SHOW INDEX FROM Customers;


/* =========================================================
   18. QUERY EXECUTION PLAN
   ========================================================= */

EXPLAIN
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
    COUNT(*) AS total_orders,
    SUM(order_value) AS total_revenue
FROM Sales
WHERE order_date >= '2024-01-01'
  AND order_date < '2025-01-01'
GROUP BY DATE_FORMAT(order_date, '%Y-%m');


/* =========================================================
   19. VERIFY REPORTING OBJECTS
   ========================================================= */

SHOW FULL TABLES
WHERE Table_type = 'VIEW';

SHOW PROCEDURE STATUS
WHERE Db = 'Task6_Business_Analytics';


/* =========================================================
   END OF TASK 6 SQL IMPLEMENTATION
   ========================================================= */
