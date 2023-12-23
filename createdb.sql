CREATE TABLE public.stores(
    store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(255) NOT NULL,
    store_country VARCHAR(255) NOT NULL, 
    store_city VARCHAR(255) NOT NULL, 
    store_address VARCHAR(255) NOT NULL 
);

CREATE TABLE public.manufacturers(
    manufacturer_id SERIAL PRIMARY KEY,
    manufacturer_name VARCHAR(100) NOT NULL,
    manufacturer_legal_entity VARCHAR(100) NOT NULL 
);

CREATE TABLE public.categories(
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR (100) NOT NULL
);

CREATE TABLE public.customers(
    customer_id SERIAL PRIMARY KEY,
    customer_fname VARCHAR (100) NOT NULL,
    customer_lname VARCHAR (100) NOT NULL,
    customer_gender VARCHAR(100) NOT NULL,  
    customer_phone VARCHAR(100) NOT NULL 
);

CREATE TABLE products(
    category_id BIGINT REFERENCES categories(category_id),
    manufacturer_id BIGINT REFERENCES manufacturers(manufacturer_id),
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    product_picture_url VARCHAR(255) NOT NULL,  
    product_description VARCHAR(255) NOT NULL, 
    product_age_restriction INTEGER NOT NULL,
    FOREIGN KEY (category_id) BIGINT REFERENCES public.categories(category_id),
    FOREIGN KEY (manufacturer_id) BIGINT REFERENCES public.manufacturers(manufacturer_id)
);

CREATE TABLE public.price_change(
    product_id BIGINT REFERENCES products(product_id),
    price_change_ts TIMESTAMP NOT NULL,
    new_price NUMERIC(9, 2) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES public.products(product_id)    
);

CREATE TABLE public.deliveries(  
    delivery_date DATE NOT NULL,
    product_count INTEGER NOT NULL,
    delivery_id BIGINT PRIMARY KEY,
    store_id BIGINT REFERENCES stores(store_id),
    product_id BIGINT REFERENCES products(product_id),
    delivery_date DATE NOT NULL,
    product_count INTEGER  NOT NULL,
    FOREIGN KEY (store_id) REFERENCES public.stores(store_id),
    FOREIGN KEY (product_id) REFERENCES public.products(product_id)
);

CREATE TABLE public.purchases(  
    store_id BIGINT REFERENCES stores(store_id),
    customer_id BIGINT REFERENCES customers(customer_id),
    purchase_id SERIAL PRIMARY KEY,
    purchase_date DATE NOT NULL,
    purchase_payment_type VARCHAR(100) NOT NULL, 
    FOREIGN KEY (store_id) REFERENCES public.stores(store_id),
    FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id)
);

CREATE TABLE public.purchase_items(  
    product_id BIGINT REFERENCES products(product_id),
    purchase_id BIGINT REFERENCES purchases(purchase_id),
    product_count BIGINT NOT NULL,
    product_price NUMERIC(9, 2) NOT NULL,
    FOREIGN KEY (product_id) REFERENCES public.products(product_id),
    FOREIGN KEY (purchase_id) REFERENCES public.purchases(purchase_id)
);

CREATE VIEW public.GMV AS
(SELECT
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
)

CREATE SCHEMA dwh_detailed;

CREATE TABLE dwh_detailed.sat_price_change (
    hub_product_id BIGINT REFERENCES hub_products(hub_product_id),
    price_change_ts TIMESTAMP NOT NULL,
    new_price NUMERIC(9,2) NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (hub_product_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.sat_purchase_product (
    lnk_purchase_product_id BIGINT REFERENCES lnk_purchase_product(lnk_purchase_product_id),
    product_count BIGINT NOT NULL,
    product_price NUMERIC(9,2) NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (lnk_purchase_product_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.lnk_purchase_product (
    lnk_purchase_product_id SERIAL PRIMARY KEY,
    hub_product_id BIGINT REFERENCES hub_products(hub_product_id),
    hub_purchase_id BIGINT REFERENCES hub_purchases(hub_purchase_id),
    lnk_load_dts DATE NOT null,
    lnk_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.lnk_purchase_customer (
    lnk_purchase_store_id SERIAL PRIMARY KEY,
    purchase_id BIGINT REFERENCES hub_purchases(hub_purchase_id),
    customer_id BIGINT REFERENCES hub_customers(hub_customer_id),
    lnk_load_dts DATE NOT null,
    lnk_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.lnk_purchase_store (
    lnk_purchase_store_id SERIAL PRIMARY KEY,
    store_id BIGINT REFERENCES hub_stores(hub_store_id),
    purchase_id BIGINT REFERENCES hub_purchases(hub_purchase_id),
    lnk_load_dts DATE NOT null,
    lnk_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.sat_purchases (
    hub_purchase_id BIGINT REFERENCES hub_purchases(hub_purchase_id),
    purchase_date DATE,
    purchase_payment_type VARCHAR(100) NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (hub_purchase_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.hub_purchases (
    hub_purchase_id SERIAL PRIMARY KEY,
    hub_load_dts DATE NOT null,
    hub_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.sat_customers (
    hub_customer_id BIGINT REFERENCES hub_customers(hub_customer_id),
    customer_fname VARCHAR(100) NOT NULL,
    customer_lname VARCHAR(100) NOT NULL,
    customer_gender VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(100) NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (hub_customer_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.hub_customers (
    hub_customer_id SERIAL PRIMARY KEY,
    hub_load_dts DATE NOT null,
    hub_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.sat_deliveries (
    lnk_delivery_id BIGINT REFERENCES lnk_deliveries(lnk_delivery_id),
    delivery_date DATE NOT NULL,
    product_count INTEGER NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (lnk_delivery_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.lnk_deliveries (
	lnk_delivery_id SERIAL PRIMARY KEY,
    hub_store_id BIGINT REFERENCES hub_stores(hub_store_id),
    hub_product_id BIGINT REFERENCES hub_products(hub_product_id),
    lnk_load_dts DATE NOT null,
    lnk_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.sat_stores (
    hub_store_id BIGINT REFERENCES hub_stores(hub_store_id),
    store_country VARCHAR(255) NOT NULL,
    store_city VARCHAR(255) NOT NULL,
    store_address VARCHAR(255) NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (hub_store_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.hub_stores (
    hub_store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(255) NOT NULL,
    hub_load_dts DATE NOT null,
    hub_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.lnk_product_category (
	lnk_product_category_id SERIAL PRIMARY KEY,
    hub_category_id BIGINT REFERENCES hub_categories(hub_category_id),
    hub_product_id BIGINT REFERENCES hub_products(hub_product_id),
    lnk_load_dts DATE NOT null,
    lnk_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.lnk_product_manufacturers (
	lnk_product_manufacturers_id SERIAL PRIMARY KEY,
    manufacturer_id BIGINT REFERENCES hub_manufacturers(hub_manufacturer_id),
    product_id BIGINT REFERENCES hub_products(hub_product_id),
    lnk_load_dts DATE NOT null,
    lnk_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.sat_purchases (
    hub_product_id BIGINT REFERENCES hub_products(hub_product_id),
    product_picture_url VARCHAR(255) NOT NULL,
    product_description VARCHAR(255) NOT NULL,
    product_age_restriction INT NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (hub_product_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.hub_products (
    hub_product_id BIGINT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    hub_load_dts DATE NOT null,
    hub_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.hub_categories (
    hub_category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    hub_load_dts DATE NOT null,
    hub_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.sat_manufacturers (
    hub_manufacturer_id BIGINT REFERENCES hub_manufacturers(hub_manufacturer_id),
    manufacturer_legal_entity VARCHAR(100) NOT null,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (hub_manufacturer_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.hub_manufacturers (
    hub_manufacturer_id SERIAL PRIMARY KEY,
    manufacturer_name VARCHAR(100) NOT NULL,
    manufacturer_legal_entity VARCHAR(100) NOT null,
    hub_load_dts DATE NOT null,
    hub_rec_src VARCHAR(100) NOT NULL
);






