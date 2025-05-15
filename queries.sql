-- ===========================================
-- 1. BASIC QUERIES
-- ===========================================

-- Customers from São Paulo
SELECT customer_id, customer_city, customer_state
FROM customers
WHERE customer_state = 'SP'
LIMIT 10;

-- Products sorted alphabetically
SELECT product_id, product_category_name
FROM products
WHERE product_category_name IS NOT NULL
ORDER BY product_category_name ASC
LIMIT 10;


-- ===========================================
-- 2. JOINS
-- ===========================================

-- Orders with customer details
SELECT o.order_id, c.customer_city, o.order_status, o.order_purchase_timestamp
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LIMIT 10;

-- All products with sales count
SELECT p.product_id, p.product_category_name, COUNT(oi.order_id) AS times_ordered
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id
ORDER BY times_ordered DESC
LIMIT 10;


-- ===========================================
-- 3. AGGREGATES
-- ===========================================

-- Popular product categories with average price
SELECT p.product_category_name,
       COUNT(DISTINCT p.product_id) AS product_count,
       AVG(oi.price) AS avg_price,
       SUM(oi.price) AS total_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
HAVING COUNT(DISTINCT p.product_id) > 10
ORDER BY total_revenue DESC;

-- Total revenue by state
SELECT c.customer_state,
       SUM(oi.price) AS total_revenue,
       COUNT(DISTINCT o.order_id) AS order_count
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- ===========================================
-- 4. SUBQUERIES
-- ===========================================

-- High-value customers (spent > R$1000)
SELECT c.customer_id, c.customer_city, c.customer_state, cust_stats.total_spent
FROM customers c
JOIN (
    SELECT o.customer_id, SUM(oi.price) AS total_spent
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
    HAVING SUM(oi.price) > 1000
) cust_stats ON c.customer_id = cust_stats.customer_id
ORDER BY cust_stats.total_spent DESC;

-- Customers with recent orders (2018 onwards)
SELECT c.customer_id, c.customer_city
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
    AND o.order_purchase_timestamp >= '2018-01-01'
)
LIMIT 10;


-- ===========================================
-- 5. VIEWS
-- ===========================================

-- Create a view for customer spending
CREATE VIEW IF NOT EXISTS customer_spending AS
SELECT c.customer_id, c.customer_city, c.customer_state,
       SUM(oi.price) AS total_spent,
       COUNT(DISTINCT o.order_id) AS order_count
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id;

-- Query the view (Top 10 customers)
SELECT * FROM customer_spending
ORDER BY total_spent DESC
LIMIT 10;

