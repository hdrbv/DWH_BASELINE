from airflow import DAG
from airflow.providers.postgres.operators.postgres import PostgresOperator
import os
from datetime import datetime, timedelta

sql_1 = '''
    CREATE SCHEMA IF NOT EXISTS presentation;
'''
sql_2 = '''
    DROP TABLE IF EXISTS presentation.gmv_categories;
'''
sql_3 = '''
    CREATE TABLE presentation.gmv_categories AS
    SELECT
        CURRENT_TIMESTAMP AS created_at,
        d.purchase_date AS business_date,
        c.category_name,
        COALESCE(SUM(p.product_count * p.product_price), 0) AS category_gmv
    FROM public.categories c
    CROSS JOIN (
        SELECT DISTINCT purchase_date
        FROM public.purchases
    ) AS d
    LEFT JOIN (
        SELECT 
            pi.product_count,
            pi.product_price,
            pr.category_id,
            pu.purchase_date
        FROM public.purchase_items pi 
        LEFT JOIN public.purchases pu ON pi.purchase_id = pu.purchase_id
        LEFT JOIN public.products pr ON pi.product_id = pr.product_id
    ) p ON c.category_id = p.category_id AND d.purchase_date = p.purchase_date
    WHERE d.purchase_date = CURRENT_DATE - 1
    GROUP BY d.purchase_date, c.category_name;
'''

init_arguments = {
    'owner': 'hdrbv',
    'start_date': datetime(2023, 12, 20),
    'email': None,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes = 5),
    'execution_timeout': timedelta(minutes = 120)
}

with DAG("gmv_categories",
         default_args = init_arguments,
         catchup = False,
         schedule_interval = "@daily",
         max_active_runs = 1,
         concurrency = 1) as dag :
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

