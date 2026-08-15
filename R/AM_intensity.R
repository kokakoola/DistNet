library(readxl)
library(readr)
library(dplyr)
library(purrr)
library(stringr)
library(here)

# ============================================================
# 1. Quadrat lookup: millised liigid loevad forest/grassland kategooriasse
#    (naabertaimede kooslus, katvuse lävend 0.8%)
# ============================================================
cover_threshold <- 0.8

forest_quadrat <- read_excel(
  here("data", "raw", "DistNet_2026-08-15.xlsx"),
  sheet = "Quadrat_Forest"
)
grassland_quadrat <- read_excel(
  here("data", "raw", "DistNet_2026-08-15.xlsx"),
  sheet = "Quadrat_Grassland"
)

forest_species <- forest_quadrat %>%
  filter(Mean_cover >= cover_threshold) %>%
  distinct(Species) %>%
  mutate(needed_habitat = "forest")

grassland_species <- grassland_quadrat %>%
  filter(Mean_cover >= cover_threshold) %>%
  distinct(Species) %>%
  mutate(needed_habitat = "grassland")

species_habitat_lookup <- bind_rows(forest_species, grassland_species)

# ============================================================
# 2. FungalRoot: kõik liigi-CSV-d
# ============================================================
files <- list.files(
  here("data", "raw", "FungalRoot"),
  pattern = "\\.csv$",
  full.names = TRUE
)

fungalroot <- map_dfr(files, read_csv, show_col_types = FALSE)

# McGonigle + biome-tähistatud kirjed (forest = coniferous + broadleaf kokku)
fungalroot_clean <- fungalroot %>%
  filter(`AM method` == "McGonigle et al. 1990: RLC (%)") %>%
  filter(!is.na(`AM intensity`)) %>%
  mutate(
    habitat_class = case_when(
      str_detect(
        Habitat,
        "temperate coniferous forest|temperate broadleaf forest"
      ) ~ "forest",
      str_detect(Habitat, "temperate grassland") ~ "grassland",
      TRUE ~ NA_character_
    )
  ) %>%
  rename(species = ID, am_intensity = `AM intensity`)

# kõik McGonigle kirjed liigi kohta, olenemata biomist (fallback-andmestik)
fungalroot_all_mcgonigle <- fungalroot %>%
  filter(`AM method` == "McGonigle et al. 1990: RLC (%)") %>%
  filter(!is.na(`AM intensity`)) %>%
  rename(species = ID, am_intensity = `AM intensity`)

# ============================================================
# 3. Ühenda quadrat-lookup + FungalRoot
# ============================================================

# 3a. Biome-spetsiifiline vaste
fungalroot_habitat_specific <- fungalroot_clean %>%
  filter(!is.na(habitat_class)) %>%
  inner_join(
    species_habitat_lookup,
    by = c("species" = "Species", "habitat_class" = "needed_habitat")
  ) %>%
  mutate(data_source = "habitat-specific")

# 3b. Liik-kasvukoha kombinatsioonid, millel biome-spetsiifiline andmestik puudub
missing_combos <- species_habitat_lookup %>%
  rename(species = Species, habitat_class = needed_habitat) %>%
  anti_join(fungalroot_habitat_specific, by = c("species", "habitat_class"))

missing_combos # kontrolliks

# 3c. Fallback: kõik McGonigle kirjed neile kombodele, olenemata biomist
fungalroot_fallback <- fungalroot_all_mcgonigle %>%
  inner_join(missing_combos, by = "species") %>%
  mutate(data_source = "general (no biome match)")

# 3d. Kokku
fungalroot_final <- bind_rows(fungalroot_habitat_specific, fungalroot_fallback)

# ============================================================
# 4. Tõeliselt puuduvad liigid (pole ühtegi McGonigle kirjet üldse)
#    -> need vajavad ise mikroskoopimist
# ============================================================
truly_missing_species <- species_habitat_lookup %>%
  distinct(Species) %>%
  anti_join(fungalroot_all_mcgonigle, by = c("Species" = "species"))

truly_missing_species

# ============================================================
# 5. Liigi keskmine kasvukoha kaupa
# ============================================================
species_means <- fungalroot_final %>%
  group_by(species, habitat_class) %>%
  summarise(
    mean_am = mean(am_intensity, na.rm = TRUE),
    n = n(),
    data_source = first(data_source),
    .groups = "drop"
  ) %>%
  mutate(override_reason = NA_character_)

# ============================================================
# 6. Käsitsi ülekirjutused (ökoloogilise teadmise põhjal)
# ============================================================
manual_overrides <- tribble(
  ~species               , ~habitat_class , ~mean_am , ~override_reason                                                                                                  ,
  "Orthilia secunda"     , "forest"       ,        0 , "Predominantly EcM/NM, ecologically implausible AM host"                                                          ,
  "Melampyrum nemorosum" , "forest"       ,        0 , "Hemiparasitic, predominantly NM/EcM"                                                                             ,
  "Chimaphila umbellata" , "forest"       ,        0 , "Pyroloideae, arbutoid/NM; sole AM record from subpolar biome, geographically mismatched to 58°N hemiboreal site"
)

# lisan kui on mikroskoobitud
# manual_overrides <- manual_overrides %>%
#   bind_rows(
#     tribble(
#       ~species                   , ~habitat_class , ~mean_am , ~override_reason                          ,
#       "Carex disticha"           , "forest"       , XX       , "Measured by author (microscopy), [date]" ,
#       "Helictotrichon pratensis" , "grassland"    , XX       , "Measured by author (microscopy), [date]" ,
#       "Artemisia campestris"     , "forest"       , XX       , "Measured by author (microscopy), [date]" ,
#       "Pulsatilla pratensis"     , "grassland"    , XX       , "Measured by author (microscopy), [date]"
#     )
#   )

species_means_final <- species_means %>%
  rows_upsert(manual_overrides, by = c("species", "habitat_class"))

species_means_final

# ============================================================
# 7. Kasvukoha keskmine (iga liik võrdselt kaalutud)
# ============================================================
habitat_means <- species_means_final %>%
  group_by(habitat_class) %>%
  summarise(
    mean_am = mean(mean_am, na.rm = TRUE),
    n_species = n(),
    .groups = "drop"
  )

habitat_means

# Kokkuvõtlik tabel viitamiseks, Appendix
species_means_final %>%
  select(species, habitat_class, mean_am, n, data_source, override_reason) %>%
  arrange(habitat_class, species)
