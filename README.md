# Armed Conflict Analysis

This repository contains the CHL5233H: Statistical Programming and Computation in Health Data in-class assignment on armed conflict and health outcomes.

## Contents

* data/raw/ — Original mortality, conflict, disaster, and covariate data
* data/processed/ — Final merged analytical dataset
* scripts/ — R scripts used to clean, transform, and merge the data
* reports/ — Quarto analysis and rendered reports

## Analysis

The analysis combines country-year data on:

* Maternal mortality
* Infant mortality
* Neonatal mortality
* Under-5 mortality
* Armed conflict
* Earthquakes
* Drought
* Country-level covariates

World Bank mortality data are converted from wide to long format. Disaster data are used to create country-year indicators for earthquakes and droughts. Armed conflict is defined using a threshold of at least 25 battle-related deaths and is lagged by one year.

The final analytical dataset contains 3,720 country-year observations covering 186 countries from 2000 to 2019.