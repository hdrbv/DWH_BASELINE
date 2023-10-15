# DWH_HSE_23

## Процедура запуска

1. Выполнить команду: `docker-compose up --build`
2. Определить пользователя: <<user = 'postgres'>>
3. Задать пароль: <<password = 'postgres'>>
4. Задать host: <<host = 'localhost'>>
5. Задать port: <<port = '5432'>>

## Содержание

- Поднят инстанс PostgreSQL в Docker
- Написан DDL для структуры [structure]([structure.com](https://github.com/hdrbv/DWH_HSE_23/blob/main/structure.png)) в SQL-файл ([dtb_creating](https://github.com/hdrbv/DWH_HSE_23/blob/main/dtb_creating.sql))
- Поднята реплика в docker-compose, настроена репликация
- Реализован скрипт, который считает GMV (Gross Merchandise Value) и отдает таблицу в заданном формате (store_id | category_id | sales_sum) с превращением скрипта выше во view ([view_creating](https://github.com/hdrbv/DWH_HSE_23/blob/main/view_creating.sql))
