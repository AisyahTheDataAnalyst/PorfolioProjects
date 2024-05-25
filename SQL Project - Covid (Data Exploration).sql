--- MSSQL Project Data Exploration - Covid Deaths and Vaccinations
--- 85171 data
---https://ourworldindata.org/covid-deaths
--- worldwide, 28/1/2020 - 3-/4/2021

-- Overview
-- We want location=countries only, not location=continents
SELECT *
FROM CovidDeaths 
WHERE continent IS NOT NULL 
ORDER BY 3,4

SELECT *
FROM CovidVaccinations
WHERE continent IS NOT NULL 
ORDER BY 3,4

-- Select data that were going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Looking at total cases vs total deaths vs percentage total cases over total death
-- Shows the likelihood of dying if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Looking at the Total Cases VS Population 
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, total_deaths, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with the highest death count per Population
-- total death was originally nvarchar --> int
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC



--------- LET'S BREAK THINGS DOWN BY CONTINENT ----------------------

-- Showing the continent with the highest death count
-- total death was originally nvarchar --> int

----INCORRECT NUMBERS
--SELECT continent, MAX(cast(total_deaths as int)) AS ContinentsTotalDeathCount
--FROM CovidDeaths
--WHERE continent IS NOT NULL 
--GROUP BY continent
--ORDER BY ContinentsTotalDeathCount DESC

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC



-- GLOBAL NUMBERS 
-- looking at numbers as a whole, worldwide, so location/continent is not needed
-- total death was originally nvarchar --> int

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2



-- Looking at Total Population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

---------------- CAN USE EITHER USE CTE OR TEMPTABLE
-- CTE 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
AS
( 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac




-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar (225),
Location nvarcHar (225),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated




-- CREATING VIEW TO STORE DATA FPR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3



SELECT * 
FROM PercentPopulationVaccinated
