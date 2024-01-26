
docker stop pgadmin

docker stop postgres_master 
del /S /q \\wsl$\docker-desktop-data\data\docker\volumes\pgdata\_data\*
rmdir /S /q \\wsl$\docker-desktop-data\data\docker\volumes\pgdata\_data
mkdir \\wsl$\docker-desktop-data\data\docker\volumes\pgdata\_data

docker stop postgres_slave
del /S /q \\wsl$\docker-desktop-data\data\docker\volumes\pgslave\_data\*
rmdir /S /q \\wsl$\docker-desktop-data\data\docker\volumes\pgslave\_data
mkdir \\wsl$\docker-desktop-data\data\docker\volumes\pgslave\_data


docker stop postgres_dwh
del /S /q \\wsl$\docker-desktop-data\data\docker\volumes\data_pgre_ddwh\_data\*
rmdir /S /q \\wsl$\docker-desktop-data\data\docker\volumes\data_pgre_ddwh\_data
mkdir \\wsl$\docker-desktop-data\data\docker\volumes\data_pgre_ddwh\_data
