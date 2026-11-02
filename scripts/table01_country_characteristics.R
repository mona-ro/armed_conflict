
# Table 1: Country Characteristics by Armed Conflict Status
# Descriptive statistics use 2001 observations.
# Missing data are calculated across all years (2000-2019).


# 1. Load packages --------------------------------------------------------

library(dplyr)
library(tidyr)
library(table1)
library(flextable)
library(here)
library(kableExtra)
library(pagedown)
library(grid)


# 2. Read processed dataset -----------------------------------------------

conflict_data <- read.csv(
  here("data", "processed", "final_data.csv")
)


# 3. Define variables ------------------------------------------------------

table_variables <- c(
  "armed_conflict_lagged",
  "maternal_mortality",
  "infant_mortality",
  "neonatal_mortality",
  "under5_mortality",
  "earthquake",
  "drought",
  "gdp_1000",
  "oecd",
  "pop_dens",
  "urban",
  "age_dep",
  "male_edu",
  "temp",
  "rainfall_1000"
)


# 4. Calculate missing data across all years ------------------------------

missing_data <- conflict_data |>
  filter(year >= 2000, year <= 2019) |>
  summarise(
    across(
      all_of(table_variables),
      ~ sum(is.na(.x))
    )
  ) |>
  pivot_longer(
    cols = everything(),
    names_to = "Variable",
    values_to = "Number_missing"
  ) |>
  mutate(
    Total_observations = nrow(
      filter(conflict_data, year >= 2000, year <= 2019)
    ),
    Percent_missing = round(
      100 * Number_missing / Total_observations,
      2
    )
  ) |>
  mutate(
    Variable = recode(
      Variable,
      armed_conflict_lagged = "Previous-year armed conflict",
      maternal_mortality = "Maternal mortality",
      infant_mortality = "Infant mortality",
      neonatal_mortality = "Neonatal mortality",
      under5_mortality = "Under-five mortality",
      earthquake = "Earthquake",
      drought = "Drought",
      gdp_1000 = "GDP per capita",
      oecd = "OECD membership",
      pop_dens = "Population density",
      urban = "Urban",
      age_dep = "Age dependency ratio",
      male_edu = "Male education",
      temp = "Temperature",
      rainfall_1000 = "Rainfall"
    )
  ) |>
  rename(
    `Total observations` = Total_observations,
    `Percent missing` = Percent_missing,
    `Number missing` = Number_missing
  )

# Display missing data
print(missing_data)


# 5. Prepare data for Table 1 ---------------------------------------------

# Use observations from 2001 only
table_data <- conflict_data |>
  filter(year == 2001) |>
  mutate(
    armed_conflict_group = factor(
      armed_conflict_lagged,
      levels = c(0, 1),
      labels = c("No armed conflict", "Armed conflict")
    )
  )

# Convert categorical variables to factors
table_data <- table_data |>
  mutate(
    across(
      c(earthquake, drought, oecd),
      as.factor
    )
  )

# Keep observations with known conflict status
table_data <- table_data |>
  filter(!is.na(armed_conflict_group))

# Select variables for Table 1
table_data <- table_data |>
  select(
    armed_conflict_group,
    maternal_mortality,
    infant_mortality,
    neonatal_mortality,
    under5_mortality,
    earthquake,
    drought,
    gdp_1000,
    oecd,
    pop_dens,
    urban,
    age_dep,
    male_edu,
    temp,
    rainfall_1000
  )


# Use publication-friendly row labels without changing the variables or data.
variable_labels <- c(
  maternal_mortality = "Maternal mortality",
  infant_mortality = "Infant mortality",
  neonatal_mortality = "Neonatal mortality",
  under5_mortality = "Under-five mortality",
  earthquake = "Earthquake",
  drought = "Drought",
  gdp_1000 = "GDP per capita (thousands)",
  oecd = "OECD membership",
  pop_dens = "Population density",
  urban = "Urban population (%)",
  age_dep = "Age dependency ratio (%)",
  male_edu = "Male education",
  temp = "Temperature",
  rainfall_1000 = "Rainfall (thousands)"
)
for (variable in names(variable_labels)) {
  label(table_data[[variable]]) <- variable_labels[[variable]]
}

# 6. Generate Table 1 -----------------------------------------------------

table_one <- table1(
  ~ maternal_mortality +
    infant_mortality +
    neonatal_mortality +
    under5_mortality +
    earthquake +
    drought +
    gdp_1000 +
    oecd +
    pop_dens +
    urban +
    age_dep +
    male_edu +
    temp +
    rainfall_1000 |
    armed_conflict_group,
  data = table_data,
  overall = TRUE,
  caption = "Table 1. Country Characteristics by Armed Conflict Status in 2001"
)



# 7. Format tables --------------------------------------------------------

# Convert Table 1 into a flextable object
table_one_flex <- table1::t1flex(table_one)
table_one_flex$header$dataset[] <- lapply(
  table_one_flex$header$dataset,
  function(column) sub("^TRUE\\n", "Overall\\n", column)
)

table_one_flex <- flextable::autofit(table_one_flex)

# Format missing data table
missing_data_flex <- flextable::flextable(missing_data)
missing_data_flex <- flextable::colformat_num(missing_data_flex, j = c("Number missing", "Total observations"), digits = 0, big.mark = ",")
missing_data_flex <- flextable::colformat_num(missing_data_flex, j = "Percent missing", digits = 1)
missing_data_flex <- flextable::theme_booktabs(missing_data_flex)
missing_data_flex <- flextable::font(missing_data_flex, fontname = "sans", part = "all")
missing_data_flex <- flextable::fontsize(missing_data_flex, size = 9, part = "all")
missing_data_flex <- flextable::bold(missing_data_flex, part = "header")
missing_data_flex <- flextable::align(missing_data_flex, j = 1, align = "left", part = "all")
missing_data_flex <- flextable::align(missing_data_flex, j = 2:4, align = "right", part = "all")
missing_data_flex <- flextable::padding(missing_data_flex, padding = 4, part = "all")
missing_data_flex <- flextable::autofit(missing_data_flex)


# 8. Create output folder -------------------------------------------------

dir.create(
  here("output"),
  showWarnings = FALSE,
  recursive = TRUE
)


# 9. Export tables directly to PDF ----------------------------------------

pdf_file <- here(
  "output",
  "table01_country_characteristics.pdf"
)

# Open PDF device in landscape format
grDevices::pdf(
  file = pdf_file,
  width = 14,
  height = 8.5,
  onefile = TRUE
)

# First page: Table 1
grid::grid.newpage()

grid::grid.text(
  "Table 1. Country Characteristics by Armed Conflict Status in 2001",
  y = 0.96,
  gp = grid::gpar(fontsize = 16, fontface = "bold", fontfamily = "sans")
)

grid::pushViewport(
  grid::viewport(
    x = 0.5,
    y = 0.46,
    width = 0.96,
    height = 0.82
  )
)

grid::grid.draw(
  flextable::gen_grob(table_one_flex)
)

grid::popViewport()


# Second page: Missing data
grid::grid.newpage()

grid::grid.text(
  "Missing Data Across All Years (2000-2019)",
  y = 0.96,
  gp = grid::gpar(fontsize = 16, fontface = "bold", fontfamily = "sans")
)

grid::pushViewport(
  grid::viewport(
    x = 0.5,
    y = 0.46,
    width = 0.85,
    height = 0.85
  )
)

grid::grid.draw(
  flextable::gen_grob(missing_data_flex)
)

grid::popViewport()


# Close PDF device
grDevices::dev.off()


# 10. Confirmation --------------------------------------------------------

cat(
  "PDF successfully exported to:",
  pdf_file,
  "\n"
)
