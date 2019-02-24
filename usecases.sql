
-- Client
-- order info
SELECT
os.id as order_status_id,
os.order_id,
os.time,
os.reason,
o.client_id,
c.name,
li.street_address,
bi.payment_method,
bi.payment_info
FROM order_status AS os
LEFT JOIN
`order` as o ON os.order_id = o.id
LEFT JOIN 
client as c ON o.client_id = c.id
LEFT JOIN
location_info AS li ON li.id = o.location_info_id
LEFT JOIN
billing_info AS bi ON bi.id = o.billing_info_id
WHERE o.id=3;

-- what was ordered:
SELECT *
from order_detail as od 
LEFT JOIN dish AS d ON od.dish_id = d.id
WHERE od.order_id = 3;


-- time placed, ETA, delivery status for the order
SELECT
max(ds.time) as deliveryOpenTime,
DATE_ADD(max(ds.time),INTERVAL '1200.00' SECOND_MICROSECOND) as estimatedDeliveryTime,
TIMEDIFF(DATE_ADD(max(ds.time),INTERVAL '1200.00' SECOND_MICROSECOND), NOW(6)) as timeLeft
FROM 
order_status AS os
LEFT JOIN
`order` as o ON os.order_id = o.id
LEFT JOIN
delivery as d ON d.order_id = o.id
LEFT JOIN 
delivery_status AS ds ON ds.delivery_id = d.id 
WHERE o.id=3
AND ds.status='open'
GROUP BY os.id
;


-- previous orders
SELECT * FROM `order` 
LEFT JOIN order_detail AS od ON od.order_id = `order`.id
LEFT JOIN dish AS d ON d.id = od.dish_id 
LEFT JOIN order_status AS os ON os.order_id = `order`.id
WHERE client_id=1;


-- Admin
-- List of clients (with numbers of locations and billing infos)
SELECT * from CLIENT;

-- List of daily menu items (sorted by date)
SELECT * from menu
LEFT JOIN dish AS d on d.id = menu.dish_id
ORDER BY date_available;


-- List of delivery people
SELECT * from couriers;

-- Order history for a client
SELECT
o.client_id,
c.name,
li.street_address,
bi.payment_method,
bi.payment_info
FROM `order` AS o
LEFT JOIN 
client as c ON o.client_id = c.id
LEFT JOIN
location_info AS li ON li.id = o.location_info_id
LEFT JOIN
billing_info AS bi ON bi.client_id = c.id
WHERE c.id=1;



-- More interesting:

-- complete delivery breakdown

-- currently unfulfilled deliveries
SELECT * FROM delivery_status WHERE status!='complete' and time IN (
	SELECT max(time) from delivery_status GROUP BY delivery_id
);

-- currently unfulfilled deliveries with order info
SELECT * FROM 
delivery_status AS ds 
LEFT JOIN
delivery AS d ON ds.delivery_id = d.id 
WHERE status!='complete' and time IN (
	SELECT max(time) from delivery_status GROUP BY delivery_id
)
ORDER BY d.order_id, ds.time
;


-- currently unfulfilled deliveries with order info and ETA
SELECT 
d.id,
d.order_id,
d.courier_id,
ds.*,
DATE_ADD(ds.time, INTERVAL '1200.00' SECOND_MICROSECOND) as estimatedDeliveryTime
FROM 
delivery_status AS ds 
LEFT JOIN
delivery AS d ON ds.delivery_id = d.id 
WHERE status!='complete' and time IN (
	SELECT max(time) from delivery_status GROUP BY delivery_id
)
ORDER BY d.order_id, ds.time
;






-- complete breakdown of order situation
-- currently open orders
SELECT
os.id as order_status_id,
os.order_id,
os.time,
os.reason,
o.client_id
FROM order_status AS os
LEFT JOIN
`order` as o ON os.order_id = o.id
WHERE os.status!='complete' and os.time IN (
	SELECT max(time) from order_status GROUP BY order_id
);

-- currently open orders with client info, location and payment method
SELECT
os.id as order_status_id,
os.order_id,
os.time,
os.reason,
o.client_id,
c.name,
li.street_address,
bi.payment_method,
bi.payment_info
FROM order_status AS os
LEFT JOIN
`order` as o ON os.order_id = o.id
LEFT JOIN 
client as c ON o.client_id = c.id
LEFT JOIN
location_info AS li ON li.id = o.location_info_id
LEFT JOIN
billing_info AS bi ON bi.id = o.billing_info_id
WHERE os.status!='complete' and os.time IN (
	SELECT max(time) from order_status GROUP BY order_id
);


-- details on currently open orders with delivery status history
SELECT
os.id as order_status_id,
os.order_id,
os.reason,
os.status as order_status,
os.time,
o.client_id,
d.id AS deliveryId,
ds.status,
ds.time,
ds.reason
FROM 
order_status AS os
LEFT JOIN
`order` as o ON os.order_id = o.id
LEFT JOIN
delivery as d ON d.order_id = o.id
LEFT JOIN 
delivery_status AS ds ON ds.delivery_id = d.id 
WHERE os.status!='complete' and os.time IN (
	SELECT max(time) from order_status GROUP BY order_id
)
ORDER BY o.id, os.time, ds.time
;



-- current delivery history for order
SELECT
os.id as order_status_id,
os.order_id,
os.reason,
os.status as order_status,
os.time,
o.client_id,
d.id,
ds.status,
ds.time,
ds.reason,
DATE_ADD(os.time,INTERVAL '1200.00' SECOND_MICROSECOND) as estimatedDeliveryTime,
TIMEDIFF(os.time, DATE_ADD(NOW(6),INTERVAL '1200.00' SECOND_MICROSECOND)) as timeLeft
FROM 
order_status AS os
LEFT JOIN
`order` as o ON os.order_id = o.id
LEFT JOIN
delivery as d ON d.order_id = o.id
LEFT JOIN 
delivery_status AS ds ON ds.delivery_id = d.id 
WHERE o.id=3
AND
ds.time = (SELECT max(time) from delivery_status WHERE delivery_id=ds.delivery_id)
;





