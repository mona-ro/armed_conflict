library(tidyverse)
library(janitor)
library(countrycode)
library(here)


# ============================================================
# 1. WORLD BANK MORTALITY DATA
# ============================================================

maternal <- read_csv("../data/raw/maternal_mortality.csv")
infant <- read_csv("../data/raw/infant_mortality.csv")
neonatal <- read_csv("../data/raw/neonatal_mortality.csv")
under5 <- read_csv("../data/raw/under5_mortality.csv")


prepare_world_bank_mortality_data <- function(data, mortality_variable_name) {
  
  data |>
    pivot_longer(
      cols = starts_with("X"),
      names_to = "year",
      names_prefix = "X",
      values_to = mortality_variable_name
    ) |>
    mutate(year = as.numeric(year)) |>
    select(iso, year, all_of(mortality_variable_name))
}


maternal_mortality <- prepare_world_bank_mortality_data(
  maternal,
  "maternal_mortality"
)

infant_mortality <- prepare_world_bank_mortality_data(
  infant,
  "infant_mortality"
)

neonatal_mortality <- prepare_world_bank_mortality_data(
  neonatal,
  "neonatal_mortality"
)

under5_mortality <- prepare_world_bank_mortality_data(
  under5,
  "under5_mortality"
)


mortality_data <- maternal_mortality |>
  full_join(infant_mortality, by = c("iso", "year")) |>
  full_join(neonatal_mortality, by = c("iso", "year")) |>
  full_join(under5_mortality, by = c("iso", "year"))


# ============================================================
# 2. DISASTER DATA
# ============================================================

disaster_data <- read_csv("../data/raw/disaster.csv")

disaster_data <- disaster_data |>
  clean_names()

disaster_data <- disaster_data |>
  filter(
    year >= 2000,
    year <= 2019,
    disaster_type %in% c("Earthquake", "Drought")
  )

disaster_data <- disaster_data |>
  select(year, iso, disaster_type)

disaster_data <- disaster_data |>
  group_by(year, iso) |>
  summarise(
    earthquake = as.integer(any(disaster_type == "Earthquake")),
    drought = as.integer(any(disaster_type == "Drought")),
    .groups = "drop"
  )


# ============================================================
# 3. CONFLICT DATA
# ============================================================

conflict_data <- read_csv("../data/raw/conflict.csv")

conflict_data <- conflict_data |>
  mutate(
    armed_conflict = as.integer(best >= 25)
  )

conflict_data <- conflict_data |>
  group_by(iso, year) |>
  summarise(
    armed_conflict = max(armed_conflict),
    .groups = "drop"
  )


# ============================================================
# 4. COVARIATES
# ============================================================

covariates_data <- read_csv("../data/raw/covariates.csv")


# ============================================================
# 5. MERGE DATASETS
# ============================================================

final_data <- mortality_data |>
  left_join(
    disaster_data,
    by = c("iso", "year")
  ) |>
  left_join(
    conflict_data,
    by = c("iso", "year")
  ) |>

  left_join(
    covariates_data,
    by = c("iso", "year")
  )

final_data <- final_data |>
  mutate(
    earthquake = replace_na(earthquake, 0L),
    drought = replace_na(drought, 0L),
    armed_conflict = replace_na(armed_conflict, 0L)
  )

final_data <- final_data |>
  arrange(iso, year) |>
  group_by(iso) |>
  mutate(
    armed_conflict_lagged = lag(armed_conflict)
  ) |>
  ungroup()

final_data <- final_data |>
  select(-armed_conflict)


# ============================================================
# 6. CHECK FINAL DATASET
# ============================================================

names(final_data)

dim(final_data)

head(final_data)


# ============================================================
# 7. SAVE FINAL DATASET
# ============================================================

write_csv(
  final_data,
  "data/processed/final_data.csv")