USE express_food;

INSERT INTO `client` (
	`id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
	`name`, -- varchar(25) NOT NULL,
	`email_address`, -- varchar(255) NOT NULL UNIQUE KEY,
	`cell_phone_number` -- varchar(25) NOT NULL
) 
VALUES
(
	null,
	'Bilbo Baggins',
	'bilbo.baggins@hobiton.com',
	'111-1111'	
),
(
	null,
	'Frodo Baggins',
	'frodo.baggins@hobbiton.com',
	'333-3333'
),
(
	null,
	'Sam Gamgee',
	'sam.gamgee@hobbiton.com',
	'222-2222'
);


INSERT INTO `location_info` (
	`id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
	`client_id`, -- int(10) unsigned NOT NULL,
	`street_address`, -- varchar(255) NOT NULL,
	`phone_number`, -- varchar(25),
	`delivery_instructions` -- varchar(255), -- e.g., buzz code
)
VALUES
(
	null,
	(SELECT id FROM client WHERE name='Bilbo Baggins'),
	'Bag End',
	'123-1111',
	'ring a bell'
),
(
	null,
	(SELECT id FROM client WHERE name='Bilbo Baggins'),
	'Rivendell',
	'456-1111',
	'check Hall of Fire'
),
(
	null,
	(SELECT id FROM client WHERE name='Frodo Baggins'),
	'Bag End',
	'123-3333',
	'ring a bell'
),
(
	null,
	(SELECT id FROM client WHERE name='Frodo Baggins'),
	'Rivendell',
	'456-3333',
	'check Hall of Fire'
),
(
	null,
	(SELECT id FROM client WHERE name='Sam Gamgee'),
	'#1 Bagshot Row',
	'123-2222',
	'keep knocking'
),
(
	null,
	(SELECT id FROM client WHERE name='Sam Gamgee'),
	'Bag End',
	'456-2222',
	'ring a bell'
);


INSERT INTO `billing_info` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `client_id`, -- int(10) unsigned NOT NULL,
  `payment_method`, -- ENUM('cash', 'credit card') NOT NULL,
  `payment_info` -- VARCHAR(255)
)
VALUES
(
	null,
	(SELECT id FROM client WHERE name='Sam Gamgee'),
	'credit card',
	'invoice to Bagshot Row'
),
(
	null,
	(SELECT id FROM client WHERE name='Sam Gamgee'),
	'cash',
	'dragon treasure'
),
(
	null,
	(SELECT id FROM client WHERE name='Bilbo Baggins'),
	'cash',
	'dragon treasure'
),
(
	null,
	(SELECT id FROM client WHERE name='Frodo Baggins'),
	'credit card',
	'invoice to Bag End'
),
(
	null,
	(SELECT id FROM client WHERE name='Frodo Baggins'),
	'cash',
	'dragon treasure'
);


-- Dish
INSERT INTO `dish` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name`, -- int(10) unsigned  NOT NULL,
  `type` -- ENUM('main dish', 'desert') NOT NULL
)
VALUES 
(
	null,
	'Saucisse Minuit',
	'main dish'
),
(
	null,
	'Salade Printemps',
	'main dish'
),
(
	null,
	'Langoustine Ravioli',
	'main dish'
),
(
	null,
	'Saffron Risotto',
	'main dish'
),
(
	null,
	'Tiramisu',
	'desert'
),
(
	null,
	'Crème brûlée',
	'desert'
),
(
	null,
	'Charlotte',
	'desert'
),
(
	null,
	'Crêpe Suzette',
	'desert'
);


-- Menu

INSERT INTO `menu` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `dish_id`, -- int(10) unsigned  NOT NULL,
  `date_available` -- date NOT NULL, 
)
VALUES 
(
	null,
	(SELECT id FROM dish WHERE name='Saucisse Minuit'),
	CURDATE()
),
(
	null,
	(SELECT id FROM dish WHERE name='Saffron Risotto'),
	CURDATE()
),
(
	null,
	(SELECT id FROM dish WHERE name='Crème brûlée'),
	CURDATE()
),
(
	null,
	(SELECT id FROM dish WHERE name='Tiramisu'),
	CURDATE()
);


-- Delivery people

INSERT INTO `courier` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name`, -- varchar(25) NOT NULL,
  `email_address`, -- varchar(255) NOT NULL UNIQUE KEY,
  `phone_number` -- varchar(25) NOT NULL
)
VALUES
(
	null,
	'Glorfindel',
	'glorfindel@rivendell.com',
	'555-5555'	
),
(
	null,
	'Erestor',
	'erestor@rivendell.com',
	'777-7777'
);


-- Order

INSERT INTO `order` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `client_id`, -- int(10) unsigned NOT NULL,
  `billing_info_id`, -- int(10) unsigned NOT NULL,
  `location_info_id`--  int(10) unsigned NOT NULL
)
VALUES 
(
	null,
	(SELECT id FROM client WHERE name='Bilbo Baggins'),
	(SELECT id FROM billing_info WHERE payment_method="cash" AND client_id=(
		SELECT id FROM client WHERE name='Bilbo Baggins')
	),
	(SELECT id FROM location_info WHERE street_address="Bag End" AND client_id=(
		SELECT id FROM client WHERE name='Bilbo Baggins')
	)
),
(
	null,
	(SELECT id FROM client WHERE name='Bilbo Baggins'),
	(SELECT id FROM billing_info WHERE payment_method="cash" AND client_id=(
		SELECT id FROM client WHERE name='Bilbo Baggins')
	),
	(SELECT id FROM location_info WHERE street_address="Rivendell" AND client_id=(
		SELECT id FROM client WHERE name='Bilbo Baggins')
	)
),
(
	null,
	(SELECT id FROM client WHERE name='Sam Gamgee'),
	(SELECT id FROM billing_info WHERE payment_method="cash" AND client_id=(
		SELECT id FROM client WHERE name='Sam Gamgee')),
	(SELECT id FROM location_info WHERE street_address="Bag End" AND client_id=(
		SELECT id FROM client WHERE name='Sam Gamgee'))
);


-- order detail
INSERT INTO `order_detail` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `order_id`, -- int(10) unsigned NOT NULL,
  `dish_id`, -- int(10) unsigned NOT NULL,
  `quantity` -- int(10) unsigned NOT NULL DEFAULT 1, 
)
VALUES 
(
	null,
	1,
	(SELECT id FROM dish WHERE name='Saucisse Minuit'),
	2
), -- order 1 dish 1
(
	null,
	1,
	(SELECT id FROM dish WHERE name='Crème brûlée'),
	5
), -- order 1 dish 2
(
	null,
	2,
	(SELECT id FROM dish WHERE name='Saffron Risotto'),
	2
), -- order 2 dish 1
(
	null,
	2,
	(SELECT id FROM dish WHERE name='Tiramisu'),
	1
), -- order 2 dish 2
(
	null,
	3,
	(SELECT id FROM dish WHERE name='Saucisse Minuit'),
	10
), -- order 3 dish 1
(
	null,
	3,
	(SELECT id FROM dish WHERE name='Crème brûlée'),
	1
); -- order 3 dish 2



-- order status
INSERT INTO `order_status` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `order_id`, -- int(10) unsigned NOT NULL,
  `status`, -- ENUM('open', 'completed', 'cancelled') NOT NULL,
  `time`, -- timestamp NOT NULL,
  `reason` -- varchar(255),
)
VALUES 
(
	null,
	1,
	'open',
	sysdate(6),
	'order placed'
), -- order 1
(
	null,
	1,
	'complete',
	sysdate(6),
	'order arrived'
),
(
	null,
	2,
	'open',
	sysdate(6),
	'order placed'
), -- order 2
(
	null,
	2,
	'complete',
	sysdate(6),
	'order arrived'
),
(
	null,
	3,
	'open',
	sysdate(6),
	'order placed'
); -- order 3



-- Delivery
INSERT INTO `delivery` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `order_id`, -- int(10) unsigned NOT NULL,
  `courier_id` -- int(10) unsigned NOT NULL,
) VALUES 
(
	null,
	1,
	(SELECT id FROM courier WHERE name='Glorfindel')
),
(
	null,
	2,
	(SELECT id FROM courier WHERE name='Erestor')	
),
(
	null,
	3,
	(SELECT id FROM courier WHERE name='Glorfindel')	
); 


-- delivery history
INSERT INTO `delivery_status` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `delivery_id`, -- int(10) unsigned NOT NULL,
  `status`, -- ENUM('open', 'complete', 'cancelled') NOT NULL,
  `time`, -- timestamp NOT NULL,
  `reason` -- varchar(255),
)
VALUES 
(
	null,
	1,
	'open',
	sysdate(6),
	'courier assigned'
), -- delivery for order 1
(
	null,
	1,
	'complete',
	sysdate(6),
	'order delivered'
),
(
	null,
	2,
	'open',
	sysdate(6),
	'courier assigned'
), -- delivery for order 2
(
	null,
	2,
	'complete',
	sysdate(6),
	'order delivered'
),
(
	null,
	3,
	'open',
	sysdate(6),
	'courier assigned'
); -- delivery for order 3

 
SELECT sleep(2);

-- cancel delivery attempt for order 3
INSERT INTO `delivery_status` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `delivery_id`, -- int(10) unsigned NOT NULL,
  `status`, -- ENUM('open', 'complete', 'cancelled') NOT NULL,
  `time`, -- timestamp NOT NULL,
  `reason` -- varchar(255),
)
VALUES 
(
	null,
	3,
	'cancelled',
	sysdate(6),
	'Asfaloth has flat tire'
); -- repeated delivery for order 3


SELECT sleep(2);

-- reattempt delivery for order 3

-- Create new delivery
INSERT INTO `delivery` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `order_id`, -- int(10) unsigned NOT NULL,
  `courier_id` -- int(10) unsigned NOT NULL,
) 
VALUES 
(
	null,
	3,
	(SELECT id FROM courier WHERE name='Erestor')	
); -- reassigned


-- Update delivery status
INSERT INTO `delivery_status` (
  `id`, -- int(10) unsigned NOT NULL AUTO_INCREMENT UNIQUE KEY,
  `delivery_id`, -- int(10) unsigned NOT NULL,
  `status`, -- ENUM('open', 'complete', 'cancelled') NOT NULL,
  `time`, -- timestamp NOT NULL,
  `reason` -- varchar(255),
)
VALUES 
(
	null,
	4,
	'open',
	sysdate(6),
	'courier re-assigned'
); -- repeated delivery for order 3







