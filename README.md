# TomoQC
Tomosequencing QC function
# Overview
The goal of TomoQC is to provide a quick, simple quality control to assess the quality of a tomosequencing sample.
Read, UMI , and Transcript count tables are required for the function to run.
#Installation
TomoQC is available to install from github:

```R
# install.packages("devtools")
devtools::install_github("thomasp85/patchwork")
```

# Example
The package includes a 1000 gene dummy dataset which gives an idea of how output may look. Note that in a real experiment, the data input would be based on many more genes
```r example
TomoQC::tomo_quality(example_data$ex_transcripts, example_data$ex_reads, example_data$ex_barcodes, cutoff_spike = 0.2, cutoff_genes = 90, plot_title = "Example output")
```
