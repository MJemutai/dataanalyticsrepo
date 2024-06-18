-- CLEANING DATA
SELECT * FROM data_employees;

-- create a copy of the original table
CREATE TABLE data_employees_staging
LIKE data_employees;

INSERT INTO data_employees_staging
SELECT *
FROM data_employees;

SELECT * FROM data_employees_staging;

-- remove duplicates
-- number the rows
SELECT *,
row_number() OVER(
PARTITION BY `Current Role`, Level,`Employer industry`, Gender,`Main techstack`, `Monthly gross salary`) AS Row_Num
FROM data_employees_staging;

-- identify where row num is greater than 1, using cte
WITH duplicate_cte AS
(
SELECT *,
row_number() OVER(
PARTITION BY `Current Role`, Level,`Employer industry`, Gender,`Main techstack`, `Monthly gross salary`) AS Row_Num
FROM data_employees_staging
)
SELECT *
FROM duplicate_cte
WHERE Row_Num > 1;

-- copy data to new table to delete the duplicates
CREATE TABLE `data_employees_staging2` (
  `Timestamp` text,
  `Current Role` text,
  `Other Role` text,
  `Level` text,
  `Years of experience` text,
  `Employer industry` text,
  `Gender` text,
  `Main techstack` text,
  `Other techstack` text,
  `Monthly gross salary` text,
  `Benefits` text,
  `Work setup` text,
  `Employer Type` text,
  `Row_Num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM data_employees_staging2;

INSERT INTO data_employees_staging2
SELECT *,
row_number() OVER(
PARTITION BY `Current Role`, Level,`Employer industry`, Gender,`Main techstack`, `Monthly gross salary`) AS Row_Num
FROM data_employees_staging;

SELECT * FROM data_employees_staging2
WHERE Row_Num > 1;

DELETE
FROM data_employees_staging2
WHERE Row_Num > 1;

SELECT * FROM data_employees_staging2;

-- STANDARDIZING DATA
 -- Perform TRIM function if necessary
 SELECT `Employer industry`, TRIM(`Employer industry`)
 FROM data_employees_staging2;
 
 UPDATE data_employees_staging2
 SET `Employer industry` = TRIM(`Employer industry`);
  
 SELECT distinct(`Employer industry`)
 FROM data_employees_staging2
 ORDER BY 1;
 
 UPDATE data_employees_staging2
 SET `Employer industry` = 'Banking'
 WHERE `Employer industry` = 'Bank' ;
 
UPDATE data_employees_staging2
SET `Employer industry` = 'Consultancy'
WHERE `Employer industry` LIKE 'Consult%';

UPDATE data_employees_staging2
SET `Employer industry` = 'Finance'
WHERE `Employer industry` LIKE 'Finance%';

UPDATE data_employees_staging2
SET `Employer industry` = 'Finance'
WHERE `Employer industry` LIKE 'Financial%';

UPDATE data_employees_staging2
SET `Employer industry` = 'Fintech'
WHERE `Employer industry` LIKE 'Fintech%';

UPDATE data_employees_staging2
SET `Employer industry` = 'Fintech'
WHERE `Employer industry` LIKE 'Finetech%';

UPDATE data_employees_staging2
SET `Employer industry` = 'FMCG'
WHERE `Employer industry` LIKE 'FMCG%';

UPDATE data_employees_staging2
SET `Employer industry` = 'FMCG'
WHERE `Employer industry` LIKE 'Fast Moving%';

UPDATE data_employees_staging2
SET `Employer industry` = 'Government'
WHERE `Employer industry` LIKE 'Government%';

UPDATE data_employees_staging2
SET `Employer industry` = 'Health'
WHERE `Employer industry` LIKE 'Heal%';

UPDATE data_employees_staging2
SET `Employer industry` = 'Insurance'
WHERE `Employer industry` LIKE 'Insurance%';

UPDATE data_employees_staging2
SET `Employer industry` = 'Manufacturing'
WHERE `Employer industry` LIKE 'Manufacturing%';

UPDATE data_employees_staging2
SET `Employer industry` = 'Marketing'
WHERE `Employer industry` LIKE 'Market%';

UPDATE data_employees_staging2
SET `Employer industry` = 'NGO'
WHERE `Employer industry` LIKE 'Non Profit%';

UPDATE data_employees_staging2
SET `Employer industry` = 'NGO'
WHERE `Employer industry` LIKE 'Non-Profit%';

UPDATE data_employees_staging2
SET `Employer industry` = 'Telecommunications'
WHERE `Employer industry` LIKE 'Telco%';

UPDATE data_employees_staging2
SET `Employer industry` = 'Transportation'
WHERE `Employer industry` LIKE 'Transport%';

 SELECT *
 FROM data_employees_staging2;
 
 SELECT distinct(`Gender`)
 FROM data_employees_staging2
 ORDER BY 1;
 
 SELECT * FROM data_employees_staging2;
 
 -- change data types where necessary
 SELECT `Monthly gross salary`
 FROM data_employees_staging2;
 
 SELECT `Monthly gross salary`, TRIM(`Monthly gross salary`)
 FROM data_employees_staging2;
 
 UPDATE data_employees_staging2
 SET `Monthly gross salary` = TRIM(`Monthly gross salary`);
 
UPDATE data_employees_staging2
SET `Monthly gross salary`= '0'
WHERE `Monthly gross salary` LIKE '%N%';

SELECT `Monthly gross salary`, trim(TRAILING 'KES' FROM `Monthly gross salary`)
FROM data_employees_staging2;

UPDATE data_employees_staging2
SET `Monthly gross salary`= trim(TRAILING 'KES' FROM `Monthly gross salary`)
WHERE `Monthly gross salary` LIKE '%KES%';

SELECT `Monthly gross salary`, trim(TRAILING 'EURO%' FROM `Monthly gross salary`)
FROM data_employees_staging2;

UPDATE data_employees_staging2
SET `Monthly gross salary`= trim(TRAILING 'EURO%' FROM `Monthly gross salary`)
WHERE `Monthly gross salary` LIKE '%EURO%';

SELECT `Monthly gross salary`, trim(TRAILING '/-' FROM `Monthly gross salary`)
FROM data_employees_staging2;

UPDATE data_employees_staging2
SET `Monthly gross salary`= trim(TRAILING '/-' FROM `Monthly gross salary`)
WHERE `Monthly gross salary` LIKE '%/-';

UPDATE data_employees_staging2
SET `Monthly gross salary`= '60000'
WHERE `Monthly gross salary` LIKE '%ksh%';

UPDATE data_employees_staging2
SET `Monthly gross salary`= '126990'
WHERE `Monthly gross salary` LIKE '920 EUROS';

UPDATE data_employees_staging2
SET `Monthly gross salary`= '64250'
WHERE `Monthly gross salary` LIKE '500$';

UPDATE data_employees_staging2
SET `Monthly gross salary`= '35728'
WHERE `Monthly gross salary` LIKE '35728.3';


SELECT `Monthly gross salary`
FROM data_employees_staging2;
 
SELECT `Monthly gross salary`, replace(`Monthly gross salary`,',','')
FROM data_employees_staging2;

UPDATE data_employees_staging2
SET `Monthly gross salary`= replace(`Monthly gross salary`,',','');
 
 SELECT cast(`Monthly gross salary` AS unsigned)
 FROM data_employees_staging2;
 
 UPDATE data_employees_staging2
 SET `Monthly gross salary` = cast(`Monthly gross salary` AS unsigned);
 
 -- change to INT column
 ALTER TABLE data_employees_staging2
 MODIFY COLUMN `Monthly gross salary` INT;
 
 -- Remove NULL AND BLANKS where necessary
SELECT * FROM data_employees_staging2;

-- drop the rownum column
ALTER TABLE data_employees_staging2
DROP COLUMN Row_Num;

-- Exploring Data
SELECT * FROM data_employees_staging2;

-- Total count of participants
SELECT COUNT(Gender)
FROM data_employees_staging2;

-- participation by gender
SELECT DISTINCT(Gender), COUNT(Gender)
FROM data_employees_staging2
GROUP BY Gender;

-- data roles, employer type, industry, work setup
SELECT DISTINCT(`Current Role`)
FROM data_employees_staging2;

SELECT DISTINCT(`Employer Type`)
FROM data_employees_staging2;

SELECT DISTINCT(`Employer industry`)
FROM data_employees_staging2;

SELECT DISTINCT(`Work setup`)
FROM data_employees_staging2;

-- Job Level distribution
SELECT DISTINCT(`Level`), COUNT(`Level`)
FROM data_employees_staging2
GROUP BY `Level`;

-- Work setup distribution
SELECT DISTINCT(`Work setup`),COUNT(`Work setup`)
FROM data_employees_staging2
GROUP BY `Work setup`;

-- TOP 10 EMPLOYER INDUSTRIES
SELECT DISTINCT(`Employer industry`),COUNT(`Employer industry`) AS Total_Employees
FROM data_employees_staging2
GROUP BY  `Employer industry`
ORDER BY Total_Employees DESC
LIMIT 10;

-- TOP 5 WORK BENEFITS A DATA PROFESSIONAL GETS
SELECT Benefits
FROM data_employees_staging2
GROUP BY Benefits
ORDER BY count(Benefits) DESC
LIMIT 5;

-- TOP 10 TECH STACK COMMON AMONG DATA PROFESSIONALS
SELECT distinct(`Main techstack`)
FROM data_employees_staging2
GROUP BY (`Main techstack`)
ORDER BY count(`Main techstack`) DESC
LIMIT 10;

-- SALARY/COMPENSATION ANALYSIS
SELECT *
FROM data_employees_staging2;

-- Average Gross Salary
SELECT AVG(`Monthly gross salary`) AS Avg_Monthly_Gross_Salary
FROM data_employees_staging2;

-- Average gross salary by gender
SELECT AVG(`Monthly gross salary`) AS Female_Avg_Monthly_Gross_Salary
FROM data_employees_staging2
WHERE Gender = 'Female';

SELECT AVG(`Monthly gross salary`) AS Male_Avg_Monthly_Gross_Salary
FROM data_employees_staging2
WHERE Gender = 'Male';

-- Average salary by data role
SELECT `Current Role`, AVG(`Monthly gross salary`) AS Avg_Monthly_Gross_Salary
FROM data_employees_staging2
GROUP BY `Current Role`
ORDER BY Avg_Monthly_Gross_Salary DESC;

-- Average salary by work setup
SELECT `Work setup`, AVG(`Monthly gross salary`) AS Avg_Monthly_Gross_Salary
FROM data_employees_staging2
GROUP BY `Work setup`
ORDER BY Avg_Monthly_Gross_Salary DESC;

-- Average salary by years of experience
SELECT `Years of experience`, AVG(`Monthly gross salary`) AS Avg_Monthly_Gross_Salary
FROM data_employees_staging2
GROUP BY `Years of experience`
ORDER BY Avg_Monthly_Gross_Salary;

 
 



