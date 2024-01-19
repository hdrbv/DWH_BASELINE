echo "Clearing data"
rm -rf ../postgresql-rp/data/*
rm -rf ../postgresql-rp/data-slave/*
rm -rf ../postgresql-rp/data_pgre_ddwh/*
docker-compose down
rm -rf yes ./data
rm -rf yes ./data-slave
rm -rf yes ./data_ddwh
rm -rf yes ./data_pgre_ddwh

echo "Let's start: postgres_master node..."
docker-compose up -d postgres_master

sleep 30  

echo "Let's prepare replica config..."
docker exec -it postgres_master sh /etc/postgresql/init-script/init.sh 

echo "Let's restart master node"
docker-compose restart postgres_master

sleep 15

echo "Let's starting slave node..."
docker-compose up -d postgres_slave 

sleep 10

echo "Let's starting slave node..."
docker-compose up -d postgres_dwh 

sleep 10

echo "Launch clickhouse for detailed DWH"
docker-compose up -d clickh_master 

sleep 10

echo "Let's starting other services"
docker-compose up -d zookeeper broker debezium debezium-ui rest-proxy schema-registry 

curl --location --request POST 'http://localhost:8083/connectors'  --header 'Accept: application/json'  --header 'Content-Type: application/json'  -d @connector.json --verbose

sleep 10

echo "Airflowing :)"
cd airflow && docker-compose up -d

sleep 10

echo "Grafana & Prometheus - Up"
cd .. && docker-compose up -d grafana prometheus postgres-exporter

sleep 10

echo "Make visualusation with Shiny"
cd .. && docker-compose up -d app-in-compose shinyproxy

sleep 15  # Waits for note start complete

echo "Mission complete"

