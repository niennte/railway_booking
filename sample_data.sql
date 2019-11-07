USE railway;

-- Physical objects rail data

INSERT INTO `train` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name_or_number`, -- varchar(50) NOT NULL UNIQUE KEY,
  `description` -- varchar(255) NOT NULL
) VALUES
(
  null,
  'ABC-25',
  'Москва-Киев'
),
(
  null,
  'DEF-60',
  'Москва-Снкт.-Петербург'
);

INSERT INTO `car` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `train_id`, -- int(10) unsigned,
  `class`, -- ENUM('first', 'second', 'third') NOT NULL,
  `name_or_number` -- varchar(50),
) VALUES
(
  null,
  (SELECT id FROM train WHERE name_or_number='ABC-25'),
  'first',
  '#1'
),
(
  null,
  (SELECT id FROM train WHERE name_or_number='ABC-25'),
  'second',
  '#2'
),
(
  null,
  (SELECT id FROM train WHERE name_or_number='DEF-60'),
  'first',
  '#1'
),
(
  null,
  (SELECT id FROM train WHERE name_or_number='DEF-60'),
  'second',
  '#2'
);

INSERT INTO `seat` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `car_id`, -- int(10) unsigned NOT NULL,
  `type`, -- ENUM('aisle', 'window', 'other') NOT NULL,
  `name_or_number` -- VARCHAR(50),
) VALUES (
  null,
  (SELECT id FROM car WHERE name_or_number='#1' AND train_id=(
    SELECT id FROM train WHERE name_or_number='ABC-25')
  ),
  'aisle',
  '#1'
),
(
  null,
  (SELECT id FROM car WHERE name_or_number='#1' AND train_id=(
    SELECT id FROM train WHERE name_or_number='ABC-25')
  ),
  'window',
  '#2'
),
(
  null,
  (SELECT id FROM car WHERE name_or_number='#2' AND train_id=(
    SELECT id FROM train WHERE name_or_number='ABC-25')
  ),
  'aisle',
  '#1'
),
(
  null,
  (SELECT id FROM car WHERE name_or_number='#2' AND train_id=(
    SELECT id FROM train WHERE name_or_number='ABC-25')
  ),
  'window',
  '#2'
),
(
  null,
  (SELECT id FROM car WHERE name_or_number='#1' AND train_id=(
    SELECT id FROM train WHERE name_or_number='DEF-60')
  ),
  'aisle',
  '#1'
),
(
  null,
  (SELECT id FROM car WHERE name_or_number='#1' AND train_id=(
    SELECT id FROM train WHERE name_or_number='DEF-60')
  ),
  'window',
  '#2'
),
(
  null,
  (SELECT id FROM car WHERE name_or_number='#2' AND train_id=(
    SELECT id FROM train WHERE name_or_number='DEF-60')
  ),
  'aisle',
  '#1'
),
(
  null,
  (SELECT id FROM car WHERE name_or_number='#2' AND train_id=(
    SELECT id FROM train WHERE name_or_number='DEF-60')
  ),
  'window',
  '#2'
);


-- Data related to passengers
INSERT INTO `passenger` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `email`, -- varchar(25) NOT NULL,
  `name`, -- varchar(25) NOT NULL,
  `info` -- varchar(255) NOT NULL
) VALUES (
  null,
  'hotab@example.com',
  'Старик Хоттабыч',
  'мифический, но обаятельный персонаж'
);


-- Data related to rail movement in space

INSERT INTO `station` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name_code`, -- varchar(25) NOT NULL UNIQUE KEY,
  `location` -- varchar(255) NOT NULL
) VALUES
(
  null,
  'MSC',
  'Москва'
),
(
  null,
  'BRY',
  'Брянск'
),
(
  null,
  'KNT',
  'Конотоп'
),
(
  null,
  'KYV',
  'Киев'
),
(
  null,
  'BLH',
  'Балагое'
),
(
  null,
  'PTB',
  'Санкт-Петербург'
);


INSERT INTO `route` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name_or_number`, -- varchar(25) NOT NULL UNIQUE KEY,
  `departure_station_id`, -- int(10) unsigned NOT NULL,
  `arrival_station_id` -- int(10) unsigned NOT NULL,
) VALUES (
  null,
  'Москва-Петербург',
  (SELECT id FROM station WHERE name_code='MSC'),
  (SELECT id FROM station WHERE name_code='PTB')
),
(
  null,
  'Москва-Киев',
  (SELECT id FROM station WHERE name_code='MSC'),
  (SELECT id FROM station WHERE name_code='KYV')
);


-- Add a test schedule
INSERT INTO `schedule` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `train_id`, -- int(10) unsigned NOT NULL,
  `route_id`, -- int(10) unsigned NOT NULL,
  `station_id`, -- int(10) unsigned NOT NULL,
  `date_time`, -- TIMESTAMP NOT NULL,
  `type` -- ENUM('departure', 'arrival') NOT NULL,
) VALUES
(
  null,
  (SELECT id FROM train WHERE name_or_number='DEF-60'),
  (SELECT id FROM route WHERE name_or_number='Москва-Петербург'),
  (SELECT id FROM station WHERE name_code='MSC'),
  NOW() + INTERVAL 1 DAY, -- tomorrow same time as now
  'departure'
),
(
  null,
  (SELECT id FROM train WHERE name_or_number='DEF-60'),
  (SELECT id FROM route WHERE name_or_number='Москва-Петербург'),
  (SELECT id FROM station WHERE name_code='BLH'),
  NOW() + INTERVAL 1 DAY + INTERVAL 2 HOUR,
  'arrival'
),
(
  null,
  (SELECT id FROM train WHERE name_or_number='DEF-60'),
  (SELECT id FROM route WHERE name_or_number='Москва-Петербург'),
  (SELECT id FROM station WHERE name_code='BLH'),
  NOW() + INTERVAL 1 DAY + INTERVAL 2 HOUR + INTERVAL 30 MINUTE,
  'departure'
),
(
  null,
  (SELECT id FROM train WHERE name_or_number='DEF-60'),
  (SELECT id FROM route WHERE name_or_number='Москва-Петербург'),
  (SELECT id FROM station WHERE name_code='PTB'),
  NOW() + INTERVAL 1 DAY + INTERVAL 5 HOUR,
  'arrival'
),
(
  null,
  (SELECT id FROM train WHERE name_or_number='ABC-25'),
  (SELECT id FROM route WHERE name_or_number='Москва-Киев'),
  (SELECT id FROM station WHERE name_code='MSC'),
  NOW() + INTERVAL 1 DAY,
  'departure'
),
(
  null,
  (SELECT id FROM train WHERE name_or_number='ABC-25'),
  (SELECT id FROM route WHERE name_or_number='Москва-Киев'),
  (SELECT id FROM station WHERE name_code='BRY'),
  NOW() + INTERVAL 1 DAY + INTERVAL 3 HOUR,
  'arrival'
),
(
  null,
  (SELECT id FROM train WHERE name_or_number='ABC-25'),
  (SELECT id FROM route WHERE name_or_number='Москва-Киев'),
  (SELECT id FROM station WHERE name_code='BRY'),
  NOW() + INTERVAL 1 DAY + INTERVAL 3 HOUR + INTERVAL 45 MINUTE,
  'departure'
),
(
  null,
  (SELECT id FROM train WHERE name_or_number='ABC-25'),
  (SELECT id FROM route WHERE name_or_number='Москва-Киев'),
  (SELECT id FROM station WHERE name_code='KNT'),
  NOW() + INTERVAL 1 DAY + INTERVAL 5 HOUR,
  'arrival'
),
(
  null,
  (SELECT id FROM train WHERE name_or_number='ABC-25'),
  (SELECT id FROM route WHERE name_or_number='Москва-Киев'),
  (SELECT id FROM station WHERE name_code='KNT'),
  NOW() + INTERVAL 1 DAY + INTERVAL 5 HOUR + INTERVAL 45 MINUTE,
  'departure'
),
(
  null,
  (SELECT id FROM train WHERE name_or_number='ABC-25'),
  (SELECT id FROM route WHERE name_or_number='Москва-Киев'),
  (SELECT id FROM station WHERE name_code='KYV'),
  NOW() + INTERVAL 1 DAY + INTERVAL 7 HOUR + INTERVAL 15 MINUTE,
  'arrival'
);


-- make a booking
INSERT INTO `booking` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `departure_schedule_id`, -- int(10) unsigned NOT NULL,
  `arrival_schedule_id`, -- int(10) unsigned NOT NULL,
  `seat_id`, -- int(10) unsigned NOT NULL,
  `passenger_id`, -- int(10) unsigned NOT NULL,
  `date_time` -- TIMESTAMP NOT NULL,
) VALUES (
  null,
  1, -- MSC
  2, -- BLH
  7, -- aisle seat #1 second class car, train DEF-60
  1,
  NOW()
);

