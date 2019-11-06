DROP DATABASE IF EXISTS railway;


CREATE DATABASE railway CHARACTER SET utf8 COLLATE utf8_general_ci;
USE railway;

-- Use strong constraints
SET default_storage_engine=InnoDB;



-- Physical objects rail data

CREATE TABLE `train` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name_or_number` varchar(25) NOT NULL UNIQUE KEY,
  `description` varchar(255) NOT NULL
);

CREATE TABLE `car` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `train_id` int(10) unsigned,
  `class` ENUM('first', 'second', 'third') NOT NULL,
  `booking_reference` varchar(25),
  FOREIGN KEY (train_id)
    REFERENCES train(id)
    ON UPDATE CASCADE
    -- car can exist without a train
    -- but should propagate change in train
);

CREATE TABLE `seat` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `car_id` int(10) unsigned NOT NULL,
  `type` ENUM('aisle', 'window') NOT NULL,
  `booking_reference` VARCHAR(25),
  FOREIGN KEY (car_id)
    REFERENCES car(id)
    ON DELETE CASCADE
    -- seat can't exist without a car
);


-- Data related to passengers
CREATE TABLE `passenger` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(255) NOT NULL,
  `info` varchar(255) NOT NULL
);


-- Data related to rail movement in space

CREATE TABLE `station` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name_code` varchar(25) NOT NULL UNIQUE KEY,
  `location` varchar(255) NOT NULL
);


CREATE TABLE `route` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name_or_number` varchar(255) NOT NULL UNIQUE KEY,
  `departure_station_id` int(10) unsigned NOT NULL,
  `arrival_station_id` int(10) unsigned NOT NULL,
  FOREIGN KEY (departure_station_id)
    REFERENCES station(id)
    ON DELETE RESTRICT -- can't delete a station assigned as route departure
    ON UPDATE CASCADE, -- should propagate change in station
  FOREIGN KEY (arrival_station_id)
    REFERENCES station(id)
    ON DELETE RESTRICT -- can't delete a station assigned as route destination
    ON UPDATE CASCADE -- should propagate change in station
);



-- Data related to rail objects and users movement in time


-- Schedule records
-- Note: this table should be regularly maintained to have no outdated records
/*
A collection all of points in time related to trains movement through a station,
with type of event (either departure or arrival);
- a full timetable by train, by route, by station arrivals and departures can be derived;
- base for deriving seats availability
*/
CREATE TABLE `schedule` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `train_id` int(10) unsigned NOT NULL,
  `route_id` int(10) unsigned NOT NULL,
  `station_id` int(10) unsigned NOT NULL,
  `date_time` TIMESTAMP NOT NULL,
  `type` ENUM('departure', 'arrival') NOT NULL,
  FOREIGN KEY (train_id)
    REFERENCES train(id)
    ON DELETE RESTRICT -- can't delete a train assigned to active schedule
    ON UPDATE CASCADE, -- should propagate change in train
  FOREIGN KEY (route_id)
    REFERENCES route(id)
    ON DELETE RESTRICT -- can't delete a route that is scheduled
    ON UPDATE CASCADE, -- should propagate change in route
  FOREIGN KEY (station_id)
    REFERENCES station(id)
    ON DELETE RESTRICT -- can't delete a station with records in active schedule
    ON UPDATE CASCADE -- should propagate change in schedule
);


-- Booking records
-- Note: this table should be archived and purged as each travel completes
/*
A collection of travel segments between adjacent stations
listed per seat assigned to a passenger;
- full ticketing info can be derived,
- absence of record represents the seat is free for the segment,
- datetime for the same booking is shared between all segments;
- also, takes part in deriving seat availability
*/
CREATE TABLE `booking` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `departure_schedule_id` int(10) unsigned NOT NULL,
  `arrival_schedule_id` int(10) unsigned NOT NULL,
  `seat_id` int(10) unsigned NOT NULL,
  `passenger_id` int(10) unsigned NOT NULL,
  `date_time` TIMESTAMP NOT NULL,
  FOREIGN KEY (departure_schedule_id)
    REFERENCES schedule(id)
    ON DELETE RESTRICT -- can't delete a scheduled departure part of active booking
    ON UPDATE CASCADE, -- should propagate change in scheduled departure
  FOREIGN KEY (arrival_schedule_id)
    REFERENCES schedule(id)
    ON DELETE RESTRICT -- can't delete a scheduled arrival part of active booking
    ON UPDATE CASCADE, -- should propagate change in scheduled arrival
  FOREIGN KEY (seat_id)
    REFERENCES seat(id)
    ON DELETE RESTRICT -- can't delete a seat that is booked
    ON UPDATE CASCADE, -- should propagate change in seat
  FOREIGN KEY (passenger_id)
    REFERENCES passenger(id)
    ON DELETE RESTRICT -- can't delete a passenger with active booking
    ON UPDATE CASCADE -- should propagate change in seat
);

