library(Microsoft365R)

get_data <- function(path_env_var, dest_prefix) {
  site <- get_sharepoint_site(Sys.getenv("SHAREPOINT_SITE"))
  drv <- site$get_drive()

  remote_path <- Sys.getenv(path_env_var)
  if (remote_path == "") {
    stop(paste0("Missing env var: ", path_env_var, ". Check .Renviron"))
  }

  dest_path <- paste0("data/raw/", dest_prefix, "_", Sys.Date(), ".xlsx")

  drv$download_file(remote_path, dest = dest_path, overwrite = TRUE)

  return(dest_path)
}
