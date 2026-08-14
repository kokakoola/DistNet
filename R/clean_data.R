source("R/fetch_data.R")

library(readxl)
library(dplyr)
library(janitor) # for clean_names()

clean_masterdata <- function(raw_path) {
  raw <- read_excel(raw_path, sheet = "Colonization_Pilot")

  cleaned <- raw %>%
    clean_names() %>%
    filter(!is.na(arb_calc)) %>%
    distinct() %>%
    mutate(
      species = factor(species),
      habitat = factor(habitat),
      ring_id = factor(ring_id),
      treatment = factor(treatment),
      arb = as.numeric(arb_calc),
      ves = as.numeric(ves_calc),
      hyp = as.numeric(hyp_calc),
      noamf = as.numeric(noamf_calc),
      total = as.numeric(total_calc)
    ) %>%
    select(
      species,
      habitat,
      ring_id,
      treatment,
      arb,
      ves,
      hyp,
      noamf,
      total
    )

  # Quality check
  # stopifnot(
  #   "Puuduvad väärtused kriitilises veerus" = !any(is.na(cleaned$colonisation))
  # )

  cleaned
}

# check if error
# raw <- read_excel(raw_file, sheet = "sheet_name")
# raw %>% clean_names() %>% colnames()

# usage
raw_file <- get_latest_data() # calls fetch_data.R
colonization <- clean_masterdata(raw_file)

# Save for analyze
write.csv(colonization, "data/processed/colonization.csv", row.names = FALSE)
