#######################################
## Extract SNPs that would be good case studies for poor behavior
## of uniform and flexible priors
#######################################

## Read in data ---------------------------------------------------------------
suppressPackageStartupMessages(library(vcfR))

dat <- vcfR::read.vcfR(file = "./data/KDRIsweetpotatoXushu18S1LG2017.vcf.gz")
alt_mat <- apply(extract.gt(x = dat, element = "AD"), 2, as.numeric)
ref_mat <- apply(extract.gt(x = dat, element = "RD"), 2, as.numeric)

var_ave <- rowMeans(ref_mat + alt_mat, na.rm = TRUE)
order_vec <- order(var_ave, decreasing = TRUE)
alt_mat <- alt_mat[order_vec, ]
ref_mat <- ref_mat[order_vec, ]


## Extract SNPs ---------------------------------------------------------------
snpnum <- 3002
altvec <- alt_mat[snpnum, ]
refvec <- ref_mat[snpnum, ]
totvec <- altvec + refvec

dat <- data.frame(index = 3002,
                  ref   = refvec,
                  size  = totvec)

write.csv(dat, "./output/example_snps/shir_snp.csv", row.names = TRUE)


