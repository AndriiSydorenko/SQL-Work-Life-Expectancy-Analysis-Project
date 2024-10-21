# World Life Expectancy Project (Data Cleaning)

SELECT * 
FROM world_life_expectancy;

# 1.Find and delete duplicates from the Country column

#Identifyning duplicates
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1
;

# Identifyning Row_ID where duplicates are

SELECT *
FROM ( 
	SELECT Row_ID,
	CONCAT(Country, Year),
    ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
    FROM world_life_expectancy
    ) AS Row_Table
WHERE Row_Num > 1
;

# Delete duplicates from the table

DELETE FROM world_life_expectancy
WHERE 
	Row_ID IN (
    SELECT Row_ID
FROM (
	SELECT Row_ID,
	CONCAT(Country, Year),
    ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
    FROM world_life_expectancy
    ) AS Row_Table
WHERE Row_Num > 1
)
;

# 2.Check quantity of blank flieds in Status column

SELECT * 
FROM world_life_expectancy
WHERE Status = ''
;

# Check what kind of satus can be in Status column
SELECT DISTINCT(Status) 
FROM world_life_expectancy
WHERE Status <> ''
;

# Fill all the blanks where Country is DELEVOPING with DEVELOPING Status

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
  ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;

# We can see the Country: USA is not affected, bacause it is DEVELOPED country

SELECT*
FROM world_life_expectancy
WHERE Country = 'United States of America'
;
# Using the same logic do it for DEVELOPED Country

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
  ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

# Check if every changes what we have done applied correctly
SELECT *
FROM world_life_expectancy
WHERE Status = ''
;

# 3. Identifying blanks in Life expectancy column
SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
;

# Let's fill the blanks in Life expectancy with average between next and previous years

SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
    AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
    AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;

SELECT *
FROM world_life_expectancy
;

# Exloratory Data Analysis

# Explore increase of Life expectancy in different Coutries

SELECT Country, MIN(`Life expectancy`), MAX(`Life expectancy`),
ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years DESC
;

# Average increae in life expectancy thoughout years 

SELECT Year, ROUND(AVG(`Life expectancy`),2)
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year 
ORDER BY Year DESC
;

# Let's take a look at the GDP in different countries

SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(GDP),1) AS GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND GDP > 0
ORDER BY GDP ASC
;

# High GDP countries vs low GDP contries

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life expectancy` ELSE NULL END) Low_GDP_Life_Expectancy
FROM world_life_expectancy
;

# Life expectancy by Status

SELECT Status, ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;

# Amount of countries by Status and their life expectancy

SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life expectancy`),1)
FROM world_life_expectancy
GROUP BY Status
;
# BMI for coutry and life expectancy

SELECT Country, ROUND(AVG(`Life expectancy`),1) AS Life_Exp, ROUND(AVG(BMI),1) AS BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Life_Exp > 0
AND BMI > 0
ORDER BY BMI DESC
;

# Adult mortality

SELECT Country,
Year,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy
;
