SELECT *
FROM PortfolioProject ..covidDeaths$
where continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject ..covidVaccinations$
--ORDER BY 3,4

--Select Data that we will be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject ..covidDeaths$
where continent is not null
order by 1,2

--looking at total cases vs total deaths



select location, date, total_cases, total_deaths,
    CASE 
        WHEN ISNUMERIC(total_deaths) = 1 AND ISNUMERIC(total_cases) = 1 AND CAST(total_cases AS FLOAT) <> 0
            THEN CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)
        ELSE NULL
    END AS death_rate
	
FROM PortfolioProject ..covidDeaths$
where continent is not null


select location, date, total_cases, total_deaths,
    CASE 
        WHEN ISNUMERIC(total_deaths) = 1 AND ISNUMERIC(total_cases) = 1 AND CAST(total_cases AS FLOAT) <> 0
            THEN (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100
        ELSE NULL
    END AS death_rate_percentage
FROM PortfolioProject ..covidDeaths$
where continent is not null

----code for both the death_rate and death_rate percentage
----select location, date, total_cases, total_deaths, 
----    CASE 
----        WHEN ISNUMERIC(total_deaths) = 1 AND ISNUMERIC(total_cases) = 1 AND CAST(total_cases AS FLOAT) <> 0
----            THEN CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)
----        ELSE NULL
----    END AS death_rate,
----    CASE 
----        WHEN ISNUMERIC(total_deaths) = 1 AND ISNUMERIC(total_cases) = 1 AND CAST(total_cases AS FLOAT) <> 0
----            THEN (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100
----        ELSE NULL
----    END AS death_rate_percentage
----FROM PortfolioProject ..covidDeaths$

--data from specific countries
--shows likelihood of one dying in the affected country
select location, date, total_cases, total_deaths,
    CASE 
        WHEN ISNUMERIC(total_deaths) = 1 AND ISNUMERIC(total_cases) = 1 AND CAST(total_cases AS FLOAT) <> 0
            THEN (CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100
        ELSE NULL
    END AS death_rate_percentage
FROM PortfolioProject ..covidDeaths$
where location = 'Anguilla'
order by 1,2

--looking at total cases vs population
--shows what percentage of population has covid
select location, date, total_cases, total_deaths, (total_cases/population)*100 as percentgaeInfectedPop
FROM PortfolioProject ..covidDeaths$
where location = 'Anguilla'
order by 1,2

--what country has the highest infection rate
select population, location, MAX( total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 as percentgaeInfectedPop
FROM PortfolioProject ..covidDeaths$
where continent is not null
group by population, location
--descending order
order by percentgaeInfectedPop desc


--countries with highest death count
select location, MAX(cast( total_deaths as int)) as TotalDeathCount
FROM PortfolioProject ..covidDeaths$
where continent is not null
group by location
--descending order
order by TotalDeathCount desc


--continents with highest death count
select location, MAX(cast( total_deaths as int)) as TotalDeathCount
FROM PortfolioProject ..covidDeaths$
where continent is  null
group by location
--descending order
order by TotalDeathCount desc

--global numbers
SELECT 
    date,
    SUM(new_cases) AS total_cases,
	sum(cast(new_deaths as int)) AS total_deaths,
    CASE 
        WHEN SUM(CASE WHEN ISNUMERIC(new_deaths) = 1 AND ISNUMERIC(new_cases) = 1 AND CAST(new_cases AS FLOAT) <> 0 THEN 1 ELSE 0 END) > 0
            THEN (SUM(CAST(new_deaths AS FLOAT)) / SUM(CAST(new_cases AS FLOAT))) * 100
        ELSE NULL
    END AS death_rate_percentage
FROM PortfolioProject..covidDeaths$
WHERE continent IS NULL
GROUP BY date
ORDER BY date;

--looking at total vaccination vs total population
SELECT
    dea.location,
    dea.continent,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location order by dea.location , dea.date ) AS total_vaccinations
FROM PortfolioProject..covidDeaths$ dea
JOIN PortfolioProject..covidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1, 2, 3;

--use cte
with popvsvac (continent, location, date, population, new_vaccinations, total_vaccinations)
as
(
SELECT
    dea.location,
    dea.continent,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location order by dea.location , dea.date ) AS total_vaccinations
FROM PortfolioProject..covidDeaths$ dea
JOIN PortfolioProject..covidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1, 2, 3;
)
select*, (total_vaccinations/population)* 100
from popvsvac


--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations numeric
)
insert into #percentpopulationvaccinated
SELECT
    dea.location,
    dea.continent,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location order by dea.location , dea.date ) AS total_vaccinations
FROM PortfolioProject..covidDeaths$ dea
JOIN PortfolioProject..covidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1, 2, 3;
select*, (total_vaccinations/population)* 100
from #percentpopulationvaccinated


--creating view to store data for visualization
create view percentpopulationvacinated as
SELECT
    dea.location,
    dea.continent,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location order by dea.location , dea.date ) AS total_vaccinations
FROM PortfolioProject..covidDeaths$ dea
JOIN PortfolioProject..covidVaccinations$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 1, 2, 3;

select *
from percentpopulationvacinated