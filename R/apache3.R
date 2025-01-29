#' Generate Apache III composite scores
#'
#' @description
#' Given a `data.frame` or `tibble`  which complies with nomenclature outlined in the
#' ANZICS data dictionary, this will generate a data-set containing each component of the
#' APACHE III score for each 'IcuEpisodeId'
#'
#' @details
#' See the \href{../doc/apache3.html}{\code{vignette("Apache3", package = "icuscorer")}}
#' vignette
#'
#' @returns A `tibble` containing age, physiology and lab components of the
#' APACHE III score for each `IcuEpisodeId`
#'
#' @param df a `data.frame` or `tibble`  which complies with nomenclature outlined in the
#' ANZICS data dictionary. see [add_miss_ap3_cols()] and example data from the article
#' [ap3_appendix_example].
#'
#' @references Knaus WA, Wagner DP, Draper EA, et al. The APACHE III prognostic system. Risk prediction of hospital mortality for critically ill hospitalized adults. Chest. 1991 Dec;100(6):1619-36. doi: 10.1378/chest.100.6.1619. PMID: 1959406.
#' @references https://www.anzics.org/wp-content/uploads/2021/03/ANZICS-APD-Dictionary-Version-6.1.pdf (ANZICS APD Data Dictionary)
#' @examples
#' data("ap3_appendix_example")
#' ap3.scores <- apache3(ap3_appendix_example)
#' ap3.scores
#' @family Apache3
#' @export
apache3 <- function(df) {
  return_var <- df %>%
    dplyr::rename_with(\(n) {
      replace_matches(tolower(n),
        c(rrlo_vent = "rr_ventlo", rrhi_vent = "rr_venthi"),
        unmatched_as_na = FALSE
      )
    })
  hilo_pattern <- "^([a-z]+)(lo|hi)$"
  if (any(grepl(hilo_pattern, colnames(return_var)))) {
    return_var <- return_var %>%
      tidyr::pivot_longer(dplyr::ends_with(c("lo", "hi")),
        names_to = c(".value", "extreme"),
        names_pattern = hilo_pattern
      )
  }
  if(length(intersect(c("systolic", "diastolic"), colnames(return_var))) == 2) {
    within(return_var, map[is.na(map)] <- (2 * diastolic + systolic) / 3)
  }
  return_var %>%
    dplyr::mutate(
      icuepisodeid = .data$icuepisodeid,
      age.ap3score = assign_scores(.data$age,
        delimiters = c(45, 60, 65, 70, 75, 85),
        score_assigned = c(0, 5, 11, 13, 16, 17, 24)
      ),
      hr.ap3score = assign_scores(.data$hr,
        delimiters = c(40, 50, 100, 110, 120, 140, 155),
        score_assigned = c(8, 5, 0, 1, 5, 7, 13, 17)
      ),
      map.ap3score = assign_scores(.data$map,
        delimiters = c(40, 60, 70, 80, 100, 120, 130, 140),
        score_assigned = c(23, 15, 7, 6, 0, 4, 7, 9, 10)
      ),
      temp.ap3score = assign_scores(.data$temp,
        delimiters = c(33, 33.5, 34, 35, 36, 40),
        score_assigned = c(20, 16, 13, 8, 2, 0, 4)
      ),

      # TODO figure out if this is efficient
      rr.ap3score = dplyr::if_else(
        vector_to_logical(.data$rr_vent),
        assign_scores(.data$rr,
          delimiters = c(6, 25, 35, 40, 50),
          score_assigned = c(17, 0, 6, 9, 11, 18)
        ),
        assign_scores(.data$rr,
          delimiters = c(6, 12, 14, 25, 35, 40, 50),
          score_assigned = c(17, 8, 7, 0, 6, 9, 11, 18)
        ),
        NA_integer_
      ),
      hct.ap3score = assign_scores(dplyr::if_else(.data$hct > 1, .data$hct / 100.0, .data$hct, NA_real_),
        delimiters = c(0.41, 0.5),
        score_assigned = c(3, 0, 3)
      ),
      wcc.ap3score = assign_scores(.data$wcc,
        delimiters = c(1, 3, 20, 25),
        score_assigned = c(19, 5, 0, 1, 5)
      ),
      creat.ap3score = dplyr::if_else(
        vector_to_logical(.data$arf),
        dplyr::if_else(.data$creat < 133, 0L, 10L, NA_integer_),
        assign_scores(.data$creat,
          delimiters = c(44, 133, 172),
          score_assigned = c(3, 0, 4, 7)
        ),
        NA_integer_
      ),
      urineop.ap3score = assign_scores(.data$urineop,
        delimiters = c(400, 600, 900, 1500, 2000, 4000),
        score_assigned = c(15, 8, 7, 5, 4, 0, 1)
      ),
      urea.ap3score = assign_scores(.data$urea,
        delimiters = c(6.2, 7.2, 14.4, 26.6),
        score_assigned = c(0, 2, 7, 11, 12)
      ),
      Na.ap3score = assign_scores(.data$na,
        delimiters = c(120, 135, 155),
        score_assigned = c(3, 2, 0, 4)
      ),
      album.ap3score = assign_scores(.data$album,
        delimiters = c(20, 25, 45),
        score_assigned = c(11, 6, 0, 4)
      ),
      bili.ap3score = assign_scores(.data$bili,
        delimiters = c(35, 52, 86, 136),
        score_assigned = c(0, 5, 6, 8, 16)
      ),
      gluc.ap3score = assign_scores(.data$gluc,
        delimiters = c(2.2, 3.4, 11.2, 19.4),
        score_assigned = c(8, 9, 0, 3, 5)
      ),
      gcs.ap3score = .score_gcs(.data$gcsmotor, .data$gcsverb, .data$gcseye, .data$gcs_sedated),
      .keep = "none"
    ) %>%
    dplyr::group_by(.data$icuepisodeid) %>%
    dplyr::summarise_all(max) %>%
    dplyr::ungroup()
}
