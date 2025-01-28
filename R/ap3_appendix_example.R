#' Apache III Example ICU Patient Data
#'
#' Data representing the variables for the example patients described in
#' appendix B of the original paper reporting the Apache III score.
#'
#' The data format is according to the ANZICS APD data dictionary
#'
#' @format ## `ap3_appendix_example`
#' A data frame with 2 rows and 22 columns:
#' \describe{
#'   \item{IcuEpisodeId}{A unique identified for each ICU admission episode},
#'   \item{age}{Age in years}
#'   \item{comorb}{Apache III Comorbidity diagnosis as a string - use `data("ap3comorbidity_scores")` to see acceptable terms & associated score}
#'   \item{elect_surg}{Was the ICU admission after elective surgery (comorb is not assigned a score)}
#'   \item{hr}{Heart Rate in beats per minute}
#'   \item{map}{Mean Arterial Blood Pressure in mmHg}
#'   \item{temp}{Temperature in °C}
#'   \item{rr}{Respirator Rate in breaths per minute. If ventilated, it is the total respiratory rate (mandatory + spontaneous respirations)}
#'   \item{rr_vent}{Was the patient on a ventilator when the respiratory rate was recorded}
#'   \item{hct}{Haematocrit (as a % or fraction)}
#'   \item{wcc}{White Cell Count × 10^9/L}
#'   \item{creat}{Creatinine in µmol/L}
#'   \item{urineop}{Urine Output in mL per 24 hours}
#'   \item{urea}{Urea in mmol/L}
#'   \item{Na}{Sodium in mmol/L}
#'   \item{album}{Albumin in g/L}
#'   \item{bili}{Bilirubin in µmol/L}
#'   \item{gluc}{Blood Glucose in mmol/L}
#'   \item{gcseye}{The Eyes component of the Glasgow Coma Scale (GCS) - 1 to 4}
#'   \item{gcsverb}{The Verbal component of the GCS - 1 to 5}
#'   \item{gcsmotor}{The Motor Component of the GCS - 1 to 6}
#'   \item{gcs_sedated}{Was a meaningful GCS impossible to obtain due to medical sedation}
#'   \item{arf}{Was the patient in Acute Renal Failure within 24 hours of admission, defined as 1) Urine < 410 ml in 1st 24hr 2) Creatinine >133 μmol/L 3) No chronic dialysis}
#' }
#' @docType data
#' @keywords datasets
#' @name ap3_appendix_example
#' @usage data(ap3_appendix_example)
#' @source <https://pubmed.ncbi.nlm.nih.gov/1959406/>
#' @family Apache3
#' @family Apache3_data
NULL


#' Apache III Example ICU ABG Data
#'
#' Data representing arterial blood gasses obtained in the first 24 hours of
#' ICU admission - taken from the original paper reporting the Apache III score
#'
#' The data format is similar to the ANZICS APD data dictionary, although PaO2
#' is used rather than PO2 (and PaCO2) The `apache3_resp` functions in this
#' package work with either abbreviation, but  PaO2 is clearer when
#' differentiating arterial from venous, central venous or mixed venous gasses.
#' @name ap3_appendix_gas
#' @docType data
#'
#' @format ## `ap3_appendix_gas`
#' A data frame with 2 rows and 22 columns:
#' \describe{
#'   \item{IcuEpisodeId}{A unique identified for each ICU admission episode}
#'   \item{intubated}{Was the patient intubated at the time the gas was obtained}
#'   \item{pao2}{Partial pressure of Oxygen in the arterial gas in mmHg}
#'   \item{fio2}{Fraction of inspired oxygen the patient was receiving at the time the gas was obtained}
#'   \item{ph}{pH of the sample}
#'   \item{paco2}{Partial pressure of Carbon Dioxide in the arterial gas in mmHg}
#' }
#' @keywords datasets
#' @usage data(ap3_appendix_gas)
#' @source <https://pubmed.ncbi.nlm.nih.gov/1959406/>
#' @family Apache3
#' @family Apache3_data
NULL
