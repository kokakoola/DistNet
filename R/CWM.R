library(readxl)
library(dplyr)
library(tidyr)
library(here)

source(here("R/helpers/fetch_data.R"))

# Copy DistNet_Quadrat.xlsx from the synced SharePoint folder into data/raw/
quadrat_path <- get_data("SHAREPOINT_PATH_QUADRAT", "quadrat")
sheets <- c(forest = "Quadrat_Forest", grassland = "Quadrat_Grassland")

# Species kept in the CWM: mean cover across the habitat's 12 quadrats >= threshold
# (same as R/AM_intensity.R; final threshold still open, see docs/markmed.md)
cover_threshold <- 0.8

# Species rows only (numbered in the first column; general cover and
# bryophyte rows have no number). AM % = Excel column "AM intensity FungalRoot".
read_quadrat_species <- function(sheet) {
  x <- read_excel(
    quadrat_path,
    sheet = sheet,
    na = c("", "NA"),
    .name_repair = "unique_quiet"
  )
  names(x)[1] <- "row_no"
  am_col <- grep("^AM intensity", names(x), value = TRUE)

  x |>
    filter(!is.na(row_no)) |>
    select(
      species = Species,
      am = all_of(am_col),
      mean_cover = Mean_cover,
      matches("^[FG][0-9][YN]_cover$")
    ) |>
    pivot_longer(
      matches("^[FG][0-9][YN]_cover$"),
      names_to = "ring_id",
      values_to = "cover"
    ) |>
    mutate(
      ring_id = sub("_cover$", "", ring_id),
      cover = replace_na(cover, 0)
    )
}

quadrat_species <- bind_rows(
  lapply(sheets, read_quadrat_species),
  .id = "habitat"
)

# Community-weighted mean AM (%) of the 1 m2 quadrat, one row per ring.
# cover_share = cover of species above the threshold / cover of all species
# (how much of the community the CWM represents).
cwm <- quadrat_species |>
  mutate(keep = mean_cover >= cover_threshold) |>
  group_by(habitat, ring_id) |>
  summarise(
    cwm = weighted.mean(am[keep], w = cover[keep]),
    n_species = sum(keep & cover > 0),
    cover_share = sum(cover[keep]) / sum(cover),
    .groups = "drop"
  ) |>
  mutate(
    pair = substr(ring_id, 1, 2),
    treatment = ifelse(substr(ring_id, 3, 3) == "Y", "severed", "control"),
    habitat = factor(habitat),
    treatment = factor(treatment)
  )

stopifnot(
  !anyDuplicated(cwm$ring_id),
  !anyNA(cwm$cwm),
  # every kept species must have an AM value
  !anyNA(quadrat_species$am[quadrat_species$mean_cover >= cover_threshold])
)

write.csv(cwm, here("data", "processed", "cwm.csv"), row.names = FALSE)

# Does neighbourhood AM (CWM) differ between habitats and treatments?
# Reference plants have no quadrat, so treatment has only severed/control.
stopifnot(nlevels(cwm$treatment) == 2)

m_cwm <- lm(cwm ~ habitat * treatment, data = cwm)
summary(m_cwm)
anova(m_cwm)

par(mfrow = c(2, 2))
plot(m_cwm)
par(mfrow = c(1, 1))
