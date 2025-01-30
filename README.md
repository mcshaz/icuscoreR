
<!-- README.md is generated from README.Rmd. Please edit that file -->

# icuscoreR

<!-- badges: start -->

[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN
status](https://www.r-pkg.org/badges/version/icuscoreR)](https://CRAN.R-project.org/package=icuscoreR)
<!-- badges: end -->

icuscoreR is intended to collate `R` functions which apply clinical
scoring systems to ICU patient data.

Currently a set of function calculate the Acute Physiology and Chronic
Health Evaluation (APACHE) III score (Knaus et al. (1991)) for patient
data pertaining to the first 24 hours of admission to an intensive care
unit.

The `R` Data Frame must contain the field names described in the
Australia New Zealand Intensive Care Society (ANZICS) Adult Patient Data
(APD) Data Dictionary (Australian and New Zealand Intensive Care Society
Centre for Outcome and Resource Evaluation (2022)). All field names are
case insensitive, including a mandatory `IcuEpisodeId` field. `HI` and
`LO` suffixes on field names such as `HRHI` (the highest heart rate in
24 hours from ICU admission) are optional, so `HRHI` can be `HR` if only
1 extreme is available, or if there are multiple rows of data for each
`IcuEpisodeId`.

For greater detail, after installing the package as below, read
`vignette(apache3)`.

Extensive and clearly written resources regarding variable collection,
nomeclature and units of measure used by this package are available,
hosted by ANZICS at [ANZICS Data Collection
Tools](https://www.anzics.org/data-collection-tools/).

## Installation

You can install the development version of [icuscoreR on
GitHub](https://github.com/mcshaz/icuscoreR) with:

``` r
# 'remotes' package will be installed if devtools is installed
# install.packages("remotes")  
remotes::install_github("mcshaz/icuscoreR", build_vignettes = TRUE)
```

Alternatively, you may also wish to use
`pak::pkg_install("mcshaz/icuscoreR")`, Although you will not have
access to the `vignette("apache3")`.

## Example

See the `vignette(apache3)` for an in depth explanation of the following
example:

``` r
library(icuscorer)
data("ap3_appendix_example")
ap3_patient_data <- add_miss_ap3_cols(ap3_appendix_example)
#> The column names conform to required nomenclature
ap3.scores <- apache3(ap3_appendix_example)
ap3.comorb.scores <- apache3_comorb(ap3_appendix_example)
data("ap3_appendix_gas")
ap3.abg.scores <- apache3_resp(ap3_appendix_gas)

ap3.scores <- merge(ap3.scores, ap3.abg.scores, by = "icuepisodeid")
ap3.scores <- merge(ap3.scores, ap3.comorb.scores, by = "icuepisodeid")
# Calculating the total Apache III score using
ap3.scores$totalap3 <- rowSums(ap3.scores[,endsWith(colnames(ap3.scores), 'ap3score')], na.rm = TRUE)
ap3.scores
#>   icuepisodeid age.ap3score hr.ap3score map.ap3score temp.ap3score rr.ap3score
#> 1            1            5           7            6             0           9
#> 2            2           17           5            0             0           0
#>   hct.ap3score wcc.ap3score creat.ap3score urineop.ap3score urea.ap3score
#> 1            3            5              7                5            12
#> 2            3            0              4                4             7
#>   Na.ap3score album.ap3score bili.ap3score gluc.ap3score gcs.ap3score
#> 1           0              6             6             3            3
#> 2           0              0             5             0            0
#>   o2.ap3score ph.ap3score comorb.ap3score totalap3
#> 1          11           9              10      107
#> 2           0           0               0       45
```

*Note*

- At present the use cases for this package seem too niche to publish it
  to CRAN , but please feel free to create an issue if you would prefer
  this to simplify your workflow.
- If you believe other (adult or paediatric) scores should be added
  (APACHE2, ANZROD, PIM2, PIM3, Trauma Severity Score, SOFA …) please
  feel free to create an
  [issue](https://github.com/mcshaz/icuscoreR/issues) (± [pull
  request](https://github.com/mcshaz/icuscoreR/pulls)).

## Contributing

Contributions are welcome. However before submitting a pull request
please:

- Create a Github issue first.
- Try and minimise dependencies beyond those existing (e.g. `DPLYR`)
  unless there is a [reasonable case to do
  so](https://r-pkgs.org/dependencies-mindset-background.html).
- Please include documentation(`roxygen2`) and tests (`testthat`) with
  the pull request.
- Code style follows the [Tidyverse style
  guide](https://style.tidyverse.org/).
- Read the design principles of the library below:

### Design Principles

- Consider performance and while maintaing readability, try to keep
  functions vectorised (e.g. avoid `dplyr::rowwise`). It is conceivable
  these functions could be executed on a multinational ICU database with
  100 000 rows of patient data (and many fold more Arterial Blood Gas
  results).
- Consider different use cases and database structures.
- Reference clear and publicly available data dictionaries.
- Generate composite scores where feasible - the researcher using the
  score may wish to include or exclude certain components because that
  is the exact component under investigation.
- Differentiate NA from a score of 0 even if 0 is the final score
  contributed.

## References

<div id="refs" class="references csl-bib-body hanging-indent"
entry-spacing="0">

<div id="ref-apddatadictionary" class="csl-entry">

Australian and New Zealand Intensive Care Society Centre for Outcome and
Resource Evaluation. 2022. *Adult Patient Database Data Dictionary*. 6.1
ed. Prahran, Victoria, Australia.
<https://www.anzics.org/wp-content/uploads/2021/03/ANZICS-APD-Dictionary-Version-6.1.pdf>.

</div>

<div id="ref-Knaus1991-be" class="csl-entry">

Knaus, William A, Douglas P Wagner, Elizabeth A Draper, Jack E
Zimmerman, Marilyn Bergner, Paulo G Bastos, Carl A Sirio, et al. 1991.
“[The APACHE III Prognostic
System](https://www.ncbi.nlm.nih.gov/pubmed/1959406).” *Chest* 100 (6):
1619–36.

</div>

</div>
