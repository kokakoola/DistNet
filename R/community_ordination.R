library(readxl)
library(dplyr)
library(tibble)
library(vegan)
library(here)

source(here("R/helpers/fetch_data.R"))

# Community composition: NMDS, PERMANOVA and partial dbRDA.
# Analysis by the supervisor (originally report/thesis/_quadrat.qmd); object
# names kept as in the original. Results are saved to
# data/processed/community.rda and plotted in report/thesis/_tulemused_kooslused.qmd.

# Copy DistNet_Quadrat.xlsx from the synced SharePoint folder into data/raw/.
# Sheet "Community" was regenerated from the Quadrat_* sheets on 2026-11-14
# (forest block was shifted by one column, see docs/markmed.md).
quadrat_path <- get_data("SHAREPOINT_PATH_QUADRAT", "quadrat")

Distnet_comm <- read_excel(quadrat_path, sheet = "Community", na = c("", "NA"))
Distnet_meta <- read_excel(quadrat_path, sheet = "Meta", na = c("", "NA"))

# Checks: rows in the same order, one column per species, no gaps
stopifnot(
  identical(Distnet_comm$Code, Distnet_meta$Code),
  !anyDuplicated(names(Distnet_comm)),
  !anyNA(Distnet_comm)
)

Distnet_mat <- Distnet_comm |>
  column_to_rownames("Code")

# NMDS (Bray-Curtis)
set.seed(123)
nmds <- metaMDS(
  Distnet_mat,
  distance = "bray",
  k = 2,
  try = 100,
  trymax = 1000
)
# Warning message:
# In metaMDS(Distnet_mat, distance = "bray", k = 2, try = 100, trymax = 1000) :
#   stress is (nearly) zero: you may have insufficient data

# NMDS separately for habitats (rows selected by Habitat; species absent from
# the habitat dropped)
habitat_mat <- function(h) {
  m <- Distnet_mat[Distnet_meta$Habitat == h, ]
  m[, colSums(m) > 0]
}
set.seed(123)
ndms_G <- metaMDS(
  habitat_mat("Grassland"),
  distance = "bray",
  k = 2,
  try = 100,
  trymax = 1000
)
set.seed(123)
ndms_F <- metaMDS(
  habitat_mat("Forest"),
  distance = "bray",
  k = 2,
  try = 100,
  trymax = 1000
)

# PERMANOVA within each habitat: treatment effect, permutations restricted
# within ring pairs (pair = "G1", "F3", ...; one severed + one control ring)
Distnet_meta <- Distnet_meta |>
  mutate(Pair = substr(Code, 1, 2))
habitat_permanova <- function(h) {
  meta_h <- Distnet_meta[Distnet_meta$Habitat == h, ]
  set.seed(123)
  adonis2(
    habitat_mat(h) ~ Treatment,
    data = meta_h,
    method = "bray",
    permutations = permute::how(blocks = meta_h$Pair, nperm = 999)
  )
}
permanova_G <- habitat_permanova("Grassland")
permanova_F <- habitat_permanova("Forest")

# PERMANOVA: main effects and interaction, terms tested sequentially
set.seed(123)
permanova_model <- adonis2(
  Distnet_mat ~ Habitat * Treatment,
  data = Distnet_meta,
  method = "bray",
  by = "terms",
  permutations = 999
)

# Partial dbRDA: treatment effect after removing habitat
dbrda_model <- dbrda(
  Distnet_mat ~ Treatment + Condition(Habitat),
  data = Distnet_meta,
  distance = "bray"
)
set.seed(123)
dbrda_anova <- anova(dbrda_model, permutations = 999)

print(permanova_model)
print(dbrda_anova)
print(permanova_G)
print(permanova_F)

save(
  Distnet_mat,
  Distnet_meta,
  nmds,
  ndms_G,
  ndms_F,
  permanova_model,
  permanova_G,
  permanova_F,
  dbrda_model,
  dbrda_anova,
  file = here("data/processed/community.rda")
)
