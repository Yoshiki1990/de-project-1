# Витрина RFM

## 1.1. Выясните требования к целевой витрине.

Постановка задачи выглядит достаточно абстрактно - постройте витрину. Первым делом вам необходимо выяснить у заказчика детали. Запросите недостающую информацию у заказчика в чате.

Зафиксируйте выясненные требования. Составьте документацию готовящейся витрины на основе заданных вами вопросов, добавив все необходимые детали.

-----------

Задача: необходимо создать витрину данных для RFM-классификации пользователей приложения. Название витрины - dm_rfm_segments. Расположение витрины - БД de, схема analysis.
Заказчик: компания, которая разрабатывает приложение по доставке еды.
Цель: подготовить данне, на основе которых будут выбраны клиентские категории, на которые стоит направить маркетинговые усилия.
Глубина данных: с начала 2022 года.
Обновление данных: не требуется.
Кому доступна: нет данных.
Необходимая структура:
- user_id — идентификатор пользователя;
- recency — давность предыдущего заказа (может принимать значения от 1 до 5);
- frequency — количество совершенных заказов пользователем (может принимать значения от 1 до 5);
- monetary_value  — сумма, пораченная пользователем на заказы (может принимать значения от 1 до 5)
Источник данных: БД de, схема production
Примечание: успешно выполненным считается заказ со статусом "Closed"



## 1.2. Изучите структуру исходных данных.

Полключитесь к базе данных и изучите структуру таблиц.

Если появились вопросы по устройству источника, задайте их в чате.

Зафиксируйте, какие поля вы будете использовать для расчета витрины.

-----------

Схема production доступна и содержит следующие таблицы:
- orderitems
- orders
- orderstatuses
- orderstatuslog
- products
- users

При построении витрины будут использованы следующие поля:
- orders.orderid
- orders.order_ts
- orders.userid
- orders.payment
- orders.status
- orderstatuses.id
- orderstatuses.key
- users.id 


## 1.3. Проанализируйте качество данных

Изучите качество входных данных. Опишите, насколько качественные данные хранятся в источнике. Так же укажите, какие инструменты обеспечения качества данных были использованы в таблицах в схеме production.

-----------

Дубли и пропущенные значения отсутствуют.
Все поля имеют корректные тип данных и верные форматы записей.  

Для обеспечения качества данных были использованы следующие инструменты:

Таблица orders:
- ограничение NOT NULL для всех столбцов;
- ограничение-проверка CHECK для корректности значений поля стоимости заказа cost = (payment + bonus_payment) (данное поле не используется при формировании нашей витрины);
- ограничение (первичный ключ) pkey по полю order_id;

Таблица orderstatuses:
- ограничение NOT NULL для всех столбцов;
- ограничение PRIMARY KEY (первичный ключ) по полю id;

Таблица orderstatuslog:
- ограничение NOT NULL для всех столбцов;
- ограничение GENERATED ALWAYS AS IDENTITY для обеспечения уникальности идентификаторов (поле id);
- ограничение PRIMARY KEY (первичный ключ) по полю id;
- ограничение уникальности UNIQUE сочетания полей order_id, status_id;
- внешний ключ FOREIGN KEY, поле order_id ссылается на поле order_id таблицы orders для исключения добавления значения id заказа, не присутствующего в orders
- внешний ключ FOREIGN KEY, поле status_id ссылается на поле id таблицы orderstatuses для исключения добавления значения статуса заказа, не присутствующего в orderstatuses

## 1.4. Подготовьте витрину данных

Теперь, когда требования понятны, а исходные данные изучены, можно приступить к реализации.

### 1.4.1. Сделайте VIEW для таблиц из базы production.**

Вас просят при расчете витрины обращаться только к объектам из схемы analysis. Чтобы не дублировать данные (данные находятся в этой же базе), вы решаете сделать view. Таким образом, View будут находиться в схеме analysis и вычитывать данные из схемы production. 

Напишите SQL-запросы для создания пяти VIEW (по одному на каждую таблицу) и выполните их. Для проверки предоставьте код создания VIEW. 

```SQL
CREATE VIEW analysis.orders AS SELECT * FROM production.orders;
CREATE VIEW analysis.orderitems AS SELECT * FROM production.orderitems;
CREATE VIEW analysis.orderstatuses AS SELECT * FROM production.orderstatuses;
CREATE VIEW analysis.products AS SELECT * FROM production.products;
CREATE VIEW analysis.users AS SELECT * FROM production.users;

```

### 1.4.2. Напишите DDL-запрос для создания витрины.**

Далее вам необходимо создать витрину. Напишите CREATE TABLE запрос и выполните его на предоставленной базе данных в схеме analysis.

```SQL
CREATE TABLE analysis.dm_rfm_segments (
	user_id INT PRIMARY KEY,
	recency smallint NOT NULL CHECK (recency between 1 and 5),
	frequency smallint NOT NULL CHECK (frequency between 1 and 5) ,
	monetary_value smallint NOT NULL CHECK (monetary_value between 1 and 5)
	);

```

### 1.4.3. Напишите SQL запрос для заполнения витрины

Наконец, реализуйте расчет витрины на языке SQL и заполните таблицу, созданную в предыдущем пункте.

Для решения предоставьте код запроса.

```SQL
insert into analysis.dm_rfm_segments
with forders as(
	select * from analysis.orders o
	where o.status = 4 and extract('year' from order_ts) > 2021
	),
usertab as (select id
		,max(order_ts)as recent
		,count(distinct order_id) as cnt
		,sum(payment) as pay_sum
	from analysis.users u
	left join forders f on u.id = f.user_id 
	group by id
)

select id as user_id
	,ntile(5) over(order by recent) as recency
	,ntile(5) over(order by cnt) as frequency
	,ntile(5) over(order by pay_sum) as monetary_value
from usertab u;

/* Или, если согласно описанию задания на сайте */

CREATE TABLE analysis.tmp_rfm_recency (
 user_id INT NOT NULL PRIMARY KEY,
 recency INT NOT NULL CHECK(recency >= 1 AND recency <= 5)
);
CREATE TABLE analysis.tmp_rfm_frequency (
 user_id INT NOT NULL PRIMARY KEY,
 frequency INT NOT NULL CHECK(frequency >= 1 AND frequency <= 5)
);
CREATE TABLE analysis.tmp_rfm_monetary_value (
 user_id INT NOT NULL PRIMARY KEY,
 monetary_value INT NOT NULL CHECK(monetary_value >= 1 AND monetary_value <= 5)
);
----------------------------------------------------------------------------------------

insert into analysis.tmp_rfm_recency
with rec as(
	select * from analysis.orders o
	where o.status = 4 and extract('year' from order_ts) > 2021
	),
usertab1 as (select id
		,max(order_ts)as recent
	from analysis.users u
	left join rec f on u.id = f.user_id 
	group by u.id
)
select id as user_id
	,ntile(5) over(order by recent) as recency
from usertab1 u;
----------------------------------------------------------------------------------------

insert into analysis.tmp_rfm_frequency
with rec as(
	select * from analysis.orders o
	where o.status = 4 and extract('year' from order_ts) > 2021
	),
usertab2 as (select id
		,count(distinct order_id) as cnt
	from analysis.users u
	left join rec f on u.id = f.user_id 
	group by u.id
)
select id as user_id
	,ntile(5) over(order by cnt) as frequency
from usertab2 u;
----------------------------------------------------------------------------------------

insert into analysis.tmp_rfm_monetary_value
with rec as(
	select * from analysis.orders o
	where o.status = 4 and extract('year' from order_ts) > 2021
	),
usertab3 as (select id
		,sum(payment) as pay_sum
	from analysis.users u
	left join rec f on u.id = f.user_id 
	group by u.id
)
select id as user_id
	,ntile(5) over(order by pay_sum) as monetary_value
from usertab3 u;
---------------------------------------------------------------------------------------

insert into analysis.dm_rfm_segments
select r.user_id, r.recency, f.frequency, mv.monetary_value
from analysis.tmp_rfm_recency r
join analysis.tmp_rfm_frequency f on f.user_id = r.user_id
join analysis.tmp_rfm_monetary_value mv on mv.user_id = r.user_id

|user_id|recency|frequency|monetary_value|
|-------|-------|---------|--------------|
|0|1|3|4|
|1|4|3|3|
|2|2|3|5|
|3|2|3|3|
|4|4|3|3|
|5|5|5|5|
|6|1|3|5|
|7|4|2|2|
|8|1|1|3|
|9|1|3|2|
|10|3|5|2|
```



