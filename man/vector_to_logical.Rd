% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/helpers.R
\name{vector_to_logical}
\alias{vector_to_logical}
\title{Convert 'truthy' vector to logical vector}
\usage{
vector_to_logical(v)
}
\arguments{
\item{v}{A vector which is either \code{character}, \code{logical} or `numeric}
}
\value{
A logical vector
}
\description{
If a numeric vector, converts 0 to false and other numbers
(ecluding NA_integer_ & NA_real_) to true. If a character, convert (case
insensitive) 'y' or 'yes' to true and 'n' or 'no' to false and other values
to NA. logical vectors are returned unchanged.
}
\examples{
vector_to_logical(c("y", "yes", "YES", "Yes", "n", "no", "random", "NA", "1", "0"))
vector_to_logical(0:3)
}
\seealso{
Other clinical_scoring_utilities: 
\code{\link{assign_scores}()},
\code{\link{if_else_fns}()},
\code{\link{replace_matches}()}
}
\concept{clinical_scoring_utilities}
