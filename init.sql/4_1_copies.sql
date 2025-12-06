CREATE TABLE sales AS SELECT * FROM hr.sales;
CREATE TABLE products AS SELECT * FROM hr.products;


ALTER TABLE sales
    ADD CONSTRAINT pk_sales PRIMARY KEY (sale_id);

ALTER TABLE products
    ADD CONSTRAINT pk_products PRIMARY KEY (product_id);

ALTER TABLE sales
    ADD CONSTRAINT fk_sales_employee
        FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

ALTER TABLE sales
    ADD CONSTRAINT fk_sales_product
        FOREIGN KEY (product_id) REFERENCES products(product_id);

COMMIT;