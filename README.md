
<!-- README.md is generated from README.Rmd. Please edit that file -->

# moveworkflow

<!-- badges: start -->
<!-- badges: end -->

The goal of moveworkflow is to …

## Installation

You can install the development version of moveworkflow from
[GitHub](https://github.com/) with:

``` r
install.packages("pak")
pak::pak("gehco-univ-tours/moveworkflow")
```

## Convert date to posixct

function to convert date found in row data of MOVE project in posixct

``` r
date <- c("03/12/24 14:50:01", "03/12/24 14:50:12", "03/12/24 14:50:24")
convert_date_posixct <- function(date)
```
