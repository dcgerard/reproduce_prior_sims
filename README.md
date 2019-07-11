
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Reproduce the Results of Gerard and Ferrão (2019)

## Introduction

This repository contains the code and instructions needed to reproduce
all of the results from Gerard and Ferrão (2019).

If you find a bug, please create an
[issue](https://github.com/dcgerard/reproduce_priors/issues).

## Instructions

1.  Install the appropriate R packages
    
    ``` r
    install.packages(c("updog",
                       "tidyverse", 
                       "vcfR",
                       "ggthemes",
                       "doSNOW"))
    ```

2.  Download the data from Uitdewilligen et al. (2013).
    
    Place the file “journal.pone.0062355.s007.GZ” in the “data” folder.
    
    You can obtain this file from
    <https://doi.org/10.1371/journal.pone.0062355.s007>.
    
    This step is optional since running `make` will attempt to download
    all of the required data using `wget`.

3.  Download the data from Shirasawa et al. (2017).
    
    Place the file “KDRIsweetpotatoXushu18S1LG2017.vcf.gz” in the “data”
    folder.
    
    You can obtain this file from
    <ftp://ftp.kazusa.or.jp/pub/sweetpotato/GeneticMap/KDRIsweetpotatoXushu18S1LG2017.vcf.gz>.
    
    This step is optional since running `make` will attempt to download
    all of the required data using `wget`.

4.  Adjust the Makefile. Change the `nc` and `rexec` variables in the
    Makefile according to your local computing environment. For example,
    you would need to decrease `nc` if you have fewer than 12 CPU cores.
    You can check the number of CPU cores you have by typing the
    following in R:
    
    ``` r
    parallel::detectCores()
    ```

5.  Run `make`.
    
      - To reproduce all of the results in the paper, simply run in the
        terminal:
        
        ``` bash
        make
        ```
    
      - To reproduce just the example bad behavior under the general or
        uniform priors, run in the terminal:
        
        ``` bash
        make example
        ```
    
      - To reproduce just the simulation results, run in the terminal:
        
        ``` bash
        make sims
        ```

6.  Get coffee. Running `make sims` should take a few hours. You should
    get some coffee\! Here is a list of some of my favorite places:
    
      - Washington, DC
          - [Colony
            Club](https://www.yelp.com/biz/colony-club-washington)
          - [Grace Street
            Coffee](https://www.yelp.com/biz/grace-street-coffee-georgetown)
          - [Shop Made in
            DC](https://www.yelp.com/biz/shop-made-in-dc-washington)
      - Chicago
          - [Sawada
            Coffee](https://www.yelp.com/biz/sawada-coffee-chicago)
          - [Plein Air
            Cafe](https://www.yelp.com/biz/plein-air-cafe-and-eatery-chicago-2)
      - Seattle
          - [Bauhaus
            Ballard](https://www.yelp.com/biz/bauhaus-ballard-seattle)
          - [Cafe
            Solstice](https://www.yelp.com/biz/cafe-solstice-seattle)
      - Columbus
          - [Yeah, Me
            Too](https://www.yelp.com/biz/yeah-me-too-columbus)
          - [Stauf’s Coffee
            Roasters](https://www.yelp.com/biz/staufs-coffee-roasters-columbus-2)

## Package Versions

If you are having trouble reproducing these results, check your package
versions. These are the ones that I used:

``` r
sessionInfo()
#> R version 3.6.1 (2019-07-05)
#> Platform: x86_64-pc-linux-gnu (64-bit)
#> Running under: Ubuntu 18.04.2 LTS
#> 
#> Matrix products: default
#> BLAS:   /usr/lib/x86_64-linux-gnu/openblas/libblas.so.3
#> LAPACK: /usr/lib/x86_64-linux-gnu/libopenblasp-r0.2.20.so
#> 
#> locale:
#>  [1] LC_CTYPE=en_US.UTF-8       LC_NUMERIC=C              
#>  [3] LC_TIME=en_US.UTF-8        LC_COLLATE=en_US.UTF-8    
#>  [5] LC_MONETARY=en_US.UTF-8    LC_MESSAGES=en_US.UTF-8   
#>  [7] LC_PAPER=en_US.UTF-8       LC_NAME=C                 
#>  [9] LC_ADDRESS=C               LC_TELEPHONE=C            
#> [11] LC_MEASUREMENT=en_US.UTF-8 LC_IDENTIFICATION=C       
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#>  [1] doSNOW_1.0.16    snow_0.4-3       iterators_1.0.10 foreach_1.4.4   
#>  [5] ggthemes_4.2.0   vcfR_1.8.0       forcats_0.4.0    stringr_1.4.0   
#>  [9] dplyr_0.8.3      purrr_0.3.2      readr_1.3.1      tidyr_0.8.3     
#> [13] tibble_2.1.3     ggplot2_3.2.0    tidyverse_1.2.1  updog_1.0.1     
#> 
#> loaded via a namespace (and not attached):
#>  [1] Rcpp_1.0.1                lubridate_1.7.4.9000     
#>  [3] ape_5.3                   lattice_0.20-38          
#>  [5] assertthat_0.2.1          zeallot_0.1.0            
#>  [7] digest_0.6.20             R6_2.4.0                 
#>  [9] cellranger_1.1.0          backports_1.1.4          
#> [11] evaluate_0.14             httr_1.4.0               
#> [13] pillar_1.4.2              rlang_0.4.0              
#> [15] lazyeval_0.2.2            readxl_1.3.1             
#> [17] rstudioapi_0.10           vegan_2.5-5              
#> [19] Matrix_1.2-17             rmarkdown_1.13           
#> [21] splines_3.6.1             pinfsc50_1.1.0           
#> [23] munsell_0.5.0             broom_0.5.2              
#> [25] compiler_3.6.1            modelr_0.1.4             
#> [27] xfun_0.8                  pkgconfig_2.0.2          
#> [29] mgcv_1.8-28               htmltools_0.3.6          
#> [31] tidyselect_0.2.5          codetools_0.2-16         
#> [33] viridisLite_0.3.0         permute_0.9-5            
#> [35] crayon_1.3.4              withr_2.1.2              
#> [37] MASS_7.3-51.4             grid_3.6.1               
#> [39] nlme_3.1-140              jsonlite_1.6             
#> [41] gtable_0.3.0              magrittr_1.5             
#> [43] scales_1.0.0              cli_1.1.0                
#> [45] stringi_1.4.3             RcppArmadillo_0.9.500.2.0
#> [47] doParallel_1.0.14         xml2_1.2.0               
#> [49] vctrs_0.2.0               generics_0.0.2           
#> [51] tools_3.6.1               glue_1.3.1               
#> [53] hms_0.5.0                 parallel_3.6.1           
#> [55] yaml_2.2.0                colorspace_1.4-1         
#> [57] cluster_2.1.0             rvest_0.3.4              
#> [59] knitr_1.23                haven_2.1.1
```

Note that I’ve also only tried this on Ubuntu.

## References

<div id="refs" class="references">

<div id="ref-gerard2019priors">

Gerard, David, and Luis Felipe Ventorim Ferrão. 2019. “Priors for
Genotyping Polyploids.”

</div>

<div id="ref-shirasawa2017high">

Shirasawa, Kenta, Masaru Tanaka, Yasuhiro Takahata, Daifu Ma, Qinghe
Cao, Qingchang Liu, Hong Zhai, et al. 2017. “A High-Density SNP Genetic
Map Consisting of a Complete Set of Homologous Groups in Autohexaploid
Sweetpotato (*Ipomoea Batatas*).” *Scientific Reports* 7. Nature
Publishing Group. <https://doi.org/10.1038/srep44207>.

</div>

<div id="ref-uitdewilligen2013next">

Uitdewilligen, Jan G. A. M. L., Anne-Marie A. Wolters, Bjorn B. D’hoop,
Theo J. A. Borm, Richard G. F. Visser, and Herman J. van Eck. 2013. “A
Next-Generation Sequencing Method for Genotyping-by-Sequencing of Highly
Heterozygous Autotetraploid Potato.” *PLOS ONE* 8 (5). Public Library of
Science: 1–14. <https://doi.org/10.1371/journal.pone.0062355>.

</div>

</div>
