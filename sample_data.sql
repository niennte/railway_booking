USE railway;

-- Physical objects rail data

INSERT INTO `train` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name_or_number`, -- varchar(25) NOT NULL UNIQUE KEY,
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
  `booking_reference` -- varchar(25),
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
  `type`, -- ENUM('aisle', 'window') NOT NULL,
  `booking_reference` -- VARCHAR(25),
) VALUES (
  null,
  (SELECT id FROM car WHERE booking_reference='#1' AND train_id=(
    SELECT id FROM train WHERE name_or_number='ABC-25')
  ),
  'aisle',
  '#1'
),
(
  null,
  (SELECT id FROM car WHERE booking_reference='#1' AND train_id=(
    SELECT id FROM train WHERE name_or_number='ABC-25')
  ),
  'window',
  '#2'
),
(
  null,
  (SELECT id FROM car WHERE booking_reference='#2' AND train_id=(
    SELECT id FROM train WHERE name_or_number='ABC-25')
  ),
  'aisle',
  '#1'
),
(
  null,
  (SELECT id FROM car WHERE booking_reference='#2' AND train_id=(
    SELECT id FROM train WHERE name_or_number='ABC-25')
  ),
  'window',
  '#2'
),
(
  null,
  (SELECT id FROM car WHERE booking_reference='#1' AND train_id=(
    SELECT id FROM train WHERE name_or_number='DEF-60')
  ),
  'aisle',
  '#1'
),
(
  null,
  (SELECT id FROM car WHERE booking_reference='#1' AND train_id=(
    SELECT id FROM train WHERE name_or_number='DEF-60')
  ),
  'window',
  '#1'
),
(
  null,
  (SELECT id FROM car WHERE booking_reference='#2' AND train_id=(
    SELECT id FROM train WHERE name_or_number='DEF-60')
  ),
  'aisle',
  '#1'
),
(
  null,
  (SELECT id FROM car WHERE booking_reference='#2' AND train_id=(
    SELECT id FROM train WHERE name_or_number='DEF-60')
  ),
  'window',
  '#2'
);


-- Data related to passengers
INSERT INTO `passenger` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name`, -- varchar(25) NOT NULL,
  `info` -- varchar(255) NOT NULL
) VALUES (
  null,
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
