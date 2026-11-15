library(readxl)
library(dplyr)
library(tidyr)
library(here)

source(here("R/helpers/fetch_data.R"))

# Species-level mean AM colonization for the quadrat species (used in R/CWM.R).
# Source: FungalRoot database (Soudzilovskaia et al. 2020), queried through the
# GBIF API (dataset "Taxon occurrence data for the FungalRoot database",
# https://doi.org/10.15468/a7ujmj). Only records with AM method
# "McGonigle et al. 1990: RLC (%)" are used; one pooled mean per species over
# all records (not per habitat, as agreed with the supervisor).
# Species without such records get manual values with their source.
# Output: data/processed/am_colonization.csv, plus a comparison with the
# "AM intensity FungalRoot" column in DistNet_Quadrat.xlsx.

fungalroot_dataset <- "744edc21-8dd2-474e-8a0b-b8c3d56a3c2d"
gbif <- "https://api.gbif.org/v1/"

quadrat_path <- get_data("SHAREPOINT_PATH_QUADRAT", "quadrat")

# Species and the Excel AM column from both quadrat sheets
read_quadrat_am <- function(sheet) {
  x <- read_excel(quadrat_path, sheet = sheet, na = c("", "NA"), .name_repair = "unique_quiet")
  names(x)[1] <- "row_no"
  am_col <- grep("^AM intensity", names(x), value = TRUE)
  x |>
    filter(!is.na(row_no)) |>
    transmute(species = Species, am_excel = as.numeric(.data[[am_col]]))
}

quadrat_am <- bind_rows(
  forest = read_quadrat_am("Quadrat_Forest"),
  grassland = read_quadrat_am("Quadrat_Grassland"),
  .id = "habitat"
)

# Names GBIF cannot match unambiguously (see R/gbif_name_check.R);
# "sp" names use all records of the genus
gbif_name_map <- c(
  "Bromus mollis" = "Bromus hordeaceus",
  "Festuca pratensis" = "Lolium pratense",
  "Hieracium sp" = "Hieracium",
  "Euphrasia sp" = "Euphrasia"
)

gbif_get <- function(path) jsonlite::fromJSON(paste0(gbif, path), simplifyVector = FALSE)

# All FungalRoot records of one taxon with their MeasurementOrFact values
fungalroot_records <- function(name) {
  m <- gbif_get(paste0("species/match?kingdom=Plantae&name=", utils::URLencode(name, reserved = TRUE)))
  # Species names must match at species rank, genus names at genus rank
  wanted_rank <- if (grepl(" ", name)) "SPECIES" else "GENUS"
  if (!identical(m$rank, wanted_rank)) return(tibble())
  key <- m$acceptedUsageKey %||% m$usageKey
  occ <- list()
  offset <- 0
  repeat {
    r <- gbif_get(sprintf(
      "occurrence/search?datasetKey=%s&taxonKey=%s&limit=300&offset=%d",
      fungalroot_dataset, key, offset
    ))
    occ <- c(occ, r$results)
    offset <- offset + 300
    if (isTRUE(r$endOfRecords)) break
  }
  bind_rows(lapply(occ, function(o) {
    v <- gbif_get(paste0("occurrence/", o$key, "/verbatim"))
    mof <- v$extensions[["http://rs.tdwg.org/dwc/terms/MeasurementOrFact"]]
    vals <- vapply(mof, function(x) x[["http://rs.tdwg.org/dwc/terms/measurementValue"]] %||% NA_character_, "")
    names(vals) <- vapply(mof, function(x) x[["http://rs.tdwg.org/dwc/terms/measurementType"]] %||% NA_character_, "")
    tibble(
      gbif_key = o$key,
      am_method = unname(vals["AM method"]),
      am_intensity = suppressWarnings(as.numeric(vals["AM intensity"]))
    )
  }))
}

# Query GBIF once per day; raw records are cached in data/raw/. Species
# missing from the cache (incl. those without records) are queried again.
cache <- here("data", "raw", paste0("fungalroot_gbif_", Sys.Date(), ".rds"))
fungalroot_raw <- if (file.exists(cache)) readRDS(cache) else tibble(species = character())
query_names <- setdiff(unique(quadrat_am$species), fungalroot_raw$species)
fungalroot_raw <- bind_rows(fungalroot_raw, lapply(query_names, function(sp) {
  q <- if (sp %in% names(gbif_name_map)) gbif_name_map[[sp]] else sp
  fungalroot_records(q) |> mutate(species = sp, query_name = q, .before = 1)
}))
saveRDS(fungalroot_raw, cache)

am_fungalroot <- fungalroot_raw |>
  filter(grepl("McGonigle", am_method), !is.na(am_intensity)) |>
  summarise(am = mean(am_intensity), n_records = n(), .by = species) |>
  mutate(data_source = "FungalRoot via GBIF, McGonigle et al. 1990 RLC%")

# Manual values (sources from cell notes in DistNet_Quadrat.xlsx)
am_manual <- tribble(
  ~species,                   ~am,                 ~data_source,
  "Artemisia campestris",     (53 + 48 + 82) / 3,  "Koorem et al. 2024",
  "Pulsatilla pratensis",     (37 + 76) / 2,       "Moora et al. 2004, Fig. 1c, 14 weeks (forest/grassland inoculum)",
  "Carex disticha",           7,                   "Own microscopy, 2026-11-04",
  "Helictotrichon pratensis", 72,                  "Own microscopy, 2026-11-03",
  # No McGonigle records; FungalRoot records mostly ectomycorrhizal/ericoid -> 0
  "Chimaphila umbellata",     0,                   "FungalRoot: EcM/ErM, no McGonigle AM records",
  "Corylus avellana",         0,                   "FungalRoot: EcM, no McGonigle AM records",
  "Orthilia secunda",         0,                   "FungalRoot: EcM/ErM, no McGonigle AM records",
  "Pinus sylvestris",         0,                   "FungalRoot: EcM, no McGonigle AM records",
  "Pyrola rotundifolia",      0,                   "FungalRoot: EcM, no McGonigle AM records",
  "Quercus robur",            0,                   "FungalRoot: EcM, no McGonigle AM records",
  "Melampyrum nemorosum",     0,                   "FungalRoot: EcM (1 record), NM per L. Tedersoo comment 2019"
)

am_colonization <- am_fungalroot |>
  rows_upsert(am_manual, by = "species")

# Compare with the Excel column
am_check <- quadrat_am |>
  left_join(am_colonization, by = "species") |>
  mutate(diff = round(am - am_excel, 2))

am_check |>
  filter(is.na(diff) | abs(diff) > 0.01) |>
  arrange(species) |>
  print(n = Inf)

write.csv(am_colonization, here("data/processed/am_colonization.csv"), row.names = FALSE)
