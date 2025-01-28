This `R` Package calculates the Acute Physiology and Chronic Health Evaluation
(APACHE) III score[^1] to patient data pertaining to the first 24 hours of
admission to an intensive care unit.

The `R` Data Frame must contain the field names described in the
[Australia New Zealand Intensive Care Society (ANZICS) Adult Patient Data (APD)
Data Dictionary][^2]. The field names are case insensitive, and the `HI` and
`LO` suffixes on field names such as `HRHI` are optional (although recommended
in order to obtain the most accurate Apache III score).
Each `data.frame` must have an `IcuEpisodeId` field.

For a quick look at example data type `?ap3_appendix_example` in the `R` Console
. Extensive and clearly written resources are available, hosted by ANZICS at
[ANZICS Data Collection Tools](https://www.anzics.org/data-collection-tools/).

## Getting started

```R
# install.packages("remotes")
library(remotes)
remotes::install_github("mcshaz/icuscorer")
```

## Preparng the data
Please note the units for lab data are all in mmol or μmol/L. If your data is in mg/dL
the data can be converted with:

```R
data("lab_conversions")
# display the conversions
lab_conversions
# using dplyr mutate, obviously you can use plain R
my.icu.data %>%
  mutate(
    creat = creatinine * lab_conversions["CREAT", "to_required"], # from mg/dl
    urea = urea_highest24 * lab_conversions["UREA", "to_required"], # from mg/dl
    album = albumin *10, # from g/dl to g/L
    bili = bilirubin * lab_conversions["BILI", "to_required"], # from mg/dl
    gluc = glucose * lab_conversions["GLUC", "to_required"], # from mg/dl
  )
```

## Generate the scores
```R
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
# calculate the comorbidity score based on a single string (this is unlikely
# to be the workflow used against a real database).
# to see scores load `data("ap3_comorbidity_scores")`
ap3.comorb.scores <- apache3_comorb(ap3_appendix_example)

# and now join the 3 data frames to create the total score:
ap3.scores <- merge(ap3.scores, ap3.abg.scores, by = "IcuEpisodeId")
ap3.scores <- merge(ap3.scores, ap3.comorb.scores, by = "IcuEpisodeId")
ap3.scores %>%
  mutate(total = rowSums(select(., ends_with('ap3score')), na.rm = TRUE))
```

*Note*
- At present the use cases for this package seem too niche to publish it to CRAN
, but please feel free to create an issue if you would prefer this to simplify
your workflow.
- Thank you to bgulbis who wrote and published [icuriskr](https://github.com/bgulbis/icuriskr).
At the time of writing, I believe `icuriskr` is a stale repository, including a
dependency on the `ICD` (International Classification of Diseases) `R` Package
which has been removed from CRAN, and also beware `icuriskr` contains a minor 
error in the calculation of pH component of the Apache III score
- If you believe other (adult or paediatric) scores should be added
(APACHE2, ANZROD, PIM2, PIM3, Trauma Severity Score, SOFA ...) please create an
issue (+/- pull request).

## Design Principles
- Consider performance and while maintaing readability, try to keep functions
vectorised (e.g. avoid `dplyr::rowwise`). It is conceivable these functions
could be executed on a multinational ICU database with 100 000 rows of patient
data (and many fold more Arterial Blood Gas results).
- Consider different use cases and database structures
- Reference clear and publicly available data dictionaries
- Generate composite scores where feasible - the researcher using the score may
wish to include or exclude certain components because that is the exact component
under investigation
- Differentiate NA from a score of 0 even if 0 is the final score contributed

## Contributing
Contributions are welcome. However before submitting a pull request please:
- Create a Github issue first.
- Try and minimise dependencies beyond those existing (e.g. `DPLYR`) unless
there is a reasonable case to do so[^3].
- Please include documentation(`roxygen2`) and tests (`testthat`) with the pull
request.
- Code style follows the [Tidyverse style guide](https://style.tidyverse.org/)

## References
[1]: Knaus WA, Wagner DP, Draper EA, et al. The APACHE III prognostic system. Risk prediction of hospital mortality for critically ill hospitalized adults. Chest. 1991 Dec;100(6):1619-36. doi: 10.1378/chest.100.6.1619. PMID: 1959406.
[2]: https://www.anzics.org/wp-content/uploads/2021/03/ANZICS-APD-Dictionary-Version-6.1.pdf (ANZICS APD Data Dictionary)
[3]: https://r-pkgs.org/dependencies-mindset-background.html
