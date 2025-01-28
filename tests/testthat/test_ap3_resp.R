test_that("apache3_resp returns values in appendix example", {
  expect <- tibble::tibble(
    icuepisodeid = c(1L, 2L),
    o2.ap3score = c(11L, 0L),
    ph.ap3score = c(9L, 0L)
  )
  expect_equal(apache3_resp(ap3_appendix_gas), expect)
})

test_that("apache3_resp chooses gas with worst oxygen score", {
  df <- data.frame(
    IcuEpisodeId = 1:3,
    intubated = c(FALSE, FALSE, TRUE),
    pao2 = c(53, 64, 70), # mmHG 50-69 = 5, 70 - 79 = 2
    fio2 = c(0.7, 0.7, 0.4),
    ph = c(7.20, 7.31, 7.32), # scores 2, 0 & 9 respectively
    paco2 = c(55, 44, 28)
  )
  expect <- tibble::tibble(
    icuepisodeid = 1:3,
    o2.ap3score = c(5L, 5L, 2L),
    ph.ap3score = c(2L, 0L, 9L)
  )
  expect_equal(apache3_resp(df), expect)

  # now should take the score with the highest O2 score, 1st priority, highest ph score 2nd priority
  df$IcuEpisodeId <- rep_len(1L, 3)
  expect <- tibble::tibble(
    icuepisodeid = 1,
    o2.ap3score = 5L,
    ph.ap3score = 2L
  )
  expect_equal(apache3_resp(df), expect)
})
