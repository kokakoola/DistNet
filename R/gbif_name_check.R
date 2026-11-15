library(readxl)
library(dplyr)
library(here)

source(here("R/helpers/fetch_data.R"))

# Check all plant names used in the project against the GBIF Backbone Taxonomy
# (GBIF Secretariat 2023, https://doi.org/10.15468/39omei). Excel files are not
# changed; the result table is data/processed/gbif_name_check.csv.

master_path <- get_data("SHAREPOINT_PATH_MASTER", "master")
quadrat_path <- get_data("SHAREPOINT_PATH_QUADRAT", "quadrat")

quadrat_names <- function(sheet) {
  x <- read_excel(quadrat_path, sheet = sheet, na = c("", "NA"), .name_repair = "unique_quiet")
  names(x)[1] <- "row_no"
  x |> filter(!is.na(row_no)) |> pull(Species)
}

names_used <- bind_rows(
  tibble(
    name = read_excel(master_path, sheet = "Species", na = c("", "NA"))$Species,
    source = "MasterData:Species"
  ),
  tibble(name = quadrat_names("Quadrat_Forest"), source = "Quadrat_Forest"),
  tibble(name = quadrat_names("Quadrat_Grassland"), source = "Quadrat_Grassland")
) |>
  filter(!is.na(name)) |>
  mutate(name = trimws(name)) |>
  summarise(source = paste(unique(source), collapse = ", "), .by = name)

# GBIF species match API, one request per name
gbif_match <- function(name) {
  url <- paste0(
    "https://api.gbif.org/v1/species/match?kingdom=Plantae&name=",
    utils::URLencode(name, reserved = TRUE)
  )
  r <- jsonlite::fromJSON(url)
  tibble(
    gbif_name = r$scientificName %||% NA_character_,
    match_type = r$matchType %||% NA_character_,
    rank = r$rank %||% NA_character_,
    status = r$status %||% NA_character_,
    accepted_species = if (identical(r$status, "ACCEPTED")) r$species %||% NA_character_ else r$species %||% NA_character_,
    family = r$family %||% NA_character_
  )
}

gbif_name_check <- names_used |>
  rowwise() |>
  mutate(gbif_match(name)) |>
  ungroup() |>
  mutate(
    # Flag names that need a decision
    flag = case_when(
      match_type == "NONE" ~ "not found",
      match_type == "HIGHERRANK" ~ "genus only",
      match_type == "FUZZY" ~ "spelling",
      status != "ACCEPTED" ~ "synonym",
      name != accepted_species ~ "differs",
      .default = ""
    )
  ) |>
  arrange(flag == "", name)

write.csv(gbif_name_check, here("data/processed/gbif_name_check.csv"), row.names = FALSE)
