-- 1. How many airports are in the database?
SELECT COUNT(airport_id) AS num_airports
FROM Airport;

-- 2. How many carriers are in the database?
SELECT COUNT(carrier_id) AS num_carriers
FROM Carrier;

-- 3. What date range does this data comprise?
SELECT MIN(TO_DATE(CONCAT(Year, '/', Month), 'YYYY/MM')) AS min_date,
	MAX(TO_DATE(CONCAT(Year, '/', Month), 'YYYY/MM')) AS max_date
FROM flights

-- 4. What are the average number of flights per month in each year?
WITH flights_agg AS (
SELECT year,  
	month,
	SUM(num_flights) AS num_flights
FROM Flights
GROUP BY year, month)

SELECT year,
	   ROUND(AVG(num_flights),0) AS avg_flights
FROM flights_agg
GROUP BY year



-- 4. What is the percentage of delays in each year
WITH yearly_data AS (
	SELECT year, 
			SUM(num_flights) AS total_flights,
			SUM(num_delayed) AS total_delays,
			SUM(num_cancelled) AS total_cancelled,
			SUM(num_diverted) AS total_diverted
		FROM Flights
		GROUP BY year)
		
SELECT year,
	ROUND((CAST(total_delays AS DECIMAL)/total_flights)*100,2) AS pct_delayed,
	ROUND((CAST(total_cancelled AS DECIMAL)/total_flights)*100,2) AS pct_cancelled,
	ROUND((CAST(total_diverted AS DECIMAL)/total_flights)*100,2) AS pct_diverted
FROM yearly_data;

-- 4. What is the percentage of delays in each month in 2020?
WITH yearly_data AS (
	SELECT TO_DATE(CONCAT(Year, '/', Month), 'YYYY/MM') AS date, 
			SUM(num_flights) AS total_flights,
			SUM(num_delayed) AS total_delays,
			SUM(num_cancelled) AS total_cancelled,
			SUM(num_diverted) AS total_diverted
		FROM Flights
		GROUP BY TO_DATE(CONCAT(Year, '/', Month), 'YYYY/MM'))
		
SELECT date,
	ROUND((CAST(total_delays AS DECIMAL)/total_flights)*100,2) AS pct_delayed,
	ROUND((CAST(total_cancelled AS DECIMAL)/total_flights)*100,2) AS pct_cancelled,
	ROUND((CAST(total_diverted AS DECIMAL)/total_flights)*100,2) AS pct_diverted
FROM yearly_data
WHERE EXTRACT(YEAR FROM date) = 2020;



-- 6. What is the number of minutes of delay in each month
SELECT TO_DATE(CONCAT(year, '/', month),'YYYY/MM') AS date, 
	SUM(total_delay) AS total_delay
FROM Flights
GROUP BY TO_DATE(CONCAT(year, '/', month),'YYYY/MM')


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
	ROUND(((CAST(total_flights AS DECIMAL)-total_flights_prev)/total_flights_prev) *100,2) AS pct_change
FROM prev_flights




-- 7. Which airports of each airport size had the worst 2020?

SELECT *
FROM Airport_flights_temp
WHERE year = 2020
	AND pct_change IS NOT NULL
ORDER BY pct_change	
LIMIT 5;

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


SELECT *
FROM Airport_flights_temp
WHERE year = 2021
	AND pct_change IS NOT NULL
ORDER BY pct_change	DESC
LIMIT 5;

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
	ROUND(((CAST(total_flights AS DECIMAL)-total_flights_prev)/total_flights_prev) *100,2) AS pct_change
FROM prev_flights


-- 9. Wchich were the 5 best and 5 worst affected airlines in 2020?

SELECT carrier_name,
	   pct_change
FROM Carrier_flights_temp
WHERE year = 2020
ORDER BY pct_change 
LIMIT 5

SELECT carrier_name,
	   pct_change
FROM Carrier_flights_temp
WHERE year = 2020
ORDER BY pct_change DESC
LIMIT 5

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

SELECT carrier_name,
	   pct_change
FROM Carrier_flights_temp
WHERE year = 2021
	AND pct_change IS NOT NULL
ORDER BY pct_change 
LIMIT 5

SELECT carrier_name,
	   pct_change
FROM Carrier_flights_temp
WHERE year = 2021
	AND pct_change IS NOT NULL
ORDER BY pct_change  DESC
LIMIT 5



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
WITH sum_delay AS (
SELECT year, 
	SUM(total_delay) AS total_delay, 
	SUM(carrier_delay) AS carrier_delay, 
	SUM(weather_delay) AS weather_delay,
	SUM(nas_delay) AS nas_delay,
	SUM(security_delay) AS security_delay,
	SUM(late_aircraft_delay) AS late_aircraft_delay
FROM Flights
GROUP BY year)

SELECT year,
	CASE GREATEST(carrier_delay, weather_delay, nas_delay, security_delay, late_aircraft_delay)
	WHEN carrier_delay THEN 'Carrier Delay'
	WHEN weather_delay THEN 'Weather Delay'
	WHEN nas_delay THEN 'NAS Delay'
	WHEN security_delay THEN 'Security Delay'
	WHEN late_aircraft_delay THEN 'Late Aircraft Delay'
	ELSE 'Two or More Leading Causes' END AS leading_cause
FROM sum_delay;

-- What is the leading cause of delay for each airport type?

WITH sum_delay AS (
SELECT year, 
	COALESCE(A_T.airport_type, 'Small or Non Hub') AS airport_type,
	SUM(F.total_delay) AS total_delay, 
	SUM(F.carrier_delay) AS carrier_delay, 
	SUM(F.weather_delay) AS weather_delay,
	SUM(F.nas_delay) AS nas_delay,
	SUM(F.security_delay) AS security_delay,
	SUM(F.late_aircraft_delay) AS late_aircraft_delay
FROM Flights F
JOIN Airport A
	ON F.airport_id = A.airport_id
LEFT JOIN Airport_type A_T
	ON A.airport = A_T.airport_code
GROUP BY year, COALESCE(A_T.airport_type, 'Small or Non Hub'))

SELECT year,
	airport_type,
	CASE GREATEST(carrier_delay, weather_delay, nas_delay, security_delay, late_aircraft_delay)
	WHEN carrier_delay THEN 'Carrier Delay'
	WHEN weather_delay THEN 'Weather Delay'
	WHEN nas_delay THEN 'NAS Delay'
	WHEN security_delay THEN 'Security Delay'
	WHEN late_aircraft_delay THEN 'Late Aircraft Delay'
	ELSE 'Two or More Leading Causes' END AS leading_cause
FROM sum_delay;

-- Which states have been most impacted by the pandemic in 2020?

-- CREATE TEMP TABLE

CREATE TEMP TABLE IF NOT EXISTS State_flights_temp AS 
WITH airport_flights AS (
SELECT f.year,
	a.state,
	SUM(num_flights) AS total_flights
FROM Flights f
JOIN Airport a
	ON f.airport_id = a.airport_id
GROUP BY f.year, a.state
ORDER BY a.state, f.year),

prev_flights AS (
SELECT *,
	LAG(total_flights) OVER(PARTITION BY state ORDER BY YEAR) AS total_flights_prev
FROM airport_flights)


SELECT *,
	ROUND(((CAST(total_flights AS DECIMAL)-total_flights_prev)/total_flights_prev) *100,2) AS pct_change
FROM prev_flights


SELECT state,
	   total_flights,
	   pct_change
FROM State_flights_temp
WHERE year = 2020
ORDER BY pct_change 
LIMIT 10
UNION 
SELECT state,
       total_flights,
	   pct_change
FROM State_flights_temp
WHERE year = 2020
ORDER BY pct_change DESC
LIMIT 10
-- Which states have recovered the most from the downturn in 2020?

SELECT state,
	   total_flights,
	   pct_change
FROM State_flights_temp
WHERE year = 2021
ORDER BY pct_change
LIMIT 10;

SELECT state,
	   total_flights,
	   pct_change
FROM State_flights_temp
WHERE year = 2021
ORDER BY pct_change DESC
LIMIT 10

