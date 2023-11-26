CREATE TABLE stores(
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(255) NOT NULL
);

CREATE TABLE manufacturers(
    manufacturer_id SERIAL PRIMARY KEY,
    manufacturer_name VARCHAR(100) NOT NULL
);

CREATE TABLE categories(
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR (100) NOT NULL
);

CREATE TABLE customers(
    customer_id SERIAL PRIMARY KEY,
    customer_fname VARCHAR (100) NOT NULL,
    customer_lname VARCHAR (100) NOT NULL
);

CREATE TABLE products(
    category_id BIGINT REFERENCES categories(category_id),
    manufacturer_id BIGINT REFERENCES manufacturers(manufacturer_id),
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
);

CREATE TABLE price_change(
    product_id BIGINT REFERENCES products(product_id),
    price_change_ts TIMESTAMP NOT NULL,
    new_price NUMERIC(9,2) NOT NULL,
);

CREATE TABLE deliveries(  
    delivery_date DATE NOT NULL,
    product_count INTEGER NOT NULL,
    store_id BIGINT REFERENCES stores(store_id),
    product_id BIGINT REFERENCES products(product_id),
);

CREATE TABLE purchases(  
    store_id BIGINT REFERENCES stores(store_id),
    customer_id BIGINT REFERENCES customers(customer_id),
    purchase_id serial PRIMARY KEY,
    purchase_date DATE NOT NULL,
);

CREATE TABLE purchase_items(  
    product_id BIGINT REFERENCES products(product_id),
    purchase_id BIGINT REFERENCES purchases(purchase_id),
    product_count BIGINT NOT NULL,
    product_price NUMERIC(9,2) NOT NULL 
);

CREATE VIEW public.GMV AS
SELECT
    pu.store_id,
    pr.category_id,
    SUM(pi.product_price * pi.product_count) AS sales_sum
FROM
    system.purchase_items pi
JOIN
    system.products pr ON pi.product_id = pr.product_id
JOIN
    system.purchases pu ON pi.purchase_id = pu.purchase_id
GROUP BY
    pu.store_id,
    pr.category_id
