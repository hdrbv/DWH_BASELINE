from kafka import KafkaConsumer
import avro.schema
import psycopg2
from datetime import datetime as dt
import datetime
from avro.io import DatumReader, BinaryDecoder
import io
import os
import json
import yaml
def decode(msg_value,pReader):
    message_bytes = io.BytesIO(msg_value)
    message_bytes.seek(7)
    decoder = BinaryDecoder(message_bytes)
    event_dict = pReader.read(decoder)
    return event_dict

with open('mapping.yml', 'r') as file:
    mapping = yaml.safe_load(file)
print(mapping)

table_list = list(mapping.keys())
schema = dict()
reader = dict()
for table in table_list:
    schema = avro.schema.parse(open(table+".avsc", "rb").read())
    reader["postgres.public."+table] = DatumReader(schema)
consumer = KafkaConsumer(
                        bootstrap_servers=["kafka:9092"],  
                        auto_offset_reset='earliest'
                        )
consumer.subscribe(reader.keys())
print(consumer.bootstrap_connected())
print(consumer.subscription())
conn = psycopg2.connect(
    host = 'postgres_dwh', 
    port = '5432',
    user = 'postgres',
    password = 'postgres',
    database = 'postgres'
)
cur = conn.cursor()
for msg in consumer:
    data = decode(msg.value, reader[msg.topic])
    print(data)
    try:
        tbl = msg.topic.split('.')[2]
        print(mapping[tbl])
        map_dict = {k: eval(v)  for k, v in mapping[tbl].items()}
        sql = f"INSERT INTO dwh_detailed.hub_{tbl} ({', '.join(map_dict.keys())}) VALUES ("+', '.join(["%s" for i in map_dict.keys()])+")"
        val=tuple(map_dict.values())
        print(sql,val)
        cur.execute(sql, val)
        conn.commit()
    except Exception as e:
        conn.rollback()
        print('ERROR',e)
cur.close()
conn.close()
kconsumer.close()
