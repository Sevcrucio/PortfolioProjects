Select * 
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4


--Select * 
--FROM PortfolioProject..CovidVaccinations
--Order By 3,4

-- Select Data that we are going to be using


Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Order By 1,2

--looking at the Total Cases vs Total Deaths
-- shows the likelyhood ofof dying if you contract covid in each country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%Singapore%'
Order By 1,2

-- Looking at the Total Cases vs Total Population
-- Shows what percentage of the population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like '%Singapore%'
Order By 1,2


-- Looking at countries with the Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) As HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%Singapore%'
Group By location, population
Order By PercentPopulationInfected Desc

--Showing Countries with the highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%Singapore%'
Where continent is not null
Group By location
Order By TotalDeathCount Desc


-- BREAK DOWN BY CONTINENT

--Showing continents with the highest Death Count per Population

Select continent, MAX(cast(total_deaths as int)) As TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%Singapore%'
Where continent is not null
Group By continent
Order By TotalDeathCount Desc


-- GLOBAL NUMBERS

Select SUM(new_cases) As Total_Cases, SUM(cast(new_deaths as int)) As total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%Singapore%'
Where continent is not null
Order By 1,2



-- Looking at Total Population Vs Vaccinations

-- USE CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated) 
As 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- TEMP TABLE
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating view to store data for later visualisations

Create View PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) As RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- Order By 2,3

Select * FROM PercentagePopulationVaccinated