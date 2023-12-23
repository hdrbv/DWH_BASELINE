from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
import os
from datetime import datetime, timedelta

sql_1 = '''
    CREATE SCHEMA IF NOT EXISTS presentation;
'''

sql_2 = '''
    DROP TABLE IF EXISTS presentation.gmv_customers;
'''

sql_3 = '''
    CREATE TABLE presentation.gmv_customers AS
SELECT
    CURRENT_TIMESTAMP AS created_at,
    rc.customer_id,
    rc.customer_gmv,
    tc.category_id AS customer_category,
    CASE
        WHEN rc.percentile <= 5 THEN '5'
        WHEN rc.percentile <= 10 THEN '10'
        WHEN rc.percentile <= 25 THEN '25'
        WHEN rc.percentile <= 50 THEN '50'
        ELSE '50+'
    END AS customer_group
FROM 
    (SELECT
        p.customer_id,
        SUM(pi.product_count * pi.product_price) AS customer_gmv,
        NTILE(100) OVER (ORDER BY SUM(pi.product_count * pi.product_price) DESC) AS percentile
    FROM public.purchases p
    JOIN public.purchase_items pi ON p.purchase_id = pi.purchase_id
    WHERE purchase_date < CURRENT_DATE
    GROUP BY p.customer_id) AS rc
    JOIN 
    (SELECT
        p.customer_id,
        pr.category_id
    FROM public.purchases p
    JOIN public.purchase_items pi ON p.purchase_id = pi.purchase_id
    JOIN public.products pr ON pi.product_id = pr.product_id
    WHERE (p.customer_id, pi.product_count * pi.product_price) IN 
        (SELECT customer_id, MAX(product_count * product_price) 
        FROM public.purchases 
        JOIN purchase_items ON purchases.purchase_id = purchase_items.purchase_id 
        WHERE purchase_date < CURRENT_DATE
        GROUP BY customer_id)
    ) AS tc ON rc.customer_id = tc.customer_id;
    '''

init_arguments = {
    'owner': 'hdrbv',
    'start_date': datetime(2023, 12, 21),
    'email': None,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes = 5),
    'execution_timeout': timedelta(minutes = 120)
}

with DAG("gmv_customers",
         default_args = init_arguments,
         catchup = False,
         schedule_interval = "@daily",
         max_active_runs = 1,
         concurrency = 1) as dag:
    task1 = PostgresOperator(
        task_id = "create_schema",
        postgres_conn_id = "postgres_master",
        sql = sql_1,
    )
    task2 = PostgresOperator(
        task_id = "drop_table",
        postgres_conn_id = "postgres_master",
        sql = sql_2,
    )
    task3 = PostgresOperator(
        task_id = "create_table",
        postgres_conn_id = "postgres_master",
        sql = sql_3,
    )
    task1 >> task2 >> task3


