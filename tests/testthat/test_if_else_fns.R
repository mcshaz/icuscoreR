test_that("sif_else_fns tests", {
  a <- 1:20
  a[c(3, 14)] <- NA_integer_

  calls <- 0L

  res <- if_else_fns(a, a %% 2 == 0, \(x) {
    calls <<- calls + 1L
    x + 40L
  }, \(x) {
    calls <<- calls + 1L
    x + 10L
  }, NA_integer_)
  expected <- c(11L, 42L, NA_integer_, 44L, 15L, 46L, 17L, 48L, 19L, 50L, 21L, 52L, 23L, NA_integer_, 25L, 56L, 27L, 58L, 29L, 60L)

  expect_identical(res, expected)
  expect_identical(calls, 2L)

  # test dplyr
  b <- data.frame(a = a)
  a <- NULL
  calls <- 0L

  c <- b %>% dplyr::mutate(
    d = if_else_fns(a, a %% 2 == 0, \(x) {
      calls <<- calls + 1L
      x + 40L
    }, \(x) {
      calls <<- calls + 1L
      x + 10L
    }, NA_integer_)
  )

  expect_identical(c$d, expected)
  expect_identical(calls, 2L)
})
