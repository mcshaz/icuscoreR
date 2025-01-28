#' Look up multiple elements in a mult-dimensional array
#'
#' @returns A vector of elements - one element for each row of 'findvalues_matrix'
#' @param lookup_array The array to be searched
#' @param findvalues_matrix a matrix with 1 column for each dimension of 'findvalues'.
#' The values in each row represent the indexes corresponding to each dimension.
#' @examples
#' l <- array(1:60, dim=5:3)
#' l
#' f <- matrix(c(4, 2, 1, 3, 4, 2, 4, 2, 1), ncol=3)
#' f
#' multilookup_of_array(l, f)
#'
multilookup_of_array <- function(lookup_array, findvalues_matrix) {
  lookup_dims <- dim(lookup_array)
  if (length(lookup_dims) != ncol(findvalues_matrix)) {
    stop("the lookup_array must have the same number of dimensions as the ncols of findvalues_matrix")
  }

  steps <- cumprod(lookup_dims[-length(lookup_dims)])
  findValues_vector <- as.vector(sweep(findvalues_matrix, 2, c(0L, rep_len(1L, length(steps))), "-") %*% c(1L, steps))
  as.vector(lookup_array)[findValues_vector]
}

# taken from figure 3 reading table scores bottom to top and right to left
# this is so that a GCS component score of 1 equates to the 1st row or column
.ap3_gcs_array <- array(c(
  48L, 33L, 16L, 16L,
  29L, 24L, rep.int(NA_integer_, 10L),
  29L, 24L, 15L, 15L,
  29L, 24L, 13L, 10L,
  13L, 13L, 8L, 3L,
  3L, 3L, 3L, 0L
), dim = c(4L, 4L, 2L))

# 2nd column repeated for verbal [2, 3], first and second rows repeated for
# motor scores [1,2] and [3,4]
.ap3_gcs_array <- .ap3_gcs_array[
  c(1L, 1L, 2L, 2L, 3L, 4L),
  c(1L, 2L, 2L, 3L, 4L),
]

.score_gcs <- function(motor, verbal, eye, was_sedated) {
  return_var <- rep.int(NA_integer_, length(motor))
  touse <- stats::complete.cases(motor, verbal, eye)
  was_sedated[is.na(was_sedated)] <- FALSE
  return_var[touse] <- ifelse(was_sedated[touse],
    0,
    multilookup_of_array(
      .ap3_gcs_array,
      matrix(c(motor[touse], verbal[touse], ifelse(eye[touse] > 1, 2, 1)),
        ncol = 3L
      )
    )
  )
  return_var
}
