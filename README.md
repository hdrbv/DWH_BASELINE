# DWH_HSE_23

## Процедура запуска

1. Осуществить клонирование текущего репозитория 
2. В терминале изменить рабочий каталог на папку с репозиторием: 

```bash
cd /path/to/your/dir/with/files/from/github
```

3. Выполнить в терминале следующую команду: `sh docker-init.sh`

## Содержание

### Часть №1
- Поднят инстанс PostgreSQL в Docker
- Написан DDL для [структуры](https://github.com/hdrbv/DWH_HSE_23/blob/main/Full_Structure.pdf) в [SQL](https://github.com/hdrbv/DWH_HSE_23/blob/main/createdb.sql)
- Настроена автоматическая инициализация

    ![](./evidences/e1.png =400x) 
    <br>Структура схемы _(terminal screenshot)_

- Поднята реплика в docker-compose, настроена репликация

    ![](./evidences/e2.png =1000x) 
    <br>Проверка запроса на master _(terminal screenshot)_

    ![](./evidences/e3.png =1000x) 
    <br>Проверка запроса на replica _(terminal screenshot)_    

    ![](./evidences/e4.png =500x) 
    <br>Insert на master передает данные на replica _(terminal screenshot)_    

- Реализован скрипт, который считает GMV (Gross Merchandise Value) и отдает таблицу в заданном формате (_store_id | category_id | sales_sum_) с превращением скрипта выше во [view](https://github.com/hdrbv/DWH_HSE_23/blob/main/createview.sql)

    ![](./evidences/e5.png =250x) 
    <br>Insert на master передает данные на replica _(DBeaver screenshot)_    

### Часть №2
- Добавлены новые поля в изначальную структуру
- Данные детального слоя сложены в схему **dwh_detailed** на отдельном инстансе Postgre

    ![](./evidences/e6.png =270x) 
    <br>Структура схемы **dwh_detailed** на Postgres _(DBeaver screenshot)_    

- Создана ER-диаграмма проинициализированный [структуры](./Full_Structure_Det_DWH.pdf)
- Также осуществлена инициализация **dwh_detailed** на ClickHouse, выбранном по следующим причинам:
    - столбцовое хранение данных
    - физическая сортировка данных по первичному ключу
    - векторные вычисления по участкам столбцов
    - децентрализация и отсутствие единой точки отказа
    - разработка Yandex (поддержим отечественного производителя :))
    
    Данные пункты (за исключением крайнего) ведут естественным образом к б*o*льшей скорости и высокой устойчивости) 

    ![](./evidences/e7.png =250x) 
    <br>Структура схемы **dwh_detailed** на Clickhouse _(DBeaver screenshot)_    


- Поднят и подключен debezium к master-хосту сервиса

    ![](./evidences/e8.png =650x) 
    <br> Подключенный debezium  _(Safari screenshot)_    

    ![](./evidences/e9.png =250x) 
    <br> Состояние развернутого debezium и debezium-ui  _(Docker screenshot)_            

- Реализован на Python [DMP-сервис](https://github.com/hdrbv/DWH_HSE_23/blob/main/DMP_service.py), который посажен в Docker-Compose 



### Часть №3
- Поднят Apache Airflow в docker-compose 
- Созданы DAG для Airflow

### Часть №4
- Поднята Grafana
- Поднят Shiny

***

FAQ


