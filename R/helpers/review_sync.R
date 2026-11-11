source(here::here("R/helpers/fetch_data.R"))

# Review cycle: render docx -> upload_review() -> supervisor edits in Word
# Online -> download_review() -> read_review() -> move edits into the .qmd by hand

# Copy a rendered docx into the synced Review folder; OneDrive uploads it.
# The file gets a version and date, e.g. DistNet_thesis_v2_2026-11-11.docx or
# metoodika_v1_2026-11-11.docx (chapter number prefix "02-" is dropped).
# version = NULL picks the next free version for that name. Never overwrites,
# so a copy the supervisor is already editing cannot be lost.
upload_review <- function(
  local_file = here::here("report/thesis/_book/DistNet_thesis.docx"),
  version = NULL,
  remote_dir = "Docs/Review"
) {
  if (!file.exists(local_file)) stop("File not found: ", local_file)

  stem <- sub("^[0-9]+-", "", tools::file_path_sans_ext(basename(local_file)))
  review_dir <- sp_local(remote_dir)

  if (is.null(version)) {
    existing <- list.files(review_dir, pattern = paste0("^", stem, "_v[0-9]+_"))
    used <- as.integer(sub(paste0("^", stem, "_v([0-9]+)_.*"), "\\1", existing))
    version <- max(c(0L, used)) + 1L
  }

  dest <- file.path(
    review_dir,
    paste0(stem, "_v", version, "_", Sys.Date(), ".docx")
  )
  if (file.exists(dest)) stop("Already exists, not overwriting: ", dest)

  file.copy(local_file, dest)
  dest
}

# Copy the supervisor-edited docx back into review/ (gitignored).
# file_name = NULL takes the most recently modified docx in the Review folder.
download_review <- function(
  file_name = NULL,
  remote_dir = "Docs/Review",
  dest_dir = here::here("review")
) {
  review_dir <- sp_local(remote_dir)
  if (is.null(file_name)) {
    docs <- list.files(review_dir, pattern = "\\.docx$", full.names = TRUE)
    if (length(docs) == 0) stop("No docx files in ", review_dir)
    file_name <- basename(docs[which.max(file.mtime(docs))])
  }

  dir.create(dest_dir, showWarnings = FALSE)
  src <- file.path(review_dir, file_name)
  if (!file.exists(src)) stop("File not found: ", src)
  dest <- file.path(dest_dir, file_name)
  file.copy(src, dest, overwrite = TRUE)
  dest
}

# Convert a reviewed docx to markdown with tracked changes and comments kept
# (pandoc --track-changes=all, via Quarto's bundled pandoc). Insertions,
# deletions and comments show up as spans, e.g. [text]{.insertion author=...}.
# Writes review/<name>.md next to the docx and returns its path.
read_review <- function(docx) {
  if (!file.exists(docx)) stop("File not found: ", docx)
  out <- sub("\\.docx$", ".md", docx)
  status <- system2(
    "quarto",
    c("pandoc", "--track-changes=all", shQuote(docx), "-t", "markdown",
      "-o", shQuote(out))
  )
  if (status != 0) stop("pandoc failed on ", docx)
  out
}
