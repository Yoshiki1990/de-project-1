# Проект 1
Описание хода решения задачи перечислено в md-файлах проекта:
	1. Требования к витрине: requirements.md
	2. Обеспечение качества данных: data_quality.md
	3. Общий ход выполнения задачи: realisation.md
Порядок запуска скриптов:
	1. views.sql - создание представлений необхоодимых таблиц схемы Production в схеме Analysis
	2. datamart_ddl.sql - DDL-запрос для создания витрины
	3. tmp_rfm_recency.sql - SQL-запрос для заполнения таблицы analysis.tmp_rfm_recency
	4. tmp_rfm_frequency.sql - SQL-запрос для заполнения таблицы analysis.tmp_rfm_frequency
	5. tmp_rfm_monetary_value.sql - SQL-запрос для заполнения таблицы analysis.tmp_rfm_monetary_value
	6. datamart_query.sql - SQL-запрос заполнения витрины analysis.dm_rfm_segments
	7. orders_view.sql - запрос для обновления представления analysis.Orders