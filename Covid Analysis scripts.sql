Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Data selection--

Select location,date,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total cases vs Total Deaths--
--Percentage of total deaths out of total cases diagnosed--
--Shows likelihood of dying if you contract covid in KE--
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%Kenya%' /*same as location=Kenya*/
and continent is not null
order by 1,2 --order by location and date--

--Total cases vs Population--
--Shows what percentage of population contracted covid--
Select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
--Where location like '%Kenya%' 
order by 1,2 

--Countries with highest infection rates compared to population--
Select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%' 
where continent is not null
Group by location,population
order by PercentPopulationInfected desc

--Showing countries with highest death count per population--
Select location,population,MAX(cast(total_deaths as int)) as HighestDeathCount,MAX((cast(total_deaths as int)/population))*100 as PercentPopulationDeath
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%' 
where continent is not null
Group by location,population
order by PercentPopulationDeath desc

--Showing continents with highest death count per population--
Select location,population,MAX(cast(total_deaths as int)) as HighestDeathCount,MAX((cast(total_deaths as int)/population))*100 as PercentPopulationDeath
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%' 
where continent is null
Group by location,population
order by PercentPopulationDeath desc

--Total death count in countries from highest to lowest--

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount --change total deaths data from nvarchar to int--
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%' 
where continent is not null
Group by location
order by TotalDeathCount desc

--DATA EXPLORATION BY CONTINENT--

--Continents with highest death counts--
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount --change total deaths data from nvarchar to int--
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%' 
where continent is null
Group by location
order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount --change total deaths data from nvarchar to int--
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%' 
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global numbers--
--deaths vs cases globally--
Select sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%' 
where continent is not null
order by 1,2 

--Grouped by date--
Select date,sum(new_cases)as total_cases, sum(cast(new_deaths as int)) as total_deaths,(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%' 
where continent is not null
group by date
order by 1,2 

/*COVID VACCINATIONS*/

Select *
From PortfolioProject..CovidVaccinations

--JOIN TABLES--
--Joined based on location and date--
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location 
	 and dea.date=vac.date

--Total population vs vaccinations--
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location 
	 and dea.date=vac.date
where dea.continent is not null
order by 2,3

--Do a rolling count i.e sum the new vaccinations--
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
      sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) 
	  as RollingPeopleVaccinated/*or CONVERT(int,vac.new_vaccinations)*/
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location 
	 and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE--
With CTE_PopvsVac(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
as
(Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
      sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) 
	  as RollingPeopleVaccinated/*or CONVERT(int,vac.new_vaccinations)*/
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location 
	 and dea.date=vac.date
where dea.continent is not null)
--order by 2,3)
Select *,(RollingPeopleVaccinated/Population)*100
From CTE_PopvsVac

--TEMP TABLE--
drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeoplevaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
      sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) 
	  as RollingPeopleVaccinated/*or CONVERT(int,vac.new_vaccinations)*/
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location 
	 and dea.date=vac.date
--where dea.continent is not null
--order by 2,3)

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

/*CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS*/
--PercentPopulationVaccinatedView--
Create View PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
      sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location ,dea.date) 
	  as RollingPeopleVaccinated/*or CONVERT(int,vac.new_vaccinations)*/
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     On dea.location=vac.location 
	 and dea.date=vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

--Death count--
Create View DeathCount as
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount --change total deaths data from nvarchar to int--
From PortfolioProject..CovidDeaths
--Where location like '%Kenya%' 
where continent is null
Group by location
--order by TotalDeathCount desc

