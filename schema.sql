DROP DATABSE express_food;


CREATE DATABASE express_food CHARACTER SET utf8 COLLATE utf8_general_ci;
USE express_food;

-- use strong constraints
SET default_storage_engine=InnoDB;



-- Client and related info

CREATE TABLE `client` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(25) NOT NULL,
  `email_address` varchar(255) NOT NULL UNIQUE KEY,
  `cell_phone_number` varchar(25) NOT NULL
);

CREATE TABLE `location_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `client_id` int(10) unsigned NOT NULL,
  `street_address` varchar(255) NOT NULL,
  `phone_number` varchar(25),
  `delivery_instructions` varchar(255), -- e.g., buzz code
  PRIMARY KEY `client_address` (`client_id`,`street_address`),
  FOREIGN KEY (client_id)
    REFERENCES client(id)
    ON DELETE CASCADE -- makes no sense in absence of client
    -- so remove them
);

CREATE TABLE `billing_info` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `client_id` int(10) unsigned NOT NULL,
  `payment_method` ENUM('cash', 'credit card') NOT NULL,
  `payment_info` VARCHAR(255),
  PRIMARY KEY `client_payment_method` (`client_id`,`payment_method`),
  FOREIGN KEY (client_id)
    REFERENCES client(id)
    ON DELETE CASCADE -- makes no sense in absence of client
    -- so remove them
);


-- Order and related info

CREATE TABLE `order` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `client_id` int(10) unsigned NOT NULL,
  `billing_info_id` int(10) unsigned NOT NULL,
  `location_info_id`int(10) unsigned NOT NULL,
  FOREIGN KEY (client_id)
    REFERENCES client(id)
    ON DELETE RESTRICT, -- prevent deletion of clients who have orders on record
  FOREIGN KEY (billing_info_id)
    REFERENCES billing_info(id)
    ON DELETE RESTRICT,
  FOREIGN KEY (location_info_id)
    REFERENCES location_info(id)
    ON DELETE RESTRICT
);


CREATE TABLE `order_status` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `order_id` int(10) unsigned NOT NULL,
  `status` ENUM('open', 'complete', 'cancelled') NOT NULL,
  `time` timestamp(6) NOT NULL, -- add microseconds for the demo purpose
  `reason` varchar(255),
  PRIMARY KEY `order_status_snapshot` (`order_id`,`status`, `time`),
  FOREIGN KEY `order_status_order_id` (order_id) 
    REFERENCES `order`(id)
    ON DELETE CASCADE -- remove snapshots for deleted orders
);



CREATE TABLE `dish` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(255) NOT NULL,
  `type` ENUM('main dish', 'desert') NOT NULL
);


CREATE TABLE `order_detail` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `order_id` int(10) unsigned NOT NULL,
  `dish_id` int(10) unsigned NOT NULL,
  `quantity` int(10) unsigned NOT NULL DEFAULT 1, 
  PRIMARY KEY `order_item` (`order_id`,`dish_id`),
  FOREIGN KEY (order_id)
    REFERENCES `order`(id)
    ON DELETE CASCADE, -- remove details for deleted or archived orders
  FOREIGN KEY (dish_id)
    REFERENCES dish(id)
    ON DELETE RESTRICT 
    -- prevent deletion of dishes with orders on record
    -- (order needs to be deleted first)
);


CREATE TABLE `menu` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `dish_id` int(10) unsigned  NOT NULL,
  `date_available` date NOT NULL, 
  PRIMARY KEY `dish_availability` (`dish_id`,`date_available`),
  FOREIGN KEY (dish_id)
    REFERENCES dish(id)
    ON DELETE CASCADE -- remove menu records for deleted dishes
);


-- Delivery people

CREATE TABLE `courier` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(25) NOT NULL,
  `email_address` varchar(255) NOT NULL UNIQUE KEY,
  `phone_number` varchar(25) NOT NULL
);

-- Delivery 

CREATE TABLE `delivery` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `order_id` int(10) unsigned NOT NULL,
  `courier_id` int(10) unsigned NOT NULL,
  PRIMARY KEY `delivery_assignment` (`courier_id`,`order_id`),
  FOREIGN KEY (order_id)
    REFERENCES `order`(id)
    ON DELETE CASCADE, -- orders might be deleted or archived
  FOREIGN KEY (courier_id)
    REFERENCES courier(id)
    ON DELETE RESTRICT -- courriers for existing deliveries may not be deleted
);

CREATE TABLE `delivery_status` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `delivery_id` int(10) unsigned NOT NULL,
  `status` ENUM('open', 'complete', 'cancelled') NOT NULL,
  `time` timestamp(6) NOT NULL, -- add microseconds for the demo purpose
  `reason` varchar(255),
  PRIMARY KEY `delivery_status_snapshot` (`delivery_id`,`status`,`time`),
  FOREIGN KEY (delivery_id) 
    REFERENCES delivery(id)
    ON DELETE CASCADE -- remove status history for deleted delivery assignments
);


