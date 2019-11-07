
#### Minimal DB implementing railway booking system

- read [brief](BRIEF.md)
- read [design notes](NOTES.md)
- download [schema UML in .pdf format](https://www.lucidchart.com/publicSegments/view/36346eee-6206-4d7c-bdfd-1571105b9b20/image.pdf)


##### Run locally:
These instructions assume Docker is [installed](https://docs.docker.com/), the deamon/process is running an accessible to a CLI client, and is shown using Mac OS terminal.

Launch the container and load schema into it
```
# download and run mySQL in a container
$ docker pull mysql
$ docker run --name railway -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:latest


### load schema

# navigate to directory where the repo is cloned
$ cd [project directory]

# make SQL file available to the container
$ docker cp ./schema.sql railway:/

# run SQL file within container
$ docker exec railway /bin/sh -c 'exec mysql  -uroot -p"my-secret-pw" </schema.sql'
```

Verify results:
```
### run client & observe
$ docker run -it --link railway:mysql --rm mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'

# - - - observe
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| railway       |
...

mysql> use railway;
...

Database changed

mysql> show tables;
+-------------------+
| Tables_in_railway |
+-------------------+
| booking           |
| car               |
| passenger         |
| route             |
| schedule          |
| seat              |
| station           |
| train             |
+-------------------+

mysql> show CREATE TABLE billing_info;
| Table   | Create Table                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
+---------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| booking | CREATE TABLE `booking` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `departure_schedule_id` int(10) unsigned NOT NULL,
  `arrival_schedule_id` int(10) unsigned NOT NULL,
  `seat_id` int(10) unsigned NOT NULL,
  `passenger_id` int(10) unsigned NOT NULL,
  `date_time` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  KEY `departure_schedule_id` (`departure_schedule_id`),
  KEY `arrival_schedule_id` (`arrival_schedule_id`),
  KEY `seat_id` (`seat_id`),
  KEY `passenger_id` (`passenger_id`),
  CONSTRAINT `booking_ibfk_1` FOREIGN KEY (`departure_schedule_id`) REFERENCES `schedule` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `booking_ibfk_2` FOREIGN KEY (`arrival_schedule_id`) REFERENCES `schedule` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `booking_ibfk_3` FOREIGN KEY (`seat_id`) REFERENCES `seat` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `booking_ibfk_4` FOREIGN KEY (`passenger_id`) REFERENCES `passenger` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 |
+---------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)


### etc.
mysql> exit
Bye
```

Load sample data:
```
### Load sample data
# make SQL file available to the container
$ docker cp ./express_food_data.sql railway:/

# run SQL file within container
$ docker exec railway /bin/sh -c 'exec mysql  -uroot -p"my-secret-pw" </sample_data.sql'
```

Verify data is loaded:
```
### run client
docker run -it --link railway:mysql --rm mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'

mysql> use railway;
...
Database changed


mysql> -- Let's view all available seats grouped by class

mysql> SELECT train.name_or_number as train, class, count(*) AS num_seats, train.description FROM seat, car, train WHERE seat.car_id = car.id AND car.train_id = train.id GROUP BY train_id, class;
+----------------+--------+-----------+-------------------------------------------+
| train | class  | num_seats | description+----------------+--------+-----------+-------------------------------------------+
| ABC-25         | second |         2 | Москва-Киев                     |
| ABC-25         | first  |         2 | Москва-Киев                     |
| DEF-60         | second |         2 | Москва-Снкт.-Петербург |
| DEF-60         | first  |         2 | Москва-Снкт.-Петербург |
+----------------+--------+-----------+-------------------------------------------+
4 rows in set (0.00 sec)


mysql> -- A simple table:

mysql> SELECT train.name_or_number AS train, route.name_or_number as route, station.name_code AS station, station.location as location, date_time, type from schedule, train, station, route WHERE schedule.train_id = train.id AND schedule.station_id = station.id AND schedule.route_id = route.id ORDER BY train;
+--------+---------------------------------+---------+-------------------------------+---------------------+-----------+
| train  | route                           | station | location                      | date_time           | type      |
+--------+---------------------------------+---------+-------------------------------+---------------------+-----------+
| DEF-60 | Москва-Петербург | MSC     | Москва                  | 2019-11-08 11:49:57 | departure |
| DEF-60 | Москва-Петербург | BLH     | Балагое                | 2019-11-08 12:21:57 | arrival   |
| DEF-60 | Москва-Петербург | BLH     | Балагое                | 2019-11-08 12:57:57 | departure |
| DEF-60 | Москва-Петербург | PTB     | Санкт-Петербург | 2019-11-08 13:29:57 | arrival   |
+--------+---------------------------------+---------+-------------------------------+---------------------+-----------+
4 rows in set (0.00 sec)




mysql> -- There is one booking made for MSC - BLH.
mysql> -- A ticket view for the booking:

mysql> SELECT 
passenger.name,
station_d.name_code as departure_station,
schedule_d.date_time as departure_time,
station_a.name_code as arrival_station,
schedule_a.date_time as arrival_time,
seat.name_or_number as seat,
seat.type as seat_type,
car.name_or_number as car,
car.class as car_class,
train.name_or_number as train
from
booking
LEFT JOIN
passenger
ON
passenger.id = booking.passenger_id 
LEFT JOIN schedule as schedule_d ON booking.departure_schedule_id = schedule_d.id
LEFT JOIN station as station_d ON schedule_d.station_id = station_d.id
LEFT JOIN schedule as schedule_a ON booking.arrival_schedule_id = schedule_a.id
LEFT JOIN station as station_a ON schedule_a.station_id = station_a.id
LEFT JOIN seat ON booking.seat_id = seat.id
LEFT JOIN car ON seat.car_id = car.id
LEFT JOIN train ON car.train_id = train.id
WHERE
passenger.id = 1;
+-------------------------------+-------------------+---------------------+-----------------+---------------------+------+-----------+------+-----------+--------+
| name                          | departure_station | departure_time      | arrival_station | arrival_time        | seat | seat_type | car  | car_class | train  |
+-------------------------------+-------------------+---------------------+-----------------+---------------------+------+-----------+------+-----------+--------+
| Старик Хоттабыч | MSC               | 2019-11-08 12:22:38 | BLH             | 2019-11-08 14:22:38 | #1   | aisle     | #2   | second    | DEF-60 |
+-------------------------------+-------------------+---------------------+-----------------+---------------------+------+-----------+------+-----------+--------+
1 row in set (0.00 sec)



mysql> -- available seats:
mysql> -- observe available tickets for second class train DEF-60 = 1
mysql> SELECT 
car.class,
count(seat.id) as num_seats,
train.name_or_number as train,
route.name_or_number as route
FROM
schedule as schedule_d
LEFT JOIN train ON schedule_d.train_id = train.id 
LEFT JOIN route ON schedule_d.route_id = route.id 
LEFT JOIN schedule as schedule_a ON schedule_a.route_id = route.id
LEFT JOIN car ON car.train_id = train.id
LEFT JOIN seat ON seat.car_id = car.id
WHERE 
schedule_d.type = 'departure'
AND
schedule_d.station_id = 1
AND
schedule_a.type = 'arrival'
AND
schedule_a.station_id = route.arrival_station_id
AND
schedule_d.date_time > NOW() + INTERVAL 1 DAY - INTERVAL 5 HOUR
AND seat.id NOT IN (
SELECT seat_id from 
booking 
LEFT JOIN schedule as sd ON booking.departure_schedule_id = sd.id
LEFT JOIN schedule as sa ON booking.arrival_schedule_id = sa.id
WHERE 
sd.date_time >= schedule_d.date_time
AND
sa.date_time <= schedule_a.date_time
)
GROUP BY car.class, train.name_or_number, route.name_or_number
;
+--------+-----------+--------+---------------------------------+
| class  | num_seats | train  | route                           |
+--------+-----------+--------+---------------------------------+
| first  |         2 | DEF-60 | Москва-Петербург |
| second |         1 | DEF-60 | Москва-Петербург |
| first  |         2 | ABC-25 | Москва-Киев           |
| second |         2 | ABC-25 | Москва-Киев           |
+--------+-----------+--------+---------------------------------+
4 rows in set (0.01 sec)

mysql> -- let's remove the booking
mysql> DELETE from booking;
Query OK, 1 row affected (0.01 sec)

mysql> -- observe:
mysql> -- available tickets for second class train DEF-60 is now 2 
mysql> SELECT 
car.class,
count(seat.id) as num_seats,
train.name_or_number as train,
route.name_or_number as route
FROM
schedule as schedule_d
LEFT JOIN train ON schedule_d.train_id = train.id 
LEFT JOIN route ON schedule_d.route_id = route.id 
LEFT JOIN schedule as schedule_a ON schedule_a.route_id = route.id
LEFT JOIN car ON car.train_id = train.id
LEFT JOIN seat ON seat.car_id = car.id
WHERE 
schedule_d.type = 'departure'
AND
schedule_d.station_id = 5
AND
schedule_a.type = 'arrival'
AND
schedule_a.station_id = route.arrival_Station_id
AND
schedule_d.date_time > NOW() + INTERVAL 1 DAY - INTERVAL 5 HOUR
AND seat.id NOT IN (
SELECT seat_id from 
booking 
LEFT JOIN schedule as sd ON booking.departure_schedule_id = sd.id
LEFT JOIN schedule as sa ON booking.arrival_schedule_id = sa.id
WHERE 
sd.date_time >= schedule_d.date_time
AND
sa.date_time <= schedule_a.date_time
)
GROUP BY car.class, train.name_or_number, route.name_or_number
;
+--------+-----------+--------+---------------------------------+
| class  | num_seats | train  | route                           |
+--------+-----------+--------+---------------------------------+
| first  |         2 | DEF-60 | Москва-Петербург |
| second |         2 | DEF-60 | Москва-Петербург |
| first  |         2 | ABC-25 | Москва-Киев           |
| second |         2 | ABC-25 | Москва-Киев           |
+--------+-----------+--------+---------------------------------+
4 rows in set (0.01 sec)

mysql> 
```

