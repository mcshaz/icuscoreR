## code to prepare `DATASET` dataset goes here

# taken from Appendix B of the the original Apache III paper
ap3_appendix_example <- data.frame(
  IcuEpisodeId = 1:2,
  age = c(56L, 79L),
  comorb = c("leukaemia", NA_character_),
  elect_surg = c(FALSE, TRUE),
  hr = c(125L, 110L),
  map = c(75L, 82L),
  temp = c(39.8, 37.5), # celcius
  rr = c(36L, 10L),
  rr_vent = c(TRUE, TRUE),
  hct = c(0.24, 0.32),
  wcc = c(1.2, 12),
  # original paper showed creatinine in mg/dL
  creat = c(2.2, 1.8) * lab_conversions["CREAT", "to_required"],
  urineop = c(1200L, 1800L), # urine output ml per 24 hours
  urea = c(85, 22) * lab_conversions["UREA", "to_required"],
  Na = c(136, 142),
  album = c(24, 28), # 2.4 g/dl in the paper so x 10 for g/L
  bili = c(3.3, 2.5) * lab_conversions["BILI", "to_required"],
  gluc = c(246, 190) * lab_conversions["GLUC", "to_required"],
  gcseye = c(4L, 3L), # apache only differentiates score eyes 1 from eyes 2-4
  gcsverb = c(4L, 5L),
  gcsmotor = c(6L, 6L),
  gcs_sedated = c(FALSE, FALSE),
  arf = c(FALSE, FALSE)
)

ap3_appendix_gas <- data.frame(
  IcuEpisodeId = c(1L, 2L),
  intubated = c(TRUE, TRUE),
  pao2 = c(68, 95), # mmHG
  fio2 = c(0.7, 0.4),
  ph = c(7.24, 7.42),
  paco2 = c(26, 38)
)

lab_conversions <- data.frame(
  reqired_units = c("g/L", "µmol/L", "µmol/L", "mmol/L", "mmol/L", "mmHg"),
  alternative_units = c("g/dL", "mg/dl", "mg/dL", "mg/dL", "BUN mg/dL", "kPa"),
  to_required = c(10, 17.1, 88.42, 0.0555, 0.3571, 7.50062),
  row.names = c("ALBUM", "BILI", "CREAT", "GLUC", "UREA", "PO2")
)

ap3_comorbidity_scores <- c(
  aids = 23L,
  "hepatic failure" = 16L,
  lymphoma = 13L,
  "metastatic cancer" = 11L,
  "Metastatic carcinoma" = 11L, # pre 2016 ANZICS terminology
  leukaemia = 10L,
  leukemia = 10L, # US spelling
  myeloma = 10L,
  immunosuppressed = 10L,
  cirrhosis = 4L
)


usethis::use_data(ap3_appendix_example, ap3_appendix_gas, lab_conversions, ap3_comorbidity_scores, overwrite = TRUE)
