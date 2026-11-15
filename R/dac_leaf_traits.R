library(readxl)
library(dplyr)
library(here)

source(here("R/helpers/fetch_data.R"))

# Dactylis glomerata leaf traits (SLA, LDMC) per ring and habitat x treatment
# models. One pooled leaf sample per ring (no focal plant in Dactylis).
# Methods: report/thesis/_metoodika_funktsionaalsed_naitajad_Dac.qmd
# Results saved to data/processed/dac_leaf_traits.rda and shown in
# report/thesis/_tulemused_funktsionaalsed_naitajad_Dac.qmd.

# Copy DistNet_Biomass.xlsx from the synced SharePoint folder into data/raw/
biomass_path <- get_data("SHAREPOINT_PATH_BIOMASS", "biomass")

# Weights: leaf_wet_weight and leaf_dry_micro (g) are the scanned leaf blades;
# leaf_dry_micro (microbalance) is used, not leaf_dry_weight
dac_weight <- read_excel(biomass_path, sheet = "Dac_weight_all", na = c("", "NA"))

# Leaf area from Fiji macro 02_leaf_area.ijm; file "F1_N_004" -> ring_id "F1N"
dac_leaf_area <- read_excel(biomass_path, sheet = "Dac_LeafResults", na = c("", "NA")) |>
  mutate(ring_id = sub("^([FG][0-9])_([YN]).*", "\\1\\2", file))

dac_leaf <- dac_weight |>
  select(ring_id, leaf_wet_weight, leaf_dry_micro) |>
  inner_join(
    select(dac_leaf_area, ring_id, leaf_area_mm2, n_pieces),
    by = "ring_id"
  ) |>
  mutate(
    across(c(leaf_wet_weight, leaf_dry_micro), as.numeric),
    habitat = factor(ifelse(substr(ring_id, 1, 1) == "F", "forest", "grassland")),
    treatment = factor(
      ifelse(substr(ring_id, 3, 3) == "Y", "severed", "control"),
      levels = c("control", "severed")
    ),
    pair = substr(ring_id, 1, 2),
    sla = leaf_area_mm2 / (leaf_dry_micro * 1000), # mm2 mg-1
    ldmc = leaf_dry_micro * 1000 / leaf_wet_weight # mg g-1
  )

stopifnot(
  nrow(dac_leaf) == 24,
  !anyDuplicated(dac_leaf$ring_id),
  !anyNA(select(dac_leaf, sla, ldmc))
)

# Group means and standard errors
dac_leaf_summary <- dac_leaf |>
  group_by(habitat, treatment) |>
  summarise(
    n = n(),
    sla_mean = mean(sla),
    sla_se = sd(sla) / sqrt(n()),
    ldmc_mean = mean(ldmc),
    ldmc_se = sd(ldmc) / sqrt(n()),
    .groups = "drop"
  )

m_sla <- lm(sla ~ habitat * treatment, data = dac_leaf)
m_ldmc <- lm(ldmc ~ habitat * treatment, data = dac_leaf)

anova(m_sla)
anova(m_ldmc)
shapiro.test(resid(m_sla))
shapiro.test(resid(m_ldmc))

save(
  dac_leaf,
  dac_leaf_summary,
  m_sla,
  m_ldmc,
  file = here("data/processed/dac_leaf_traits.rda")
)
