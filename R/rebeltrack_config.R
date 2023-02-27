rebeltrack_config <- function() {
  config_file <- file.path(
    system.file("extData", package=methods::getPackageName()),
    "config.yml"
  )
  message(config_file)

  config <- yaml::yaml.load_file(config_file)
  return(config)
}

