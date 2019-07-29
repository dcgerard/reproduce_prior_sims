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


## Extract 1000 SNPs with around 100 read-depth -------------------------------
## Choose only 30 SNPs so that priors are more important ----------------------
size_mat   <- alt_mat + ref_mat
med_size   <- apply(size_mat, 1, median, na.rm = TRUE)
which_keep <- order((med_size - 100)^2)[seq_len(1000)]
set.seed(31) ## for reproducibility
which_ind  <- sample(seq_len(ncol(size_mat)), size = 20)
subref     <- ref_mat[which_keep, which_ind]
subsize    <- size_mat[which_keep, which_ind]

saveRDS(object = subref, file = "./output/example_snps/shir_sub_ref.RDS")
saveRDS(object = subsize, file = "./output/example_snps/shir_sub_size.RDS")
