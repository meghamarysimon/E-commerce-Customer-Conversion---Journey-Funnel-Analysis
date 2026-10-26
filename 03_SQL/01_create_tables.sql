CREATE TABLE `customers` (
    `customer_id` varchar(20) NOT NULL,
    `signup_date` date DEFAULT NULL,
    `age_group` varchar(30) DEFAULT NULL,
    `region` varchar(50) DEFAULT NULL,
    `country` varchar(50) DEFAULT NULL,
    `first_purchase_date` date DEFAULT NULL,
    `purchase_status` varchar(30) DEFAULT NULL,
    PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `products` (
    `product_id` varchar(20) NOT NULL,
    `product_name` varchar(150) DEFAULT NULL,
    `product_category` varchar(50) DEFAULT NULL,
    `brand` varchar(100) DEFAULT NULL,
    `unit_price` decimal(10,2) DEFAULT NULL,
    `rating` decimal(3,2) DEFAULT NULL,
    `stock_quantity` int DEFAULT NULL,
    PRIMARY KEY (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `sessions` (
    `session_id` varchar(20) NOT NULL,
    `customer_id` varchar(20) DEFAULT NULL,
    `session_start` datetime DEFAULT NULL,
    `device_type` varchar(30) DEFAULT NULL,
    `traffic_source` varchar(50) DEFAULT NULL,
    `campaign` varchar(100) DEFAULT NULL,
    `region` varchar(50) DEFAULT NULL,
    `session_duration_sec` int DEFAULT NULL,
    `pages_viewed` int DEFAULT NULL,
    `first_purchase_date` date DEFAULT NULL,
    `visitor_type` varchar(30) DEFAULT NULL,
    PRIMARY KEY (`session_id`),
    KEY `customer_id` (`customer_id`),
    CONSTRAINT `sessions_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `events` (
    `event_id` varchar(20) NOT NULL,
    `session_id` varchar(20) DEFAULT NULL,
    `customer_id` varchar(20) DEFAULT NULL,
    `product_id` varchar(20) DEFAULT NULL,
    `event_ts` datetime DEFAULT NULL,
    `event_type` varchar(30) DEFAULT NULL,
    PRIMARY KEY (`event_id`),
    KEY `session_id` (`session_id`),
    KEY `customer_id` (`customer_id`),
    KEY `product_id` (`product_id`),
    CONSTRAINT `events_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`),
    CONSTRAINT `events_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
    CONSTRAINT `events_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `orders` (
    `order_id` varchar(20) NOT NULL,
    `session_id` varchar(20) DEFAULT NULL,
    `customer_id` varchar(20) DEFAULT NULL,
    `order_date` date DEFAULT NULL,
    `payment_method` varchar(50) DEFAULT NULL,
    `discount_amount` decimal(10,2) DEFAULT NULL,
    `shipping_cost` decimal(10,2) DEFAULT NULL,
    `order_total` decimal(10,2) DEFAULT NULL,
    `order_status` varchar(30) DEFAULT NULL,
    `net_revenue` decimal(10,2) DEFAULT NULL,
    PRIMARY KEY (`order_id`),
    KEY `session_id` (`session_id`),
    KEY `customer_id` (`customer_id`),
    CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`session_id`) REFERENCES `sessions` (`session_id`),
    CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `order_items` (
    `order_item_id` varchar(20) NOT NULL,
    `order_id` varchar(20) DEFAULT NULL,
    `product_id` varchar(20) DEFAULT NULL,
    `quantity` int DEFAULT NULL,
    `unit_price` decimal(10,2) DEFAULT NULL,
    `line_total` decimal(10,2) DEFAULT NULL,
    PRIMARY KEY (`order_item_id`),
    KEY `order_id` (`order_id`),
    KEY `product_id` (`product_id`),
    CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
    CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;