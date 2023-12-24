echo "Clearing data"
rm -rf ../postgresql-rp/data/*
rm -rf ../postgresql-rp/data-slave/*

docker-compose down
docker-compose up -d  postgres_master

echo "Let's start: postgres_master node..."
sleep 120  

echo "Let's prepare replica config..."
docker exec -it postgres_master sh /etc/postgresql/init-script/init.sh 

echo "Let's restart master node"
docker-compose restart postgres_master

sleep 30

echo "Let's starting slave node..."
docker-compose up -d  postgres_slave zookeeper broker debezium debezium-ui rest-proxy schema-registry 

curl --location --request POST 'http://localhost:8083/connectors'  --header 'Accept: application/json'  --header 'Content-Type: application/json'  -d @connector.json --verbose

echo "Airflowing :)"
cd airflow && docker-compose up -d

echo "Grafana & Prometheus - Up"
cd .. && docker-compose up -d grafana prometheus postgres-exporter

echo "Make visualusation with Shiny"
cd .. && docker-compose up -d shiny

sleep 30  # Waits for note start complete

echo "Mission complete"

