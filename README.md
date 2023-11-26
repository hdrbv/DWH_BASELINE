# DWH_HSE_23

## Процедура запуска

1. Осуществить клонирование репозитория
2. В терминале изменить рабочий каталог на папку с репозиторием: `cd /path/to/your/dir/with/files/from/github`
3. Выполнить в терминале следующую команду: `sh docker-init.sh`

## Содержание

- Поднят инстанс PostgreSQL в Docker
- Написан DDL для структуры [structure]([structure.com](https://github.com/hdrbv/DWH_HSE_23/blob/main/structure.png)) в SQL-файл ([dtb_creating](https://github.com/hdrbv/DWH_HSE_23/blob/main/createdb.sql))
- Поднята реплика в docker-compose, настроена репликация
- Реализован скрипт, который считает GMV (Gross Merchandise Value) и отдает таблицу в заданном формате (store_id | category_id | sales_sum) с превращением скрипта выше во view ([view_creating](https://github.com/hdrbv/DWH_HSE_23/blob/main/createview.sql))
