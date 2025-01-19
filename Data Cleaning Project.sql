-- Data Cleaning

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardise Data
-- 3. Deal with null Values or blank values
-- 4. Remove any Irrelevant Columns

CREATE TABLE layoffs_staging # Copying data from raw table to staging table
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

-- 1. Removing Duplicates

WITH duplicates_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicates_cte 
WHERE row_num > 1;



CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging_2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location,
industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging_2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging_2;

-- 2. Standardise Data

SELECT company, TRIM(company)
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY 1;

SELECT *
FROM layoffs_staging_2
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging_2
SET industy = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging_2
ORDER BY 1;

UPDATE layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

UPDATE layoffs_staging_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE;

-- 3. Deal with null Values or blank values

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULl
AND percentage_laid_off IS NULL;

SELECT DISTINCT industry
FROM layoffs_staging_2
WHERE industry IS NULL;

SELECT *
FROM layoffs_staging_2
WHERE industry IS NULL
OR industry = '';

UPDATE layoffs_staging_2
SET industry = NULL
WHERE industry = '';

SELECT *
FROM layoffs_staging_2
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging_2 AS t1
JOIN layoffs_staging_2 AS t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging_2 as t1
JOIN layoffs_staging_2 AS t2
	ON t1.company = t2.company
SET t1.industry = t2.industry # t1 industry is the blank one
WHERE (t1.industry IS NULL)
AND t2.industry IS NOT NULL;

-- 4. Remove any Irrelevant Columns

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging_2
DROP COLUMN row_num;
