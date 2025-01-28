#' Generate Apache III scores from Arterial Blood Gasses
#'
#' @description
#' Given a `data.frame` or tibble  of arterial blood gas results, this will
#' generate a data-set containing the O2 and pH/CO2 component of the APACHE III
#' score for each `IcuEpisodeId`
#'
#' @returns A `tibble` containing the oxygen (O2) and pH/CO2 score for each
#' `IcuEpisodeId`
#'
#' @param abgs A `data.frame` or `tibble`  which contains the columns (case
#' insensitive) `IcuEpisodeId`, `pH`, `PaCO2` or `PCO2`, `PaO2` or `PO2`, and
#' `intubated` (logical). Example gasses from the original article appendix are
#' available [ap3_appendix_gas].
#'
#' @references Knaus WA, Wagner DP, Draper EA, et al. The APACHE III prognostic system. Risk prediction of hospital mortality for critically ill hospitalized adults. Chest. 1991 Dec;100(6):1619-36. doi: 10.1378/chest.100.6.1619. PMID: 1959406.
#' @examples
#' data("ap3_appendix_gas")
#' ap3.gas.scores <- apache3_resp(ap3_appendix_gas)
#' ap3.gas.scores
#' @family apache3
#' @export
apache3_resp <- function(abgs) {
  abgs %>%
    dplyr::rename_with(\(n) {
      replace_matches(tolower(n),
        c(po2 = "pao2", pco2 = "paco2"),
        unmatched_as_na = FALSE
      )
    }) %>%
    dplyr::mutate(
      fio2 = dplyr::if_else(.data$fio2 > 1, .data$fio2 / 100, .data$fio2, NA_real_),
      pao2.score = assign_scores(.data$pao2,
        delimiters = c(50, 70, 80),
        score_assigned = c(15L, 5L, 2L, 0L)
      ),
      aado2 = 713 * .data$fio2 - .data$paco2 / 0.8 - .data$pao2,
      aado2.score = assign_scores(.data$aado2,
        delimiters = c(100, 250, 350, 500),
        score_assigned = c(0L, 7L, 9L, 11L, 14L)
      ),
      o2.ap3score = dplyr::if_else(.data$intubated & .data$fio2 >= 0.5,
        .data$aado2.score,
        .data$pao2.score, NA_integer_
      )
    ) %>%
    dplyr::group_by(.data$icuepisodeid) %>%
    dplyr::filter(.data$o2.ap3score == max(.data$o2.ap3score, na.rm = TRUE)) %>%
    dplyr::mutate(ph.ap3score = dplyr::case_when(
      is.na(ph) | is.na(paco2) ~ NA_integer_,
      ph < 7.20 & paco2 < 50 ~ 12L,
      ph < 7.20 ~ 4L,
      ph < 7.30 & paco2 >= 30 & paco2 < 40 ~ 6L,
      ph < 7.30 & paco2 >= 40 & paco2 < 50 ~ 3L,
      ph < 7.30 & paco2 >= 50 ~ 2L,
      ph < 7.35 & paco2 < 30 ~ 9L,
      ph < 7.45 & paco2 >= 45 ~ 1L,
      ph < 7.50 & paco2 < 30 ~ 5L,
      ph >= 7.45 & ph < 7.50 & paco2 >= 35 & paco2 < 45 ~ 2L,
      ph >= 7.45 & paco2 >= 45 ~ 12L,
      ph >= 7.50 & paco2 >= 40 ~ 12L,
      ph >= 7.50 & paco2 >= 25 ~ 3L,
      ph < 7.60 & ph >= 7.50 & paco2 < 25 ~ 3L,
      .default = 0L
    )) %>%
    # have already selected max o2.score - in case there are ties on o2 score
    dplyr::slice_max(.data$ph.ap3score) %>%
    dplyr::select("icuepisodeid", "o2.ap3score", "ph.ap3score") %>%
    dplyr::ungroup()
}
