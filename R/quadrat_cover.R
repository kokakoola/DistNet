library(readxl)
library(dplyr)
library(tidyr)
library(here)

source(here("R/helpers/fetch_data.R"))

# Was the neighbourhood community around severed rings altered (e.g. by
# trampling during weekly severing)? Quadrats were surveyed 26-27 July 2026,
# after severing had started, so treatment differences may not be baseline.

quadrat_path <- get_data("SHAREPOINT_PATH_QUADRAT", "quadrat")
sheets <- c(forest = "Quadrat_Forest", grassland = "Quadrat_Grassland")

# Sheet layout: row 1 = general vascular cover (quadrat minus d = 15 cm ring),
# row 2 = bryophytes, then one row per species (numbered in the first column).
# Each ring has a "<ring_id>_cover" column.
read_quadrat <- function(sheet) {
  x <- read_excel(
    quadrat_path,
    sheet = sheet,
    na = c("", "NA"),
    .name_repair = "unique_quiet"
  )
  names(x)[1] <- "row_no"
  cover_cols <- grep("^[FG][0-9][YN]_cover$", names(x), value = TRUE)

  list(
    general = x[1, cover_cols],
    bryo = x[2, cover_cols],
    species = x |>
      filter(!is.na(row_no)) |>
      select(species = Species, all_of(cover_cols)) |>
      pivot_longer(-species, names_to = "ring_id", values_to = "cover") |>
      mutate(
        ring_id = sub("_cover$", "", ring_id),
        cover = replace_na(cover, 0)
      )
  )
}

quadrat <- lapply(sheets, read_quadrat)

# Ring IDs: F/G = habitat, digit = pair, Y = severed, N = control
add_design <- function(d) {
  d |>
    mutate(
      habitat = ifelse(substr(ring_id, 1, 1) == "F", "forest", "grassland"),
      pair = substr(ring_id, 1, 2),
      treatment = ifelse(substr(ring_id, 3, 3) == "Y", "severed", "control")
    )
}

# ------------------------------------------------------------
# 1. Total cover per ring
# ------------------------------------------------------------
cover <- bind_rows(lapply(quadrat, function(q) {
  tibble(
    ring_id = sub("_cover$", "", names(q$general)),
    general = unlist(q$general),
    bryo = unlist(q$bryo)
  ) |>
    left_join(
      q$species |>
        group_by(ring_id) |>
        summarise(sum_species = sum(cover), n_species = sum(cover > 0)),
      by = "ring_id"
    )
})) |>
  add_design()

cover |>
  group_by(habitat, treatment) |>
  summarise(
    across(c(general, bryo, sum_species, n_species), mean),
    .groups = "drop"
  )
#   A tibble: 4 × 6
#   habitat   treatment general  bryo sum_species n_species
#   <chr>     <chr>       <dbl> <dbl>       <dbl>     <dbl>
# 1 forest    control      25    62          26        13.2
# 2 forest    severed      19.2  60.8        27.5       9.5
# 3 grassland control      81.7  69.2       139.       20.5
# 4 grassland severed      79.2  71.7       144.       21.8

# Paired severed - control differences within each pair
cover_pairs <- cover |>
  select(habitat, pair, treatment, general, sum_species, n_species) |>
  pivot_wider(
    names_from = treatment,
    values_from = c(general, sum_species, n_species)
  ) |>
  mutate(
    d_general = general_severed - general_control,
    d_sum_species = sum_species_severed - sum_species_control,
    d_n_species = n_species_severed - n_species_control
  )
cover_pairs

# Paired Wilcoxon signed-rank tests (n = 6 pairs per habitat; ties -> no exact p)
cover_tests <- cover_pairs |>
  group_by(habitat) |>
  summarise(
    p_general = suppressWarnings(wilcox.test(d_general)$p.value),
    p_sum_species = suppressWarnings(wilcox.test(d_sum_species)$p.value),
    p_n_species = suppressWarnings(wilcox.test(d_n_species)$p.value)
  )
cover_tests

# # A tibble: 2 × 4
#   habitat   p_general p_sum_species p_n_species
#   <chr>         <dbl>         <dbl>       <dbl>
# 1 forest        0.181         0.844      0.0591
# 2 grassland     0.581         0.688      0.496

write.csv(
  cover,
  here("data", "processed", "quadrat_cover.csv"),
  row.names = FALSE
)

# ------------------------------------------------------------
# 2. Which species are missing from severed quadrats?
# ------------------------------------------------------------
species_pairs <- bind_rows(lapply(quadrat, `[[`, "species")) |>
  add_design() |>
  select(habitat, pair, species, treatment, cover) |>
  pivot_wider(names_from = treatment, values_from = cover) |>
  filter(control > 0 | severed > 0)

# Per species: in how many pairs it occurs only in control / only in severed
species_shift <- species_pairs |>
  group_by(habitat, species) |>
  summarise(
    n_pairs = n(),
    only_control = sum(control > 0 & severed == 0),
    only_severed = sum(severed > 0 & control == 0),
    mean_cover_control = mean(control),
    mean_cover_severed = mean(severed),
    .groups = "drop"
  ) |>
  mutate(net_loss = only_control - only_severed) |>
  arrange(habitat, desc(net_loss))

species_shift |> filter(net_loss != 0) |> print(n = Inf)

write.csv(
  species_shift,
  here("data", "processed", "quadrat_species_shift.csv"),
  row.names = FALSE
)
