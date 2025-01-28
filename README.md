
<!-- README.md is generated from README.Rmd. Please edit that file -->

# icuscoreR

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/icuscoreR)](https://CRAN.R-project.org/package=icuscoreR)
<!-- badges: end -->

icuscoreR is intended to collate `R` functions which apply clinical
scoring systems to ICU patient data.

Currently a set of function calculate the Acute Physiology and Chronic
Health Evaluation (APACHE) III score\[^1\] for patient data pertaining
to the first 24 hours of admission to an intensive care unit.

The `R` Data Frame must contain the field names described in the
\[Australia New Zealand Intensive Care Society (ANZICS) Adult Patient
Data (APD) Data Dictionary\]\[^2\]. The field names are case
insensitive, and the `HI` and `LO` suffixes on field names such as
`HRHI` are optional (although recommended in order to obtain the most
accurate Apache III score). Each `data.frame` must have an
`IcuEpisodeId` field.

For greater detail, read `vignette(apache3)`.

Extensive and clearly written resources regarding variable collection,
nomeclature and units of measure used by this package are available,
hosted by ANZICS at [ANZICS Data Collection
Tools](https://www.anzics.org/data-collection-tools/).

## Installation

You can install the development version of [icuscoreR on
GitHub](https://github.com/mcshaz/icuscorer) with:

``` r
# install.packages("pak")
pak::pak("mcshaz/icuscoreR")
```

## Example

See the `vignette(apache3)` for a more detailed explanation

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
rowSums(ap3.scores[,endsWith(colnames(ap3.scores), 'ap3score')], na.rm = TRUE)
#> [1] 107  45
```
