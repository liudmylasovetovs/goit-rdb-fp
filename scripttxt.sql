CREATE database pandemic;

USE pandemic;


CREATE TABLE entities (
                          id INT AUTO_INCREMENT PRIMARY KEY,
                          entity_name VARCHAR(255) NOT NULL,
                          entity_code VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE infectious_data (
                                 id INT AUTO_INCREMENT PRIMARY KEY,
                                 entity_id INT NOT NULL,
                                 year INT NOT NULL,
                                 number_rabies INT,
                                 number_malaria INT,
                                 FOREIGN KEY (entity_id) REFERENCES entities(id)
);
INSERT INTO entities (entity_name, entity_code)
SELECT DISTINCT Entity, Code
FROM infectious_cases;

INSERT INTO infectious_data (entity_id, year, number_rabies, number_malaria)
SELECT entities.id, infectious_cases.Year,
       NULLIF(infectious_cases.Number_rabies, '') AS number_rabies,
       NULLIF(infectious_cases.Number_malaria, '') AS number_malaria
FROM infectious_cases
         JOIN entities
              ON infectious_cases.Entity = entities.entity_name AND infectious_cases.Code = entities.entity_code;

SELECT * FROM entities LIMIT 10;

SELECT * FROM infectious_data LIMIT 100;

SELECT
    entity_name,
    entity_code,
    AVG(number_rabies) AS average_rabies,
    MIN(number_rabies) AS min_rabies,
    MAX(number_rabies) AS max_rabies,
    SUM(number_rabies) AS sum_rabies
FROM
    infectious_data
        JOIN
    entities
    ON
        infectious_data.entity_id = entities.id
WHERE
    infectious_data.number_rabies IS NOT NULL
GROUP BY
    entities.entity_name, entities.entity_code
ORDER BY
    average_rabies DESC
    LIMIT 10;

SELECT * 
FROM infectious_data 
WHERE number_rabies IS NOT NULL 
LIMIT 10;

ALTER TABLE infectious_data
    ADD COLUMN start_of_year DATE;

SET SQL_SAFE_UPDATES = 0;
UPDATE infectious_data
SET start_of_year = STR_TO_DATE(CONCAT(year, '-01-01'), '%Y-%m-%d')
WHERE year IS NOT NULL;

SELECT year, start_of_year 
FROM infectious_data 
LIMIT 10;

ALTER TABLE infectious_data
    ADD COLUMN `current_date` DATE;
    
UPDATE infectious_data
SET `current_date` = CURDATE();

SELECT year, `current_date`
FROM infectious_data
LIMIT 10;

ALTER TABLE infectious_data
    ADD COLUMN year_difference INT;
    
UPDATE infectious_data
SET year_difference = TIMESTAMPDIFF(YEAR, STR_TO_DATE(CONCAT(year, '-01-01'), '%Y-%m-%d'), CURDATE())
WHERE year IS NOT NULL;

SELECT year, start_of_year, `current_date`, year_difference
FROM infectious_data 
LIMIT 10;

DELIMITER $$

CREATE FUNCTION calc_year_diff(input_year INT)
    RETURNS INT
    DETERMINISTIC
BEGIN
RETURN TIMESTAMPDIFF(YEAR, STR_TO_DATE(CONCAT(input_year, '-01-01'), '%Y-%m-%d'), CURDATE());
END$$

DELIMITER ;


SELECT year, calc_year_diff(year) AS year_diff
FROM infectious_data
WHERE year IS NOT NULL;