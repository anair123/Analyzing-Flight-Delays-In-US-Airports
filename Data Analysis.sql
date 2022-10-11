-- 1. How many airports are in the database?
SELECT COUNT(*)
FROM Airport;

-- 2. How many carriers are in the database?
SELECT COUNT(*)
FROM Carrier;

-- 3. What are the total number of flights in each year?
SELECT year,  month, SUM(num_flights) AS total_flights
FROM Flights
GROUP BY year, month;

-- 4. What is the percentage of delays in each year
CREATE TEMP TABLE yearly_data AS
	SELECT year, 
		SUM(num_flights) AS total_flights,
		SUM(num_delayed) AS total_delays,
		SUM(num_cancelled) AS total_cancelled,
		SUM(num_diverted) AS total_diverted
	FROM Flights
	GROUP BY year;
	

	ROUND((CAST(total_delays AS DECIMAL)/total_flights)*100,2) AS pct_delayed
FROM yearly_data;

-- 5. What is the percentage of cancellation in each year?
SELECT year,
	ROUND((CAST(total_cancelled AS DECIMAL)/total_flights)*100,2) AS pct_cancelled
FROM yearly_data;

-- 6. What is the percentage of diverte in each year?
SELECT year,
	ROUND((CAST(total_diverted AS DECIMAL)/total_flights)*100,2) AS pct_diverted
FROM yearly_data;


-- CREATE TEMP TABLE

CREATE TEMP TABLE IF NOT EXISTS Airport_flights_temp AS 

WITH airport_flights AS (
SELECT f.year,
	a.airport_name, 
	a.state,
	COALESCE(airport_type, 'Small or Non Hub') AS airport_type, 
	SUM(num_flights) AS total_flights
FROM Flights f
JOIN Airport a
	ON f.airport_id = a.airport_id
LEFT JOIN Airport_type a_t
	ON a.airport =  a_t.airport_code
GROUP BY f.year, a.airport_name, a.state, a_t.airport_type
ORDER BY a.airport_name, f.year),

prev_flights AS (
SELECT *,
	LAG(total_flights) OVER(PARTITION BY airport_name ORDER BY YEAR) AS total_flights_prev
FROM airport_flights)


SELECT *,
	ROUND(((CAST(total_flights AS DECIMAL)-total_flights_prev)/total_flights) *100,2) AS pct_change
FROM prev_flights



-- 7. Which airports of each airport size had the worst 2020?

WITH rankings AS (
	SELECT *,
		RANK() OVER(PARTITION BY airport_type ORDER BY pct_change) AS rk
	FROM Airport_flights_temp
	WHERE year = 2020 
		AND pct_change IS NOT NULL
)

SELECT year,
	airport_name,
	state,
	airport_type,
	pct_change
FROM rankings 
WHERE rk <=5
ORDER BY airport_type, rk;

-- 8. Which airports had the best 2021?

WITH rankings AS (
	SELECT *,
		RANK() OVER(PARTITION BY airport_type ORDER BY pct_change DESC) AS rk
	FROM Airport_flights_temp
	WHERE year = 2021 AND
		pct_change IS NOT NULL
)

SELECT year,
	airport_name,
	state,
	airport_type,
	pct_change
FROM rankings 
WHERE rk <=5
ORDER BY airport_type, rk;

-- 9. How is each carrier affected in 2020?

CREATE TEMP TABLE IF NOT EXISTS Carrier_flights_temp AS 

WITH carrier_flights AS (
SELECT f.year,
	c.carrier_name, 
	SUM(num_flights) AS total_flights
FROM Flights f
JOIN Carrier c
	ON f.carrier_id = c.carrier_id

GROUP BY f.year, c.carrier_name
ORDER BY c.carrier_name, f.year),

prev_flights AS (
SELECT *,
	LAG(total_flights) OVER(PARTITION BY carrier_name ORDER BY year) AS total_flights_prev
FROM carrier_flights)


SELECT *,
	ROUND(((CAST(total_flights AS DECIMAL)-total_flights_prev)/total_flights) *100,2) AS pct_change
FROM prev_flights

WITH rankings AS (
	SELECT *,
		RANK() OVER(PARTITION BY airport_type ORDER BY pct_change) AS rk
	FROM Airport_flights_temp
	WHERE year = 2020 
		AND pct_change IS NOT NULL
)

-- 9. Wchich were the 5 best and 5 worst affected airlines in 2020?

WITH rankings AS (
	SELECT *,
		RANK() OVER(ORDER BY pct_change) AS rk1,
		RANK() OVER(ORDER BY pct_change DESC) AS rk2
	FROM Carrier_flights_temp
	WHERE year = 2020 
		AND pct_change IS NOT NULL
)

SELECT year,
	carrier_name,
	pct_change,
	rk1
FROM rankings 
WHERE rk1 <=5 
	OR rk2 <=5
ORDER BY pct_change;

-- 10. Which airlines have recovered the least and the  most in 2021

WITH rankings AS (
	SELECT *,
		RANK() OVER(ORDER BY pct_change) AS rk1,
		RANK() OVER(ORDER BY pct_change DESC) AS rk2
	FROM Carrier_flights_temp
	WHERE year = 2021
		AND pct_change IS NOT NULL
)

SELECT year,
	carrier_name,
	pct_change,
	rk1
FROM rankings 
WHERE rk1 <=5 
	OR rk2 <=5
ORDER BY pct_change;



-- 11. Did large airport react differrently to 2021 compared to airport of other sizes

WITH airport_flights AS (
SELECT f.year,
	COALESCE(airport_type, 'Small or Non Hub') AS airport_type, 
	SUM(num_flights) AS total_flights
FROM Flights f
JOIN Airport a
	ON f.airport_id = a.airport_id
LEFT JOIN Airport_type a_t
	ON a.airport =  a_t.airport_code
GROUP BY f.year, a_t.airport_type
ORDER BY a_t.airport_type, f.year),

prev_flights AS (
SELECT *,
	LAG(total_flights) OVER(PARTITION BY airport_type ORDER BY year) AS total_flights_prev
FROM airport_flights)


SELECT *,
	ROUND(((CAST(total_flights AS DECIMAL)-total_flights_prev)/total_flights) *100,2) AS pct_change
FROM prev_flights
WHERE year = 2021


-- What is the leading cause of delay in each year? Does it change throughout the years?
SELECT year, 
	month, 
	airport_id, 
	carrier_id, 
	num_delayed, 
	total_delay, 
	carrier_delay, 
	weather_delay,
	nas_delay,
	security_delay,
	late_aircraft_delay
FROM Flights;

-- What is the leading cause of delay for each airport type?


--