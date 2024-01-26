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

CREATE TABLE public.products(
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    product_picture_url VARCHAR(255) NOT NULL,  
    product_description VARCHAR(255) NOT NULL, 
    product_age_restriction INTEGER NOT NULL,
    category_id BIGINT REFERENCES public.categories(category_id),
    manufacturer_id BIGINT REFERENCES public.manufacturers(manufacturer_id)
);

ALTER TABLE public.products REPLICA IDENTITY FULL;

CREATE TABLE public.price_change(
    product_id BIGINT,
    FOREIGN KEY(product_id) REFERENCES public.products(product_id),
    price_change_ts TIMESTAMP NOT NULL,
    new_price NUMERIC(9, 2) NOT NULL
);

CREATE TABLE public.deliveries(  
    delivery_id SERIAL PRIMARY KEY,
    delivery_date DATE NOT NULL,
    product_count INTEGER NOT NULL,
    store_id BIGINT,
    product_id BIGINT,
    FOREIGN KEY(store_id) REFERENCES public.stores(store_id),
    FOREIGN KEY(product_id) REFERENCES public.products(product_id)
);

CREATE TABLE public.purchases(  
    store_id BIGINT,
    FOREIGN KEY (store_id) REFERENCES public.stores(store_id),
    customer_id BIGINT,
    FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id),
    purchase_id SERIAL PRIMARY KEY,
    purchase_date DATE NOT NULL,
    purchase_payment_type VARCHAR(100) NOT NULL 
);

CREATE TABLE public.purchase_items(  
    product_count BIGINT NOT NULL,
    product_price NUMERIC(9, 2) NOT NULL,
    product_id BIGINT,
    purchase_id BIGINT,
    FOREIGN KEY (product_id) REFERENCES public.products(product_id),
    FOREIGN KEY (purchase_id) REFERENCES public.purchases(purchase_id)
);

