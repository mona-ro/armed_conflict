
# Figure 1: Maternal Mortality Trends in Countries with Increasing Mortality
# Shows trends from 2000 to 2017 for countries where maternal mortality
# increased between 2000 and 2017.

# 1. Load packages --------------------------------------------------------

library(dplyr)
library(here)


# 2. Read processed dataset -----------------------------------------------

conflict_data <- read.csv(
  here("data", "processed", "final_data.csv")
)


# 3. Calculate change in maternal mortality -------------------------------

maternal_mortality_data <- conflict_data |>
  dplyr::select(iso, year, maternal_mortality) |>
  dplyr::filter(year < 2018) |>
  dplyr::arrange(iso, year) |>
  dplyr::group_by(iso) |>
  dplyr::mutate(
    diff_matmor = maternal_mortality - maternal_mortality[1L]
  ) |>
  dplyr::ungroup()


# 4. Identify countries with increasing maternal mortality ----------------

increasing_countries <- maternal_mortality_data |>
  dplyr::filter(year == 2017, diff_matmor > 0) |>
  dplyr::pull(iso)

figure_data <- maternal_mortality_data |>
  dplyr::filter(iso %in% increasing_countries)


# 5. Create maternal mortality trend figure -------------------------------

maternal_mortality_figure <- ggplot2::ggplot(
  figure_data,
  ggplot2::aes(
    x = year,
    y = maternal_mortality,
    colour = iso,
    group = iso
  )
) +
  ggplot2::geom_line(linewidth = 0.8, alpha = 0.9) +
  ggplot2::scale_colour_viridis_d(option = "turbo", end = 0.94) +
  ggplot2::labs(
    title = "Maternal mortality trends",
    subtitle = "Countries with an increase from 2000 to 2017",
    x = NULL,
    y = "Maternal deaths per 100,000 live births",
    colour = "Country",
    caption = "Annual country estimates, 2000–2017"
  ) +
  ggplot2::theme_minimal(base_size = 12, base_family = "sans") +
  ggplot2::theme(
    plot.title = ggplot2::element_text(
      face = "bold",
      size = 18,
      colour = "#172B4D",
      margin = ggplot2::margin(b = 5)
    ),
    plot.subtitle = ggplot2::element_text(size = 11, colour = "#526273"),
    plot.caption = ggplot2::element_text(size = 9, colour = "#526273", hjust = 0),
    axis.title.y = ggplot2::element_text(face = "bold", margin = ggplot2::margin(r = 9)),
    axis.text = ggplot2::element_text(colour = "#344054"),
    panel.grid.minor = ggplot2::element_blank(),
    panel.grid.major.x = ggplot2::element_blank(),
    panel.grid.major.y = ggplot2::element_line(colour = "#E5EAF0", linewidth = 0.45),
    legend.position = "bottom",
    legend.title = ggplot2::element_text(face = "bold", size = 10),
    legend.text = ggplot2::element_text(size = 9),
    legend.key.width = grid::unit(1.2, "cm"),
    legend.box = "vertical",
    plot.margin = ggplot2::margin(14, 18, 12, 14)
  ) +
  ggplot2::guides(colour = ggplot2::guide_legend(nrow = 3, byrow = TRUE)) +
  ggplot2::scale_x_continuous(
    breaks = c(seq(2000, 2016, by = 2), 2017),
    expand = ggplot2::expansion(mult = c(0.01, 0.02))
  ) +
  ggplot2::scale_y_continuous(
    labels = scales::label_comma(),
    expand = ggplot2::expansion(mult = c(0.03, 0.08))
  )


# 6. Display figure -------------------------------------------------------

if (interactive()) {
  print(maternal_mortality_figure)
}


# 7. Save figure ----------------------------------------------------------

dir.create(
  here("output"),
  showWarnings = FALSE,
  recursive = TRUE
)

ggplot2::ggsave(
  filename = here(
    "output",
    "fig01_maternal_mortality_trends.png"
  ),
  plot = maternal_mortality_figure,
  width = 12,
  height = 8,
  dpi = 400,
  bg = "white"
)


# 8. Confirmation ---------------------------------------------------------

cat(
  "Figure successfully exported to:",
  here("output", "fig01_maternal_mortality_trends.png"),
  "\n"
)
