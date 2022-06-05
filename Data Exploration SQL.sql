

-- Check the data just imported:

SELECT *
FROM [Covid Project]..Covid_Deaths
ORDER BY location, date

SELECT *
FROM [Covid Project]..Covid_Vaccinations
ORDER BY location, date

SELECT *
FROM [Covid Project]..Covid_Deaths
WHERE continent IS NOT NULL -- making sure the grouped data (e.g. World, Asia, etc. ) does not show in our chart or present in calculations
ORDER BY location, date

SELECT *
FROM [Covid Project]..Covid_Vaccinations
WHERE continent IS NOT NULL
ORDER BY location, date

 

-- Select data we will use: 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Covid Project]..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY location, date


-- death_rates: (shows the likelihood of dying if infect covid)

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_rates
FROM [Covid Project]..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- death_rates in Canada: 

SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_rates
FROM [Covid Project]..Covid_Deaths
WHERE continent IS NOT NULL AND location = 'Canada'
ORDER BY location, date


-- infection_rates:  (shows the likelihood of getting infected)

SELECT location, date, total_cases, population, (total_cases / population) * 100 AS infection_rates
FROM [Covid Project]..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- infection_rates in Canada: 

SELECT location, date, total_cases, population, (total_cases / population) * 100 AS infection_rates
FROM [Covid Project]..Covid_Deaths
WHERE continent IS NOT NULL AND location = 'Canada'
ORDER BY location, date


-- Find Countries with highest infection_rate

SELECT location, MAX(total_cases) AS max_total_cases, population, (MAX(total_cases) / population) * 100 AS infection_rate
FROM [Covid Project]..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY infection_rate DESC


-- Find Countries with highest deaths in population

SELECT location, MAX(CAST(total_deaths AS INT)) AS max_total_deaths
FROM [Covid Project]..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY max_total_deaths DESC


-- Find grouped locations with highest deaths in population

SELECT location, MAX(CAST(total_deaths AS INT)) AS max_total_deaths
FROM [Covid Project]..Covid_Deaths
WHERE continent IS NULL AND location NOT LIKE '%income' -- excluding income groups (which is included in location column originally)
GROUP BY location
ORDER BY max_total_deaths DESC




-- BREAK DOWN BY CONTINENTS



-- Find continents wiht hightest deaths in population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS max_total_deaths
FROM [Covid Project]..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY max_total_deaths DESC




-- GLOBAL NUMBERS


-- Global death_rates by time

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS death_rates
FROM [Covid Project]..Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date


-- Global total_death_rate

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases)) * 100 AS death_rates
FROM [Covid Project]..Covid_Deaths
WHERE continent IS NOT NULL




-- Total population vs New Vaccination: 

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS rolling_total_vaccinations
FROM [Covid Project]..Covid_Deaths AS dea
JOIN [Covid Project]..Covid_Vaccinations AS vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3



-- Use CTE (vaccination_rates)

WITH Pop_vs_Vac (continent, location, date, population, new_vaccinations, rolling_total_vaccinations)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
FROM [Covid Project]..Covid_Deaths AS dea
JOIN [Covid Project]..Covid_Vaccinations AS vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_total_vaccinations/population) * 100 AS vaccination_rates
FROM Pop_vs_Vac



-- Temp Table

DROP TABLE IF EXISTS #Vaccination_Rates
CREATE TABLE #Vaccination_Rates (continent NVARCHAR(255),
				 location NVARCHAR(255),
				 date DATETIME,
				 population NUMERIC,
				 new_vaccinations NUMERIC,
				 rolling_total_vaccinations NUMERIC)


INSERT INTO #Vaccination_Rates
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
FROM [Covid Project]..Covid_Deaths AS dea
JOIN [Covid Project]..Covid_Vaccinations AS vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (rolling_total_vaccinations/population)*100 AS vaccination_rates
FROM #Vaccination_Rates



-- View

CREATE VIEW Vaccination_Rates_View AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS total_vaccinations
FROM [Covid Project]..Covid_Deaths AS dea
JOIN [Covid Project]..Covid_Vaccinations AS vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *
FROM Vaccination_Rates_View
