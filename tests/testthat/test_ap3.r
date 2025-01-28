test_that("apache3 returns values in appendix example", {
  ap3_appendix_example <- add_miss_ap3_cols(ap3_appendix_example)
  expect <- tibble::tibble(
    icuepisodeid = c(1L, 2L),
    age.ap3score = c(5L, 17L),
    hr.ap3score = c(7L, 5L),
    map.ap3score = c(6, 0L),
    temp.ap3score = c(0, 0L),
    rr.ap3score = c(9, 0L),
    hct.ap3score = c(3, 3L),
    wcc.ap3score = c(5, 0L),
    creat.ap3score = c(7, 4),
    urineop.ap3score = c(5, 4),
    urea.ap3score = c(12, 7),
    Na.ap3score = c(0, 0),
    album.ap3score = c(6, 0),
    bili.ap3score = c(6, 5),
    gluc.ap3score = c(3, 0),
    gcs.ap3score = c(3, 0)
  )
  expect_equal(apache3(ap3_appendix_example), expect)
})
