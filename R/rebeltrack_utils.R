#' new
#'
#' @name new
#' @rdname new
#' @keywords internal
#' @importFrom methods new
#' @usage new
NULL

#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

#' Within operator
#'
#' @name %within%
#' @rdname within
#' @keywords internal
#' @importFrom lubridate %within%
#' @usage lhs \%within\% rhs
NULL

#' Format variable name for side A or B
#'
#' @param pattern Format string
#' @param side Side A/B or 1/2
#' @keywords internal
#'
get_var_by_side <- function(pattern, side) {
  sides <- base::letters[1:2]

  if (is.character(side) & nchar(side)==1) {
    side <- tolower(side)
    side <- utf8ToInt(side) - utf8ToInt(letters[1]) +1
  }

  if (!is.numeric(side) | side < 1 | side > 2)
    stop("side must be one of: {SIDE_A or SIDE_B} or {'A' or 'B'} or {'a' or 'b'} or {1 or 2}")

  sprintf(pattern, sides)[side]
}

#' Calculate lead/lag
#'
#' @param x A vector of values
#' @param n Positive or negative integer giving the number of positions to lead or lag by
#' @param order_by Override the default ordering to use another vector
#' @keywords internal
#'
lead_lag <- function(x, n, order_by) {
  if (n < 0)
    x <- dplyr::lead(x, n = as.integer(abs(n)), order_by = order_by)
  else if (n > 0)
    x <- dplyr::lag(x, n = n, order_by = order_by)
  return(x)
}

#' Apply weight matrix
#'
#' @param x x A \code{RebelTrackDataFrame} object
#' @param w Weight matrix of NxNxT dimension
#' @param n_actors Number of actors in the panel
#' @param n_periods Number of time periods in the panel
#' @keywords internal
#'
weight_apply <- function(x, w, n_actors, n_periods) {

  if (is.null(w))
    return(x) # if null  weights do nothing i.e dont lag.

  wdim <- dim(w) # dimensions of the weight matrix - god knows where it comes from

  # replicate T times if w is NxN
  if (length(wdim) == 2)
    w <- array(w, dim = c(wdim, n_periods))

  wdim <- dim(w)

  # must be a 3-D array of NxNxT by now
  if (length(wdim) != 3 || any(wdim != c(n_actors, n_actors, n_periods))) {
    stop(sprintf("invalid dimension '%s' for weight matrix", paste(wdim, collapse = " x ")))
  }

  var <- x$.var

  # split the data into T-size vectors and change NAs to 0
  a <- array(var, dim = wdim[-1])
  a[is.na(a)] <- 0
  print(dim(a))
  # apply the weights
  wx <- as.vector(sapply(seq(n_periods), function(i) {
    t(a[,i]) %*% w[,,i]
  }))

  # set NAs back to NA
  wx[is.na(var)] <- NA

  x %>%
    dplyr::mutate(.var = wx)
}

#' Apply weight matrix for Gid Class
#'
#' @param x x A \code{RebelTrackDataFrameGid} object
#' @param w Weight matrix of NxNxT dimension - must be a slam simple sparse array
#' @param n_actors Number of actors in the panel
#' @param n_periods Number of time periods in the panel
#' @keywords internal
#'
weight_apply_gid <- function(x, w, n_actors, n_periods) {


  if (is.null(w))
    return(x) # if null  weights do nothing i.e dont lag.

  wdim <- dim(w) # dimensions of the weight matrix


  # replicate T times if w is NxN
  if (length(wdim) == 2)
    w <- array(w, dim = c(wdim, n_periods))

  wdim <- dim(w)
  # x@dataset@events$priogrid_gid
  n_grids = length(unique(x$priogrid_gid))

  # must be a 3-D array of NxNxT by now
  if (length(wdim) != 3 || any(wdim != c(n_grids, n_grids, n_periods))) {
    stop(sprintf("invalid dimension '%s' for weight matrix", paste(wdim, collapse = " x ")))
  }

  var <- x$.var

  # split the data into T-size vectors and change NAs to 0
  a <- array(var, dim = wdim[-1])
  a[is.na(a)] <- 0

  # apply the weights
  wx <- as.vector(sapply(seq(n_periods), function(i) {
    # slam::matprod_simple_triplet_matrix(as.simple_triplet_matrix(t(a[,i])) , as.simple_triplet_matrix(w[,,i]))
    t(a[,i]) %*% as.matrix(drop(as.array(w[,,i])))

  }))

  # set NAs back to NA
  wx[is.na(var)] <- NA

  x %>%
    dplyr::mutate(.var = wx)
}

#' Calculate weighted lag
#'
#' @param x A \code{RebelTrackDataFrame} object
#' @param var Name of the variable to create
#' @param group Grouped dataset
#' @param group_summary Variable specific group summary
#' @param fill Default value when no events are observed in the specified period.
#' @param lag An integer giving the number of positions to lead or lag by.
#' @param weight A weight matrix to apply.
#' @keywords internal
#'
weighted_lag <- function(x, var, group, group_summary, fill, lag, weight) {
  group_vars <- attributes(group)$vars

  x %>%
    as.data.frame() %>%
    dplyr::left_join(group_summary, by = group_vars) %>%
    dplyr::mutate(.var = ifelse(is.na(.var) & active, fill, .var)) %>%
    dplyr::group_by(actor) %>%
    dplyr::mutate(.var = lead_lag(.var, lag, order_by = period_start)) %>%
    dplyr::ungroup() %>%
    weight_apply(weight, x@n_actors, x@n_periods) %>%
    dplyr::mutate(!!var := .var) %>%
    dplyr::select(-.var)
}

#' Calculate weighted lag for Gid Dataframe
#'
#' @param x A \code{RebelTrackDataFrameGid} object
#' @param var Name of the variable to create
#' @param group Grouped dataset
#' @param group_summary Variable specific group summary
#' @param fill Default value when no events are observed in the specified period.
#' @param lag An integer giving the number of positions to lead or lag by.
#' @param weight A weight matrix to apply.
#' @keywords internal
#'
weighted_lag_gid <- function(x, var, group, group_summary, fill, lag, weight) {
  group_vars <- attributes(group)$vars

  x %>%
    as.data.frame() %>%
    dplyr::left_join(group_summary, by = group_vars) %>%
    dplyr::mutate(.var = ifelse(is.na(.var) & active, fill, .var)) %>% # if active - ensures balanced = TRUE still lags properly
    dplyr::group_by(priogrid_gid) %>%
    dplyr::mutate(.var = lead_lag(.var, lag, order_by = period_start)) %>%
    dplyr::ungroup() %>%
    weight_apply_gid(weight, x@n_actors, x@n_periods) %>%
    dplyr::mutate(!!var := .var) %>%
    dplyr::select(-.var)
}

