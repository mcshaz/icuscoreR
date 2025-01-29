#' Assign scores to a vector
#'
#' Assign a scoring system across a vector based on arbitrary cut-points and scores corresponding to each of the intervals
#'
#' assign_scores
#' @return A vector of the same length as x, scored according to arguments provided
#' @param x A vector of values which should be assigned the relevant score, according to the partitions defined by 'delimiters'
#' @param delimiters A vector containing the partition boundaries
#' @param score_assigned The score associated with the partitions provided with the
#' delimiters parameter. The first argument is assigned if the value of x is less that
#' the value of the first delimiter, and the last value assigned if x is greater than the
#' final delimiter. The length of the score.assigned vector should be 1 element greater than the delimiters vector
#' @param rightmost_closed whether the delimiters are right closed. The default is false
#' meaning if the value is equal to the first delimiter, the 2nd score is assigned
#' and if equal to the last delimiter, the final score is assigned
#' @examples
#' assign_scores(1:20, c(3, 11, 14), c(0, 4, 7, 9))
#' @family clinical_scoring_utilities
#' @export
assign_scores <- function(x, delimiters, score_assigned, rightmost_closed = FALSE) {
  if (length(delimiters) + 1 != length(score_assigned)) {
    stop("The score_assigned argument must be a vector conaining 1 more element than the delimiters vector")
  }
  lookup <- findInterval(x, delimiters, rightmost.closed = rightmost_closed) + 1
  score_assigned[lookup]
}

#' Replace matches
#'
#' @description
#' Replace exact matches with the corresponding value provided
#'
#' replace_matches
#' @return A vector of the same length as `x`, with replacements made where matches are found
#' @param x A character vector of values to search and replace. Matches in `x` will ignore both case and leading
#' or trailing white-space
#' @param dictionary A named vector or a list with the names being the strings searched for and the
#' values being the values to replace occurrences with
#' @param unmatched_as_na when `x` contains a string not found in `dictionary`, return NA (default).
#' If FALSE the corresponding (unmatched) value of `x` is returned
#' @examples
#' replace_matches(letters[1:10], list(a = 3, c = 7, f = 12))
#' # alternatively using a named vector
#' replace_matches(letters[1:10], c(a = 3, c = 7, f = 12))
#' replace_matches(letters[1:10], c(a = 3, c = 7, f = 12), unmatched_as_na = FALSE)
#' @family clinical_scoring_utilities
#' @export
replace_matches <- function(x, dictionary, unmatched_as_na = TRUE) {
  search_for <- names(dictionary)
  if (is.null(search_for)) {
    stop("dictionary argument [key = value] must be a named vector or list")
  }
  if (is.factor(x)) {
    x <- as.character(x)
  }
  if (is.list(dictionary)) {
    dictionary <- unname(unlist(dictionary))
  }
  lookup_indices <- match(tolower(trimws(x)), tolower(search_for))
  replaced <- unname(dictionary[lookup_indices])
  if (unmatched_as_na) {
    return(replaced)
  }
  ifelse(is.na(replaced), x, replaced)
}

#' Check a data.frame for columns required to calculate Apache III score
#'
#' Given a `data.frame` or `tibble` this function checks for the minimum
#' required columns to calculate an Apache III score. The fields are documented
#' in the ANZICS Data Dictionary. An example of the minimum required data set is
#' available [ap3_appendix_example]. All missing fields are added with a column
#' containing entirely `NA_real_` and a message is printed to the console
#' describing which columns were added.
#'
#' add_miss_ap3_cols
#' @return The same data frame that was passed as an argument with all required
#' columns added
#' @param df A data frame with (case insensitive) column names conforming to the
#' ANZICS APD Data Dictionary Apache III subset of fields
#' @references https://www.anzics.org/wp-content/uploads/2021/03/ANZICS-APD-Dictionary-Version-6.1.pdf (ANZICS APD Data Dictionary)
#' @examples
#' # a complete data.frame
#' data("ap3_appendix_example")
#' add_miss_ap3_cols(ap3_appendix_example)
#' # a data.frame with many required columns missing
#' sparse.data <- data.frame(hrhi=120,maphi=55)
#' add_miss_ap3_cols(sparse.data)
#' @family Apache3
#' @export
add_miss_ap3_cols <- function(df) {
  truncate_lohi <- function(x) {
    unique(sub("(LO|HI)", "", toupper(x)))
  }
  nm <- truncate_lohi(colnames(df))
  # based on https://www.anzics.org/wp-content/uploads/2021/03/ANZICS-APD-Dictionary-Version-6.1.pdf
  # note units are all SI
  # note UREA = UREAHI
  ap3_min_dataset <- c(
    "AGE", "ALBUMHI", "ALBUMLO", "ARF", "BILI", "COMORB",
    "CREATHI", "CREATLO",
    "ELECT_SURG", "GCS_SEDATED", "GCSEYE", "GCSMOTOR",
    "GCSVERB", "GCS_SEDATED", "GLUCHI", "GLUCLO", "HCTHI",
    "HCTLO", "HRHI", "HRLO", "MAPHI", "MAPLO", "NAHI", "NALO",
    "RRHI", "RRHI_VENT", "RRLO", "RRLO_VENT", "TEMPHI", "TEMPLO", "UREA", "URINEOP",
    "WCCHI", "WCCLO"
  )
  # "DIASTOLICHI", "DIASTOLICLO", "SYSTOLICHI", "SYSTOLICLO"  are only relevant when MAP is.na
  ap3_vars <- c(truncate_lohi(ap3_min_dataset), "ICUEPISODEID")

  miss_names <- ap3_vars[sapply(ap3_vars, function(v) {
    !any(v == nm)
  }, USE.NAMES = FALSE)]
  if (length(miss_names) > 0) {
    cat(paste0(
      "The following columns could not be found and were added:\n",
      paste(miss_names, collapse = ", "), "\n"
    ))
    empty_cols <- matrix(rep(NA_real_, times = nrow(df) * length(miss_names)),
      ncol = length(miss_names)
    )
    colnames(empty_cols) <- miss_names
    df <- cbind(df, empty_cols)
    if ("ICUEPISODEID" %in% miss_names) {
      df$ICUEPISODEID <- seq_len(nrow(df))
    }
  } else {
    cat("The column names conform to required nomenclature\n")
  }
  df
}

#' Convert 'truthy' vector to logical vector
#' @description If a numeric vector, converts 0 to false and other numbers
#' (ecluding NA_integer_ & NA_real_) to true. If a character, convert (case
#' insensitive) 'y' or 'yes' to true and 'n' or 'no' to false and other values
#' to NA. logical vectors are returned unchanged.
#' @returns A logical vector
#' @param v A vector which is either `character`, `logical` or `numeric
#' @examples
#' vector_to_logical(c("y", "yes", "YES", "Yes", "n", "no", "random", "NA", "1", "0"))
#' vector_to_logical(0:3)
#' @family clinical_scoring_utilities
vector_to_logical <- function(v) {
  t <- typeof(v)
  if (t == "logical") {
    return(v)
  }
  if (t == "double") {
    return(v != 0.0)
  }
  if (t == "integer") {
    return(v != 0L)
  }
  if (t == "character") {
    lv <- tolower(trimws(v))
    return(ifelse(lv %in% c("y", "yes", "1"),
      TRUE,
      ifelse(
        lv %in% c("n", "no", "0"),
        FALSE,
        NA
      )
    ))
  }
  stop(paste("unable to convert type", t, "to logical"))
}

#' vectorised if_else with conditional functions
#'
#' @description
#' vectorised if_else which executes true and false functions passed a  vector
#' filtered on the condition
#'
#' @details
#' Similar to dplyr if_else, but accepts a function for the true and false arguments.
#' The true and false function will be executed once each, with the argument passed
#' to the function being a vector containing all data meeting the condition.
#' It expects a vector of the same length as that passed in the return value of the function
#' and this returned vector is then placed into a corresponding position in the final vector.
#'
#' It could be considered a vectorised form of purrr::map_if
#'
#' if_else_fns
#' @return A vector of the same length as x, with the returned data from the functions
#' executed acording to the condition vector
#' @param x Any vector
#' @param condition A logical vector the same length as x corresponding to the if_else condition
#' @param if_true The function to be executed on all values of x where condition is TRUE. Must be a vectorised function
#' should return vector of the same length as the vector passed to it.
#' @param if_false As per the if_true argument, but where condition is FALSE.
#' @param .missing The value to be returned for elements where condition is NA. Default NA_real_
#' @examples
#' if_else_fns(1:20, 1:20 %% 2 == 0, \(x) {
#'   cat("passed arg len:", length(x), "\n")
#'   -x
#' }, \(x) x + 20)
#' @family clinical_scoring_utilities
#' @export
if_else_fns <- function(x, condition, if_true, if_false, .missing = NA_real_) {
  xlen <- ifelse(is.vector(x), length(x), nrow(x))
  if (xlen != length(condition)) {
    stop(
      "the data vector(x) and the condition vector must be the same length but lengths are ",
      xlen, " & ", length(condition)
    )
  }
  true_indices <- which(condition)
  false_indices <- which(!condition)
  return_var <- rep.int(.missing, times = xlen)

  if (is.function(if_true)) {
    return_var[true_indices] <- if_true(x[true_indices])
  } else if (length(if_true) == length(condition)) {
    return_var[true_indices] <- if_true[true_indices]
  } else {
    return_var[true_indices] <- if_true
  }

  if (is.function(if_false)) {
    return_var[false_indices] <- if_false(x[false_indices])
  } else if (length(if_false) == length(condition)) {
    return_var[false_indices] <- if_false[false_indices]
  } else {
    return_var[false_indices] <- if_false
  }

  return(return_var)
}
