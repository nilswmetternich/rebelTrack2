rebeltrack_summary_stats <- function(data, func, na.rm, ...) {
  args <- list(data, ...) # func is passed in is mean, median, min, max ect - finds mean. na.rm - is boolean but dont
  if (length(args) == 1 & na.rm) { # know what does. na.rm controls if true. na. rm in r refers to the logical parameter that tells the function whether or not to remove NA values from the calculation. It literally means NA remove. It is neither a function nor an operation.
    if (identical(func, mean) | identical(func, median) |
        identical(func, min) |  identical(func, max)) {
      args <- list(data, na.rm = na.rm)
    }
  }
  do.call(func, args) # do.call constructs and executes a function call from a name or a function and a list of arguments to be passed to it.
}
