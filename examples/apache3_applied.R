data("ap3_appendix_example")
# check our data conforms, and create NA columns for missing fields
ap3_appendix_example <- add_miss_ap3_cols(ap3_appendix_example)
ap3.scores <- apache3(ap3_appendix_example)
# add our arterial blood gasses
# This is a separate function as usually this function would be executed with all
# gasses taken within the first 24 hours of ICU admission.
# Specific rules are applied to determine the 'worst gas' per ICU episode.
data("ap3_appendix_gas")
ap3.abg.scores <- apache3_resp(ap3_appendix_gas)
# calculate the co-morbidity score based on a single string (this is unlikely
# to be the workflow used against real registry data).
# to see scores load `data("ap3_comorbidity_scores")`.
# *note a score of 0 is assigned to elective post-operative admissions
ap3.comorb.scores <- apache3_comorb(ap3_appendix_example)

# and now join the 3 data frames to create the total score:
ap3.scores <- merge(ap3.scores, ap3.abg.scores, by = "IcuEpisodeId")
ap3.scores <- merge(ap3.scores, ap3.comorb.scores, by = "IcuEpisodeId")
# finally calculate the total Apache III score
library(dplyr)
ap3.scores %>%
  dplyr::mutate(total = rowSums(select(., ends_with('ap3score')), na.rm = TRUE))
