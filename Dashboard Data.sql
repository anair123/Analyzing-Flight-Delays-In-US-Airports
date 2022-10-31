-- Dataset for dashboard
SELECT row_id,
	year,
	month,
	f.airport_id,
	c.carrier_id,
	f.num_flights,
	f.num_delayed,
	f.num_cancelled,
	f.num_diverted,
	f.total_delay,
	f.carrier_delay,
	f.weather_delay,
	f.nas_delay,
	f.security_delay,
	f.late_aircraft_delay,
	a.airport,
	a.airport_name,
	a.city,
	a.state,
	COALESCE(a_t.airport_type, 'Small or Non Hub') AS airport_type,
	c.carrier,
	c.carrier_name
FROM Flights f
JOIN Airport a
	ON a.airport_id = f.airport_id
JOIN Carrier c
	ON f.carrier_id = c.carrier_id
LEFT JOIN Airport_type a_t
	ON a.airport = a_t.airport_code;
	
	
SELECT *
FROM airport_type;

SELECT * FROM Airport;


SELECT airport FROM Airport;
WHERE airport NOT IN 
	(SELECT airport_code FROM Airport_type);
	
SELECT *
FROM Airport
WHERE airport

