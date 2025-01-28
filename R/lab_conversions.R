#' Conversion factors to SI units for lab data
#'
#' The row.names represent the lab test and the other columns provide information to convert
#' the test result to the required units (if the field data is in alternative units)
#'
#' @format ## `lab_conversions`
#' A data frame with 7 rows and 3 columns:
#' \describe{
#'   \item{row.names}{The variable name as per the ANZICS data dictionary}
#'   \item{reqired_units}{The units of measurment this library assumes the field has been converted to}
#'   \item{alternative_units}{The other units of measurement commonly in use, to which the conversion factor applies}
#'   \item{to_required}{The multiplier to convert alternative_units to required_units}
#' }
#'
#' @docType data
#' @name lab_conversions
#' @usage data(lab_conversions)
#' @examples
#' data.frame(
#'   creat = c(2.2, 1.8) * lab_conversions["CREAT", "to_required"],
#'   urea = c(85, 22) * lab_conversions["UREA", "to_required"],
#'   bili = c(3.3, 2.5) * lab_conversions["BILI", "to_required"],
#'   gluc = c(246, 190) * lab_conversions["GLUC", "to_required"]
#' )
#' @family Apache3
NULL

#' Fahrenheit conversion to Centigrade
#'
#' Convert degrees Fahrenheit temperatures to degrees Celsius.
#' While this function is a ubiquitous teaching example of writing a function
#' within an R package, U.S.based users of this package may well require it
#' for this library if 'TEMPHI" and 'TEMPLO' columns are in degrees Fahrenheit!
#'
#' @return The temperature in degrees Celsius
#' @param f_temp The temperature in degrees Fahrenheit
#' @examples
#' temp1 <- F_to_C(50)
#' temp2 <- F_to_C(c(50, 63, 23))
#' @export
F_to_C <- function(f_temp) {
  c_temp <- (f_temp - 32) * 5 / 9
  return(c_temp)
}
