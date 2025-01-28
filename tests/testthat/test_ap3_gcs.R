test_that("score_gcs gives appropriate scores", {
  expect_identical(.score_gcs(1, 1, 1, FALSE), 48L)
  expect_identical(.score_gcs(5, 4, 3, FALSE), 8L)
  expect_identical(.score_gcs(5, 4, 3, NA), 8L)
  expect_equal(.score_gcs(1, 1, 1, TRUE), 0L) # not sure why 0 converted to real?
  expect_identical(.score_gcs(6:3, 5:2, 4:1, c(FALSE, TRUE, NA, FALSE)), c(0, 0, 24, 24))
})
