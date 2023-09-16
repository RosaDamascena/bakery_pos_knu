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


-- 테이블명세서

제빵카탈로그 (제품명, 제품가격)
mysql> DESCRIBE bakery_catalog;
+---------------+--------------+------+-----+---------+-------+
| Field         | Type         | Null | Key | Default | Extra |
+---------------+--------------+------+-----+---------+-------+
| product_name  | varchar(100) | NO   | PRI | NULL    |       |
| product_price | int(11)      | NO   |     | 0       |       |
+---------------+--------------+------+-----+---------+-------+
2 rows in set (0.01 sec)

브랜치재고 (브랜치이름, 제품명, 재고수량)
mysql> DESCRIBE branch_stock;
+--------------+--------------+------+-----+---------+-------+
| Field        | Type         | Null | Key | Default | Extra |
+--------------+--------------+------+-----+---------+-------+
| branch_name  | varchar(100) | NO   | PRI | NULL    |       |
| product_name | varchar(100) | NO   | PRI | NULL    |       |
| stock_volume | int(11)      | NO   |     | 0       |       |
+--------------+--------------+------+-----+---------+-------+
3 rows in set (0.01 sec)

주문 (*주문번호, 브랜치이름, 매출액, 판매일시, 고객아이디, 결제여부)
mysql> DESCRIBE order_info;
+-----------------+---------------+------+-----+-------------------+----------------+
| Field           | Type          | Null | Key | Default           | Extra          |
+-----------------+---------------+------+-----+-------------------+----------------+
| order_no        | int(11)       | NO   | PRI | NULL              | auto_increment |
| branch_name     | varchar(100)  | NO   |     | NULL              |                |
| sale_price      | int(11)       | NO   |     | NULL              |                |
| sale_datetime   | datetime      | NO   |     | CURRENT_TIMESTAMP |                |
| customer_id     | int(11)       | NO   |     | NULL              |                |
| settlement_flag | varchar(100)  | NO   |     | NULL              |                |
+-----------------+---------------+------+-----+-------------------+----------------+
6 rows in set (0.00 sec)

주문_제품 (*주문번호, *제품명, 판매량)
mysql> DESCRIBE order_product;
+--------------+--------------+------+-----+---------+----------------+
| Field        | Type         | Null | Key | Default | Extra          |
+--------------+--------------+------+-----+---------+----------------+
| order_no     | int(11)      | NO   | PRI | NULL    | auto_increment |
| product_name | varchar(100) | NO   | PRI | NULL    |                |
| sale_volume  | int(11)      | NO   |     | NULL    |                |
+--------------+--------------+------+-----+---------+----------------+
3 rows in set (0.01 sec)

고객 (고객번호, 고객이름)
mysql> DESCRIBE customer_info;
+---------------+--------------+------+-----+---------+----------------+
| Field         | Type         | Null | Key | Default | Extra          |
+---------------+--------------+------+-----+---------+----------------+
| customer_id   | int(11)      | NO   | PRI | NULL    | auto_increment |
| customer_name | varchar(100) | NO   |     | NULL    |                |
+---------------+--------------+------+-----+---------+----------------+
2 rows in set (0.01 sec)

-- 제빵카탈로그 데이터 입력 예제

INSERT INTO bakery_catalog (product_name, product_price) VALUES ('단팥빵',1000);
INSERT INTO bakery_catalog (product_name, product_price) VALUES ('크림빵',1000);
INSERT INTO bakery_catalog (product_name, product_price) VALUES ('피자빵',2000);

-- 고객정보 입력 예제

INSERT INTO customer_info (customer_name) VALUES ('김손님');

-- 생산 액티비티 
-- 빵 생산재고 입력 
--> 
INSERT INTO branch_stock (branch_name, product_name, stock_volume) VALUES ('서울지점', '단팥빵', 10) ON DUPLICATE KEY UPDATE stock_volume= stock_volume + VALUES(stock_volume);
INSERT INTO branch_stock (branch_name, product_name, stock_volume) VALUES ('서울지점', '크림빵', 10) ON DUPLICATE KEY UPDATE stock_volume= stock_volume + VALUES(stock_volume);
INSERT INTO branch_stock (branch_name, product_name, stock_volume) VALUES ('서울지점', '피자빵', 10) ON DUPLICATE KEY UPDATE stock_volume= stock_volume + VALUES(stock_volume);

INSERT INTO branch_stock (branch_name, product_name, stock_volume) VALUES ('대전지점', '단팥빵', 5) ON DUPLICATE KEY UPDATE stock_volume= stock_volume + VALUES(stock_volume);
INSERT INTO branch_stock (branch_name, product_name, stock_volume) VALUES ('대전지점', '크림빵', 20) ON DUPLICATE KEY UPDATE stock_volume= stock_volume + VALUES(stock_volume);
INSERT INTO branch_stock (branch_name, product_name, stock_volume) VALUES ('대전지점', '피자빵', 30) ON DUPLICATE KEY UPDATE stock_volume= stock_volume + VALUES(stock_volume);

SELECT * FROM branch_stock;


--- 주문받기(트랜잭션이 필요, 재고를 제거하는 과정 필요, 서울지점에서 단팥빵 20개, 크림빵 20개 살 예정 )
================================================================================================
START TRANSACTION;

-- 먼저 재고가 있나 확인, SHARE 잠금을 통해 확인 예정.

SELECT branch_name, product_name, stock_volume
FROM branch_stock
WHERE branch_name = '서울지점'
  AND product_name IN ('단팥빵','크림빵') LOCK IN SHARE MODE;

-- 여기서 stock_voume이 구매하려는 것보다 적은 경우, 롤백, 있다면 계속 진행

UPDATE branch_stock SET stock_volume = stock_volume - 20
WHERE branch_name = '서울지점'
  AND product_name = '단팥빵';

UPDATE branch_stock SET stock_volume = stock_volume - 20
WHERE branch_name = '서울지점'
  AND product_name = '크림빵';

-- 주문정보 입력을 위한 고객 아이디를 이용한 입력, 1번 손님이 주문하셨음, 결제전
INSERT INTO order_info(branch_name, sale_price, customer_id, settlement_flag) VALUES ('서울지점', (1000*20 + 1000* 20), 1, 'N');

-- 채번번호를 찾기위한 명령 
SELECT LAST_INSERT_ID(); 

SELECT * FROM order_info;

-- 해당 주문번호를 이용해 order_product 입력

INSERT INTO order_product (order_no, product_name, sale_volume) VALUES(3, '단팥빵',20), (3, '크림빵',20); 

SELECT * FROM order_info WHERE order_no = LAST_INSERT_ID();

SELECT * FROM order_product WHERE order_no = 3;

-- 입력완료후 트랜잭션 커밋

COMMIT;

-- 테이블 초기화
TRUNCATE TABLE order_product;
DELETE FROM order_info where order_no < 10000;
ALTER TABLE order_info AUTO_INCREMENT=1;
TRUNCATE TABLE branch_stock;


================================================================================================

--- 주문받기(트랜잭션이 필요, 재고를 제거하는 과정 필요, 대전지점에서 단팥빵 5개, 피자빵 20개 살 예정 )
================================================================================================
START TRANSACTION;

-- 먼저 재고가 있나 확인, SHARE 잠금을 통해 확인 예정.

SELECT branch_name, product_name, stock_volume
FROM branch_stock
WHERE branch_name = '대전지점'
  AND product_name IN ('단팥빵','피자빵') LOCK IN SHARE MODE;

-- 여기서 stock_voume이 구매하려는 것보다 적은 경우, 롤백, 있다면 계속 진행

UPDATE branch_stock SET stock_volume = stock_volume - 5
WHERE branch_name = '대전지점'
  AND product_name = '단팥빵';

UPDATE branch_stock SET stock_volume = stock_volume - 20
WHERE branch_name = '대전지점'
  AND product_name = '피자빵';

-- 주문정보 입력을 위한 고객 아이디를 이용한 입력, 1번 손님이 주문하셨음, 결제전
INSERT INTO order_info(branch_name, sale_price, customer_id, settlement_flag) VALUES ('대전지점', (1000*5 + 2000* 20), 1, 'N');

-- 채번번호를 찾기위한 명령 
SELECT LAST_INSERT_ID(); 

-- 해당 주문번호를 이용해 order_product 입력

INSERT INTO order_product (order_no, product_name, sale_volume) VALUES(2, '단팥빵',5), (2, '피자빵',20); 

-- 입력완료후 트랜잭션 커밋

COMMIT;

================================================================================================


-- 판매결제 
================================================================================================
-- 결제완료후, 주문번호를 기준으로 결제시간과 결제여부 업데이트
START TRANSACTION;

UPDATE order_info 
SET settlement_flag='Y', settlement_datetime=NOW()
WHERE order_no = 3;


UPDATE order_info 
SET settlement_flag='Y', settlement_datetime=NOW()
WHERE order_no = 2;

SELECT * FROM order_info WHERE order_no = 3;
SELECT * FROM order_info WHERE order_no = 2;

COMMIT;


================================================================================================


마감분석

================================================================================================
-- 12월달의 결제완료된 총매출, 결제완료된 매출, 미결제매출 구하기 

SELECT SUM(sale_price) as '총매출', 
  SUM(CASE settlement_flag WHEN 'Y' THEN sale_price ELSE 0 END) AS '결제완료된 매출',
  SUM(CASE settlement_flag WHEN 'N' THEN sale_price ELSE 0 END) AS '미결제매출'
FROM order_info
WHERE MONTH(sale_datetime)=12;

-- 12월달의 지점별 매출액 보기.

SELECT branch_name as '지점명',
SUM(sale_price) as '총매출'
FROM order_info
WHERE MONTH(sale_datetime)=12
GROUP BY branch_name ;

-- 12월달의 제품별 매출액 보기 
SELECT bc.product_name as '제품',  
  SUM(op.sale_volume) AS '매출수량', 
  MAX(bc.product_price) AS '매출단가(현재기준)', 
  SUM(op.sale_volume * bc.product_price) AS  '제품별 매출액(현재가격기준)'
FROM order_info oi  INNER JOIN
order_product op 
ON oi.order_no  = op.order_no LEFT OUTER JOIN 
bakery_catalog bc 
ON op.product_name = bc.product_name 
WHERE MONTH(sale_datetime)=12
GROUP BY bc.product_name ;
================================================================================================