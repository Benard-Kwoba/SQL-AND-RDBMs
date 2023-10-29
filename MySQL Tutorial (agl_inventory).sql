/*
''''''''''''''''''''''''''''''''''''''''''''''MYSQL TUTORIAL BY BENAYAHU''''''''''''''''''''''''''''''''''''''''''''''''''''''
Installation and Set-up
         - Visit the official MySQL website (https://www.mysql.com/downloads/) and download the MySQL Community Server.
         - Run the downloaded MySQL installer. Follow the installation wizard's instructions
         - During the installation, you will be prompted to configure the MySQL server. Set the root password
         - Ensure you have installed MySQL Server, MySQL Shell and MySQL Workbench
         - In the Workbench, set up a new connection to a MySQL server, you can name/rename it, default name is Local Instance
Convention and recommended practice:
         - Upper case is preferred for MySQL keywords, clauses and functions
         - Use semicolon at the end of each SQL statement.
         - Use backticks(``) with identifiers like table names
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''*/

-- __________________________________________DATABASE CREATION__________________________________________________________________
DROP DATABASE IF EXISTS `agl_inventory`;  -- the entire database will be deleted it if already exists
CREATE DATABASE `agl_inventory`;  -- this will also create a schema name 'agl_inventory' by default in mysql	
USE `agl_inventory`;  -- USE: directs the engine to switch to the just created 'agl_inventory' db(run this part first)
	
-- ______________________________________TABLE `products` CREATION_______________________________________________________________
-- ....................1. TABLE SCHEMA/TABLE DEFINITION...........................
CREATE TABLE `products` (	
  `product_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,	-- auto_increment field is the primary key
  `product_name` VARCHAR(50) NOT NULL,	-- VARCHAR is a variable-length non-Unicode character data type, see CHAR
  `product_code` INT UNSIGNED NOT NULL, -- UNSIGNED: means not negative, ZEROFILL is deprecated
  `product_bpc` INT NOT NULL,	-- you can also set the size of the integer e.g INT(6) for 6-digits integer
  /*
  Adding constraints:
   - restrict the product_code to a range between 0 and 999999, inclusive.
   - restrict values inserted into the product_bpc column to be one of the specified values (1, 12, 24, 25, or 48).
   - product_code must be unique
  */
  CONSTRAINT `Check_code_length` CHECK (`product_code` >= 0 AND `product_code` < 1000000),	
  CONSTRAINT `Check_bpc` CHECK (`product_bpc` IN (1, 12, 24, 25, 48)),	
  UNIQUE (`product_code`))	
  -- You can set primary key here.eg. PRIMARY KEY (`product_id`)- We already set primary key above, it can only be 1 in a table

-- ........................2. TABLE ENGINE SETUP...................................
/*
  - We use the default Storage Engine known as InnoDB, for the table.
     InnoDB offers ACID (Atomicity, Consistency, Isolation, Durability) compliance for transactions
  - We set auto_increment initial value to 1 i.e first row will have value of 1
  - We define default charset and collation:
                CHARSET utf8mb4 - supports wide range of characters including emojis
                COLLATE utf8mb4_0900_ai_ci - is accent and case insensitive
*/
ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;	
-- ...........................3. TABLE VALUES......................................
/*
   - Ensure that the values being inserted do not violate the primary key constraint e.g NOT NULL if not there will be an error
   - The order of the values must be the same order as the columns in the table
*/
INSERT INTO `products` (`product_name`, `product_code`, `product_bpc`) 	
VALUES 	
	('Guinness Kubwa 500ml RET Local', 696894, 25),
	('Balozi 500ml RET Local', 681232, 25),
	('Whitecap 500ml Can Local', 672419, 24),
	('Tusker 500ml RET Local', 730510, 25),
	('Senator Keg DARK 50L', 688295, 1);

-- _____________________________________________WORKING ON THE TABLE `products`___________________________________________________
-- 1. Insert new record: 'Whitecap 500ml RET Local' code 762947 bpc 25, and return the updated table
USE `agl_inventory`;  -- run this first to switch the engine to the agl_inventory db
INSERT INTO `products` (`product_name`, `product_code`, `product_bpc`) 	
VALUES 	
	('Whitecap Kubwa 500ml RET Local', 762947, 25);

USE `agl_inventory`;
SELECT * FROM `products`;  -- * returns the whole table
