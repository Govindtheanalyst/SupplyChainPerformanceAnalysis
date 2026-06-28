
CREATE TABLE orders (
    type TEXT,
    days_for_shipping_real INTEGER,
    days_for_shipment_scheduled INTEGER,
    benefit_per_order NUMERIC(12,2),
    sales_per_customer NUMERIC(12,2),
    delivery_status TEXT,
    late_delivery_risk INTEGER,
    category_id INTEGER,
    category_name TEXT,
    customer_city TEXT,
    customer_country TEXT,
    customer_id INTEGER,
    customer_segment TEXT,
    customer_state TEXT,
    department_id INTEGER,
    department_name TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    market TEXT,
    order_city TEXT,
    order_country TEXT,
    order_customer_id INTEGER,
    order_date_dateorders TIMESTAMP,
    order_id INTEGER,
    order_item_cardprod_id INTEGER,
    order_item_discount NUMERIC(12,2),
    order_item_discount_rate NUMERIC(12,4),
    order_item_id INTEGER,
    order_item_product_price NUMERIC(12,2),
    order_item_profit_ratio NUMERIC(12,4),
    order_item_quantity INTEGER,
    sales NUMERIC(12,2),
    order_item_total NUMERIC(12,2),
    order_profit_per_order NUMERIC(12,2),
    order_region TEXT,
    order_state TEXT,
    order_status TEXT,
    product_card_id INTEGER,
    product_category_id INTEGER,
    product_name TEXT,
    product_price NUMERIC(12,2),
    product_status INTEGER,
    shipping_date_dateorders TIMESTAMP,
    shipping_mode TEXT,
    order_year INTEGER,
    order_month INTEGER,
    order_month_name TEXT,
    order_day INTEGER,
    order_day_name TEXT,
    order_quarter INTEGER,
    shipping_delay INTEGER,
    late_delivery TEXT
);

----------------------------------------------------------
-- SECTION 1 : Executive KPIs
----------------------------------------------------------

-- Query 1: Total Orders
SELECT COUNT(*) AS total_orders
FROM orders;

-- Query 2: Total Sales and Profit
SELECT
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(order_profit_per_order),2) AS total_profit
FROM orders;

-- Query 3: Total Customers and Products
SELECT
    COUNT(DISTINCT customer_id) AS total_customers,
    COUNT(DISTINCT product_name) AS total_products
FROM orders;

-- Query 4: Late Delivery Rate
SELECT
    COUNT(*) AS total_orders,
    SUM(late_delivery_risk) AS late_orders,
    ROUND(AVG(late_delivery_risk) * 100,2) AS late_delivery_percentage
FROM orders;

-- Query 5: Average Shipping Delay
SELECT
    ROUND(AVG(shipping_delay),2) AS avg_shipping_delay
FROM orders;

----------------------------------------------------------
-- SECTION 2 : Shipping Performance
----------------------------------------------------------

-- Query 6: Shipping Mode Performance
SELECT
    shipping_mode,
    COUNT(*) AS total_orders,
    ROUND(AVG(shipping_delay),2) AS avg_delay,
    ROUND(AVG(late_delivery_risk)*100,2) AS late_delivery_percentage
FROM orders
GROUP BY shipping_mode
ORDER BY late_delivery_percentage DESC;

-- Query 7: Delivery status
SELECT
    delivery_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY delivery_status
ORDER BY total_orders DESC;

-- Query 8: Average VS Actual Scheduled Shipping
SELECT
    ROUND(AVG(days_for_shipping_real),2) AS avg_actual_days,
    ROUND(AVG(days_for_shipment_scheduled),2) AS avg_scheduled_days
FROM orders;

----------------------------------------------------------
-- SECTION 3 : Geographic Analysis
----------------------------------------------------------

-- Query 9: Top 10 Regions by Delay
SELECT
    order_region,
    COUNT(*) AS total_orders,
    ROUND(AVG(shipping_delay),2) AS avg_delay
FROM orders
GROUP BY order_region
ORDER BY avg_delay DESC
LIMIT 10;

-- Query 10: Countries with Highest Late Delivery %
SELECT
    order_country,
    COUNT(*) AS total_orders,
    ROUND(AVG(late_delivery_risk)*100,2) AS late_delivery_percentage
FROM orders
GROUP BY order_country
HAVING COUNT(*) >= 100
ORDER BY late_delivery_percentage DESC;

----------------------------------------------------------
-- SECTION 4 : Product Analysis
----------------------------------------------------------

-- Query 11: Top 10 Revenue Generating Products

SELECT
    product_name,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(order_profit_per_order),2) AS total_profit,
    COUNT(*) AS total_orders
FROM orders
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

-- Query 12: Product Category with Highest Sales
SELECT
    category_name,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(order_profit_per_order),2) AS total_profit,
    COUNT(*) AS total_orders
FROM orders
GROUP BY category_name
ORDER BY total_sales DESC;

-- Query 13: Categories with Highest Average Shipping Delay
SELECT
    category_name,
    ROUND(AVG(shipping_delay),2) AS avg_delay,
    ROUND(AVG(late_delivery_risk)*100,2) AS late_delivery_percentage
FROM orders
GROUP BY category_name
ORDER BY avg_delay DESC;

-- Query 14: Most Profitable Categories
SELECT
    category_name,
    ROUND(SUM(order_profit_per_order),2) AS total_profit
FROM orders
GROUP BY category_name
ORDER BY total_profit DESC;

-- Query 15: High Revenue but High Delay Products
SELECT
    product_name,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(AVG(shipping_delay),2) AS avg_delay
FROM orders
GROUP BY product_name
HAVING SUM(sales) > (
    SELECT AVG(product_sales)
    FROM (
        SELECT SUM(sales) AS product_sales
        FROM orders
        GROUP BY product_name
    ) 
)
ORDER BY avg_delay DESC
LIMIT 15;

----------------------------------------------------------
-- SECTION 5 : Customer Analysis
----------------------------------------------------------

-- Query 16: Top 10 Customers by Revenue

SELECT
	customer_id,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(order_profit_per_order),2) AS total_profit,
	COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 10;

-- Query 17: Customer Segments
SELECT
	customer_segment,
	COUNT(*) AS total_orders,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(order_profit_per_order),2) AS total_profit
FROM orders
GROUP BY customer_segment
ORDER BY total_sales DESC;

-- Query 18: Customer Segments with Highest Late Deliveries
SELECT
	customer_segment,
	ROUND(AVG(late_delivery_risk)*100,2) AS late_delivery_percentage,
	ROUND(AVG(shipping_delay),2) AS avg_delay
FROM orders
GROUP BY customer_segment
ORDER BY late_delivery_percentage DESC;

--	Query 19: Countries with Highest Revenue
SELECT
	customer_country,
	ROUND(SUM(sales),2) AS total_sales,
	COUNT(*) AS total_orders
FROM orders
GROUP BY customer_country
ORDER BY total_sales DESC
LIMIT 15;

-- Query 20: Average Order Value by Segment
SELECT
	customer_segment,
	ROUND(AVG(sales),2) AS avg_order_value
FROM orders
GROUP BY customer_segment
ORDER BY avg_order_value DESC;

----------------------------------------------------------
-- SECTION 6 : Revenue and Profit Analysis
----------------------------------------------------------

-- Query 21: Revenue by Market
SELECT
	market,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(order_profit_per_order),2) AS total_profit
FROM orders
GROUP BY market
ORDER BY total_sales DESC;

-- Query 22: Revenue Lost to Late Deliveries
SELECT
	late_delivery,
	ROUND(SUM(sales),2) AS total_sales,
	ROUND(SUM(order_profit_per_order),2) AS total_profit,
	COUNT(*) AS total_orders
FROM orders
GROUP BY late_delivery;

--Query 23: Most Profitable Markets
SELECT
	market,
	ROUND(SUM(order_profit_per_order),2) AS total_profit
FROM orders
GROUP BY market
ORDER BY total_profit DESC;

--Query 24: Profit Margin by Category
SELECT
	category_name,
	ROUND(AVG(order_item_profit_ratio)*100,2) AS avg_profit_margin
FROM orders
GROUP BY category_name
ORDER BY avg_profit_margin DESC;

--Query 25: High Revenues, Low Profit Categories
SELECT
	category_name,
	ROUND(SUM(sales),2) AS revenue,
	ROUND(SUM(order_profit_per_order),2) AS profit
FROM orders
GROUP BY category_name
ORDER BY revenue DESC;

----------------------------------------------------------
-- SECTION 7 : Time Series Analysis
----------------------------------------------------------

-- Query 26: Monthly Sales Trend
SELECT
    order_year,
    order_month,
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(order_profit_per_order),2) AS total_profit,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- Query 27: Monhly late Delivery %
SELECT
    order_year,
    order_month,
    ROUND(AVG(late_delivery_risk)*100,2) AS late_delivery_percentage
FROM orders
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

-- Query 28: Quarterly Performance
SELECT
    order_year,
    order_quarter,
    ROUND(SUM(sales),2) AS revenue,
    ROUND(SUM(order_profit_per_order),2) AS profit
FROM orders
GROUP BY order_year, order_quarter
ORDER BY order_year, order_quarter;

-- Query 29: Best Month by Revenue
SELECT
    order_month_name,
    ROUND(SUM(sales),2) AS revenue
FROM orders
GROUP BY order_month_name
ORDER BY revenue DESC;

-- Query 30: Orders by Weekday
SELECT
    order_day_name,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_day_name
ORDER BY total_orders DESC;

----------------------------------------------------------
-- SECTION 8 : Advanced SQL
----------------------------------------------------------

-- Query 31: Rank Regions by Revenue
SELECT
    order_region,
    ROUND(SUM(sales),2) AS revenue,
    RANK() OVER (
        ORDER BY SUM(sales) DESC
    ) AS revenue_rank
FROM orders
GROUP BY order_region;

-- Query 32: Top Products In Every Category
WITH ranked_products AS (

SELECT
    category_name,
    product_name,
    SUM(sales) AS revenue,

    ROW_NUMBER() OVER(
        PARTITION BY category_name
        ORDER BY SUM(sales) DESC
    ) AS rn

FROM orders
GROUP BY category_name, product_name

)

SELECT
    category_name,
    product_name,
    ROUND(revenue,2) AS revenue
FROM ranked_products
WHERE rn = 1;

-- Query 33: Running Total Sales
SELECT
    order_year,
    order_month,

    ROUND(SUM(sales),2) AS monthly_sales,

    ROUND(
        SUM(SUM(sales))
        OVER(
            ORDER BY order_year, order_month
        ),2
    ) AS running_total

FROM orders
GROUP BY order_year, order_month;

-- Query 34: Dense Rank Customers
SELECT
    customer_id,

    ROUND(SUM(sales),2) AS revenue,

    DENSE_RANK()
    OVER(
        ORDER BY SUM(sales) DESC
    ) AS customer_rank

FROM orders
GROUP BY customer_id;

--Query 35: Revenue Contribution %
SELECT
    category_name,

    ROUND(SUM(sales),2) AS revenue,

    ROUND(
        100 * SUM(sales)
        / SUM(SUM(sales)) OVER(),
        2
    ) AS revenue_share

FROM orders
GROUP BY category_name
ORDER BY revenue DESC;

/*========================================================

EXECUTIVE SUMMARY

• Analyzed 180,000+ supply chain transactions.

• Identified regions and shipping modes with the highest
  delivery delays.

• Quantified the financial impact of late deliveries.

• Evaluated product categories, customer segments,
  profitability and seasonal trends.

• Applied advanced SQL concepts including:
    - CTEs
    - Window Functions
    - Ranking
    - Running Totals
    - Revenue Contribution Analysis

========================================================*/

