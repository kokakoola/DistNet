# SharePoint is accessed through the OneDrive sync folder (SHAREPOINT_LOCAL
# in .Renviron), not the Graph API -- UT Conditional Access blocks Microsoft365R.

# Absolute local path of a file inside the synced SharePoint library
sp_local <- function(rel_path) {
  root <- Sys.getenv("SHAREPOINT_LOCAL")
  if (root == "") {
    stop("Missing env var: SHAREPOINT_LOCAL. Check .Renviron")
  }
  if (!dir.exists(root)) {
    stop("SharePoint sync folder not found: ", root, ". Is OneDrive running?")
  }
  file.path(root, rel_path)
}

get_data <- function(path_env_var, dest_prefix) {
  remote_path <- Sys.getenv(path_env_var)
  if (remote_path == "") {
    stop(paste0("Missing env var: ", path_env_var, ". Check .Renviron"))
  }

  src <- sp_local(remote_path)
  if (!file.exists(src)) stop("File not found: ", src)

  dest_path <- here::here(
    "data", "raw", paste0(dest_prefix, "_", Sys.Date(), ".xlsx")
  )
  file.copy(src, dest_path, overwrite = TRUE)

  return(dest_path)
}
