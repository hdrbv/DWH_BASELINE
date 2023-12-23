# DWH_HSE_23

## Процедура запуска

1. Осуществить клонирование репозитория
2. В терминале изменить рабочий каталог на папку с репозиторием: `cd /path/to/your/dir/with/files/from/github`
3. Выполнить в терминале следующую команду: `sh docker-init.sh`

## Содержание

- Поднят инстанс PostgreSQL в Docker
- Написан DDL для структуры [structure]([structure.com](https://github.com/hdrbv/DWH_HSE_23/blob/main/Full_Structure.pdf)) в SQL-файл ([dtb_creating](https://github.com/hdrbv/DWH_HSE_23/blob/main/createdb.sql))
- Поднята реплика в docker-compose, настроена репликация
- Реализован скрипт, который считает GMV (Gross Merchandise Value) и отдает таблицу в заданном формате (_store_id | category_id | sales_sum_) с превращением скрипта выше во view ([view_creating](https://github.com/hdrbv/DWH_HSE_23/blob/main/createview.sql))
- Данные детального слоя необходимо сложить в схему _dwh_detailed_
- Поднят и подключен debezium к master-хосту сервиса
- Реализован на Python [DMP-сервис](https://github.com/hdrbv/DWH_HSE_23/blob/main/DMP_service.py), который посажен в Docker-Compose 
- Поднят Apache Airflow в docker-compose 
- Созданы DAG для Airflow
- Поднята Grafana
