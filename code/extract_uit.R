######################
## Extract Uitdewilligen SNPs
######################

suppressPackageStartupMessages(library(vcfR))
###############################################
## Important annotations for uit VCF gt fields:
## DP = read-depth
## AA = alternative allele
## GT = genotype
## GQ = genotype quality
## GL = log-10 scaled likelihood of genotype
## RA = reference allele
###############################################
uit <- read.vcfR(file = "./data/journal.pone.0062355.s007.GZ")
refmat  <- extract.gt(uit, element = "RA")
class(refmat) <- "numeric"
altmat  <- extract.gt(uit, element = "AA")
class(altmat) <- "numeric"
sizemat <- extract.gt(uit, element = "DP")
class(sizemat) <- "numeric"

## This SNP works very poorly with the both flexible prior and uniform prior
index <- 25538
refvec <- refmat[index, ]
sizevec <- sizemat[index, ]

dat <- data.frame(index = index,
                  ref   = refvec,
                  size  = sizevec)

write.csv(dat, "./output/example_snps/uit_snp.csv", row.names = TRUE)


## Extract 1000 SNPs with around 50 read-depth -------------------------------
med_size   <- apply(sizemat, 1, median, na.rm = TRUE)
which_keep <- order((med_size - 30)^2)[seq_len(1000)]
subref     <- refmat[which_keep, ]
subsize    <- sizemat[which_keep, ]

saveRDS(object = subref, file = "./output/example_snps/uit_sub_ref.RDS")
saveRDS(object = subsize, file = "./output/example_snps/uit_sub_size.RDS")
