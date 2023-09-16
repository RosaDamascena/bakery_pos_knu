/* 
 * 프로젝트 요구사항
 개발 대상/범위 
 - 제빵 프차이즈 업소의 판매 POS 단말을 웹방식으로 구현 
 - 전국에 몇개의 브랜치를 가지고 있는 제빵업체의 POS 단말시스템을 개발
 (운영)
- 제빵업체는 여러 브랜치에 대하여 단일 제빵 카타로그(공급제품명, 제품가격)을 가지고 있음
- 브랜치는 카탈로그상의 여러 제빵을 개별 공급하고 브랜치빵 재고를 관리하면서 당일 판매함. 
- 고객주문은 주어진 브랜치에서의 재고 상황을 고려하여 여러 제빵들에 대하여 복수 구매 주문되고, 브랜치로 판매금액이 결제되고 브랜치빵 판매 현황이 관리됨. 

 (마감분석) 
 - 브랜치별 판매량, 제빵별 판매량 등의 기초 실적 현황을 분석함. 
 
- 구현 요구사항 
 - MySQL에서의 SQL 언어를 활용하여 DB 모델링, 데이터 운영 및 분석.
 - SQL 언어 외에 절차적인 C++, JAVA, Phthon을 사용하여 POS상의 빵 생산재고 입력,주문받기, 판매결제, 마감분석 등의 Activity를 구현할 수 있음. 

*/ 
-- 모델링 
CREATE DATABASE bakery;
DROP DATABASE bakery;

show create database bakery;
use bakery;

-- 제빵카탈로그 ( 공급제품명, 제품가격)
CREATE TABLE `bakery_catalog` (
  `product_name` varchar(100) NOT NULL COMMENT '제품명',
  `product_price` int(11) NOT NULL DEFAULT '0' COMMENT '제품가격',
  PRIMARY KEY (`product_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='제품 카탈로그';

SELECT version();

show create table bakery_catalog ;
INSERT INTO bakery_catalog (product_name, product_price) VALUES ('단팥빵',1000);
INSERT INTO bakery_catalog (product_name, product_price) VALUES ('크림빵',1000);
INSERT INTO bakery_catalog (product_name, product_price) VALUES ('피자빵',2000);

-- 브랜치재고 (브랜치이름, 제품명, 재고수량)

CREATE TABLE `branch_stock` (
  `branch_name` varchar(100) NOT NULL COMMENT '브랜치이름',
  `product_name` varchar(100) NOT NULL COMMENT '제품명',
  `stock_volume` int(11) NOT NULL DEFAULT '0' COMMENT '재고수',
  PRIMARY KEY (`branch_name`,`product_name`),
  KEY `fk_product_name` (`product_name`),
  CONSTRAINT `branch_stock_ibfk_1` FOREIGN KEY (`product_name`) REFERENCES `bakery_catalog` (`product_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='브랜치재고';

-- ALTER TABLE `branch_stock` ADD FOREIGN KEY fk_product_name(product_name) REFERENCES bakery_catalog(product_name);

SHOW CREATE TABLE branch_stock;

-- 고객정보 (고객아이디, 고객이름)

CREATE TABLE `customer_info` (
  `customer_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '고객번호',
  `customer_name` varchar(100) NOT NULL COMMENT '고객이름',
  PRIMARY KEY (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='고객정보';
  
 SHOW CREATE TABLE `customer_info`;

--  주문 (브랜치이름, 제품명, 판매량, 매출액, 판매일시, 고객아이디, 결제여부  )
CREATE TABLE `order_info` (
  `order_no` int(11) NOT NULL AUTO_INCREMENT COMMENT '주문번호',
  `branch_name` varchar(100) NOT NULL COMMENT '브랜치이름',
  `sale_price` int(11) NOT NULL COMMENT '매출액',
  `sale_datetime` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '판매일시',
  `customer_id` int(11) NOT NULL COMMENT '고객번호',
  `settlement_flag` enum('Y','N') NOT NULL COMMENT '결제여부',
  `settlement_datetime` datetime DEFAULT NULL COMMENT '결제일시',
  PRIMARY KEY (`order_no`),
  KEY `fk_customer_id` (`customer_id`),
  CONSTRAINT `order_info_ibfk_1` FOREIGN KEY (`customer_id`) REFERENCES `customer_info` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COMMENT='주문정보';

SHOW CREATE TABLE `order_info`;

CREATE TABLE `order_product` (
  `order_no` int(11) NOT NULL AUTO_INCREMENT COMMENT '주문번호',
  `product_name` varchar(100) NOT NULL COMMENT '제품명',
  `sale_volume` int(11) NOT NULL COMMENT '판매량',
  PRIMARY KEY (`order_no`,`product_name`),
  KEY `fk_product_name` (`product_name`),
  CONSTRAINT `order_product_ibfk_1` FOREIGN KEY (`product_name`) REFERENCES `bakery_catalog` (`product_name`),
  CONSTRAINT `order_product_ibfk_2` FOREIGN KEY (`order_no`) REFERENCES `order_info` (`order_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='주문_제품';

SHOW CREATE TABLE order_product;

 
