# Panel Regression Models


# 1. Load packages --------------------------------------------------------

library(plm)
library(modelsummary)
library(here)
library(flextable)
library(grid)


# 2. Read the dataset -----------------------------------------------------

finaldata <- read.csv(
  here("data", "processed", "final_data.csv")
)


# 3. Prepare variables ----------------------------------------------------

# Rename the lagged conflict variable to match the lecture slides
finaldata$armed_conflict <- finaldata$armed_conflict_lagged

# Log-transform GDP per capita
finaldata$log_gdp_1000 <- log(finaldata$gdp_1000)


# 4. Define common predictors --------------------------------------------

preds <- as.formula(
  "~ armed_conflict + log_gdp_1000 + oecd + pop_dens + urban +
    age_dep + male_edu + temp + rainfall_1000 + earthquake + drought"
)


# 5. Fit the four two-way fixed-effects models ---------------------------

maternal_model <- plm(
  update.formula(preds, maternal_mortality ~ .),
  index = c("iso", "year"),
  effect = "twoways",
  model = "within",
  data = finaldata
)

under5_model <- plm(
  update.formula(preds, under5_mortality ~ .),
  index = c("iso", "year"),
  effect = "twoways",
  model = "within",
  data = finaldata
)

infant_model <- plm(
  update.formula(preds, infant_mortality ~ .),
  index = c("iso", "year"),
  effect = "twoways",
  model = "within",
  data = finaldata
)

neonatal_model <- plm(
  update.formula(preds, neonatal_mortality ~ .),
  index = c("iso", "year"),
  effect = "twoways",
  model = "within",
  data = finaldata
)


# 6. Combine models -------------------------------------------------------

models <- list(
  "Maternal mortality" = maternal_model,
  "Under-5 mortality" = under5_model,
  "Infant mortality" = infant_model,
  "Neonatal mortality" = neonatal_model
)


# 7. Display model summaries ---------------------------------------------

summary(maternal_model)
summary(under5_model)
summary(infant_model)
summary(neonatal_model)


# 8. Create output folder -------------------------------------------------

dir.create(
  here("output"),
  showWarnings = FALSE,
  recursive = TRUE
)


# 9. Create regression table ----------------------------------------------

regression_table_flex <- modelsummary(
  models,
  output = "flextable",
  coef_map = c(
    "armed_conflict" = "Armed conflict (lagged)",
    "log_gdp_1000" = "Log GDP per capita",
    "oecd" = "OECD",
    "pop_dens" = "Population density",
    "urban" = "Urban population",
    "age_dep" = "Age dependency",
    "male_edu" = "Male education",
    "temp" = "Temperature",
    "rainfall_1000" = "Rainfall",
    "earthquake" = "Earthquake",
    "drought" = "Drought"
  ),
  statistic = "({std.error})",
  stars = TRUE,
  gof_omit = "AIC|BIC|Log.Lik.|RMSE"
)

regression_table_flex <- flextable::autofit(
  regression_table_flex
)


# 10. Export regression table directly to PDF -----------------------------

pdf_file <- here(
  "output",
  "table02_panel_regression_results.pdf"
)

grDevices::pdf(
  file = pdf_file,
  width = 14,
  height = 8.5,
  onefile = TRUE
)

grid::grid.newpage()

grid::grid.text(
  "Table 2. Panel Regression Results",
  y = 0.96,
  gp = grid::gpar(
    fontsize = 16,
    fontface = "bold",
    fontfamily = "sans"
  )
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
  flextable::gen_grob(regression_table_flex)
)

grid::popViewport()

grDevices::dev.off()


# 11. Confirmation --------------------------------------------------------

cat(
  "PDF successfully exported to:",
  pdf_file,
  "\n"
)