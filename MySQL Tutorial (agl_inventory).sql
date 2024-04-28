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
Contents:
     - Database Creation
     - Table Creation
     - Sql Indexes
     - Creating Stored Procedures
     - Mysql Triggers
     - Mysql Views And Stored Procedures
     - Mysql Data Import
     - Mysql Data Export
     - Automatically Calculated Rows
     - Foreign Keys And Normalization
     - Mysql Subqueries
     - Preventing Table Record Deletion With Sql Trigger
     - Mysql Regular Expressions
     - Mysql Common Table Expressions (CTE) And Recursive Queries/Recursive CTE
     - Mysql Functions
     - Mysql Operators
     - Mysql Joins
     - Mysql Database Integration With Python
     - Mysql Transactions
     - Sql Language Types
     - Creating Stored Functions In Mysql
     - Mysql Window/Analytic Functions
     - Preventing Sql Injection With Python
     - Mysql Administrative Backend Programming
     - Mysql Through Command-Line Interface(CLI)
     - Monitoring Server Performance
     - Mysql Database Security Management 
     - Mysql Database Remote Access
     - Database Version Control


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''*/

-- __________________________________________ DATABASE CREATION __________________________________________________________________
DROP DATABASE IF EXISTS `agl_inventory`;  -- the entire database will be deleted if it already exists
CREATE DATABASE `agl_inventory`;  -- this will also create a schema name 'agl_inventory' by default in mysql	
USE `agl_inventory`;  -- USE: directs the engine to switch to the just created 'agl_inventory' db(always run this part first)
	
-- ______________________________________TABLE `products` CREATION_______________________________________________________________
-- ....................1. TABLE SCHEMA/TABLE DEFINITION...........................
CREATE TABLE `products` (	
  `product_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,	-- auto_increment field is the primary key, product_id is a surrogate key
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

-- _____________________________________________ WORKING ON THE TABLE `products`___________________________________________________
-- Insert new record: 'Whitecap 500ml RET Local' code 762947 bpc 25, and return the updated table
USE `agl_inventory`;  -- run this first to switch the engine to the agl_inventory db
INSERT INTO `products` (`product_name`, `product_code`, `product_bpc`) 	
VALUES 	
	('Whitecap Kubwa 500ml RET Local', 762947, 25);

USE `agl_inventory`;
SELECT * FROM `products`;  -- * returns the whole table
-- Insert data from a csv file('agl_products.csv') - the csv has values in the first row to the last in the format above
USE `agl_inventory`;
LOAD DATA INFILE 'C:\Users\user\Desktop\DATA++\CLASS NOTES\Program files\agl_products.csv'  -- change accordingly
INTO TABLE `products`
FIELDS TERMINATED BY ','  -- fields(`product_name`, `product_code`, `product_bpc`) are seperated by a comma
LINES TERMINATED BY '\n'  -- lines are seperated by newline character '\n'
IGNORE 0 ROWS;  -- ignore zero rows(you can skip this part), use IGNORE 1 if the csv has first row being headers
/*
Error Code: 1290 - indicates that the MySQL server has been configured with the --secure-file-priv option,
which restricts the location from which you can read or write files.
Solution - Right-click table -> Table Data Import Wizard -> Select File(csv) -> Configure Import Settings(e.g encoding utf-8) to import data OR
         - find the directory that you are allowed to save to using: mysql> SHOW VARIABLES LIKE "secure_file_priv" and place your file there
*/
USE `agl_inventory`;
CALL `agl_inventory`.`GetAllProducts`();  -- Our products have been updated

-- Retrieve all products where product_name ends with 'Local'(perform a case-sensitive search)
USE `agl_inventory`;
SELECT `product_name` FROM `products`
WHERE `product_name` LIKE "%Local" COLLATE utf8mb4_bin;
-- Retrieve all records where the action is neither 'last updated on' nor 'inserted on'
SELECT * FROM `products` 
WHERE `action` NOT LIKE 'last updated on' AND `action` NOT LIKE 'inserted on';
-- Retrieve the total number of records in the products table
SELECT COUNT(`product_name`) FROM `products`; -- COUNT(*) will include rows with NULL values in any column, COUNT(column) - count non-null values
-- use the EXPLAIN statement to see how MySQL executes a query 
EXPLAIN SELECT * FROM products WHERE product_name = 'Whitecap crisp 330ml RET LOCAL';
-- Display the structure of a table:
DESCRIBE `products`;

-- ____________________________________________________ SQL INDEXES _______________________________________________________________
/*
Indexes are helpful for improving query performance, especially for columns frequently used in WHERE clauses or JOIN conditions.
Indexes in a database are crucial for optimizing query performance and accelerating data retrieval. However, it's important to 
note that while indexes provide performance benefits for read operations, they can impact the performance of 
write operations (INSERT, UPDATE, DELETE). Each modification to the indexed columns requires updating the index, 
so the trade-off between read and write performance should be carefully considered.
*/
-- Creating an index on the 'product_code' column in the 'products' table
CREATE INDEX idx_product_code ON products(product_code); -- See UNIQUE INDEX
-- Query using the index
SELECT * FROM products WHERE product_code = '672404';
-- Query using the index for sorting
SELECT * FROM products ORDER BY product_code;
-- See the index
SHOW INDEX FROM products WHERE Key_name = 'idx_product_code';
-- drop the index
ALTER TABLE `products`
DROP INDEX idx_product_code;

-- ___________________________________________ CREATING STORED PROCEDURE___________________________________________________________
/* We will often use SELECT * FROM products. We can set it as a stored procedure*/
DELIMITER // -- used to write multiple statement and execute them as one script

CREATE PROCEDURE GetAllProducts()  -- creates a stored procedure named GetAllProducts.
BEGIN
    SELECT * FROM products;  -- is the query you want to execute.
END // --  signifies the end of the procedure body.

DELIMITER ;

-- After creating the stored procedure, you can call it like this:
CALL GetAllProducts(); -- or use CALL `agl_inventory`.`GetAllProducts`();

-- Creating stored procedure for a selection that expects an argument: Recursive CTE. See more in CTE
CREATE PROCEDURE GetBOM(IN starting_product_code INT)
BEGIN
    WITH RECURSIVE ProductHierarchy AS (
        SELECT 
            `complete code` AS product_code,
            `bottle component code` AS bottle_code,
            `shell component code` AS shell_code
        FROM `products_bom`
        WHERE `complete code` = starting_product_code

        UNION ALL

        SELECT 
            pb.`complete code` AS product_code,
            pb.`bottle component code` AS bottle_code,
            pb.`shell component code` AS shell_code
        FROM `products_bom` pb
        INNER JOIN ProductHierarchy ph ON pb.`complete code` = ph.bottle_code
    )
    -- Retrieve the results from the temporary table
    SELECT * FROM ProductHierarchy;

END //

DELIMITER ;
CALL `agl_inventory`.GetBOM(771134);

-- _________________________________________________________ MYSQL TRIGGERS ______________________________________________________
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

-- ______AFTER INSERTION TRIGGER TABLE WITH JOINS FOR AUTOMATIC UPDATES____
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

-- ____________UPDATING TRIGGER TABLE WITH SQL JOIN______________________
-- Updating product_name for products_audit table from products table
/*Our products_audit table has product_id 12 with no product_name, assign it the product_name for
product_id 12 on the products table*/
UPDATE products_audit AS pa  -- or you can just use: UPDATE products_audit pa instead of using AS alias keyword
JOIN products AS p ON pa.product_id = p.product_id
SET pa.product_name = p.product_name
WHERE pa.product_id = 12;

SELECT * FROM `products_audit`; -- now we have the name Allsopps 500ml RET Local and all other new products


-- _____________________________________________ MYSQL VIEWS AND STORED PROCEDURES __________________________________________
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


-- ____________________________________ BEFORE INSERTION TRIGGER(Error Testing) _________________________________________
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


-- ________________________________________________________________ MYSQL DATA IMPORT ________________________________________________________
USE `agl_inventory`;

-- Drop the table if it exists (run this part first)
DROP TABLE IF EXISTS `recharge_prices`;

-- Create the table
CREATE TABLE `recharge_prices` (
    `product_id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `product_name` VARCHAR(50) NOT NULL,
    `product_code` INT UNSIGNED NOT NULL,
    `product_bpc` INT NOT NULL,
    `recharge_per_case` DECIMAL(12, 4) DEFAULT 0.0000,
    -- Up to 12 digits with 4 decimal places; defaults to 0 with 4 decimal places
    CONSTRAINT `Check_recharge_bpc` CHECK(`product_bpc` IN (1, 12, 24, 25, 48)),
    UNIQUE(`product_code`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Add data into the created table recharge_prices; MANUAL INSERTION
INSERT INTO `recharge_prices` (`product_name`, `product_code`, `product_bpc`, `recharge_per_case`)
VALUES (
'Guinness Kubwa 500ml RET Local', 696894, 25, 4117.33960348504, 
'Balozi 500ml RET Local', 681232, 25, 3707.80964313653,
'Whitecap 500ml Can Local', 672419, 24, 4086.72685933414,
'Tusker 500ml RET Local', 730510, 25, 3707.80964313653,
'Senator Keg DARK 50L', 688295, 1, 4631.02836042214
);

-- Add data into the created table recharge_prices; IMPORT FROM CSV FILE. Update all missing recharge_per_case prices from csv file
/*We will use "agl_recharge_prices_percase.csv" ensure you preprocess it, missing values impute with 0.0000
 - Sample Data from our csv file
    SKU,Description,BPC,Recharge Price / Case
    704768,Tusker Lite 330ml RET 25X01 EXP,25,2942.21
    695544,Tusker In Bottl 500ml RET 25X01 UBL,25,1927.31
    616854,Tusker In Bottl 355ml NRB 24X01,24,2972.19
 - We must first clean this data
 the CSV file uses double quotes around some columns, and the numeric columns have commas as thousand separators.
 - We will then create a temporary table that we will use to load data into our recharge_price table
*/
-- Create the temp_recharge_prices table if it doesn't exist
CREATE TABLE IF NOT EXISTS temp_recharge_prices (
    SKU INT, -- or SKU BIGINT to accomodate bigger SKU codes like 3105443756
    Description VARCHAR(255),
    BPC INT,
    `Recharge Price / Case` DECIMAL(10, 4),
    ExtraColumn VARCHAR(255), -- Add an extra column to capture any additional data
    PRIMARY KEY (SKU)  -- must be unique, if not remove the duplicated sku code
);
/* We have characters like & in our product names(Manyatta C P&M  300ml), ensure your csv file is encoded in utf-8
    To convert your ANSI encoded CSV file to UTF-8(allows "26.24" to be read as 26.24) you have to open your CSV file in notepad 
    and then click the save as option. 
    In the popped-up window, you can see the encoding type option beside the save button. Change it to your desired format and save it.
 We also have the product 3105443756 Amber 355ml Bottle Exp, this is a bigger size than integer.
*/
    -- Ammend the SKU data type to BIGINT To accomodate the code 3105443756
ALTER TABLE temp_recharge_prices
MODIFY COLUMN SKU BIGINT;
    -- Load data from CSV into temp_recharge_prices(LOAD DATA INFILE(file path) INTO TABLE(table name))
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/agl_recharge_prices_percase.csv' --  main statement used to load data from file
INTO TABLE temp_recharge_prices
CHARACTER SET utf8mb4  -- Specify the character set to handle characters like & in Manyatta C P&M  300ml
FIELDS TERMINATED BY ',' -- Specifies that the fields in the CSV file are separated by commas (,)
ENCLOSED BY '"' -- If fields in the CSV file are enclosed within double quotation marks, e.g "Manyatta", since we encoded to utf-8, skip
LINES TERMINATED BY '\r\n'  -- \r for carriage return character, and \n for line feed character. Together, \r\n is used to indicate a new line. 
-- This is commonly used in CSV files on Windows platforms. '\n' is used in Unix/Linux
IGNORE 1 ROWS -- Ignore the first row or line since it has the headers; SKU,Description,BPC,Recharge Price / Case
(SKU, Description, BPC, @RechargePrice, @ExtraColumn) -- Use @RechargePrice variable, just a placeholder to capture data in Recharge Price / Case column
SET 
    `Recharge Price / Case` = 
        CASE 
            WHEN TRIM(@RechargePrice) REGEXP '^[0-9]+(\.[0-9]+)?$' --  ensures that the trimmed value represents a numeric format, ints and floats
                THEN REPLACE(TRIM(@RechargePrice), ',', '') -- replaces any commas as thousands separators, with no space. e.g 2,225.54 to 2225.54
            ELSE 0.0000 -- Default value for non-numeric entries
        END; -- marks the end of the CASE statement
    -- check loaded date by without recharge_prices
    SELECT * FROM `temp_recharge_prices` WHERE `Recharge Price / Case` = 0.0000;

-- update missing recharge_per_case in the recharge_prices table with the temp_recharge_prices data
SET SQL_SAFE_UPDATES = 0;
UPDATE recharge_prices rp
JOIN temp_recharge_prices trp ON rp.product_code = trp.SKU  --  only matching records between the two tables should be updated
SET rp.`recharge_per_case` = trp.`Recharge Price / Case`
WHERE rp.`recharge_per_case` IS NULL OR rp.`recharge_per_case` = 0.0000;
SET SQL_SAFE_UPDATES = 1;
-- IMPORT FROM EXCEL FILE
/* We need to create another table "kbl_sales" from the with 'KBL DECEMBER 2023 SALES.xlsx' data
For Excel files (.xls or .xlsx), you usually need to convert them to a supported text-based format like CSV before using LOAD DATA INFILE
Sample data in KBL DECEMBER 2023 SALES.csv:
    Posting Date,Posting Time,User Name,Sales Deliveries,Distributor Name,Truck Number,Material,Material Description,quantity cases,Amount
    31.12.2023,9:41:59,ADEKCOLL,1053889873,DAKANEY KEROW COMMUNICATION LIMITED,KAR 539P AGI,603482,Senator Keg Bee 50L   KEG,216,369631.21
    31.12.2023,9:29:25,ADEKCOLL,1053891036,Mt.Kenya Karue Beverages Ltd.,KDD 087Z ZC2370 DHL,603482,Senator Keg Bee 50L   KEG,438,749529.95
*/
CREATE TABLE kbl_sales (
    `Posting Date` DATE,
    `Posting Time` TIME,
    `User Name` VARCHAR(255),
    `Sales Deliveries` INT(10), -- Note Integer display width is deprecated, don't use INT(10)
    `Distributor Name` VARCHAR(255),
    `Truck Number` VARCHAR(255),
    `Material` INT(6),
    `Material Description` VARCHAR(255),
    `quantity cases` INT,
    `Amount` DECIMAL(10, 2)
)
ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;	
 -- We need to change our column 'quantity cases' to 'Quantity Cases'
ALTER TABLE kbl_sales
CHANGE COLUMN `quantity cases` `Quantity Cases`;
/*
some quantity in cases had quotation e.g "1,600" for delivery 1053880656 in our csv, update the columns to replace them to integers
open in excel and uncheck use thousand seperator(,) to convert the columns to general
date formats like '31.12.2023' are deprecated; use standard hyphen(-) convert to YYYY-mm-dd or SET sql_mode = 'ALLOW_INVALID_DATES';
Example
    Posting Date,Posting Time,User Name,Sales Deliveries,Distributor Name,Truck Number,Material,Material Description,quantity cases,Amount
    2023-12-31,9:41:59,ADEKCOLL,1053889873,DAKANEY KEROW COMMUNICATION LIMITED,KAR 539P AGI,603482,Senator Keg Bee 50L   KEG,216,369631.21
 */
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/KBL DECEMBER 2023 SALES.csv'
INTO TABLE kbl_sales
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
-- Check if the data is loaded SELECT * FROM `kbl_sales`;
-- Create table products_bom
CREATE TABLE `products_bom` (
	`complete code` INT DEFAULT NULL,
    `complete code description` VARCHAR(255) DEFAULT NULL,
    `bottle component code` INT DEFAULT NULL,
    `bottle component code description` VARCHAR(255) DEFAULT NULL,
    `shell component code` INT DEFAULT NULL,
    `shell component code description` VARCHAR(255) DEFAULT NULL 
);
DROP TABLE `products_bom`;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/agl_products_bom.csv'
INTO TABLE `products_bom`
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(@complete_code, @complete_code_desc, @bottle_code, @bottle_code_desc, @shell_code, @shell_code_desc)
SET
    `complete code` = NULLIF(TRIM(@complete_code), ''),
    `complete code description` = NULLIF(TRIM(@complete_code_desc), ''),
    `bottle component code` = NULLIF(TRIM(@bottle_code), ''),
    `bottle component code description` = NULLIF(TRIM(@bottle_code_desc), ''),
    `shell component code` = NULLIF(TRIM(@shell_code), ''),
    `shell component code description` = NULLIF(TRIM(@shell_code_desc), '');
SELECT * FROM `products_bom`;

-- ____________________________________________________________ MYSQL DATA EXPORT ___________________________________________________________
-- We need a csv file 'agl_export_products.csv' with export products exported from the products table, replace the file if exists
/*
Ensure that the MySQL user has the FILE privilege, and the MySQL server has write permissions to the specified directory.*/
SET SQL_SAFE_UPDATES = 0;
SELECT `product_code` AS `CODE`, `product_name` AS `DESCRIPTION`
FROM `products`
WHERE `product_name` LIKE "%EXPORT"
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/agl_export_products.csv' -- Use single quotes around the file path
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' -- if you may have fields like "001","Product One"
LINES TERMINATED BY '\n' -- Use \n for line endings
;
SET SQL_SAFE_UPDATES = 1;
-- Our csv file does not have header columns CODE and DESCRIPTION, Update.
SELECT 'CODE', 'DESCRIPTION'  -- This is a static row containing the headers 'CODE' and 'DESCRIPTION'. 
-- It doesn't come from any table; it's just a way to provide column headers for the export
UNION ALL  -- UNION ALL is used to combine the result sets of the two SELECT statements.  
-- allows duplicate rows to be included in the result set. If you want to remove duplicates, you would use UNION instead of UNION ALL.
-- number of columns in the result sets being combined must be equal.
SELECT `product_code` AS `CODE`, `product_name` AS `DESCRIPTION`
FROM `products`
WHERE `product_name` LIKE "%EXPORT"
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/agl_export_products.csv' -- Use single quotes around the file path
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' -- if you may have fields like "001","Product One"
LINES TERMINATED BY '\n' -- Use \n for line endings
;
/* select all defco products from both products and recharge_prices tables, have two columns
for your extract; "DEFCO CODES" and "DEFCO MATERIALS"*/
SELECT `product_code` AS "DEFCO CODES", `product_name` AS "DEFCO MATERIALS"
FROM `products`
WHERE `product_name` LIKE "%DEFCO%"
UNION
SELECT `product_code`, `product_name`
FROM `recharge_prices`
WHERE `product_name` LIKE "%DEFCO%";

-- __________________________________________________________ AUTOMATICALLY CALCULATED ROWS _________________________________________________
-- Add a new column named 'recharge_per_piece' with values equal to recharge_per_case divided by product_bpc
-- ..........Approach 1: Step-wise manipulation: Manual
ALTER TABLE `recharge_prices` -- used to modify the structure of a table
ADD COLUMN `recharge_per_piece` DECIMAL(12, 4); -- you can explicitly set the default here DEFAULT 0.0000
-- Update the values of recharge_per_piece by dividing recharge_per_case by product_bpc
UPDATE `recharge_prices` -- used to modify the data within a table
SET `recharge_per_piece` = `recharge_per_case` / `product_bpc`;
-- We failed to set the default value for the recharge_per_piece table, set it to 0.0000
ALTER TABLE `recharge_prices`
MODIFY COLUMN `recharge_per_piece` DECIMAL(12, 4) DEFAULT 0.0000; --You can remove the DECIMAL(12, 4) part as we are not changing the data type
--......Approach 2: Direct Manipulation: Value is automatically calculated
ALTER TABLE `recharge_prices`
MODIFY COLUMN `recharge_per_piece` DECIMAL(12, 4) GENERATED ALWAYS AS (`recharge_per_case` / `product_bpc`) STORED;

-- __________________________________________________________ FOREIGN KEYS AND NORMALIZATION  ________________________________________________
-- We have created our second table but failed to add a foreign key
ALTER TABLE `recharge_prices`
ADD CONSTRAINT `fk_recharge_prices_product_id`
FOREIGN KEY (`product_id`) REFERENCES `products`(`product_id`) 
ON DELETE CASCADE ON UPDATE CASCADE; -- CASCADE options ensure that changes to the products table propagate to the related rows 
--in the recharge_prices table automatically. Other options: SET NULL, RESTRICT, NO ACTION(default)
/*REFERENTIAL INTEGRITY WITH PRIMARY AND FOREIGN KEYS
Ensuring that entries in tables with foreign keys (e.g., recharge_prices) and primary keys (e.g., products) are aligned appropriately.
Example:
Rows 1-5 in the 'products' table share the same product_id values and corresponding names, matching rows 1-5 in the 'recharge_prices' table.*/
-- Check for this integrity with INNER JOIN/JOIN
SELECT
    p.product_id AS products_product_id,
    p.product_code AS products_product_code,
    rp.product_id AS recharge_prices_product_id,
    rp.product_code AS recharge_prices_product_code
FROM
    products p
INNER JOIN -- or JOIN
    recharge_prices rp ON p.product_id = rp.product_id
WHERE
    p.product_id BETWEEN 1 AND 5;
/* Let us maintain this referential integrity by adding product_name, product_code and product_bpc
rows 6 to the last of products table to our recharge_prices table to complete the recharge_prices remaining data*/
-- Insert rows from products (6 to last) into recharge_prices(INSERT INTO...SELECT construct)
INSERT INTO recharge_prices (product_name, product_code, product_bpc)
SELECT product_name, product_code, product_bpc
FROM products
WHERE product_id > 5;

/*
 __________________ NORMALIZATION: We have worked towards Second Normal Form (2NF): ___
Must be in 1NF: Each table should have a primary key, and no repeating groups or arrays should be present. 

Eliminate partial dependencies: Every non-prime attribute (non-key column) must be fully functionally dependent 
on the entire primary key. In our case, the product_id column in the recharge_prices table depends on the entire 
primary key of the products table.

Levls of NORMALIATION
First Normal Form (1NF):
Eliminate duplicate columns and ensure each table has a primary key.

Second Normal Form (2NF):
Remove partial dependencies by ensuring non-prime attributes depend on the entire primary key.

Third Normal Form (3NF):
Eliminate transitive dependencies, ensuring non-prime attributes are not dependent on other non-prime attributes.

Boyce-Codd Normal Form (BCNF):
Address all non-trivial functional dependencies, ensuring each determinant is a superkey.

Fourth Normal Form (4NF):
Eliminate multi-valued dependencies by organizing data in separate tables.

Fifth Normal Form (5NF):
Address join dependencies, minimizing redundancy by decomposing tables.
*/

-- _________________________________________________________________ MYSQL SUBQUERIES ___________________________________________
/* Consider table 'kbl_sales'. We need to return a column named "Correct Scraping Header". The column combines
Sales Delivery and truck number and haulier abbreviation. Example:
    1053889873 KAR 539P AGI -> 1053889873 KAR 539P AGI 
    1053891036 KDD 087Z ZC2370 DHL -> 1053891036 KDD 087Z DHL*/
SELECT 
    CASE WHEN 
        LENGTH(replaced_truck_number) > 10  -- replaced_truck_number e.g KDD 087Z ZC2370 DHL -> KDD087ZDHL
    THEN
        CONCAT(
            LEFT(`Sales Deliveries`, 10),
            ' ',
            SUBSTRING(replaced_truck_number, 1, 3),
            ' ',
            SUBSTRING(replaced_truck_number, 4, 4),
            ' ',
            SUBSTRING(replaced_truck_number, 14, 3)
        ) 
    ELSE
        CONCAT(                                                     -- CONCAT: Used to join strings, See CONCAT_WS.
            LEFT(`Sales Deliveries`, 10),
            ' ',
            SUBSTRING(replaced_truck_number, 1, 3),                 -- SUBSTRING; Similar to MID function
            ' ',
            SUBSTRING(replaced_truck_number, 4, 4),
            ' ',
            SUBSTRING(replaced_truck_number, 8, 3)
        )
    END AS "Correct Scraping Header"-- End of the logic block
FROM (
	-- the subquery returns a result set with two columns derived from the kbl_sales table: replaced_truck_number and Sales Deliveries
    -- the two are needed in our field list above. replaced_truck_number avoids repeting REPLACE(TRIM(`Truck Number`) in the field list
    SELECT REPLACE(TRIM(`Truck Number`), " ", "") AS replaced_truck_number, `Sales Deliveries`
    FROM `kbl_sales`
) AS subquery;
-- Return all Agility trucks that loaded products
SELECT DISTINCT replaced_truck_number AS `AGILITY TRUCKS`  -- we need unique truck numbers
-- replaced_truck_number in the inner SELECT statement should be directly accessible in the outer query's SELECT statement.
FROM (
	-- the subquery returns a result set with two columns derived from the kbl_sales table: replaced_truck_number and Sales Deliveries
    -- the two are needed in our field list above
    SELECT REPLACE(TRIM(`Truck Number`), " ", "") AS replaced_truck_number, `Sales Deliveries`
    FROM `kbl_sales`
) AS subquery  -- Every derived table MUST have an alias, here we name the alias "subquery"
WHERE replaced_truck_number LIKE "%AGI";
-- Find the product names and product codes in recharge_prices table that were not sold in December 2023 kbl_sales
SELECT `product_code`, `product_name`
FROM `recharge_prices`
WHERE `product_code` NOT IN (SELECT `Material` FROM `kbl_sales`);
-- Find the distributor name, sales delivery and truck number that made the biggest sale
SELECT `Distributor Name`, `Sales Deliveries`, `Truck Number`  
FROM `kbl_sales`
WHERE (`Sales Deliveries`) = (SELECT `Sales Deliveries` FROM `kbl_sales` ORDER BY `Amount` DESC LIMIT 1);
-- Find the truck with the maximum number of counts/appearances
SELECT `Truck Number`, COUNT(`Truck Number`) AS EntryCount
FROM KBL_SALES
GROUP BY `Truck Number`
HAVING COUNT(`Truck Number`) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(`Truck Number`) AS cnt
        FROM KBL_SALES
        GROUP BY `Truck Number`
    ) AS subquery
);

-- _______________________________________________ PREVENTING TABLE RECORD DELETION WITH SQL TRIGGER _______________________________
/* We want to secure the products table to prevent insertion or deletion of products. Deletion or insertion is only allowed
when the products are unlocked. We will use a trigger*/
-- Add a Column for Lock Status:
ALTER TABLE `products`
ADD COLUMN `is_locked` BOOLEAN DEFAULT false;  -- the is_locked columnn is filled with 0(default) in all rows
-- Lock all the products:
SET SQL_SAFE_UPDATES = 0;
UPDATE `products`
SET `is_locked` = true;  -- our column is now filled with 1 meaning locked, setting to false will unlock
SET SQL_SAFE_UPDATES = 1;
-- check if there is a locked record: SELECT * FROM `products` WHERE `is_locked` = false;
-- Add a trigger to prevent the deletion of a locked product:
DELIMITER //
CREATE TRIGGER before_delete_product
BEFORE DELETE ON products
FOR EACH ROW
BEGIN
    IF OLD.is_locked = true THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete a locked product';
    END IF;
END;
//
DELIMITER ;
-- Try deleting product_code 777694 to see the result
DELETE FROM `products` WHERE `product_code` = 777694; -- Error Code: 1644. Cannot delete a locked product

-- ______________________________________________________________ MYSQL REGULAR EXPRESSIONS ___________________________________________________
SELECT DISTINCT `Distributor Name` FROM `kbl_sales` WHERE `Distributor Name` REGEXP '^ENGIPRO';  -- ^: starts with
-- Find all PPD trucks that begin with plate number KCC
SELECT DISTINCT `Truck Number` FROM `kbl_sales` WHERE `Truck Number` RLIKE/*orREGEXP*/ '^KCC.+PPD$';  -- .:any char except new line; +:one or more, $:end
-- Find all DHL trailers that loaded products. Note: trailers have at least 10chars in truck number after 'K' and before the end 'DHL'
SELECT DISTINCT `Truck Number` FROM `kbl_sales` WHERE `Truck Number`  RLIKE '^K.{10, }DHL$';
-- EMAIL VALIDITY TEST
/*update the kbl_sales table by adding another column("User Email") between the columns 'User Name' and 'Sales Deliveries'
with data from "kbl_ncd_data_clerks.csv. We will use this column to test for regular expressions"
Sample data:
User Name,User Email
ADEKCOLL,Collins.Adek@eabl.com
*/
-- Create a temporary table 'kbl_sales_user_names'
CREATE TABLE `temp_kbl_sales_user_names` (
	`User Name` VARCHAR(255) NOT NULL,
    `User Email` VARCHAR(255) NOT NULL,
    UNIQUE(`User Name`)
);
-- Import data from "kbl_ncd_data_clerks.csv" into the `temp_kbl_sales_user_names` table
SET SQL_SAFE_UPDATES = 0;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/kbl_ncd_data_clerks.csv'  -- change accordingly
INTO TABLE `temp_kbl_sales_user_names`
FIELDS TERMINATED BY ','  
LINES TERMINATED BY '\r\n'  
IGNORE 1 ROWS; 
SET SQL_SAFE_UPDATES = 1;
-- Check if the data has been imported - SELECT * FROM `temp_kbl_sales_user_names`;
-- Insert the User Email data into the kbl_sales table between the columns 'User Name' and 'Sales Deliveries'
-- Add a column in the kbl_sales table
ALTER TABLE `kbl_sales`
ADD COLUMN `User Email` VARCHAR(255) AFTER `User Name`;
-- update the new column with data from the temporary table
SET SQL_SAFE_UPDATES = 0;
UPDATE `kbl_sales` ks
JOIN `temp_kbl_sales_user_names` tks ON ks.`User Name` = tks.`User Name`
SET ks.`User Email` = tks.`User Email`;
SET SQL_SAFE_UPDATES = 1;
-- Check if the update is correct; SELECT * FROM `kbl_sales` WHERE `User Email` IS NULL;
-- Check if the emails are legal
SELECT
  `User Email` AS `test_emails`,
  CASE
    WHEN `User Email` REGEXP '\\b[^\\W][a-zA-Z0-9_.-]+[\\w$]*(?<!@)@[^\W][a-zA-Z0-9_.-]+[\\w$]*(?<!\\.)\\.[a-zA-Z]+' THEN 'VALID EMAIL'
    ELSE 'INVALID EMAIL'
  END AS `Email Validation` -- Forms a column name 'Email Validation
FROM
  `kbl_sales`;
/*		 EXPLANATION
\b: Asserts a word boundary, ensuring that the match starts at the beginning of a word.
[^\W]: Matches any alphanumeric character (equivalent to [a-zA-Z0-9_]), excluding non-word characters.
[a-zA-Z0-9_.-]+: Matches one or more occurrences of alphanumeric characters, underscores, dots, or hyphens.
[\w$]*: Matches zero or more word characters or the dollar sign.
(?<!@): A negative lookbehind assertion. It ensures that what precedes the current position is not the at symbol (@). 
This is used to prevent matching an email address that starts with an at symbol.
@: Matches the at symbol.
[^\W]: Similar to point 2, matches any alphanumeric character.
[a-zA-Z0-9_.-]+: Similar to point 3, matches the domain part of the email address.
[\w$]*: Similar to point 4, matches the optional additional word characters or the dollar sign.
(?<!\.): Another negative lookbehind assertion. It ensures that what precedes the current position is not a dot (.). 
This is used to prevent matching an email address that ends with a dot.
*/
-- Replace email address for the User KAWIRBEA to kawira.kawira@diageocom and rerun email validity test
SET SQL_SAFE_UPDATES = 1;
UPDATE `kbl_sales`
SET `User Email` = "kawira.kawira@diageocom" WHERE `User Name` = "KAWIRBEA"; -- INVALID EMAILS
-- Select cider products from recharge_prices table, that are local and are not cartoned
SELECT `Product_Name`
FROM `recharge_prices`
WHERE
  `Product_Name` REGEXP 'cider.*Local$' AND
  `Product_Name` NOT REGEXP 'CTN';
-- Note: MySQL's regex support doesn't include full support for lookaheads and lookbehinds as some other regex engines do.

-- ______________________________________________ MYSQL COMMON TABLE EXPRESSIONS (CTE) AND RECURSIVE QUERIES/RECURSIVE CTE _________________
/*
    Consider below subquery that returns a column 'Email Validity', we also need to have a column for 'User Email'
        SELECT `Email Validation` 
            FROM (
                SELECT
                    `User Email` AS `test_emails`,
                CASE
                    WHEN `User Email` REGEXP '\\b[^\\W][a-zA-Z0-9_.-]+[\\w$]*(?<!@)@[^\W][a-zA-Z0-9_.-]+[\\w$]*(?<!\\.)\\.[a-zA-Z]+' THEN 'VALID EMAIL'
                ELSE 'INVALID EMAIL'
            END AS `Email Validation` -- Forms a column name 'Email Validation
        FROM
        `kbl_sales`
        ) AS regex_subquery
        WHERE `Email Validation` = "INVALID EMAIL";
        Result sample: INVALID EMAIL, we need something like KAWIRBEA INVALID EMAIL
*/
-- Find the invalid email address in kbl_sales table
WITH regex_subquery AS (
    SELECT
        `User Email`,-- the comma here means we have another column(derived column - will be  `Email Validation`)
        CASE
            WHEN `User Email` REGEXP '\\b[^\\W][a-zA-Z0-9_.-]+[\\w$]*(?<!@)@[^\W][a-zA-Z0-9_.-]+[\\w$]*(?<!\\.)\\.[a-zA-Z]+' THEN 'VALID EMAIL'
            ELSE 'INVALID EMAIL'
        END AS `Email Validation`
    FROM
        `kbl_sales` -- This SELECT returns `Email Validation` column (with rows having 'VALID EMAIL' or 'INVALID EMAIL' entries)
)
SELECT DISTINCT `User Email`, `Email Validation`   
FROM regex_subquery  -- regex_subquery has `User Email` and `Email Validation` columns
WHERE `Email Validation` = 'INVALID EMAIL';
-- Find total amount sold by each user, order in descending order
WITH UserSalesCTE AS (-- You can also explicitly define the column names, this is optional e.g WITH UserSalesCTE(user_name, total_amount_sold) 
    -- CTE query
	SELECT 
		`User Name` AS user_name,
        SUM(`Amount`) As total_amount_sold
	FROM 
		`kbl_sales`
	GROUP BY `User Name`
    ORDER BY total_amount_sold DESC
)
-- Main query using the CTE
SELECT 
	`user_name`,
    `total_amount_sold`
FROM UserSalesCTE;

-- Recursive CTE
WITH RECURSIVE Numbers (numbers_column) AS ( 
-- WITH RECURSIVE: specifies that the CTE is recursive, allowing it to refer to itself in the subsequent SELECT statement.
-- Numbers (numbers_column): Declares the CTE with the name "Numbers" and a single column "numbers_column"
	-- the recursive part of the CTE, which adds 1 to the current value of "numbers_column" until "numbers_column" reaches 10.
	SELECT 1 --  base case 
    UNION ALL
    SELECT numbers_column + 1 FROM Numbers WHERE numbers_column < 10
)
SELECT numbers_column FROM Numbers; -- Retrieves the values of "n" from the Numbers CTE.

-- Finding product Bill of Material(BOM) from a database using Recursive CTE
WITH RECURSIVE ProductHierarchy AS (
-- Initial Query (Anchor Member). It selects information for the starting product with the complete code 696894.
    SELECT 
        `complete code` AS product_code,
        `bottle component code` AS bottle_code,
        `shell component code` AS shell_code
    FROM `products_bom`
    WHERE `complete code` = 762947
-- Recursive Member. It selects additional rows by joining the products_bom table with the ProductHierarchy CTE on the
--                   condition that the complete code of the product matches the bottle_code of the previous level.   
    UNION ALL

    SELECT 
        pb.`complete code` AS product_code,
        pb.`bottle component code` AS bottle_code,
        pb.`shell component code` AS shell_code
    FROM `products_bom` pb
-- Termination Condition: The INNER JOIN ensures that only the rows where there is a match between the complete code of the 
-- current product (pb) and the bottle_code of the previous level in the hierarchy (ph) are included in the result.
    INNER JOIN ProductHierarchy ph ON pb.`complete code` = ph.bottle_code
)
-- Final Query Using the Recursive CTE:
SELECT * FROM ProductHierarchy;

-- Let us create a GetBOM procedure that takes the product code as argument and returns the BOM values from our CTE above
DELIMITER //

CREATE PROCEDURE GetBOM(IN starting_product_code INT)
BEGIN
    WITH RECURSIVE ProductHierarchy AS (
        SELECT 
            `complete code` AS product_code,
            `bottle component code` AS bottle_code,
            `shell component code` AS shell_code
        FROM `products_bom`
        WHERE `complete code` = starting_product_code

        UNION ALL

        SELECT 
            pb.`complete code` AS product_code,
            pb.`bottle component code` AS bottle_code,
            pb.`shell component code` AS shell_code
        FROM `products_bom` pb
        INNER JOIN ProductHierarchy ph ON pb.`complete code` = ph.bottle_code
    )
    -- Retrieve the results from the temporary table
    SELECT * FROM ProductHierarchy;

END //

DELIMITER ;
-- Example, return the BOM data for product with code 696906
CALL `agl_inventory`.GetBOM(696906);

-- ______________________________________________________________ MYSQL FUNCTIONS (Table `kbl_sales`) _________________________________________
/* AGGREGATE AND MATHEMATICAL FUNCTIONS:*/
-- Find the minimum and maximum amount sold, the total number of products sold, the average amount(to 4d.p) and the total amount sold
SELECT MIN(`Amount`) AS "Minimum Amount sold", MAX(`Amount`) AS "Maximum Amount sold", 
COUNT(DISTINCT `Material`) AS "Total Products sold",  -- excluding duplicates 
ROUND(AVG(`Amount`), 4) AS "Average Amount sold", SUM(`Amount`) AS "Total Amount sold" -- NULL values are ignored, only works in numeric values
FROM `kbl_sales`;

-- To find the total amount made by each distributor daily without additional subtotals(GROUPING)
SELECT
    `Posting Date`,
    `Distributor Name`,
    SUM(`Amount`) AS daily_total_amount
FROM
    kbl_sales
GROUP BY
    `Posting Date`,`Distributor Name`
ORDER BY 
	`Posting Date` ASC, daily_total_amount DESC;

 -- To find the total amount made by each distributor daily with subtotals(WITH ROLL UP)
SELECT
    `Posting Date`,
    `Distributor Name`,
    SUM(`Amount`) AS daily_total_amount
FROM
    kbl_sales
GROUP BY
    `Posting Date`, `Distributor Name` WITH ROLLUP
ORDER BY 
	`Posting Date` ASC, daily_total_amount DESC;   

/* STRING FUNCTIONS:*/
-- Select the average amount if total sales is a contribution of all users' efforts, format with thousand seperators to 4.dp
SELECT
    FORMAT(SUM(`Amount`) / COUNT(DISTINCT `User Name`), 4) AS "Average Amount"
FROM
    `kbl_sales`;
-- Return a column "User Details" that combines User Name and User Email e.g ADEKCOLL: Collins.Adek@eabl.com : CONCAT()
SELECT CONCAT(`User Name`,":"," ",`User Email`) AS "User Details" FROM `kbl_sales`;  -- > ADEKCOLL: Collins.Adek@eabl.com
-- Concat with a pipe operator: CONCAT_WS()
SELECT CONCAT_WS(" | ",`User Name`,`User Email`) AS "User Details" FROM `kbl_sales`;  -- > ADEKCOLL | Collins.Adek@eabl.com
-- Find the position of the character '@' in the User Emails and also its index(LOCATE(), POSITION(), INSTR())
-- "position": 1-based ordinal number of a character within a string, while 
-- "index": 0-based ordinal number of a character within a string or an element within a data structure.
SELECT DISTINCT
    `User Email`,
    LOCATE('@', `User Email`) AS `Position of @`,  -- OR  POSITION('@' IN `User Email`) AS `Position of @`, OR INSTR(`User Email`, '@') AS `Position of @`
    LOCATE('@', `User Email`) - 1 AS `Index of @` -- OR POSITION('@' IN `User Email`) - 1 AS `Index of @`, OR INSTR(`User Email`, '@') AS `Position of @` - 1,
FROM
    `kbl_sales`;
-- Select the full user names from kbl_sales, you can use user_email to fetch the strings.e.g ADEKCOLL ->Collins Adek(from Collins.Adek@eabl.com)
SELECT DISTINCT `User Name`, `Full Name`
FROM (
	SELECT `User Name`, CONCAT(LEFT(`User Email`, LOCATE(".", `User Email`)-1), " ", 
    MID(`User Email`, LOCATE(".", `User Email`) + 1, LOCATE("@", `User Email`) - LOCATE(".", `User Email`)-1)) AS "Full Name"
    FROM `kbl_sales`
) AS subquery;
-- Alternative query
SELECT DISTINCT 
    `User Name`,
    CONCAT(
        SUBSTRING_INDEX(`User Email`, '.', 1),' ', -- returns: Collins 
        -- SUBSTRING_INDEX(`User Email`, '@', 1): returns: Collins.Adek
        SUBSTRING_INDEX(SUBSTRING_INDEX(`User Email`, '@', 1), '.', -1) -- returns: Adek
    ) AS `Full Name` -- returns: Collins Adek
FROM 
    `kbl_sales`;
-- A typical user name for agl data clerks should end with -AGL in their names e.g ADEKCOLL -->ADEKCOLL-AGL, return a column 'agl_users'
SELECT
    `User Name`,
    RPAD(`User Name`, CHAR_LENGTH(`User Name`) + CHAR_LENGTH('-AGL'), '-AGL') AS `agl_users`  -- CHAR_LENGTH OR CHARACTER_LENGTH 
FROM
    `kbl_sales`;
-- Return a column "Updated_distributor_name" having proper case for the distributor names(proper case formatting in MySQL)
SELECT
    `Distributor Name`,
    CONCAT(
        UPPER(SUBSTRING(`Distributor Name`, 1, 1)),
        LOWER(SUBSTRING(`Distributor Name`, 2))  -- return from char 2 to end
    ) AS `Proper Case Distributor Name`
FROM
    `kbl_sales`
LIMIT 5;
-- See other functions like: REPLACE, REVERSE, LTRIM, RTRIM, TRIM

/* DATE AND TIME FUNCTIONS:*/
-- Posting after cut-off means posting time is from 00:00:01 to 03:00:00(included), return all deliveries posted after cut-off
-- between 15.12.2023 to 31.12.2023 
SELECT
    `Sales Deliveries`,
    `Posting Date`,
    `Posting Time`,
    `Cut-off Category`
FROM (
    SELECT
        `Posting Date`,
        `Sales Deliveries`,
        `Posting Time`,
        CASE
            WHEN DATE(`Posting Date`) BETWEEN '2023-12-15' AND '2023-12-31' AND 
                TIME(`Posting Time`) BETWEEN '00:00:01' AND '03:00:00' 
            THEN 'After Cut-off'  -- BETWEEN includes both ends
            ELSE 'Before Cut-off'
        END AS `Cut-off Category`
    FROM
        `kbl_sales`
) AS subquery
WHERE
    `Cut-off Category` = 'After Cut-off';
-- return current date and current time
SELECT CURRENT_DATE() AS "Current Date", CURRENT_TIME() AS "Current Time";  -- OR CURDATE(), CURTIME()
-- return current date and time
SELECT CURRENT_TIMESTAMP AS "Current Date and Time"; -- OR use;LOCALTIMESTAMP(for session time zone) or SELECT NOW() AS "Current Date and Time";
-- Loading KPI requires that all deliveries be loaded within three days. Select a column indicating deadline for loading
SELECT DATE(`Posting Date`) AS "Posting Date", 
	DATE(DATE_ADD(DATE(`Posting Date`), INTERVAL 3 DAY)) -- Use DATE_ADD not ADDDATE(non-standard) with INTERVAL; DATE_SUB() use -3 DAY
    AS "Loading Deadline"
FROM `kbl_sales` LIMIT 5;
-- how many days did it take to sell the highest amount ever since we sold the least amount
-- (we will use derived table or inline view)
SELECT
    DATEDIFF(MAX(subquery1.best_selling_day), MIN(subquery2.least_selling_day)) AS "Difference in days"
FROM (
    SELECT
        ks1.`Posting Date` AS best_selling_day
    FROM
        `kbl_sales` ks1
    WHERE
        ks1.`Amount` = (SELECT MAX(`Amount`) FROM `kbl_sales`)
) AS subquery1,  -- alias subquery1 subquery is referenced in the outer query. 
(
    SELECT
        ks2.`Posting Date` AS least_selling_day
    FROM
        `kbl_sales` ks2
    WHERE
        ks2.`Amount` = (SELECT MIN(`Amount`) FROM `kbl_sales`)
) AS subquery2;  -- alias subquery2 subquery is referenced in the outer query. 
-- return current month name 
SELECT MONTHNAME(NOW());
-- Extract the month from the last date in kbl_sales
SELECT EXTRACT(MONTH FROM MAX(`Posting Date`)) AS ExtractedMonth -- Other parts: QUARTER, YEAR, DAY
FROM `kbl_sales`;
-- return the last date of sales formated in week day name, day, month and year format e.g Saturday 20th Jan 2024
SELECT DATE_FORMAT(MAX(`Posting Date`), "%W, %D, %M, %Y") AS "formated_date" FROM `kbl_sales`;

/*ADVANCED FUNCTIONS*/
-- Convert the text "2024-01-24" to Mysql date and extract the month
SELECT EXTRACT(MONTH FROM CAST("2024-01-24" AS DATE)) "Month of casted date";
-- select null entries in product_id column of products table
SELECT `product_id` AS Result
FROM products
WHERE ISNULL(product_id) = 1; -- OR: WHERE product_id IS NULL. 
-- NULLIF() to set NULL values for missing data during data loading: `complete code` = NULLIF(@complete_code, '')
-- Select the first non-null value from a set of literals
SELECT COALESCE(NULL, 'Default') AS Result;
-- compare current_timestamp() and now() functions, return True, if the two return same result, else False
SELECT IF(CURRENT_TIMESTAMP() = NOW(), "True", "False") AS AreEqual; -- OR SELECT current_timestamp() = NOW() AS AreEqual; -> returns 1

-- _______________________________________________________________ MYSQL OPERATORS ___________________________________________________________
/*COMPARISON OPERATORS*/
-- find the product code whose length is not equal to 6, from the products table
SELECT `product_code` FROM `products` WHERE CHAR_LENGTH(`product_code`) != 6 ; -- Use != or <> 
-- Hitting daily target means a user being able to sell atleast 50000 cases of keg throughout the month. Find the 3 top users who hit the target
SELECT
    `User Name`,
    SUM(`Quantity Cases`) AS `Total Quantity Sold`
FROM
    `kbl_sales`
WHERE
    `Material Description` LIKE "%KEG"
GROUP BY
    `User Name`
HAVING
    SUM(`Quantity Cases`) >= 50000
ORDER BY
    `Total Quantity Sold` DESC
LIMIT 3;

/*ARITHMETIC OPERATORS*/
-- Suppose total amount sold is considered as an effort of all users, find the average amount sold per user round to 4 decimal places
SELECT
    ROUND(SUM(`Amount`) / COUNT(DISTINCT `User Name`), 4) AS "Average Amount"
FROM
    `kbl_sales`;
-- If the amount sold was to be divided among the users, what would remain?
SELECT SUM(`Amount`) % COUNT(DISTINCT `User Name`) AS`Amount remaining` FROM `kbl_sales`; -- > 8.06
-- all users who sold KEG products were to be given 3 bottles of Gilbeys gin 75cl, How many bottles would be used?
SELECT
    COUNT(`User Name`) * 3 AS "Total Number of Gilbeys given"
FROM
    `kbl_sales`
WHERE
    `Material Description` LIKE "%KEG"; -- '2349'

/*LOGICAL OPERATORS*/
-- large trucks have wheels between 12 to 22, they typically carry keg quantities between 215 and 433 cases, find the deliveries of large trucks
-- suppose agility and ponty pridd trucks are not considered large trucks
SELECT
    `Sales Deliveries`,
    SUM(`Quantity Cases`) AS "Total Cases loaded"
FROM
    `kbl_sales`
WHERE
    `Material Description` LIKE "%KEG" AND `Truck Number` NOT LIKE "%AGIL" OR `Truck Number` NOT LIKE "%PPD"
GROUP BY
    `Sales Deliveries`
HAVING
    SUM(`Quantity Cases`) BETWEEN 215 AND 439
ORDER BY SUM(`Quantity Cases`) DESC;
-- Find sales deliveries with less than 120cases
SELECT DISTINCT `Sales Deliveries`
FROM `kbl_sales` k1
WHERE 120 > ALL (
    SELECT SUM(`Quantity Cases`)
    FROM `kbl_sales` k2
    WHERE k2.`Sales Deliveries` = k1.`Sales Deliveries`
)
LIMIT 10;
--  find deliveries where at least one user sold keg products:
SELECT DISTINCT `Sales Deliveries`
FROM `kbl_sales` k1
WHERE EXISTS (
    SELECT 1
    FROM `kbl_sales` k2
    WHERE k2.`Sales Deliveries` = k1.`Sales Deliveries`
      AND k2.`Material Description` LIKE "%KEG"
);
-- find sales deliveries where the quantity of cases is greater than some of the cases in another delivery:
SELECT DISTINCT `Sales Deliveries`
FROM `kbl_sales` k1
WHERE 120 < SOME (
    SELECT `Quantity Cases`
    FROM `kbl_sales` k2
    WHERE k2.`Sales Deliveries` = k1.`Sales Deliveries`
) LIMIT 5;

-- _______________________________________________________________ MYSQL JOINS ________________________________________________________________
/*CARTESIAN JOIN
 A Cartesian join combines each row from the first table with every row from the second table, resulting in a cross-product of the two tables.
 While Cartesian joins can be useful in specific scenarios, they often result in a large number of rows
 ON 1 = 1, means "join every row from subquery1 with every row from subquery2.(there is no explicit condition for the join.)
*/
-- Consider table "kbl_sales", how many days did it take to sell the highest amount ever since we sold the least amount
SELECT
    DATEDIFF(MAX(subquery1.best_selling_day), MIN(subquery2.least_selling_day)) AS "Difference in days"
FROM (
    SELECT
        ks1.`Posting Date` AS best_selling_day
    FROM
        `kbl_sales` ks1
    WHERE
        ks1.`Amount` = (SELECT MAX(`Amount`) FROM `kbl_sales`)
) AS subquery1
JOIN (
    SELECT
        ks2.`Posting Date` AS least_selling_day
    FROM
        `kbl_sales` ks2
    WHERE
        ks2.`Amount` = (SELECT MIN(`Amount`) FROM `kbl_sales`)
) AS subquery2 ON 1 = 1; -- or ON true;

/*SELF JOIN*/
-- Find the users who loaded the truck that made the highest entries(KBZ 035X ZE7303 PPD)
SELECT DISTINCT kb1.`User Name` AS data_clerk, kb1.`Truck Number` AS truck
FROM kbl_sales kb1
JOIN kbl_sales kb2 ON kb2.`User Name` = kb1.`User Name`
WHERE kb1.`Truck Number` = 'KBZ 035X ZE7303 PPD' AND kb2.`Truck Number` = 'KBZ 035X ZE7303 PPD';

/* INNER JOIN OR JOIN: retrieves only the rows where there is a match in both tables based on the specified condition.
All postings by the user MBEREMAR1 are done for reversals of sales deliveries. Suppose AGL is charged with the formula
"total amount reversed / recharge cost per case" for each product, find the cost incurred by AGL as a result of the reversal
in the kbl_sales report for Dec 2023*/
SELECT 
    ks.`Posting Date` AS posting_date,
    ks.`User Name` AS user_name,
    ks.`Sales Deliveries` AS sales_deliveries,
    ks.`Distributor Name` AS distributor_name,
    ks.`Truck Number` AS truck_number,
    ks.`Material` AS material,
    ks.`Material Description` AS material_description,
    ks.`Quantity Cases` AS quantity_cases,
    ks.`Amount` AS amount,
    rp.`recharge_per_case` AS recharge_amount,
    CASE
        WHEN rp.`recharge_per_case` <> 0 THEN
            ks.`Amount` / rp.`recharge_per_case`
        ELSE
            0 -- Avoid division by zero
    END AS cost_incurred_by_agl
FROM kbl_sales ks
JOIN `recharge_prices` rp ON ks.`Material` = rp.`product_code`  -- OR INNER JOIN
WHERE ks.`User Name` = 'MBEREMAR1'
    AND MONTH(ks.`Posting Date`) = 12
    AND YEAR(ks.`Posting Date`) = 2023;
-- Demonstrate 2 joins using the above(include lock status of the product from products table)
SELECT 
    ks.`Posting Date` AS posting_date,
    ks.`User Name` AS user_name,
    ks.`Sales Deliveries` AS sales_deliveries,
    ks.`Distributor Name` AS distributor_name,
    ks.`Truck Number` AS truck_number,
    ks.`Material` AS material,
    ks.`Material Description` AS material_description,
    ks.`Quantity Cases` AS quantity_cases,
    ks.`Amount` AS amount,
    rp.`recharge_per_case` AS recharge_amount,
    p.`is_locked` AS product_lock_status,
    CASE
        WHEN rp.`recharge_per_case` <> 0 THEN
            ks.`Amount` / rp.`recharge_per_case`
        ELSE
            0 -- Avoid division by zero
    END AS cost_incurred_by_agl
FROM ((kbl_sales ks
JOIN `recharge_prices` rp ON ks.`Material` = rp.`product_code`)
JOIN `products` p ON ks.`Material` = p.`product_code`)
WHERE ks.`User Name` = 'MBEREMAR1'
    AND MONTH(ks.`Posting Date`) = 12
    AND YEAR(ks.`Posting Date`) = 2023;

/*LEFT OUTER JOIN OR LEFT JOIN: Return all rows from the left table and matched rows from the right table, NULL for right table if no match
Update kbl_sales products with their recharge prices
*/
SELECT 
    ks.`Posting Date` AS posting_date,
    ks.`User Name` AS user_name,
    ks.`Sales Deliveries` AS sales_deliveries,
    ks.`Distributor Name` AS distributor_name,
    ks.`Truck Number` AS truck_number,
    ks.`Material` AS material,
    ks.`Material Description` AS material_description,
    ks.`quantity cases` AS quantity_cases,
    ks.`Amount` AS amount,
    rp.`recharge_per_case` AS recharge_amount
FROM kbl_sales ks
LEFT JOIN recharge_prices rp ON ks.`Material` = rp.`product_code`;
-- ANTI LEFT JOIN (Return all products of the kbl_sales table that were sold but missing recharge prices)
SELECT 
    ks.`Posting Date` AS posting_date,
    ks.`User Name` AS user_name,
    ks.`Sales Deliveries` AS sales_deliveries,
    ks.`Distributor Name` AS distributor_name,
    ks.`Truck Number` AS truck_number,
    ks.`Material` AS material,
    ks.`Material Description` AS material_description,
    ks.`quantity cases` AS quantity_cases,
    ks.`Amount` AS amount,
    rp.`recharge_per_case` AS recharge_amount
FROM kbl_sales ks
LEFT JOIN recharge_prices rp ON ks.`Material` = rp.`product_code`
WHERE rp.`recharge_per_case` IS NULL;

/*RIGHT OUTER JOIN OR RIGHT JOIN: Return all rows from the right table and matched rows from the left table, NULL for left table if no match
Check for all recharge prices table products that were sold
Please note that RIGHT JOIN is not as commonly used as LEFT JOIN in practice, as it can be expressed using LEFT JOIN with the tables swapped. 
*/
SELECT DISTINCT
    rp.`product_code` AS product_code,
    rp.`product_name` AS product_name,
    rp.`recharge_per_case` AS recharge_amount
FROM recharge_prices rp
RIGHT JOIN 	`kbl_sales` ks ON ks.`Material` = rp.`product_code`;
/*ANTI RIGHT JOIN: Return all recharge price table products that were not sold
*/
SELECT DISTINCT
    rp.`product_code` AS product_code,
    rp.`product_name` AS product_name,
    rp.`recharge_per_case` AS recharge_amount
FROM recharge_prices rp
RIGHT JOIN 	`kbl_sales` ks ON ks.`Material` = rp.`product_code`
WHERE rp.`product_code` IS NULL;

/*FULL OUTER JOIN OR FULL JOIN
It's often used in scenarios where you need to see unmatched rows from both tables.
MySQL does not directly support FULL JOIN syntax. Instead, you can simulate a FULL JOIN using a combination of LEFT JOIN and UNION
*/
-- Simulating FULL OUTER JOIN using UNION of LEFT and RIGHT JOIN subqueries
SELECT 
    COALESCE(rp.`product_code`, ks.`Material`) AS product_code,
    COALESCE(rp.`product_name`, ks.`Material Description`) AS product_name,
    rp.`recharge_per_case` AS recharge_amount,
    ks.`Amount` AS sales_amount
FROM recharge_prices rp
LEFT JOIN kbl_sales ks ON rp.`product_code` = ks.`Material`

UNION

SELECT 
    COALESCE(rp.`product_code`, ks.`Material`) AS product_code,
    COALESCE(rp.`product_name`, ks.`Material Description`) AS product_name,
    rp.`recharge_per_case` AS recharge_amount,
    ks.`Amount` AS sales_amount
FROM kbl_sales ks
RIGHT JOIN recharge_prices rp ON ks.`Material` = rp.`product_code`;
-- ANTI FULL JOIN: find rows that do not have a match in either table
SELECT 
    COALESCE(rp.`product_code`, ks.`Material`) AS product_code,
    COALESCE(rp.`product_name`, ks.`Material Description`) AS product_name,
    rp.`recharge_per_case` AS recharge_amount,
    ks.`Amount` AS sales_amount
FROM recharge_prices rp
LEFT JOIN kbl_sales ks ON rp.`product_code` = ks.`Material`
WHERE ks.`Material` IS NULL

UNION

SELECT 
    COALESCE(rp.`product_code`, ks.`Material`) AS product_code,
    COALESCE(rp.`product_name`, ks.`Material Description`) AS product_name,
    rp.`recharge_per_case` AS recharge_amount,
    ks.`Amount` AS sales_amount
FROM kbl_sales ks
LEFT JOIN recharge_prices rp ON ks.`Material` = rp.`product_code`
WHERE rp.`product_code` IS NULL;

-- _____________________________________________ MYSQL DATABASE INTEGRATION WITH PYTHON USING MYSQL.CONNECTOR DRIVER  ____________________
-- EXECUTING (FETCHING FROM THE DB): Execute our stored procedure GetBOM() to fetch BOM data for product 681232
/*
        Python code:
# Import key modules
import mysql.connector
import json

# Initialize cursor and connection
cursor = None
conn = None

# Try to load MySQL credentials from a JSON file
try:
    with open(r'C:\Users\user\Desktop\DATA++\CLASS NOTES\Program files\mysql_credentials.json') as f:
        credentials = json.load(f)
except FileNotFoundError:
    credentials = None
    print("Error: MySQL credentials file not found.")

# Ensure your credentials were set up
if credentials:
    try:
        # Connect to the MySQL database
        conn = mysql.connector.connect(
            user=credentials.get('username'),
            password=credentials.get('password'),
            database=credentials.get('database'),
            host=credentials.get('host')
        )

        # Create a cursor object to execute SQL queries
        cursor = conn.cursor()

        # Example:Get the BOM of a product using database stored procedure GetBOM()
        product_code = int(input('Enter product code: '))
        query = f"CALL `agl_inventory`.GetBOM({product_code});"
        cursor.execute(query)
        # Fetch all the rows
        rows = cursor.fetchall()

        # Print the results
        print(f"_________________________ BILL OF MATERIAL FOR: {product_code} _____________________")
        print("(product, bottle, shell)")
        for row in rows:
            print(row)

    except mysql.connector.Error as err:
        print(f"Error: {err}")

    finally:
        # Close the cursor and connection in the 'finally' block to ensure they are closed
        if cursor is not None:
            cursor.close()
        if conn is not None and conn.is_connected():
            conn.close()
else:
    print("Error: Unable to load MySQL credentials.")

    """
    Python Console Result:
    Enter product code: 681232
    _________________________ BILL OF MATERIAL FOR: 681232 _____________________
    (product, bottle, shell)
    (681232, 350592, 350605)
    """
*/

-- COMMITTING TO THE DB: Add another column in the `temp_recharge_prices` table called 'PythonColumn' with default value NULL
/*
        Python code:
# Import key modules
import mysql.connector
import json

# Initialize cursor and connection
cursor = None
conn = None

# Try to load MySQL credentials from a JSON file
try:
    with open(r'C:\Users\user\Desktop\DATA++\CLASS NOTES\Program files\mysql_credentials.json') as f:
        credentials = json.load(f)
except FileNotFoundError:
    credentials = None
    print("Error: MySQL credentials file not found.")

# Ensure your credentials were set up
if credentials:
    try:
        # Connect to the MySQL database
        conn = mysql.connector.connect(
            user=credentials.get('username'),
            password=credentials.get('password'),
            database=credentials.get('database'),
            host=credentials.get('host')
        )

        # Create a cursor object to execute SQL queries
        cursor = conn.cursor()

        # Add a new column with default value NULL
        add_column_query = "ALTER TABLE `temp_recharge_prices` ADD COLUMN `PythonColumn` VARCHAR(255) DEFAULT NULL"
        cursor.execute(add_column_query)

        # Commit the changes
        conn.commit()

    except mysql.connector.Error as err:
        print(f"Error: {err}")

    finally:
        # Close the cursor and connection in the 'finally' block to ensure they are closed
        if cursor is not None:
            cursor.close()
        if conn is not None and conn.is_connected():
            conn.close()
else:
    print("Error: Unable to load MySQL credentials.")
*/

-- EXECUTING DYNAMIC SQL: Dynamic SQL refers to the creation and execution of SQL statements at runtime e.g based on user input
/*
    Python Code:

# Import key modules
import mysql.connector
import json


def execute_dynamic_query(product_name=input('Enter product name: ')):
    # Initialize cursor and connection
    cursor = None
    conn = None

    # Try to load MySQL credentials from a JSON file
    try:
        with open(r'C:\Users\user\Desktop\DATA++\CLASS NOTES\Program files\mysql_credentials.json') as f:
            credentials = json.load(f)
    except FileNotFoundError:
        credentials = None
        print("Error: MySQL credentials file not found.")

    # Ensure your credentials were set up
    if credentials:
        try:
            # Connect to the MySQL database
            conn = mysql.connector.connect(
                user=credentials.get('username'),
                password=credentials.get('password'),
                database=credentials.get('database'),
                host=credentials.get('host')
            )

            # Create a cursor object to execute SQL queries
            cursor = conn.cursor()

            # Use parameterized query to prevent sql injection
            query = "SELECT * FROM `products` WHERE `product_name` = %s"
            """
             the database driver will substitute %s with the actual value 'some_product_name', ensuring that the query 
             is executed safely and securely.
            """
            cursor.execute(query, (product_name,))  # passes the actual values in a tuple as the second argument.

            # Fetch the results
            results = cursor.fetchall()

            # Fetch column names from cursor description
            column_names = [desc[0] for desc in cursor.description]

            # Print the title row
            print("____________________________________________ DATABASE DATA ________________________________________")
            print(" , ".join(column_names))

            # Print the results
            for row in results:
                print(row)

        except mysql.connector.Error as err:
            print(f"Error: {err}")

        finally:
            # Close the cursor and connection in the 'finally' block to ensure they are closed
            if cursor is not None:
                cursor.close()
            if conn is not None and conn.is_connected():
                conn.close()
    else:
        print("Error: Unable to load MySQL credentials.")


execute_dynamic_query()
*/

-- _____________________________________________________ MYSQL TRANSACTIONS ______________________________________________________________
/*A transaction is a sequence of one or more SQL statements that are treated as a single, atomic unit of work. 
This means that either all the statements within a transaction are successfully executed, or none of them are. 
Transactions adhere to the ACID(atomicity, consistency, isolation, and durability) properties:
    Atomicity: All changes in a transaction are committed, or none are, ensuring the transaction is indivisible.
    Consistency: Transactions bring the database from one valid state to another, adhering to integrity constraints.
    Isolation: Concurrent transactions behave as if executed in isolation, preventing interference.
    Durability: Committed transactions' effects are permanent and survive failures, ensuring persistence
Example: We will set PythonColumn column of temp_recharge_prices table with "missing_price" where `Recharge Price / Case` is 0.0000
and also set it to "updated_price" when the value is not equal to 0.0000. Since we will use If statements, we will create a procedure
*/
DELIMITER //

CREATE PROCEDURE TransactionUpdatePythonColumn() -- stored procedure TransactionUpdatePythonColumn(does not take any parameters)
BEGIN
    -- Begin the transaction
    START TRANSACTION;

    -- Create a savepoint(not meant for storing or retrieving values but rather for controlling the flow of transactions) named before_update
    SAVEPOINT before_update; --  Savepoints are used to mark a point within a transaction to which you can later roll back.

    -- Update PythonColumn based on conditions
    UPDATE temp_recharge_prices
    SET PythonColumn = CASE
        WHEN Recharge_Price_Per_Case = 0.0000 THEN 'missing_price'  -- Recharge_Price_Per_Case. This is same as `Recharge Price / Case`
        WHEN Recharge_Price_Per_Case >= 6000 THEN 'illegal_price'
        ELSE 'updated_price'
    END;

    -- Check if any rows were affected(Atomicity)
    IF ROW_COUNT() > 0 THEN -- ROW_COUNT() - used to get the number of affected rows by the last statement that changed something in the database
        -- Commit the transaction if successful
        COMMIT;
        SELECT 'Transaction committed' AS Result; --  A message indicating that the transaction was committed is selected and returned as a result.
    ELSE
        -- Rollback to the savepoint if no rows were affected
        ROLLBACK TO before_update;
        -- Alternatively, you can simply use ROLLBACK; to undo the entire transaction
        -- ROLLBACK;
        SELECT 'Transaction rolled back' AS Result;
    END IF;
END //

DELIMITER ;

-- _____________________________________________________ SQL LANGUAGE TYPES ________________________________________________________________
-- DDL (Data Definition Language):
CREATE: Defines new database objects like tables, indexes, or views.
ALTER: Modifies the structure of existing database objects.
DROP: Deletes existing database objects.
TRUNCATE: Removes all records from a table, but retains the structure for future use.
COMMENT: Adds comments to the data dictionary.

-- DML (Data Manipulation Language):
SELECT: Retrieves data from one or more tables.
INSERT: Adds new records into a table.
UPDATE: Modifies existing records in a table.
DELETE: Removes records from a table.
MERGE: Performs insert, update, or delete operations based on a condition.

-- TCL (Transaction Control Language):
COMMIT: Saves all changes made during the current transaction.
ROLLBACK: Undoes changes made during the current transaction.
SAVEPOINT: Sets a savepoint within a transaction to which you can later roll back.
SET TRANSACTION: Specifies characteristics for a transaction.

-- DCL (Data Control Language):
GRANT: Provides specific privileges to database users.
REVOKE: Removes specific privileges from database users.

-- SQL/PSM (SQL/Persistent Stored Modules):
DECLARE: Declares variables and cursors.
SET: Assigns values to variables.
IF, ELSEIF, ELSE: Conditional statements.
LOOP, WHILE, REPEAT: Looping constructs.
LEAVE, ITERATE: Controlling the flow within loops.


-- _________________________________________________________ CREATING STORED FUNCTIONS IN MYSQL _____________________________________________
/* - Stored functions in MySQL are named blocks of code that perform a 
specific task and return a single value.
   - They are similar to stored procedures but are designed to return a value
 rather than a result set*/
DELIMITER //

/* Create a function named MultiplyNumbers(DETERMINISTIC)*/
CREATE FUNCTION MultiplyNumbers(a INT, b INT)
RETURNS INT
DETERMINISTIC -- returns the same result, see No SQL, READS SQL DATA
BEGIN
    -- Declare a variable to store the result
    DECLARE result INT;

    -- Perform multiplication
    SET result = a * b;

    -- Return the result
    RETURN result;
END //

-- Reset the statement delimiter to ;
DELIMITER ;

-- Call the function and display the result
SELECT MultiplyNumbers(5, 7) AS Result;

/* Create a stored function that gets the average recharge price from the temp_recharge_prices table(READS SQL DATA)*/
DELIMITER //

CREATE FUNCTION GetAverageRechargePrice() RETURNS DECIMAL(10, 2) READS SQL DATA
BEGIN
    DECLARE avg_price DECIMAL(10, 2);

    -- Calculate the average recharge price
    SELECT AVG(`Recharge Price / Case`) INTO avg_price
    FROM temp_recharge_prices;

    RETURN avg_price;
END //

DELIMITER ;
/* create a deterministic function named CalculateTax that calculates the tax for a given amount (DETERMINISTIC NO SQL)*/
DELIMITER //

CREATE FUNCTION CalculateTax(amount DECIMAL(10, 2))
RETURNS DECIMAL(10, 2)
DETERMINISTIC
NO SQL
BEGIN
    DECLARE tax DECIMAL(10, 2);

    -- Assume a simple tax calculation of 10%
    SET tax = amount * 0.10;

    RETURN tax;
END //

DELIMITER ;

SELECT CalculateTax(32500.00) AS TaxPayedByClerk;

/* Create GetProductName function that retrieves the product name based on product code by reading data from the temp_recharge_prices table.
DETERMINISTIC READS SQL DATA
*/
DELIMITER //

CREATE FUNCTION GetProductName(productCode INT) -- If you want to drop the function->DROP FUNCTION GetProductName;
RETURNS VARCHAR(255)
DETERMINISTIC --  because the result is deterministic for the same input.
READS SQL DATA --  because it reads data from the temp_recharge_prices table.
BEGIN
    DECLARE productName VARCHAR(255);

    -- Retrieve the product name based on the provided product code
    SELECT `Description` INTO productName
    FROM temp_recharge_prices
    WHERE `SKU` = productCode
    LIMIT 1;

    RETURN productName;
END //

DELIMITER ;


-- ________________________________________________________________ MYSQL WINDOW/ANALYTIC FUNCTIONS _______________________________________
/*
OVER(): Specifies the window or partition of rows over which the window function operates.								
ROW_NUMBER(): Assigns a unique number to each row within a partition.								
RANK(): Assigns a rank to each row within a partition.								
DENSE_RANK(): Similar to RANK(), but without leaving gaps for ties.								
SUM(), AVG(), MIN(), MAX(), COUNT(): Aggregate functions that can be used with the OVER() clause to perform calculations over a window.								
LEAD(): Accesses data from subsequent rows.								
LAG(): Accesses data from preceding rows.								
FIRST_VALUE() and LAST_VALUE(): Returns the first or last value in a window frame.								
PARTITION BY: Divides the result set into partitions to which the window function is applied.	
--SEE FOLLOWING, UNBOUND FOLLOWING, UNBOUND PRECEDING							
*/
-- Example 1: Calculate the running total of sales amount for each distributor over time.
SELECT
    `Posting Date`,
    `Distributor Name`,
    Amount,
    SUM(Amount) OVER (PARTITION BY `Distributor Name` ORDER BY `Posting Date`) AS Running_Total
FROM
    kbl_sales;

-- Example 2: Rank the sales deliveries based on the quantity of cases.
SELECT
    `Posting Date`,
    `Sales Deliveries`,
    `Quantity Cases`,
    RANK() OVER (ORDER BY `Quantity Cases` DESC) AS Case_Rank
FROM
    kbl_sales;

-- Example 3: Calculate the average quantity of cases for each distributor, considering the last three sales.
SELECT
    `Posting Date`,
    `Distributor Name`
    `Quantity Cases`,
    AVG(`Quantity Cases`) OVER (PARTITION BY `Distributor Name` ORDER BY `Posting Date` ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS Avg_Quantity_Last_Three
FROM
    kbl_sales;

-- Example 4: Determine the percentage contribution of each sale to the total amount within its distributor.
SELECT
    `Posting Date`,
    `Distributor Name`,
    `Amount`,
    `Amount` / SUM(`Amount`) OVER (PARTITION BY `Distributor Name`) * 100 AS Contribution_Percentage
FROM
    kbl_sales;

-- Example 5: Find the material with the highest quantity of cases for each distributor.
SELECT
    `Posting Date`,
    `Distributor Name`,
    `Material`,
    `Quantity Cases`,
    MAX(`Quantity Cases`) OVER (PARTITION BY `Distributor Name`) AS Max_Quantity_Cases
FROM
    kbl_sales;

-- Example 6: Determine the growth rate of sales quantity compared to the previous day for each distributor.
SELECT
    `Posting Date`,
    `Distributor Name`,
    `Quantity Cases`,
    (`Quantity Cases` - LAG(`Quantity Cases`) OVER (PARTITION BY `Distributor Name` ORDER BY `Posting Date`)) / LAG(`Quantity Cases`) OVER (PARTITION BY `Distributor Name` ORDER BY `Posting Date`) * 100 AS Growth_Rate
FROM
    kbl_sales;

-- Example 7: Rank distributors based on the total sales amount and apply ties using the average quantity of cases.
SELECT
    `Distributor Name`,
    SUM(`Amount`) AS Total_Sales_Amount,
    AVG(`Quantity Cases`) AS Avg_Quantity_Cases,
    RANK() OVER (ORDER BY SUM(`Amount`) DESC, AVG(`Quantity Cases`) DESC) AS Distributor_Rank
FROM
    kbl_sales
GROUP BY
    `Distributor Name`;

-- Example 8: Identify the top-selling material for each distributor based on the total sales amount.
WITH RankedMaterials AS (
    SELECT
        `Distributor Name`,
        `Material`,
        SUM(`Amount`) AS Total_Sales
    FROM
        kbl_sales
    GROUP BY
        `Distributor Name`, `Material`
),
RankedMaterialsByDistributor AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY `Distributor Name` ORDER BY Total_Sales DESC) AS RowNum,
        DENSE_RANK() OVER (PARTITION BY `Distributor Name` ORDER BY Total_Sales DESC) AS DenseRank,
        LEAD(`Material`) OVER (PARTITION BY `Distributor Name` ORDER BY Total_Sales DESC) AS NextMaterial,
        FIRST_VALUE(`Material`) OVER (PARTITION BY `Distributor Name` ORDER BY Total_Sales DESC) AS FirstMaterial,
        LAST_VALUE(`Material`) OVER (PARTITION BY `Distributor Name` ORDER BY Total_Sales DESC) AS LastMaterial
    FROM
        RankedMaterials
)
SELECT
    `Distributor Name`,
    `Material`,
    Total_Sales,
    RowNum,
    DenseRank,
    NextMaterial AS Next_Best_Material,
    FirstMaterial AS Top_Material,
    LastMaterial AS Last_Material
FROM
    RankedMaterialsByDistributor
WHERE
    RowNum = 1;

-- Example 9: Calculate percentiles for the sales amount within each material category.
WITH MaterialSalesStats AS (
    SELECT
        `Material`,
        `Amount`,
        NTILE(4) OVER (PARTITION BY `Material` ORDER BY `Amount`) AS Quartile,
        PERCENT_RANK() OVER (PARTITION BY `Material` ORDER BY `Amount`) AS Percentile_Rank,
        CUME_DIST() OVER (PARTITION BY `Material` ORDER BY `Amount`) AS Cumulative_Distribution
    FROM
        kbl_sales
)
SELECT
    m.`Material`,
    m.`Amount`,
    m.Quartile,
    m.Percentile_Rank,
    m.Cumulative_Distribution,
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(GROUP_CONCAT(m2.`Amount` ORDER BY m2.`Amount`), ',', 50/100), ',', -1) AS DECIMAL(10, 2)) AS Median_Value
FROM
    MaterialSalesStats m
JOIN
    MaterialSalesStats m2 ON m.`Material` = m2.`Material`
GROUP BY
    m.`Material`, m.`Amount`, m.Quartile, m.Percentile_Rank, m.Cumulative_Distribution;

-- Example 10: identify trends in sales quantity for each material:
WITH MaterialSalesTrends AS (
    SELECT
        `Material`,
        `Quantity Cases`,
        LAG(`Quantity Cases`) OVER (PARTITION BY `Material` ORDER BY `Posting Date`) AS Prev_Quantity,
        LEAD(`Quantity Cases`) OVER (PARTITION BY `Material` ORDER BY `Posting Date`) AS Next_Quantity,
        CASE
            WHEN `Quantity Cases` > LAG(`Quantity Cases`) OVER (PARTITION BY `Material` ORDER BY `Posting Date`) THEN 'Increase'
            WHEN `Quantity Cases` < LAG(`Quantity Cases`) OVER (PARTITION BY `Material` ORDER BY `Posting Date`) THEN 'Decrease'
            ELSE 'Stable'
        END AS Trend
    FROM
        kbl_sales
)
SELECT
    `Material`,
    `Quantity Cases`,
    Prev_Quantity,
    Next_Quantity,
    Trend
FROM
    MaterialSalesTrends;  

-- Exxample 11: Find the total amount bought by each distributor daily in your KBL_SALES table    
SELECT DISTINCT
    `Posting Date`,
    `Distributor Name`,
    SUM(`Amount`) OVER (PARTITION BY `Distributor Name`, `Posting Date`) AS daily_total_amount
FROM
    KBL_SALES
ORDER BY
    `Posting Date`, `Distributor Name`;

-- _____________________________________________________ PREVENTING SQL INJECTION WITH PYTHON _____________________________________________
/*
Consider a simple SQL injection query used to retrieve product information based on user input for product_code,
SELECT * FROM products WHERE product_code = 'anything' OR '1'='1';
Python code for integer inputs:
# PREVENTING SQL INJECTION
        # Get user input for product_code
        product_code = int(input('Enter product code: '))

        # Validate input to ensure it's an integer
        if not isinstance(product_code, int):
            raise ValueError("Invalid input. Please enter a valid integer for product code.")

        # Use parameterized query
        query = "SELECT * FROM products WHERE product_code = %s" # %s a placeholder for the user input (product_code).
        cursor.execute(query, (product_code,))

        # Fetch the results
        results = cursor.fetchall()

        # Print the results
        print(f"_________________________ DATABASE DATA FOR {product_code} _____________________")
        for row in results:
            print(row)
Python code for string inputs:
# PREVENTING SQL INJECTION
        # Get user input for product_name. e.g Senator Keg DARK 50L
        product_name = input('Enter product name: ')


        # Use parameterized query
        query = "SELECT * FROM products WHERE product_name = %s"
        cursor.execute(query, (product_name,))  #  passes the actual value(a tuple with a single element) in a tuple as the second argument.

        # Fetch the results
        results = cursor.fetchall()

        # Print the results
        print(f"_________________________ DATABASE DATA FOR {product_name} _____________________")
        for row in results:
            print(row)
*/


-- _________________________________________________ MYSQL ADMINISTRATIVE BACKEND PROGRAMMING _______________________________________________
/* USER AND PRIVILEGE MANAGEMENT
Got to Connection->Manage connections to clear password(don't save to vault) field such that automatic login in is disabled, user needs password */
-- Check the current user:
SELECT CURRENT_USER; -- root@localhost if you are the admin
-- Show privileges for the admin(superuser)
SHOW GRANTS FOR 'root'@'localhost';
-- Show privileges for a user 'bond'
SHOW GRANTS FOR 'benayahu'@'localhost';
-- Drop user benayahu
DROP USER 'benayahu'@'localhost';
-- Change the password for 'bond'@'localhost'.Note: you can't see user password because they are stored as hashed values in the MySQL user table
SET PASSWORD FOR 'bond'@'localhost' = 'new_password';
-- Check all users and hosts
SELECT USER, HOST FROM MYSQL.USER;
-- To create a user, you can use the CREATE USER statement. Create a connection first
CREATE USER 'bond'@'localhost' IDENTIFIED BY 'Yahusha'; -- or use '%' for any host 
-- Grant access to the database
GRANT USAGE ON *.* TO 'bond'@'localhost'; -- The *.* indicates that the granted privileges apply to all databases (*) and all tables (*). 
-- To grant privileges on a specific database, e.g `kbl_sales`
GRANT ALL PRIVILEGES ON `kbl_sales`.* TO bond@Yahusha; -- may not be accepted in MySQL
-- Grant SELECT privilege to bond: After executing the GRANT statement, you should run the FLUSH PRIVILEGES; to apply the changes immediately:
GRANT SELECT ON agl_inventory.* TO 'bond'@'localhost'; -- To revoke: REVOKE SELECT ON agl_inventory.* FROM 'bond'@'localhost';
-- To revoke all privileges
REVOKE ALL PRIVILEGES ON database_name.* FROM 'username'@'localhost'; -- > Error. You need to list the privilege e.g REVOKE SELECT ON...
-- To change a user's password, you can use the SET PASSWORD statement:
SET PASSWORD FOR 'bond'@'localhost' = 'new_password';
-- Show privileges for a user 'bond'
SHOW GRANTS FOR 'bond'@'localhost'; -- > GRANT USAGE ON *.* TO `bond`@`localhost`, GRANT SELECT ON `agl_inventory`.* TO `bond`@`localhost`

/*BACKUP AND RESTORATION*/
-- MySQL Backup (SQL): Run the following SQL command in the MySQL shell. This exports the entire database to a SQL file
mysqldump -u username -p your_database > backup.sql
-- MySQL Restore (SQL): Run the following SQL command in the MySQL shell. This creates a new database and imports the data from the backup file
mysql -u username -p your_new_database < backup.sql
-- Python codes: Create a package with two functions as below
/*
import subprocess
import json


def backup_database(backup_file="agl_inventory_backup.sql"):  # file will be in current script directory
    try:
        with open(r'C:\Users\user\Desktop\DATA++\CLASS NOTES\Program files\mysql_credentials.json') as f:
            credentials = json.load(f)
    except FileNotFoundError:
        credentials = None
        print("Error: MySQL credentials file not found.")

    # Ensure your credentials were set up
    if credentials:
        try:
            user_input = input("Enter password for backup: ")
            username = credentials.get('username')
            password = credentials.get('password')
            database = credentials.get('database')

            if user_input == password:
                command = f"mysqldump -u {username} -p{password} {database} > {backup_file}"
                subprocess.run(command, shell=True)
            else:
                print('Wrong password')
                exit()

        except FileNotFoundError:
            print(f"The file with database credentials could not be loaded\nOR database error")


def restore_database(restoration_database="restored_agl_inventory"):
    try:
        with open(r'C:\Users\user\Desktop\DATA++\CLASS NOTES\Program files\mysql_credentials.json') as f:
            credentials = json.load(f)
    except FileNotFoundError:
        credentials = None
        print("Error: MySQL credentials file not found.")

    # Ensure your credentials were set up
    if credentials:
        try:
            user_input2 = input('Enter password for restoration: ')
            username = credentials.get('username')
            password = credentials.get('password')

            if user_input2 == password:
                command = f"mysql -u {username} -p{password} {restoration_database} < {'restored_agl_inventory.sql'}"
                subprocess.run(command, shell=True)
            else:
                print('Wrong password')
                exit()

        except FileNotFoundError:
            print(f"The file with database credentials could not be loaded\nOR database error")


"""
Example usage: To backup
from agl_inventory_backup import backup_database

backup_database()

Warning: mysqldump: [Warning] Using a password on the command line interface can be insecure. See getpass, os modules
"""

*/

-- ________________________________________________ MySQL THROUGH COMMAND-LINE INTERFACE(CLI) ______________________________________________
/*
    1. Open the Command-Line Interface (CLI):
        On Windows, you can use the Command Prompt or PowerShell. On Linux or macOS, you can use the terminal.
    2. Login to MySQL: mysql -u <username> -p Example: mysql -u root -p.Note: (-p) - prompts for the password, (-u) - specifies the username
    3. Switch to your database and make queries with SQL. mysql> USE `agl_inventory`;
    To modify a command that you've already typed, you can use the arrow keys to navigate to the part of the command you want to edit
    If you've made changes to the database that you don't want to keep, simply exit the CLI without issuing a COMMIT command. Use QUIT;
    Ctrl + C. This will interrupt the command and return you to the MySQL prompt. To use multiline query use Shift+Enter.
    Example:
    mysql> SELECT *
    -> FROM `products`
    -> WHERE `product_code` = 696894;
*/
-- Optimize product_code column with an sql index(CREATE INDEX idx_product_code ON products(product_code)), use the CLI before and 
-- after the optimization to check on the time taken to execute query. Before optimization with ; -- >1.05sec, after optimization --> 0.0sec

-- _________________________________________________________ MONITORING SERVER PERFORMANCE __________________________________________________
/*
Monitoring server performance with MySQL involves tracking various metrics related to the MySQL database 
to ensure it is running optimally. Here are some common methods:
*/
-- MySQL Performance Schema:
SELECT * FROM performance_schema.events_statements_current;
-- MySQL Slow Query Log: To enable the slow query log, add the following lines to your MySQL configuration file:
/*
slow_query_log = 1
slow_query_log_file = /path/to/slow-query.log
long_query_time = 1  # Time in seconds to consider a query as slow
*/
-- MySQL Workbench: server -> server status
-- Query to get the number of open connections
SHOW STATUS LIKE 'Threads_connected'; -- gives 3: The server is connected to Pycharm, Workbench and Command Prompt. See. SHOW STATUS;
-- To disconnect a specific connection from a MySQL server:
SHOW PROCESSLIST; -- Identify the Connection:
KILL [connection_id]; -- Terminate the Connection: e.g KILL 123;
SHOW PROCESSLIST; -- Verify the Disconnection:
-- find number of threads;
SELECT COUNT(*) FROM performance_schema.threads;
-- Query to get the number of open connections
SHOW STATUS LIKE 'Threads_connected';
-- Get maximum connections
SHOW VARIABLES LIKE 'max_connections';
-- To set the maximum allowed connections to 10 in MySQL. This change will not persist after a server restart.
/*
To make the change permanent, you should update the MySQL configuration file (my.cnf or my.ini). 
Open the configuration file in a text editor and add or modify the following line under the [mysqld] section:
max_connections = 10
*/
SET GLOBAL max_connections = 10; -- to change maximum number of allowed connections
-- find the threads connected
SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Threads_connected';
-- find the maximum connections
SELECT @@max_connections AS "Maximum_connections";
-- find the available connections
SELECT @@max_connections - 
(SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Threads_connected') 
AS "Available_connections";
-- check for stability, available threads should constitute at least 60% of maximum threads
SELECT 
    @@max_connections - (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Threads_connected') AS "Available_connections",
    CASE 
        WHEN @@max_connections - (SELECT VARIABLE_VALUE FROM performance_schema.global_status WHERE VARIABLE_NAME = 'Threads_connected') > 0.60 * @@max_connections THEN 'stable'
        ELSE 'unstable'
    END AS "Server_status";

-- ______________________________________________________ MYSQL DATABASE SECURITY MANAGEMENT _________________________________________________
/*
_____ GENERAL MEASURES ___________
Here are some key security measures you can implement in a MySQL database:													
Use Strong Authentication:													
	Use strong, unique passwords for MySQL user accounts.												
	Avoid using default usernames and passwords.												
	Consider using MySQL's native authentication method or integrate with an external authentication system.												
Limit Privileges:													
	Grant only the necessary privileges to database users. Be specific in granting privileges rather than using wildcards to avoid unintended access												
	Avoid using the root account for application connections.												
	Use the principle of least privilege to limit each user to the minimum necessary permissions.												
Encrypt Connections:													
	Enable SSL/TLS to encrypt data in transit between the MySQL server and clients.												
	Require SSL for user connections to ensure secure communication.												
Firewall Protection:													
	Use firewalls to restrict access to the MySQL server to trusted IP addresses.												
	Limit external access to specific ports (e.g., 3306 for MySQL) using firewall rules.												
Update MySQL Regularly:													
	Keep MySQL server software up-to-date to benefit from security patches.												
	Monitor MySQL community forums and security advisories for any vulnerabilities.												
Backup Data:													
	Regularly backup your MySQL databases to prevent data loss in case of a security incident.												
	Store backups in a secure location, and regularly test the restoration process.												
Audit Database Activity:													
	Enable MySQL's query logging and error logging to monitor database activity.												
	Regularly review logs to detect unusual or unauthorized access patterns.												
Implement Two-Factor Authentication (2FA):													
	If supported by your MySQL version, consider implementing two-factor authentication for increased user authentication security.												
Secure File Permissions:													
	Restrict file permissions on MySQL configuration files and binaries.												
	Ensure that only authorized users can access and modify MySQL-related files.												
Regularly Review User Accounts:													
	Regularly review and remove unnecessary user accounts.												
	Disable or remove accounts that are no longer needed.												
Implement Network Security Best Practices:													
	Segregate the MySQL server from other network segments.												
	Disable unnecessary network services on the MySQL server.												
Use Prepared Statements and Parameterized Queries:													
	Prevent SQL injection attacks by using prepared statements or parameterized queries in your application code.												
Monitoring and Intrusion Detection:													
	Implement monitoring tools to detect unusual activity or potential security threats.												
	Use intrusion detection systems to alert on suspicious behavior.												
Security Audits:													
	Perform regular security audits of your MySQL server.												
	Use tools like MySQL Enterprise Audit for more comprehensive auditing.												
Employ Third-Party Security Tools:													
	Consider using third-party security tools and services that specialize in database security.												
													
____ Generate SSL/TLS Certificates: _____

Create a Certificate Authority (CA) certificate and key.
Generate a server certificate and key signed by the CA.
Optionally, generate client certificates for individual clients.

Example commands to generate certificates using OpenSSL:
# Create CA certificate and key
openssl genpkey -algorithm RSA -out ca-key.pem
openssl req -new -x509 -key ca-key.pem -out ca-cert.pem

# Create server certificate and key
openssl req -newkey rsa:2048 -nodes -keyout server-key.pem -out server-req.pem
openssl x509 -req -in server-req.pem -days 365 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem

# Optionally, create client certificate and key
openssl req -newkey rsa:2048 -nodes -keyout client-key.pem -out client-req.pem
openssl x509 -req -in client-req.pem -days 365 -CA ca-cert.pem -CAkey ca-key.pem -set_serial 02 -out client-cert.pem

Configure MySQL Server:
Copy the generated server certificates and keys to a secure location on the MySQL server.
Edit the MySQL configuration file (e.g., my.cnf) to include the SSL/TLS settings.

Example configuration:
[mysqld]
ssl-ca=/path/to/ca-cert.pem
ssl-cert=/path/to/server-cert.pem
ssl-key=/path/to/server-key.pem

Restart MySQL Server:
Restart the MySQL server to apply the changes in the configuration.
sudo service mysql restart

Configure MySQL Clients:
For each MySQL client that connects to the server, configure the client to use SSL/TLS.
Provide the client with the CA certificate, client certificate, and client key.

Example connection using MySQL command-line client:
mysql --host=server_ip --user=user --password --ssl-ca=/path/to/ca-cert.pem --ssl-cert=/path/to/client-cert.pem --ssl-key=/path/to/client-key.pem
Verify SSL/TLS Connection:

Connect to the MySQL server using a client and ensure that the SSL/TLS connection is established.
mysql --host=server_ip --user=user --password --ssl-ca=/path/to/ca-cert.pem --ssl-cert=/path/to/client-cert.pem --ssl-key=/path/to/client-key.pem -e "SHOW STATUS LIKE 'Ssl_cipher';"

The output should indicate the SSL/TLS cipher used, confirming the encrypted connection.


*/

-- ________________________________________________________ MYSQL DATABASE REMOTE ACCESS ____________________________________________________
/*
To access your MySQL database from your work computer while the database is hosted on your home laptop, 
you'll need to make sure that the MySQL server on your home laptop is configured to accept remote 
connections and that any firewalls between your work computer and home laptop allow traffic on the MySQL port.

Here are the general steps you can follow:
On Your Home Laptop (Server Side):
Configure MySQL to Allow Remote Connections:

Open your MySQL configuration file (usually my.cnf or my.ini).
Set the bind-address to 0.0.0.0 or the IP address of your home laptop.
Example bind-address configuration:
[mysqld]
bind-address = 0.0.0.0

Create MySQL User for Remote Access:
Create a MySQL user account with privileges for remote access.
Grant the user access from your work computer's IP address or use '%' as a wildcard for any IP.

Example:
CREATE USER 'remote_user'@'your_work_computer_ip' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'remote_user'@'your_work_computer_ip' WITH GRANT OPTION;
FLUSH PRIVILEGES;
Replace your_work_computer_ip, remote_user, and password with your actual work computer's IP, desired username, and password.

Open MySQL Port in Firewall:
If you have a firewall on your home laptop, open the MySQL port (default is 3306) to allow incoming connections.

On Your Work Computer (Client Side):
MySQL Client Connection:
Use a MySQL client on your work computer to connect to your home laptop's MySQL server.
mysql --host=your_home_laptop_ip --user=remote_user --password
Replace your_home_laptop_ip and remote_user with your home laptop's IP and the MySQL user created for remote access.

Firewall Settings:
Ensure that any firewalls on your work computer allow outgoing connections on the MySQL port (default is 3306).

Additional Considerations:
Security Measures:
Implement SSL/TLS for encrypted connections, especially if accessing the database over the internet.
Use strong, unique passwords for MySQL users.
Regularly review and update user privileges to follow the principle of least privilege.

Dynamic DNS (Optional):
If your home IP address changes frequently, consider using Dynamic DNS (DDNS) to map a hostname to your home's dynamic IP.

Router Port Forwarding (Optional):
If you are connecting from outside your home network, you might need to set up port forwarding on your home router 
to forward external traffic on the MySQL port to your laptop.

Please note that allowing remote connections to your database introduces security risks, 
and it's crucial to take appropriate measures to secure your MySQL server. Always be mindful of the 
potential security implications when configuring remote access.
*/

-- __________________________________________________ DATABASE VERSION CONTROL ____________________________________________________________
/*
Database version control is a practice that involves managing and tracking changes to a database schema 
and its associated objects (tables, views, procedures, etc.) over time. It helps developers collaborate, 
maintain a history of changes, and deploy updates consistently. Here are some common practices and tools 
for implementing database version control:

1. Scripted Migrations:
Use scripts to represent changes to the database schema. Each script should contain a set of SQL statements 
that either modify the schema or data.
Example migration script (V1_0_0__CreateTable.sql):
-- Version 1.0.0
CREATE TABLE users (
    id INT PRIMARY KEY,
    username VARCHAR(255) NOT NULL
);

2. Versioning:
Assign a version number to each set of migration scripts. This version number helps track the state 
of the database schema.
Example versioning scheme: V1_0_0, V1_0_1, ...

3. Schema Management Tools:
Use schema management tools or migration frameworks to automate the process of applying migration 
scripts and managing the version history.
Flyway: A database migration tool that brings version control to your database. It's easy to use, supports 
multiple databases, and integrates well with different development environments.
Liquibase: An open-source database-independent library for tracking, managing, and applying database schema changes.

4. Source Control Integration:
Store your migration scripts in a version control system (e.g., Git). This allows you to track changes, 
collaborate with a team, and roll back to previous versions if needed.

5. Continuous Integration (CI):
Integrate database version control into your CI/CD pipeline. Run automated tests against different 
versions of the database to catch issues early.

6. Documentation:
Document each migration script with information about what changes it introduces, any potential data migration 
steps, and the reason for the change.

7. Backups:
Before applying a migration in a production environment, ensure that you have a reliable backup mechanism in place. 
This helps recover the database in case of issues during the migration process.

8. Rollback Scripts:
Include rollback scripts for each migration, allowing you to revert changes in case of unexpected issues.

9. Database Snapshots:
Periodically take snapshots of the database to capture its state at a specific point in time. 
This can be useful for auditing and troubleshooting.
*/

-- ___________________________________________________________ END _________________________________________________________________________

-- __________________________________________________________ TAKE-AWAYS ____________________________________________________________________
-- update missing recharge prices per case with data from temp_recharge_prices table
UPDATE `recharge_prices`
SET `recharge_per_case` = (
    SELECT `Recharge Price / Case`
    FROM `temp_recharge_prices`
    WHERE `temp_recharge_prices`.`SKU` = `recharge_prices`.`product_code`
)
WHERE `recharge_per_case` = 0.0000;
-- return all records of the table products ordered by the last word of the export product_name e.g Local, Export, Defco in ascending order
SELECT `product_name`, `product_code`, `product_bpc`
FROM (
	SELECT * 
FROM `products`
WHERE `product_name` LIKE "%Export"
ORDER BY UPPER(SUBSTRING_INDEX(`product_name`, " ", -1)) ASC
) AS subquery
ORDER BY `product_name` ASC
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/new_agl_export_products.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' -- if you may have fields like "001","Product One"
LINES TERMINATED BY '\n' -- Use \n for line endings
;

-- Delete records with `action` "new product I don't have code" OR `action` 'Missing Code'
DELETE FROM `products`
WHERE `action` LIKE "new product I don't have code" OR `action` LIKE 'Missing Code';

-- Get the leading cause of warehouse breakages
SELECT `cause_of_breakage`, SUM(`breakages_quantity_btls`) AS `Total_breakages_btls`, SUM(`cost_of_breakage`) AS `Total_breakages_cost`
FROM `2023_2024_breakages`
GROUP BY `cause_of_breakage`
ORDER BY SUM(`cost_of_breakage`) DESC;
-- Get a summary of inventory performance for 2023
SELECT * FROM `2023_performance`;
-- Find the distributor that made the most purchase from KBL in December 2023
SELECT `Distributor Name`, SUM(`Amount`) AS "Total_Purchase(kshs)"
FROM `kbl_sales`
GROUP BY `Distributor Name`
ORDER BY SUM(`Amount`) DESC;
-- Find all canned export products
SELECT `product_name` FROM `products` 
WHERE `product_name` LIKE "%Export" AND `product_name` LIKE "%CAN%"
ORDER BY `product_name`;
-- Find the BOM of the product 730510
CALL GetBOM(730510);


