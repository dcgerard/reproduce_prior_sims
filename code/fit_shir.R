##############################
## Fit different versions of flexdog on Shirasawa SNPs
##############################

library(updog)
library(doSNOW)

# Number of threads to use for multithreaded computing. This must be
# specified in the command-line shell; e.g., to use 8 threads, run
# command
#
#  R CMD BATCH '--args nc=8' mouthwash_sims.R
#
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  nc <- 1
} else {
  eval(parse(text = args[[1]]))
}


ploidy <- 6
refmat <- readRDS("./output/example_snps/shir_sub_ref.RDS")
sizemat <- readRDS("./output/example_snps/shir_sub_size.RDS")

nsnp <- nrow(refmat)
stopifnot(nsnp == nrow(sizemat))


combmat <- combn(c("unif", "f1", "hw", "bb", "norm", "ash", "flex", "s1"), m = 2)
combnames <- paste(combmat[1, ], combmat[2, ], sep = "_")

## Set up cluster and run -----------------------------------------------------
cl <- parallel::makeCluster(nc)
doParallel::registerDoParallel(cl = cl)
stopifnot(foreach::getDoParWorkers() > 1) ## make sure cluster is set up.
cat("Running multithreaded computations with", nc, "threads.\n")
simout <- foreach(i = seq_len(nrow(refmat)), .combine = rbind, .export = "flexdog") %dopar% {
  refvec <- refmat[i, ]
  sizevec <- sizemat[i, ]


  foutlist <- list(
    "unif" = flexdog(refvec = refvec, sizevec = sizevec, ploidy = ploidy, verbose = FALSE, model = "uniform"),
    "f1"   = flexdog(refvec = refvec, sizevec = sizevec, ploidy = ploidy, verbose = FALSE, model = "f1"),
    "hw"   = flexdog(refvec = refvec, sizevec = sizevec, ploidy = ploidy, verbose = FALSE, model = "hw"),
    "bb"   = flexdog(refvec = refvec, sizevec = sizevec, ploidy = ploidy, verbose = FALSE, model = "bb"),
    "norm" = flexdog(refvec = refvec, sizevec = sizevec, ploidy = ploidy, verbose = FALSE, model = "norm"),
    "ash"  = flexdog(refvec = refvec, sizevec = sizevec, ploidy = ploidy, verbose = FALSE, model = "ash"),
    "flex" = flexdog(refvec = refvec, sizevec = sizevec, ploidy = ploidy, verbose = FALSE, model = "flex"),
    "s1"   = flexdog(refvec = refvec, sizevec = sizevec, ploidy = ploidy, verbose = FALSE, model = "s1")
  )

  ## postmean distances ----
  postmeanmat <- sapply(foutlist, FUN = function(obj) {
    obj$postmean
  })
  distmat <- as.matrix(stats::dist(t(postmeanmat)))
  distvec <- distmat[lower.tri(distmat)]
  names(distvec) <- paste0("dist_", combnames)

  ## postmode distances ----
  genomat <- sapply(foutlist, FUN = function(obj) {
    obj$geno
  })
  propmat <- matrix(NA, nrow = nrow(distmat), ncol = ncol(distmat))
  dimnames(propmat) <- dimnames(distmat)
  for (i in seq_len(ncol(genomat))) {
    for (j in i:ncol(genomat)) {
      propmat[i, j] <- mean(genomat[, i] == genomat[, j], na.rm = TRUE)
      propmat[j, i] <- propmat[i, j]
    }
  }
  propvec <- propmat[lower.tri(propmat)]
  names(propvec) <- paste0("prop_", combnames)
  retvec <- c(propvec, distvec)
  retvec
}
stopCluster(cl)

saveRDS(object = simout, file = "./output/example_snps/shir_dist.RDS")
