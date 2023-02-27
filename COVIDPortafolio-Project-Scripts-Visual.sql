SELECT * FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

/*SELECT * FROM covidvaccinations
ORDER BY 3,4;*/

-- Seelct Data to be use
SELECT location, date, total_cases, new_cases, 
total_deaths, population  
FROM coviddeaths
ORDER BY 1,2;

-- Looking Total Cases Vs Total Deaths
SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 AS deathpercentage
FROM coviddeaths
ORDER BY 1,2;

-- Looking Total cases Vs Population
-- Porcentage Population that got Covid 
SELECT location, date, population, total_cases, 
(total_cases/population)*100.0 AS casespercentage
FROM coviddeaths
ORDER BY 1,2;

--Countries with Highest Infection Rates Vs Population
SELECT location, population, MAX(total_cases)AS highesinfectioncont, 
MAX((total_cases/population))*100.0 AS percentpopulationinfected
FROM coviddeaths
GROUP BY population, location
ORDER BY percentpopulationinfected DESC;

-- Countries with Highest Death Count Vs Populaition
SELECT location, MAX(total_deaths)AS totaldeathcount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY totaldeathcount DESC;

--Break by Continent
SELECT continent, MAX(total_deaths)AS totaldeathcount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC;

--Continents with Highes Death Count Per Population
SELECT continent, MAX(total_deaths)AS totaldeathcount
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY totaldeathcount DESC;

--Global numbers
SELECT location, date, total_cases, total_deaths,
SUM (CAST (total_deaths AS NUMERIC)) / 
	 SUM (CAST (total_cases AS NUMERIC))*100 AS DeathPercentage
FROM coviddeaths
WHERE continent IS NOT NULL
GROUP BY location, date, total_cases, total_deaths
ORDER BY 1,2;

SELECT SUM(new_cases) AS total_cases, SUM (new_deaths)AS total_deaths,
SUM (CAST (new_deaths AS NUMERIC))/ SUM (CAST (new_cases AS NUMERIC))* 100 AS deathpercentage
FROM coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Total Population Vs Vaccinations
SELECT dea.continent, dea.location, dea.population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS rollingpeoplevaccinated,
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--Use CTE
WITH popvsvac (continent, location, date, population, 
			   new_vaccinations,rollingpeoplevaccinated)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS rollingpeoplevaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rollingpeoplevaccinated/population)* 100
FROM popvsvac;

-- TempTable

DROP TABLE IF EXISTS percenpopulationvaccinated
CREATE TEMPORARY TABLE percenpopulationvaccinated (
continent VARCHAR(255),
location VARCHAR (255),
date TIMESTAMP,
population NUMERIC,
new_vaccinations NUMERIC,
rollinpeoplevaccinated NUMERIC
);

INSERT INTO percenpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS rollingpeoplevaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3


/*SELECT *, (rollingpeoplevaccinated/population)* 100
FROM percenpopulationvaccinated;*/

--Creating View (store data for visualiztion)

CREATE VIEW percenpopulationvaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM (vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS rollingpeoplevaccinated
FROM coviddeaths AS dea
JOIN covidvaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3

SELECT *
FROM percenpopulationvaccinated;