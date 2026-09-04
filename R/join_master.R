# How the domain files (Traits / Quadrat / Colonization) pick up ring and
# plant metadata from DistNet_MasterData.xlsx.
#
# Key idea: no cross-file Excel formulas. Each domain file on SharePoint
# only stores an ID column (plant_id or ring_id) -- never species/habitat/
# treatment directly. All joining happens here, in R, every time the
# pipeline runs, using dplyr::left_join(). Fix a mistake once in
# MasterData's "rings"/"plants" sheet, and every downstream file picks up
# the correction on the next run -- nothing to hunt down across 4 files.

library(readxl)
library(dplyr)
library(here)

# 1. Download all four workbooks from SharePoint (extends the existing
#    get_latest_data() pattern in fetch_data.R to loop over multiple files
#    instead of just one).
# site <- Microsoft365R::get_sharepoint_site("BioticNovelty-Mare")
# drv <- site$get_drive()

# files <- c(
#   master = "Mare/MasterThesis/RawData/Fieldwork/DistNet_MasterData.xlsx",
#   traits = "Mare/MasterThesis/RawData/Fieldwork/DistNet_Traits.xlsx",
#   quadrat = "Mare/MasterThesis/RawData/Fieldwork/DistNet_Quadrat.xlsx",
#   colonization = "Mare/MasterThesis/RawData/Fieldwork/DistNet_Colonization.xlsx"
# )

get_env <- function(var) {
  val <- Sys.getenv(var, unset = NA)
  if (is.na(val) || val == "") {
    stop("Missing environment variable: ", var, " (check .Renviron)")
  }
  val
}

site <- Microsoft365R::get_sharepoint_site(get_env("SHAREPOINT_SITE"))
drv <- site$get_drive()

files <- c(
  master = get_env("SHAREPOINT_PATH_MASTER"),
  traits = get_env("SHAREPOINT_PATH_TRAITS"),
  quadrat = get_env("SHAREPOINT_PATH_QUADRAT"),
  colonization = get_env("SHAREPOINT_PATH_COLONIZATION")
)

local_paths <- setNames(
  here("data", "raw", basename(files)),
  names(files)
)

for (nm in names(files)) {
  drv$download_file(files[[nm]], dest = local_paths[[nm]], overwrite = TRUE)
}

# 2. Read the two reference sheets from MasterData.
rings <- read_excel(local_paths["master"], sheet = "rings")
plants <- read_excel(local_paths["master"], sheet = "plants")

# plants already carries ring_id, so attach habitat/treatment to it once,
# here, rather than re-joining "rings" separately in every downstream script.
plants_full <- plants |>
  left_join(rings, by = "ring_id")

# 3. Example: Traits data only has plant_id + measurements -- attach
#    species/ring/habitat/treatment via plants_full.
# traits_raw <- read_excel(local_paths["traits"], sheet = "2026-06-16")
# traits_full <- traits_raw |> left_join(plants_full, by = "plant_id")

# 4. Example: Quadrat data is at the ring level, not the plant level -- it
#    joins directly against "rings", not "plants".
# quadrat_raw <- read_excel(local_paths["quadrat"], sheet = "2026-06-16")
# quadrat_full <- quadrat_raw |> left_join(rings, by = "ring_id")

# Sanity check worth running after every MasterData edit: every plant_id
# used in a domain file should actually exist in plants_full, and every
# ring_id should exist in rings. An orphaned ID almost always means a typo
# in either the domain file or MasterData.
# stopifnot(all(traits_full$plant_id %in% plants_full$plant_id))
