#' Download Datasets
#'
#' Download all datasets to local storage
#' @examples
#' library(rebeltrack)
#'
#' \dontrun{
#' rebeltrack_download()
#' }
#' @export
rebeltrack_download <- function() {
  config <- rebeltrack_config()

  for (i in seq_along(config$datasets)) {
    dataset <- config$datasets[[i]]

    for (j in seq_along(dataset)) {
      name <- list(names(config$datasets)[i], names(dataset)[j])
      dest <- file.path(config$path, do.call(file.path, name))
      rebeltrack_download_dataset(paste(name, collapse="/"), dataset[[j]], dest)
    }
  }
}

# rebeltrack_download_dataset - download a single dataset
rebeltrack_download_dataset <- function(name, source, dest) {
  temp_dir <- tempfile("rebeltrack_")
  if (!dir.exists(temp_dir))
    dir.create(temp_dir)

  parsed_url <- httr::parse_url(source$url)
  if (!is.null(source$query))
    parsed_url$query <- source$query

  url <- httr::build_url(parsed_url)

  filename <- basename(parsed_url$path)
  if (!is.null(source$basename))
    filename <- source$basename

  temp_filename <- file.path(temp_dir, filename)

  message("downloading: ", name)
  message("       from: ", url)
  message("         to: ", temp_dir)
  result <- httr::GET(url,
                      httr::write_disk(temp_filename, overwrite=TRUE),
                      httr::progress())
  if (result$status_code != 200)
    stop(paste("GET failed: error code =", result$status_code))

  if (!dir.exists(dest)) {
    message("creating: ", dest)
    dir.create(dest, recursive = TRUE)
  }

  ext <- tolower(tools::file_ext(temp_filename))
  if (ext == "zip")
    utils::unzip(temp_filename, exdir = temp_dir)

  rebeltrack_convert_to_rds(temp_dir, dest)
}

# rebeltrack_load - load a single dataset
rebeltrack_load <- function(path) {
  ext <- tolower(tools::file_ext(path))
  if (ext == "csv")
    return(as.data.frame(readr::read_csv(path)))

  if (ext == "xlsx")
    return(as.data.frame(readxl::read_xlsx(path)))

  if (ext == "rdata") {
    env <- new.env()
    vars <- load(path, envir = env, verbose = FALSE)
    data <- get(vars[1], envir = env)
    rm(env)
    return(data)
  }

  return(NULL)
}

# rebeltrack_convert_to_rds - convert a dataset to .rds
rebeltrack_convert_to_rds <- function(source, dest) {
  files <- list.files(source)
  for (file in files) {
    data <- rebeltrack_load(file.path(source, file))

    if (!is.null(data)) {
      filename <- paste(tools::file_path_sans_ext(file), "rds", sep=".")
      target <- file.path(dest, filename)
      message("saving: ", target, "\n")
      saveRDS(data, target)
    }
  }
}




