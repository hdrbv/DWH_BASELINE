echo "Clearing data"
rm -rf ../postgresql-rp/data/*
rm -rf ../postgresql-rp/data-slave/*

docker-compose down
docker-compose up -d  postgres_master

echo "Let's start: postgres_master node..."
sleep 120  # Waits for master note start complete

echo "Let's prepare replica config..."
docker exec -it postgres_master sh /etc/postgresql/inits/init.sh 

echo "Let's restart master node"
docker-compose restart postgres_master

sleep 30

echo "Let's starting slave node..."
docker-compose up -d  postgres_slave

sleep 30  # Waits for note start complete

echo "Mission complete"

