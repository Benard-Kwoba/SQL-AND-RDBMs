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
         - Use backticks(``) with identifiers like table names, reserved keywords e.g order and special characters or symbols
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''*/

-- __________________________________________DATABASE CREATION__________________________________________________________________
DROP DATABASE IF EXISTS `agl_inventory`;  -- the entire database will be deleted if it already exists
CREATE DATABASE `agl_inventory`;  -- this will also create a schema name 'agl_inventory' by default in mysql	
USE `agl_inventory`;  -- USE: directs the engine to switch to the just created 'agl_inventory' db(always run this part first)
	
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
                Note: COLLATE utf8mb4_bin is case insensitive
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
	('Whitecap 500ml Can LOCAL', 672419, 24),
	('Tusker 500ml RET Local', 730510, 25),
	('Senator Keg DARK 50L', 688295, 1);

-- _____________________________________________WORKING ON THE TABLE `products`___________________________________________________
-- i. Insert new record: 'Whitecap 500ml RET Local' code 762947 bpc 25, and return the updated table
USE `agl_inventory`;  -- run this first to switch the engine to the agl_inventory db
INSERT INTO `products` (`product_name`, `product_code`, `product_bpc`) 	
VALUES 	
	('Whitecap Kubwa 500ml RET Local', 762947, 25);

USE `agl_inventory`;
SELECT * FROM `products`;  -- * returns the whole table
-- ii. Retrieve all products where product_name ends with 'Local'(perform a case-sensitive search)
USE `agl_inventory`;
SELECT `product_name` FROM `products`
WHERE `product_name` LIKE "%Local" COLLATE utf8mb4_bin;


-- ___________________________________________CREATING STORED PROCEDURE_________________________________________
/* We will often use SELECT * FROM products. We can set it as a stored procedure*/
DELIMITER //

CREATE PROCEDURE GetAllProducts()  -- creates a stored procedure named GetAllProducts.
BEGIN
    SELECT * FROM products;  -- is the query you want to execute.
END //

DELIMITER ;

-- After creating the stored procedure, you can call it like this:
CALL GetAllProducts(); -- or use CALL `agl_inventory`.`GetAllProducts`();


-- _______________________________________ADDING TRIGGERS______________________________________________________
/* We create a product_audit table for audit log whenever a new product is inserted */
USE `agl_inventory`; 
CREATE TABLE `products_audit` (
    `product_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `action` VARCHAR(255),
    `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

/* We need to update the products table by inserting two more columns for 'action' and 'timestamp'*/
ALTER TABLE `products`
ADD COLUMN `action` VARCHAR(255),
ADD COLUMN `timestamp` TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
-- Alter the 'action' column to set a default value of 'last updated on' for new entries
ALTER TABLE `products`
MODIFY COLUMN `action` VARCHAR(255) DEFAULT 'last updated on';
-- Check the Default Value:
SHOW CREATE TABLE `products`;
-- Delete rows where product_name is NULL(these were created before action was set to default - 'inserted on')
DELETE FROM `products` WHERE `product_name` IS NULL; --  If you omit the WHERE clause, all records in the table will be deleted!
-- Our products table now has Null values for action column, let's set the value to 'Last updated on'
-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;
-- Run your update statement
UPDATE `products`
SET `action` = 'inserted on'
WHERE `action` IS NULL AND `product_id` IS NOT NULL;
-- Enable safe update mode (recommended after your update)
SET SQL_SAFE_UPDATES = 1;

/* Adding a trigger for every insertion of a new product
Note: DELIMITER keyword is used to write multiple SQL statements and execute them as a single script.
*/
--Set the new delimiter:
DELIMITER // -- run to change the default statement delimiter, which is typically a semicolon (;)
--Run to Write your multi-line trigger:
CREATE TRIGGER `after_product_insert`
AFTER INSERT ON `products`
FOR EACH ROW
BEGIN
    INSERT INTO `products_audit` (`product_id`, `action`, `timestamp`)
    VALUES (NEW.`product_id`, 'inserted', CURRENT_TIMESTAMP);
END;
--Run to end your multi-line statements with the new delimiter:
//
--Run to reset the delimiter back to the default:
DELIMITER ; -- is used to reset the delimiter back to semicolon(;)
-- Try inserting a new product 'Allsopps 500ml RET Local, 716077, it will show in the trigger table as product_id 12
SELECT * FROM `products_audit`;
-- To see more information about the trigger table use: SHOW CREATE TRIGGER `after_product_insert`;

/* We need to add a column product_name in the products_audit table and amend the trigger function to include it
MySQL does not support direct ALTER TRIGGER*/
-- Change the delimiter
-- Drop the existing trigger

-- __________________________AFTER INSERTION TRIGGER TABLE WITH JOINS FOR AUTOMATIC UPDATES_____________________
DROP TRIGGER IF EXISTS `after_product_insert`;

-- Change the delimiter
DELIMITER //

-- Create the new trigger
CREATE TRIGGER `after_product_insert`
AFTER INSERT ON `products`
FOR EACH ROW
BEGIN
    INSERT INTO `products_audit` (`product_id`, `product_name`, `action`, `timestamp`)
    VALUES (NEW.`product_id`, NEW.`product_name`, 'inserted', CURRENT_TIMESTAMP);
END;
//

-- Reset the delimiter
DELIMITER ;

-- ______________________________________________UPDATING TRIGGER TABLE WITH SQL JOIN_________________________
-- Updating product_name for products_audit table from products table
/*Our products_audit table has product_id 12 with no product_name, assign it the product_name for
product_id 12 on the products table*/
UPDATE products_audit AS pa  -- or you can just use: UPDATE products_audit pa instead of using AS alias keyword
JOIN products AS p ON pa.product_id = p.product_id
SET pa.product_name = p.product_name
WHERE pa.product_id = 12;

SELECT * FROM `products_audit`; -- now we have the name Allsopps 500ml RET Local and all other new products


-- _____________________________________________TABLE VIEW WITH SQL JOIN______________________________________________________
/* We need to can create a view that combines information from both the products_audit and products tables to 
make querying more convenient. */
CREATE VIEW products_audit_view AS
SELECT
    pa.product_id,
    pa.product_name AS audit_product_name,
    pa.action AS audit_action,
    pa.timestamp AS audit_timestamp,
    p.product_name,
    p.product_code,
    p.product_bpc,
    p.action AS original_action,
    p.timestamp AS original_timestamp
FROM
    products_audit pa
JOIN
    products p ON pa.product_id = p.product_id;
-- We can as well create a stored procedure for this
DELIMITER //

CREATE PROCEDURE GetAllProductsAuditView()
BEGIN
    SELECT * FROM products_audit_view;
END //

DELIMITER ;
-- We made a mistake, the name of the view procedure should be GetProductsAuditView
-- Drop the incorrectly named stored procedure
DROP PROCEDURE IF EXISTS GetAllProductsAuditView;
-- Create the stored procedure with the correct name
DELIMITER //
CREATE PROCEDURE GetProductsAuditView()
BEGIN
    SELECT * FROM products_audit_view;
END //
DELIMITER ;


-- ____________________________________BEFORE INSERTION TRIGGER(Error Testing)_________________________________________
-- Create a trigger before inserting into the products table
DELIMITER //

CREATE TRIGGER before_products_insert
BEFORE INSERT ON `products`
FOR EACH ROW
BEGIN
    -- Use SIGNAL to raise a warning with a custom message
    SIGNAL SQLSTATE '01000' SET MESSAGE_TEXT = 'Please use 0 for any product_code you don''t know; Comment the action column as ''I don''t know the code''.';
END;
//

DELIMITER ;
-- We created a wrong trigger, delete it
DROP TRIGGER IF EXISTS agl_inventory.before_products_insert;


-- ___________________________________NEW TABLE: recharge_prices demonstrating foreign_keys_________________________




