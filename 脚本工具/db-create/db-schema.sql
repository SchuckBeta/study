DROP database IF EXISTS `os_creative`;

-- 创建数据库
create database `os_creative` default character set utf8 collate utf8_general_ci;

use os_creative;

DROP TABLE IF EXISTS `dr_card_imp`;
CREATE TABLE `dr_card_imp` (
  `id` varchar(64) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `dr_card_imp` WRITE;

INSERT INTO `dr_card_imp` (`id`)
VALUES
	(1),
	(2);
UNLOCK TABLES;
