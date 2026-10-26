
# ============================================================
# Create Final Armed Conflict Dataset
# ============================================================

library(tidyverse)
library(janitor)
library(countrycode)
library(here)


# ============================================================
# 1. WORLD BANK MORTALITY DATA
# ============================================================

maternal <- read_csv(
  here("data", "raw", "maternal_mortality.csv")
)

infant <- read_csv(
  here("data", "raw", "infant_mortality.csv")
)

neonatal <- read_csv(
  here("data", "raw", "neonatal_mortality.csv")
)

under5 <- read_csv(
  here("data", "raw", "under5_mortality.csv")
)


prepare_world_bank_mortality_data <- function(
    data,
    mortality_variable_name
) {
  data |>
    pivot_longer(
      cols = starts_with("X"),
      names_to = "year",
      names_prefix = "X",
      values_to = mortality_variable_name
    ) |>
    mutate(year = as.numeric(year)) |>
    select(
      iso,
      year,
      all_of(mortality_variable_name)
    )
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

disaster_data <- read_csv(
  here("data", "raw", "disaster.csv")
) |>
  clean_names() |>
  filter(
    year >= 2000,
    year <= 2019,
    disaster_type %in% c("Earthquake", "Drought")
  ) |>
  select(year, iso, disaster_type) |>
  group_by(year, iso) |>
  summarise(
    earthquake = as.integer(
      any(disaster_type == "Earthquake")
    ),
    drought = as.integer(
      any(disaster_type == "Drought")
    ),
    .groups = "drop"
  )


# ============================================================
# 3. CONFLICT DATA
# ============================================================

conflict_data <- read_csv(
  here("data", "raw", "conflict.csv")
) |>
  mutate(
    armed_conflict = as.integer(best >= 25)
  ) |>
  group_by(iso, year) |>
  summarise(
    armed_conflict = max(armed_conflict),
    .groups = "drop"
  )


# ============================================================
# 4. COVARIATES
# ============================================================

covariates_data <- read_csv(
  here("data", "raw", "covariates.csv")
)


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


# Replace missing event indicators with zero
final_data <- final_data |>
  mutate(
    earthquake = replace_na(earthquake, 0L),
    drought = replace_na(drought, 0L),
    armed_conflict = replace_na(armed_conflict, 0L)
  )


# Create the one-year lagged conflict variable
final_data <- final_data |>
  arrange(iso, year) |>
  group_by(iso) |>
  mutate(
    armed_conflict_lagged = lag(armed_conflict)
  ) |>
  ungroup() |>
  select(-armed_conflict)


# ============================================================
# 6. CHECK FINAL DATASET
# ============================================================

print(names(final_data))
print(dim(final_data))
print(head(final_data))


# ============================================================
# 7. SAVE FINAL DATASET
# ============================================================

write_csv(
  final_data,
  here("data", "processed", "final_data.csv")
)

message("Final dataset saved successfully.")
