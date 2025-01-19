-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging_2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging_2;

SELECT *
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

SELECT company, SUM(total_laid_off) # Layoffs by Company
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging_2;

SELECT industry, SUM(total_laid_off) # Layoffs by Industry
FROM layoffs_staging_2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off) # Layoffs by Country
FROM layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off) # Layoffs by Year
FROM layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC; 

SELECT stage, SUM(total_laid_off) # Layoffs by Stage
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC; 

SELECT company, SUM(total_laid_off) # Layoffs by Company
FROM layoffs_staging_2
GROUP BY company
ORDER BY 2 DESC;

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging_2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH rolling_total AS 
(
SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging_2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, 
SUM(total_off) OVER(ORDER BY `MONTH`)
FROM rolling_total;

SELECT company, YEAR(`date`), SUM(total_laid_off) # Layoffs by Company and Year
FROM layoffs_staging_2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off) # Layoffs by Company and Year
FROM layoffs_staging_2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM Company_Year
WHERE years IS NOT NULL
# ORDER BY ranking
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;


