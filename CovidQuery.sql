Select *
From PortfolioProject..CovidDeaths
order by 3,4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

Select location,date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
Select location,date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Germany'
order by 1,2

--Looking at Total Cases vs Population
--shows what percentage of population got covid

Select location,date, population, total_cases, (total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
Where location like '%Germany'
order by 1,2

--Looking at countries wiht highest infection rate compare to population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Germany'
Group by location, population
order by 4 desc

--Showing countries with highest death count per population
Select location, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Germany'
Where continent is not null
Group by location
order by 2 desc


--break things by continent
Select location, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Germany'
Where continent is null
Group by location
order by 2 desc

--showing the contients with the total death count 
Select location, Sum(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Germany'
Where continent is null
and location not in ('World','European Union','International')
Group by location
order by 2 desc

--showing the contients with the highest death count per population
Select continent, Max(cast(total_deaths as int)) as HighestDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%Germany'
Where continent is not null
Group by continent
order by 2 desc

--Global numbers for each day
Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Germany'
Where continent is not null
Group by date
order by 1,2

Select location, population, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location,population
order by 1,2

Select location, population,date, Max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location,population,date
order by 5 desc

--Global numbers
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Germany'
Where continent is not null
order by 1,2




--Looing at Total Population vs. Vaccinations
-- use CTE for reusing RollingPeopleVaccinated 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--Temp Table
DROP Table if exists #PercenPopulationVaccinated
Create Table #PercenPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercenPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
	--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as Vaccinated_Percentage
From #PercenPopulationVaccinated


--Create view for later data visualizations

GO --solve the problem that CREATE VIEW must be the only statement in the batch
CREATE VIEW PercenPopulationVaccinated AS 
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER(Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
GO


Select * 
from PercenPopulationVaccinated
