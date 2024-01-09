CREATE SCHEMA dwh_detailed;

CREATE TABLE dwh_detailed.hub_products (
    hub_product_id BIGINT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    hub_load_dts DATE NOT null,
    hub_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.hub_purchases (
    hub_purchase_id SERIAL PRIMARY KEY,
    hub_load_dts DATE NOT null,
    hub_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.hub_customers (
    hub_customer_id SERIAL PRIMARY KEY,
    hub_load_dts DATE NOT null,
    hub_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.hub_stores (
    hub_store_id SERIAL PRIMARY KEY,
    store_name VARCHAR(255) NOT NULL,
    hub_load_dts DATE NOT null,
    hub_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.hub_categories (
    hub_category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    hub_load_dts DATE NOT null,
    hub_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.hub_manufacturers (
    hub_manufacturer_id SERIAL PRIMARY KEY,
    manufacturer_name VARCHAR(100) NOT NULL,
    manufacturer_legal_entity VARCHAR(100) NOT null,
    hub_load_dts DATE NOT null,
    hub_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.lnk_purchase_product (
    lnk_purchase_product_id SERIAL PRIMARY KEY,
    product_id BIGINT,
    FOREIGN KEY (product_id) REFERENCES dwh_detailed.hub_products(hub_product_id),
    purchase_id BIGINT,
    FOREIGN KEY (purchase_id) REFERENCES dwh_detailed.hub_purchases(hub_purchase_id),
    lnk_load_dts DATE NOT null,
    lnk_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.lnk_deliveries (
    lnk_delivery_id SERIAL PRIMARY KEY,
    store_id BIGINT,
    FOREIGN KEY (store_id) REFERENCES dwh_detailed.hub_stores(hub_store_id),
    product_id BIGINT,
    FOREIGN KEY (product_id) REFERENCES dwh_detailed.hub_products(hub_product_id),
    lnk_load_dts DATE NOT null,
    lnk_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.lnk_purchase_customer (
    lnk_purchase_store_id SERIAL PRIMARY KEY,
    purchase_id BIGINT,
    FOREIGN KEY (purchase_id) REFERENCES dwh_detailed.hub_purchases(hub_purchase_id),
    customer_id BIGINT,
    FOREIGN KEY (customer_id) REFERENCES dwh_detailed.hub_customers(hub_customer_id),
    lnk_load_dts DATE NOT null,
    lnk_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.lnk_purchase_store (
    lnk_purchase_store_id SERIAL PRIMARY KEY,
    store_id BIGINT,
    FOREIGN KEY (store_id) REFERENCES dwh_detailed.hub_stores(hub_store_id),
    purchase_id BIGINT,
    FOREIGN KEY (purchase_id) REFERENCES dwh_detailed.hub_purchases(hub_purchase_id),
    lnk_load_dts DATE NOT null,
    lnk_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.lnk_product_category (
    lnk_product_category_id SERIAL PRIMARY KEY,
    category_id BIGINT,
    FOREIGN KEY (category_id) REFERENCES dwh_detailed.hub_categories(hub_category_id),
    product_id BIGINT,
    FOREIGN KEY (product_id) REFERENCES dwh_detailed.hub_products(hub_product_id),
    lnk_load_dts DATE NOT null,
    lnk_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.lnk_product_manufacturers (
    lnk_product_manufacturers_id SERIAL PRIMARY KEY,
    manufacturer_id BIGINT,
    FOREIGN KEY (manufacturer_id) REFERENCES dwh_detailed.hub_manufacturers(hub_manufacturer_id),
    product_id BIGINT,
    FOREIGN KEY (product_id) REFERENCES dwh_detailed.hub_products(hub_product_id),
    lnk_load_dts DATE NOT null,
    lnk_rec_src VARCHAR(100) NOT NULL
);

CREATE TABLE dwh_detailed.sat_price_change (
    product_id BIGINT,
    FOREIGN KEY (product_id) REFERENCES dwh_detailed.hub_products(hub_product_id),
    price_change_ts TIMESTAMP NOT NULL,
    new_price NUMERIC(9,2) NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (product_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.sat_purchase_product (
    lnk_purchase_product_id BIGINT,
    FOREIGN KEY (lnk_purchase_product_id) REFERENCES dwh_detailed.lnk_purchase_product(lnk_purchase_product_id),
    product_count BIGINT NOT NULL,
    product_price NUMERIC(9,2) NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (lnk_purchase_product_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.sat_purchases (
    purchase_id BIGINT,
    FOREIGN KEY (purchase_id) REFERENCES dwh_detailed.hub_purchases(hub_purchase_id),
    purchase_date DATE,
    purchase_payment_type VARCHAR(100) NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (purchase_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.sat_customers (
    customer_id BIGINT,
    FOREIGN KEY (customer_id) REFERENCES dwh_detailed.hub_customers(hub_customer_id),
    customer_fname VARCHAR(100) NOT NULL,
    customer_lname VARCHAR(100) NOT NULL,
    customer_gender VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(100) NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (customer_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.sat_deliveries (
    lnk_delivery_id BIGINT,
    FOREIGN KEY (lnk_delivery_id) REFERENCES dwh_detailed.lnk_deliveries(lnk_delivery_id),
    delivery_date DATE NOT NULL,
    product_count INTEGER NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (lnk_delivery_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.sat_stores (
    store_id BIGINT,
    FOREIGN KEY (store_id) REFERENCES dwh_detailed.hub_stores(hub_store_id),
    store_country VARCHAR(255) NOT NULL,
    store_city VARCHAR(255) NOT NULL,
    store_address VARCHAR(255) NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (store_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.sat_product (
    product_id BIGINT,
    FOREIGN KEY (product_id) REFERENCES dwh_detailed.hub_products(hub_product_id),
    product_picture_url VARCHAR(255) NOT NULL,
    product_description VARCHAR(255) NOT NULL,
    product_age_restriction INT NOT NULL,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (product_id, sat_load_dts)
);

CREATE TABLE dwh_detailed.sat_manufacturers (
    manufacturer_id BIGINT,
    FOREIGN KEY (manufacturer_id) REFERENCES dwh_detailed.hub_manufacturers(hub_manufacturer_id),
    manufacturer_legal_entity VARCHAR(100) NOT null,
    sat_load_dts DATE NOT NULL,
    sat_rec_src VARCHAR(100) NOT null,
    PRIMARY key (manufacturer_id, sat_load_dts)
);


