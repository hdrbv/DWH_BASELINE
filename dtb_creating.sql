CREATE TABLE stores(
    store_id serial PRIMARY KEY,
    store_name VARCHAR (255) NOT NULL
);

CREATE TABLE manufacturers(
    manufacturer_id serial PRIMARY KEY,
    manufacturer_name VARCHAR (100) NOT NULL
);

CREATE TABLE categories(
    category_id serial PRIMARY KEY,
    category_name VARCHAR (100) NOT NULL
);

CREATE TABLE customers(
    customer_id serial PRIMARY KEY,
    customer_fname VARCHAR (100) NOT NULL,
    customer_lname VARCHAR (100) NOT NULL
);

CREATE TABLE products(
    category_id BIGINT,
    manufacturer_id BIGINT,
    product_id serial PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    
    CONSTRAINT fk_categories
      FOREIGN KEY(category_id) 
      REFERENCES categories(category_id),
      
    CONSTRAINT fk_manufacturers
      FOREIGN KEY(manufacturer_id)
      REFERENCES manufacturers(manufacturer_id)
);

CREATE TABLE price_change(
    product_id BIGINT,
    price_change_ts TIMESTAMP NOT NULL,
    new_price NUMERIC(9,2) NOT NULL,
    CONSTRAINT fk_products
      FOREIGN KEY(product_id) 
      REFERENCES products(product_id)
);

CREATE TABLE deliveries(  
    delivery_date DATE NOT NULL,
    product_count INTEGER NOT NULL,
    store_id BIGINT,
    product_id BIGINT,
    CONSTRAINT fk_stores
      FOREIGN KEY(store_id)
      REFERENCES stores(store_id),
    CONSTRAINT fk_products
      FOREIGN KEY(product_id)
      REFERENCES products(product_id)
);

CREATE TABLE purchases(  
    store_id BIGINT,
    customer_id BIGINT,
    purchase_id serial PRIMARY KEY,
    purchase_date DATE NOT NULL,
    CONSTRAINT fk_stores
      FOREIGN KEY(store_id) 
      REFERENCES stores(store_id),
    CONSTRAINT fk_customers
      FOREIGN KEY(customer_id)
      REFERENCES customers(customer_id)
    
);

CREATE TABLE purchase_items(  
    product_id BIGINT NOT NULL,
    purchase_id BIGINT NOT NULL,
    product_count BIGINT NOT NULL,
    product_price NUMERIC(9,2) NOT NULL,
    CONSTRAINT fk_products
      FOREIGN KEY(product_id)
      REFERENCES products(product_id),
    CONSTRAINT fk_purchases
      FOREIGN KEY(purchase_id)
      REFERENCES purchases(purchase_id)
);

CREATE VIEW GMV AS
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
