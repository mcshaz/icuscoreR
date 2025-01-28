test_that("assign_scores assigns correct score", {
  hr_cutpt <- c(40, 50, 100, 110, 120, 140, 155)
  hr_scores <- c(8, 5, 0, 1, 5, 7, 13, 17)
  # interleave
  testdata <- c(rbind(hr_cutpt - 1, hr_cutpt))

  expect <- c(rbind(hr_scores, hr_scores))
  expect <- expect[-c(1, length(expect))]

  hr_score <- assign_scores(testdata,
    delimiters = hr_cutpt,
    score_assigned = hr_scores
  )
  expect_equal(hr_score, expect)

  # handles NA
  testdata <- c(NA_real_, testdata)
  hr_score <- assign_scores(testdata,
    delimiters = hr_cutpt,
    score_assigned = hr_scores
  )
  expect_equal(hr_score, c(NA_real_, expect))
})

test_that("replace_matches replaces correctly", {
  comorb_score <- replace_matches(
    c("cirrhosis", "metastatic cancer", "metastatic cancer", "myeloma", "AIDS", "", "b", NA_character_),
    ap3_comorbidity_scores
  )

  expect_equal(comorb_score, c(4L, 11L, 11L, 10L, 23L, NA_integer_, NA_integer_, NA_integer_))

  jumble <- replace_matches(
    c(letters[1:6]),
    c(a = "z", d = "x"),
    FALSE
  )
  expect_equal(jumble, c("z", "b", "c", "x", "e", "f"))
})
