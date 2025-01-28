test_that("apache3_comorb returns values in appendix example", {
  expect <- tibble::tibble(
    icuepisodeid = c(1L, 2L),
    comorb.ap3score = c(10L, 0L)
  )
  expect_equal(apache3_comorb(ap3_appendix_example), expect)
})
