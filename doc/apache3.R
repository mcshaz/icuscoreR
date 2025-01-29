## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(icuscorer)
data("ap3_appendix_example")
ap3_patient_data <- add_miss_ap3_cols(ap3_appendix_example)
data("ap3_appendix_gas")

## -----------------------------------------------------------------------------
my.icu.data <- data.frame(
  creatinine = c(2.2, 1.8),
  urea_highest24 = c(85, 22),
  albumin = c(2.4, 2.8), # g/dl
  bilirubin = c(3.3, 2.5),
  glucose = c(246, 190)
)
data("lab_conversions")
lab_conversions 
within(my.icu.data, {
    creat <- creatinine * lab_conversions["CREAT", "to_required"] # from mg/dl
    urea <- urea_highest24 * lab_conversions["UREA", "to_required"] # from mg/dl
    album <- albumin *10 # from g/dl to g/L
    bili <- bilirubin * lab_conversions["BILI", "to_required"] # from mg/dl
    gluc <- glucose * lab_conversions["GLUC", "to_required"] # from mg/dl
})

## -----------------------------------------------------------------------------
ap3.scores <- apache3(ap3_appendix_example)
ap3.scores
ap3.abg.scores <- apache3_resp(ap3_appendix_gas)
ap3.abg.scores
ap3.comorb.scores <- apache3_comorb(ap3_appendix_example)
ap3.comorb.scores

## -----------------------------------------------------------------------------
# join the 3 data frames to create the total score:
ap3.scores <- merge(ap3.scores, ap3.abg.scores, by = "icuepisodeid")
ap3.scores <- merge(ap3.scores, ap3.comorb.scores, by = "icuepisodeid")
# Calculating the total Apache III score using
ap3.scores$total <- rowSums(ap3.scores[,endsWith(colnames(ap3.scores), '_ap3score')], na.rm = TRUE)
ap3.scores

