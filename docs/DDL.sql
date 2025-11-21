-- lgup4.category definition

CREATE TABLE `category` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `do` varchar(63) DEFAULT NULL,
  `si` varchar(63) DEFAULT NULL,
  `gu` varchar(63) DEFAULT NULL,
  `detail_address` varchar(255) DEFAULT NULL,
  `sub_category` varchar(63) DEFAULT NULL,
  `business_hour` varchar(255) DEFAULT NULL,
  `phone` varchar(12) DEFAULT NULL,
  `type` char(1) NOT NULL,
  `image` text DEFAULT NULL,
  `latitude` varchar(63) NOT NULL,
  `longitude` varchar(63) NOT NULL,
  `last_crawl` datetime NOT NULL,
  `menu` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.delete_cause definition

CREATE TABLE `delete_cause` (
  `cause` varchar(511) DEFAULT NULL,
  `count` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.tags definition

CREATE TABLE `tags` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_tags_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.users definition

CREATE TABLE `users` (
  `id` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `nickname` varchar(255) NOT NULL,
  `birth` date DEFAULT NULL,
  `phone` char(12) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `sex` tinyint(1) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.black definition

CREATE TABLE `black` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(255) DEFAULT NULL,
  `phone` char(12) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `sanction` text DEFAULT NULL,
  `started_at` datetime DEFAULT NULL,
  `finished_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_black_user_id` (`user_id`),
  KEY `idx_black_email` (`email`),
  KEY `idx_black_phone` (`phone`),
  KEY `idx_black_finished_at` (`finished_at`),
  CONSTRAINT `black_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.category_tags definition

CREATE TABLE `category_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) NOT NULL,
  `category_id` varchar(255) NOT NULL,
  `count` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_category_tags_category_id` (`category_id`),
  KEY `idx_category_tags_tag_id` (`tag_id`),
  KEY `idx_category_tags_category_count` (`category_id`,`count` DESC),
  CONSTRAINT `category_tags_ibfk_1` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `category_tags_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=92732 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.merge_history definition

CREATE TABLE `merge_history` (
  `id` varchar(255) NOT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `template_type` text DEFAULT NULL,
  `categories_name` text DEFAULT NULL,
  `visited_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_merge_history_user_visited` (`user_id`,`visited_at` DESC),
  KEY `idx_merge_history_user_id` (`user_id`),
  CONSTRAINT `merge_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.message definition

CREATE TABLE `message` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender` varchar(255) NOT NULL,
  `receiver` varchar(255) NOT NULL,
  `body` text DEFAULT NULL,
  `send_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sender` (`sender`),
  KEY `receiver` (`receiver`),
  CONSTRAINT `message_ibfk_1` FOREIGN KEY (`sender`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `message_ibfk_2` FOREIGN KEY (`receiver`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.posts definition

CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `body` text DEFAULT NULL,
  `user_id` varchar(255) NOT NULL,
  `create_at` datetime DEFAULT NULL,
  `merge_history_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `merge_history_id` (`merge_history_id`),
  CONSTRAINT `posts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `posts_ibfk_2` FOREIGN KEY (`merge_history_id`) REFERENCES `merge_history` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=136 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.report definition

CREATE TABLE `report` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `reported_at` datetime DEFAULT NULL,
  `reporter` varchar(255) DEFAULT NULL,
  `user_id` varchar(255) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `cause_id` varchar(255) DEFAULT NULL,
  `cause` text DEFAULT NULL,
  `is_processed` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `reporter` (`reporter`),
  KEY `idx_report_user_id` (`user_id`),
  CONSTRAINT `report_ibfk_1` FOREIGN KEY (`reporter`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `report_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.reviews definition

CREATE TABLE `reviews` (
  `id` varchar(255) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `category_id` varchar(255) NOT NULL,
  `stars` int(11) DEFAULT NULL,
  `comments` varchar(300) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `reviews_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reviews_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.user_history definition

CREATE TABLE `user_history` (
  `id` varchar(255) NOT NULL,
  `merge_id` varchar(255) DEFAULT NULL,
  `seq` int(11) DEFAULT NULL,
  `user_id` varchar(255) NOT NULL,
  `category_id` varchar(255) DEFAULT NULL,
  `category_name` varchar(255) DEFAULT NULL,
  `duration` int(11) DEFAULT NULL,
  `visited_at` datetime DEFAULT NULL,
  `transportation` char(1) DEFAULT NULL,
  `description` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_history_user_id` (`user_id`),
  KEY `idx_user_history_merge_id` (`merge_id`),
  KEY `idx_user_history_category_id` (`category_id`),
  KEY `idx_user_history_user_visited` (`user_id`,`visited_at` DESC),
  KEY `idx_user_history_visited_at` (`visited_at`),
  CONSTRAINT `user_history_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_history_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_history_ibfk_3` FOREIGN KEY (`merge_id`) REFERENCES `merge_history` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.user_like definition

CREATE TABLE `user_like` (
  `user_id` varchar(255) NOT NULL,
  `category_id` varchar(255) NOT NULL,
  UNIQUE KEY `idx_user_like_unique` (`user_id`,`category_id`),
  KEY `idx_user_like_category_id` (`category_id`),
  CONSTRAINT `user_like_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_like_ibfk_2` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- lgup4.comment definition

CREATE TABLE `comment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `user_id` varchar(255) NOT NULL,
  `body` text DEFAULT NULL,
  `create_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `comment_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `posts` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `comment_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;