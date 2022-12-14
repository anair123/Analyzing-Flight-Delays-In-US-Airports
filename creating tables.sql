-- Create tables
CREATE TABLE Flights (
	row_id int NOT NULL,
	airport_id int,
	carrier_id int,
	year int,
	month int,
	num_flights int,
	num_delayed int,
	num_cancelled int,
	num_diverted int,
	total_delay float4,
	carrier_delay float4,
	weather_delay float4,
	nas_delay float4,
	security_delay float4,
	late_aircraft_delay float4,
	PRIMARY KEY (row_id)
);

CREATE TABLE Airport (
	airport_id int NOT NULL,
	airport varchar(10),
	airport_name varchar(100),
	city varchar(100),
	state char(2),
	PRIMARY KEY (airport_id)
);

CREATE TABLE Carrier (
	carrier_id int NOT NULL,
	carrier varchar(10),
	carrier_name varchar(100),
	PRIMARY KEY (carrier_id)
);

CREATE TABLE Airport_type (
	airport_code varchar(10),
	airport_type varchar(100),
	PRIMARY KEY (airport_code)
);

-- Add constraints to link Flights table to Airport and Carrier tables
ALTER TABLE Flights 
ADD CONSTRAINT fk_airport FOREIGN KEY (airport_id)
REFERENCES Airport (airport_id);

ALTER TABLE Flights 
ADD CONSTRAINT fk_carrier FOREIGN KEY (carrier_id)
REFERENCES Carrier (carrier_id);

-- Get a preview of each table
SELECT * FROM Flights LIMIT 5;
SELECT * FROM Airport LIMIT 5;
SELECT * FROM Carrier LIMIT 5;
SELECT * FROM Airport_type LIMIT 5;



