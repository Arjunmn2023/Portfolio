
--Covid 19 Data Exploration 
--Skills used: Joins, CTE's,   Aggregate Functions, Creating Views, Converting Data Types


Select *
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null 
order by 1,2


-- Total Cases vs Total Deaths   he probability of mortality upon contracting COVID-19 in the INDIA (IN)
-- Shows likelihood of dying if you contract covid in your country

Select location,date,total_cases,population,(total_deaths * 100/population) As PercentPopulationInfected
From PortfolioProject ..CovidDeaths
Where location like '%India%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

SELECT  location,population,
    MAX(CAST(total_cases AS DECIMAL)) AS HighestInfectionCount,
    MAX((CAST(total_cases AS DECIMAL) * 100 / population)) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- Showing contintents with the highest death count per population

Select continent , MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject ..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select date , sum(new_cases) as total_cases, 
sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int)) * 100/ NULLIF(SUM(new_cases),0) as Deathpercentage 
From PortfolioProject ..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated,
    (SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) / NULLIF(dea.population, 0)) * 100.0 AS VaccinationPercentage
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
    FROM
        PortfolioProject..CovidDeaths dea
    JOIN
        PortfolioProject..CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)
SELECT
    pv.*,
    (CONVERT(FLOAT, pv.RollingPeopleVaccinated) / NULLIF(pv.Population, 0)) * 100.0 AS VaccinationPercentage
FROM
    PopvsVac pv;
