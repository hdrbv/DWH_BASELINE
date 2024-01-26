cd /Users/he/Documents/Projects/FKN/DWH/FULL/

cd /Users/he/Documents/Projects/FKN/DWH/FULL2/

cd /Users/he/Documents/Projects/FKN/DWH/FULL/old/app3/

rm -rf ../postgresql-rp/data/*
rm -rf ../postgresql-rp/data-slave/*
rm -rf ../postgresql-rp/data_pgre_ddwh/*
docker-compose down
rm -rf yes ./data
rm -rf yes ./data-slave
rm -rf yes ./data_ddwh
rm -rf yes ./data_pgre_ddwh

docker-compose build

docker-compose up -d 

docker-compose up -d app-in-compose shinyproxy

sh docker-init.sh

docker exec -it postgres_master psql -U postgres postgres
--List all the tables within database
\dt

--Check query on master
select * from pg_stat_replication;

select * from public.categories;

INSERT INTO categories  
VALUES (1, 'cars');

docker exec -it postgres_slave psql -U postgres postgres
--Check query on replica
select * from pg_stat_wal_receiver;

--Exit & come back to bash
\q

sh docker-init.sh -d

