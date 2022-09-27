
-- get the number of airports

SELECT COUNT(airport_id) AS num_airports 
FROM Airport;

-- get the number of carriers

SELECT COUNT(carrier_id) AS num_carriers 
FROM Carrier;

-- how many months of data for each carrier?
SELECT airport_id, COUNT(*)
FROM Flight_delays
GROUP BY airport_id;

-- what is the total number of flights in each year?
SELECT year,
	ROUND(SUM(num_flights),0) AS average_flights
FROM Flight_delays
GROUP BY year
ORDER BY year;

-- find the moving average of total flights 

WITH total AS (
SELECT year, 
	month, 
	SUM(num_flights) AS total_flights
FROM Flight_delays
GROUP BY year, month
ORDER BY year, month)

SELECT year,
	month,
	total_flights,
	ROUND(AVG(total_flights) OVER(ORDER BY year, month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),0) AS moving_average
FROM total;


-- find the best performing year and the worst performing year



-- in what month did each carrier register the most flights? 


-- in what month did each carrier register the least flights?


-- in what month did each airport register the most flights? 


-- in what month did each airport register the least flights?


-- find the airports that have suffered the most in 2020


-- find the carriers that have suffered the most in 2020



-- compare the average drop in 2020 for large hub, medium hub, and small/non hub airports


-- compare the average rise in flights in 2021/2022 for large hub, medium hub, and small/non hub 


-- find the airports that have bounced back the most in 2021 and 2022


-- compute the total cancelled flights and diverted flights in each year


-- what was the driving cause of delay in each year


-- what was the driving cause of delay in each year for large hub, medium hub, and small/non hub airports

