# Independently rebuild the analytical data from raw files; never reads final_data.csv.
make_long <- function(path, outcome) {
  x <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE)
  years <- grep("^X[0-9]{4}$", names(x), value = TRUE)
  out <- do.call(rbind, lapply(years, function(y) data.frame(
    iso = x$iso, year = as.integer(sub("^X", "", y)), value = x[[y]]
  )))
  names(out)[3] <- outcome
  out
}

raw <- file.path("data", "raw")
mortality <- Reduce(function(x, y) merge(x, y, by = c("iso", "year"), all = TRUE), list(
  make_long(file.path(raw, "maternal_mortality.csv"), "maternal_mortality"),
  make_long(file.path(raw, "infant_mortality.csv"), "infant_mortality"),
  make_long(file.path(raw, "neonatal_mortality.csv"), "neonatal_mortality"),
  make_long(file.path(raw, "under5_mortality.csv"), "under5_mortality")
))

# Earthquake/drought are country-year indicators, not counts.
d <- read.csv(file.path(raw, "disaster.csv"), check.names = FALSE, stringsAsFactors = FALSE)
d <- d[d$Year >= 2000 & d$Year <= 2019 &
         d[["Disaster Type"]] %in% c("Earthquake", "Drought"),
       c("ISO", "Year", "Disaster Type")]
disasters <- aggregate(d[["Disaster Type"]], list(iso = d$ISO, year = d$Year),
  function(z) c(earthquake = as.integer(any(z == "Earthquake")),
                drought = as.integer(any(z == "Drought"))))
disasters <- cbind(disasters[1:2], as.data.frame(disasters$x))
disasters$x <- NULL

# Armed conflict is present if any source row has at least 25 best deaths.
cfl <- read.csv(file.path(raw, "conflict.csv"), stringsAsFactors = FALSE)
conflict <- aggregate(cfl$best >= 25, list(iso = cfl$iso, year = cfl$year), any)
names(conflict)[3] <- "armed_conflict"
conflict$armed_conflict <- as.integer(conflict$armed_conflict)
covariates <- read.csv(file.path(raw, "covariates.csv"), stringsAsFactors = FALSE)

# Retain the mortality country-year panel, replace absent events with zero, and lag.
agent <- Reduce(function(x, y) merge(x, y, by = c("iso", "year"), all.x = TRUE),
                list(mortality, disasters, conflict, covariates))
for (v in c("earthquake", "drought", "armed_conflict")) {
  agent[[v]][is.na(agent[[v]])] <- 0L
  agent[[v]] <- as.integer(agent[[v]])
}
agent <- agent[order(agent$iso, agent$year), ]
agent$armed_conflict_lagged <- ave(agent$armed_conflict, agent$iso,
  FUN = function(x) c(NA_integer_, head(x, -1L)))
agent$armed_conflict <- NULL
row.names(agent) <- NULL

readr::write_csv(agent, file.path("data", "processed", "final_data_agent.csv"), na = "")
message("Created final_data_agent.csv: ", nrow(agent), " rows x ", ncol(agent), " columns.")
