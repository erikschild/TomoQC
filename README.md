
# TomoQC

A quick quality check for tomosequencing data

## Overview

The goal of TomoQC is to provide a quick, simple quality control to
assess the quality of a tomosequencing sample. Read, UMI, and Transcript
count tables are required for the function to run.

## Installation

TomoQC is available to install from github:

``` r
  # install.packages("devtools")
  devtools::install_github("erikschild/TomoQC")
```

## Example

The package includes a 1000 gene dummy dataset which gives an idea of
how output may look. Note that in a real experiment, the data input
would be based on many more genes

``` r
library(TomoQC)
  example <- tomo_quality(example_data$ex_transcripts,
               example_data$ex_reads,
               example_data$ex_barcodes,
               cutoff_spike = 0.2,
               cutoff_genes = 90,
               plot_title = "Example output")
```

![](man/figures/README-example-1.png)<!-- -->

``` r
  head(example)
#> # A tibble: 6 x 4
#>   Slices Genes Spike_ins_percentage Wormslice
#>    <dbl> <dbl>                <dbl> <chr>    
#> 1      1    38                 53.7 not_worm 
#> 2      2    34                 57.8 not_worm 
#> 3      3    49                 33.5 not_worm 
#> 4      4    43                 51.0 not_worm 
#> 5      5    34                 38.8 not_worm 
#> 6      6    33                 60.4 not_worm
```
