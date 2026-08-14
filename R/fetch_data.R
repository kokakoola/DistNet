library(Microsoft365R)

get_latest_data <- function() {
  site <- get_sharepoint_site("BioticNovelty-Mare")
  drv <- site$get_drive()

  dest_path <- paste0("data/raw/DistNet_", Sys.Date(), ".xlsx")

  drv$download_file(
    "Mare/MasterThesis/RawData/Fieldwork/DistNet_MasterData.xlsx",
    dest = dest_path,
    overwrite = TRUE
  )

  return(dest_path)
}

# Check:
# raw_file <- get_latest_data()
# print(raw_file) # "data/raw/DistNet_2026-08-13.xlsx"
# file.exists(raw_file) # TRUE
