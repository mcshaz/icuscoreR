#' Generate Apache III scores from comorbidities
#'
#' @description
#' Given a `data.frame` or tibble  of co-morbidities containing a character
#' column of diagnoses, selects the highest co-morbidity per `IcuEpisodeId`
#' or 0 if the ICU admission was following elective surgery
#'
#' @details
#' This is unlikely to be used in production given various diagnostic
#' categorisations and ICU registries in use. This function is therefore
#' provided primarily for completeness and for use in the examples.
#'
#' @returns A `tibble` containing the comorbidity score for each
#' `IcuEpisodeId`. Comorbidity scoring details are available in these data
#' [ap3_comorbidity_scores]
#'
#' @param comorbs A `data.frame` or tibble  which contains the columns (case
#' insensitive) `IcuEpisodeId`, `comorb` (character) and
#' `elect_surg` (logical).
#'
#' @references Knaus WA, Wagner DP, Draper EA, et al. The APACHE III prognostic system. Risk prediction of hospital mortality for critically ill hospitalized adults. Chest. 1991 Dec;100(6):1619-36. doi: 10.1378/chest.100.6.1619. PMID: 1959406.
#' @examples
#' data("ap3_appendix_example")
#' ap3.comorb.score <- apache3_comorb(ap3_appendix_example)
#' ap3.comorb.score
#' @family Apache3
#' @export
apache3_comorb <- function(comorbs) {
  comorbs %>%
    dplyr::rename_with(tolower) %>%
    dplyr::select("icuepisodeid", "comorb", "elect_surg") %>%
    dplyr::group_by(.data$icuepisodeid) %>%
    dplyr::mutate(
      comorb.score = dplyr::if_else(
        vector_to_logical(.data$elect_surg),
        0L,
        replace_matches(
          .data$comorb,
          ap3_comorbidity_scores
        ),
        NA_integer_
      )
    ) %>%
    dplyr::summarise(comorb.ap3score = max(.data$comorb.score)) %>%
    dplyr::ungroup()
}
