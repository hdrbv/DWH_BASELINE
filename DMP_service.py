import json
import psycopg2
from kafka import KafkaConsumer

kafka_name = 'postgres.public.products'
kafka_gr = "backend"
servers = "broker:29092"
kconsumer = KafkaConsumer(bootstrap_servers = servers,
                            value_deserializer = lambda v: v if v is None else json.loads(v.decode("utf-8")),
                            auto_offset_reset = "earliest",
                            group_id = kafka_gr)
kconsumer.subscribe(topics = kafka_name)
conn = psycopg2.connect(
    host = 'localhost',
    port = '5432',
    user = 'postgres',
    password = 'postgres',
    database = 'postgres'
)
cur = conn.cursor()
for message in kconsumer:
    try:
        data = json.loads(message.value)
        if message.topic == kafka_name:
            dwh_data = (data['hub_product_id'], data['product_name'], data['hub_load_dts'], data['hub_rec_src'])
            cur.execute("INSERT INTO dwh_detailed.hub_products (hub_product_id, product_name, hub_load_dts, hub_rec_src) VALUES (%s, %s, %s, %s)", dwh_data)
            conn.commit()
        else:
            pass
cur.close()
conn.close()
kconsumer.close()

