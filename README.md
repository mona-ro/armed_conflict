# Armed Conflict Analysis

This repository contains the CHL5233H: Statistical Programming and Computation in Health Data in-class assignment on armed conflict and health outcomes.

## Contents

- `data/raw/` — Original mortality, conflict, disaster, and covariate data
- `data/processed/` — Final merged analytical dataset
- `R/` — R scripts used to prepare the analytical dataset
- `EDA/` — Exploratory data analysis report and source file
- `reports/` — Dataset comparison report and other Quarto reports

## Exploratory Data Analysis

- [View the EDA report](EDA/eda.html)
- [View the EDA source code](EDA/eda.qmd)

The EDA explores dataset dimensions, missing values, the distribution of armed conflict, and changes in conflict-affected country-years over time.

## Analysis

The analysis combines country-year data on:

- Maternal mortality
- Infant mortality
- Neonatal mortality
- Under-5 mortality
- Armed conflict
- Earthquakes and droughts
- Economic, demographic, and environmental covariates

World Bank mortality data are converted from wide to long format. Disaster data are used to create country-year indicators for earthquakes and droughts. Armed conflict is defined using a threshold of at least 25 battle-related deaths and is lagged by one year.

The final analytical dataset contains 3,720 country-year observations covering 186 countries from 2000 to 2019. The raw conflict file ends in 2018, so 2019 is excluded from the EDA's current-year conflict summaries because conflict status for that year cannot be established from the available source data.
