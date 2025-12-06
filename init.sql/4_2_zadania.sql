--- zadanie 1
SELECT
    e.last_name,
    e.salary,
    DENSE_RANK() OVER (ORDER BY e.salary DESC) AS salary_rank
FROM employees e;


--- zadanie 2
SELECT
    e.last_name,
    e.salary,
    SUM(e.salary) OVER () AS total_salary
FROM employees e;


--- zadanie 3
SELECT
    e.last_name,
    p.product_name,
    SUM(s.quantity * s.price)
        OVER (PARTITION BY e.employee_id ORDER BY s.sale_date) AS cumulative_sales,
    RANK() OVER (ORDER BY (s.quantity * s.price) DESC) AS sale_rank
FROM sales s
         JOIN employees e ON s.employee_id = e.employee_id
         JOIN products p ON s.product_id = p.product_id;


--- zadanie 4
SELECT
    e.last_name,
    p.product_name,
    s.price,
    COUNT(*) OVER (PARTITION BY s.product_id, s.sale_date) AS transactions_that_day,
    SUM(s.price * s.quantity)
        OVER (PARTITION BY s.product_id, s.sale_date) AS daily_sum,
    LAG(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS previous_price,
    LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS next_price
FROM sales s
         JOIN employees e ON s.employee_id = e.employee_id
         JOIN products p ON s.product_id = p.product_id;


--- zadanie 5
SELECT
    p.product_name,
    s.price,
    SUM(s.price * s.quantity)
        OVER (PARTITION BY s.product_id, TO_CHAR(s.sale_date, 'YYYY-MM')) AS month_total,
    SUM(s.price * s.quantity)
        OVER (PARTITION BY s.product_id, TO_CHAR(s.sale_date, 'YYYY-MM')
            ORDER BY s.sale_date) AS month_running_total
FROM sales s
         JOIN products p ON s.product_id = p.product_id;


--- zadanie 6
-- Brak tabeli products_history ani kategorii → wersja uproszczona: porównanie cen w 2022 i 2023
WITH yr22 AS (
    SELECT product_id, sale_date, price
    FROM sales
    WHERE EXTRACT(YEAR FROM sale_date) = 2022
),
     yr23 AS (
         SELECT product_id, sale_date, price
         FROM sales
         WHERE EXTRACT(YEAR FROM sale_date) = 2023
     )
SELECT
    p.product_name,
    y22.price AS price_2022,
    y23.price AS price_2023,
    (y23.price - y22.price) AS difference
FROM yr22 y22
         JOIN yr23 y23
              ON y22.product_id = y23.product_id
                  AND TO_CHAR(y22.sale_date,'MM-DD') = TO_CHAR(y23.sale_date,'MM-DD')
         JOIN products p ON p.product_id = y22.product_id;


--- zadanie 7
-- W PRODUCTS brak kategorii numerycznej, tylko product_category (tekstowo)
SELECT
    p.product_category,
    p.product_name,
    s.price,
    MIN(s.price) OVER (PARTITION BY p.product_category) AS min_price,
    MAX(s.price) OVER (PARTITION BY p.product_category) AS max_price,
    MAX(s.price) OVER (PARTITION BY p.product_category)
        - MIN(s.price) OVER (PARTITION BY p.product_category) AS diff
FROM sales s
         JOIN products p ON p.product_id = s.product_id;


--- zadanie 8
-- Brak tabeli product_prices → robimy średnią kroczącą po cenach z SALES:
SELECT
    p.product_name,
    s.price,
    AVG(s.price)
        OVER (PARTITION BY s.product_id ORDER BY s.sale_date
            ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS moving_avg
FROM sales s
         JOIN products p ON p.product_id = s.product_id;


--- zadanie 9
-- Ranking cen w ramach kategorii (product_category)
SELECT
    p.product_category,
    p.product_name,
    s.price,
    RANK()       OVER (PARTITION BY p.product_category ORDER BY s.price) AS price_rank,
    ROW_NUMBER() OVER (PARTITION BY p.product_category ORDER BY s.price) AS price_row_number,
    DENSE_RANK() OVER (PARTITION BY p.product_category ORDER BY s.price) AS dense_price_rank
FROM sales s
         JOIN products p ON p.product_id = s.product_id;


--- zadanie 10
SELECT
    e.last_name,
    p.product_name,
    SUM(s.price * s.quantity)
        OVER (PARTITION BY e.employee_id ORDER BY s.sale_date) AS running_sales_value,
    RANK() OVER (ORDER BY (s.price * s.quantity) DESC) AS global_sale_rank
FROM sales s
         JOIN employees e ON e.employee_id = s.employee_id
         JOIN products p ON p.product_id = s.product_id;


--- zadanie 11
SELECT DISTINCT
    e.first_name,
    e.last_name,
    e.job_id
FROM employees e
         JOIN sales s ON s.employee_id = e.employee_id;

COMMIT;