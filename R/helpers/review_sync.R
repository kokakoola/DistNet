source(here::here("R/helpers/fetch_data.R"))

# Copy a rendered docx into the synced Review folder; OneDrive uploads it
upload_review <- function(
  local_file = here::here("report/thesis/_book/DistNet_thesis.docx"),
  remote_dir = "Docs/Review"
) {
  if (!file.exists(local_file)) stop("File not found: ", local_file)
  dest <- sp_local(file.path(remote_dir, basename(local_file)))
  file.copy(local_file, dest, overwrite = TRUE)
  dest
}

# Copy the supervisor-edited docx back into review/
download_review <- function(
  file_name = "DistNet_thesis.docx",
  remote_dir = "Docs/Review",
  dest_dir = here::here("review")
) {
  dir.create(dest_dir, showWarnings = FALSE)
  src <- sp_local(file.path(remote_dir, file_name))
  if (!file.exists(src)) stop("File not found: ", src)
  dest <- file.path(dest_dir, file_name)
  file.copy(src, dest, overwrite = TRUE)
  dest
}
