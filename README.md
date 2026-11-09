# Armed Conflict Analysis

This repository contains the CHL5233H: Statistical Programming and Computation in Health Data in-class assignment on armed conflict and health outcomes.

## Contents

- `data/raw/` — Original mortality, conflict, disaster, and covariate data
- `data/processed/` — Final merged analytical dataset
- `R/` — Data preparation scripts
- `scripts/` — Descriptive analysis, visualizations, and regression scripts
- `reports/` — Exploratory data analysis and dataset comparison reports
- `output/` — Generated tables and figures

## Analysis

The analysis uses country-year data from 186 countries between 2000 and 2019 to examine the relationship between armed conflict and maternal, infant, neonatal, and under-5 mortality.

Armed conflict is defined as at least 25 battle-related deaths and lagged by one year. The analysis includes descriptive statistics, mortality trend visualizations, and four two-way fixed-effects panel regression models using `plm()`. GDP per capita is log-transformed, and models adjust for additional economic, demographic, and environmental covariates.