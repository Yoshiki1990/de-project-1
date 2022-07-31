CREATE TABLE analysis.dm_rfm_segments (
	user_id INT PRIMARY KEY,
	recency smallint not null check (recency between 1 and 5),
	frequency smallint NOT NULL CHECK (frequency between 1 and 5),
	monetary_value smallint NOT NULL CHECK (monetary_value between 1 and 5)
	);