
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


mysql> select * from seat;
+----+--------+--------+-------------------+
| id | car_id | type   | booking_reference |
+----+--------+--------+-------------------+
|  1 |      1 | aisle  | #1                |
|  2 |      1 | window | #2                |
|  3 |      2 | aisle  | #1                |
|  4 |      2 | window | #2                |
|  5 |      3 | aisle  | #1                |
|  6 |      3 | window | #1                |
|  7 |      4 | aisle  | #1                |
|  8 |      4 | window | #2                |
+----+--------+--------+-------------------+
8 rows in set (0.00 sec)


```

