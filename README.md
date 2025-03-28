
<!-- README.md is generated from README.Rmd. Please edit that file -->

# moveworkflow

<!-- badges: start -->
<!-- badges: end -->

The goal of moveworkflow is to …

## Installation

You can install the development version of moveworkflow from
[GitHub](https://github.com/) with:

``` r
directory <- system.file("data_ext","data_raw","A_1_diver",package="moveworkflow", mustWork=TRUE)
file <- "CSV"
feature_file <- type_files(file)
type_file ="CSV"
combine_files(directory, "CSV")
```

## Convert date to posixct

function to convert date found in row data of MOVE project in posixct

``` r
date <- c("03/12/24 14:50:01", "03/12/24 14:50:12", "03/12/24 14:50:24")
convert_date_posixct(date)
```

## Add_time_if_missing

``` r
date <- c("2024-12-03 14:50:01", "2024-12-03", "2024-12-03 14:50:24")
lapply(date, add_time_if_missing)
```
