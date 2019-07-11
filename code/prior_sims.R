######################
## Simulation code for comparing the various priors
######################

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

## Simulation function --------------------------------------------------------
one_rep <- function(args, nvec, pilist) {
  set.seed(args$seed)
  pivec  <- pilist[[args$geno_dist]]
  geno   <- updog::rgeno(n      = length(nvec),
                         ploidy = args$ploidy,
                         model  = "flex",
                         pivec  = pivec)
  refvec <- updog::rflexdog(sizevec = nvec,
                            geno    = geno,
                            ploidy  = args$ploidy,
                            seq     = args$seq,
                            bias    = args$bias,
                            od      = args$od)

  mout <- list(hw = updog::flexdog(refvec = refvec,
                                   sizevec = nvec,
                                   ploidy = args$ploidy,
                                   model = "hw",
                                   verbose = FALSE),
               bb = updog::flexdog(refvec = refvec,
                                   sizevec = nvec,
                                   ploidy = args$ploidy,
                                   model = "bb",
                                   verbose = FALSE),
               norm = updog::flexdog(refvec = refvec,
                                     sizevec = nvec,
                                     ploidy = args$ploidy,
                                     model = "norm",
                                     verbose = FALSE),
               ash = updog::flexdog(refvec = refvec,
                                    sizevec = nvec,
                                    ploidy = args$ploidy,
                                    model = "ash",
                                    verbose = FALSE),
               f1 = updog::flexdog(refvec = refvec,
                                   sizevec = nvec,
                                   ploidy = args$ploidy,
                                   model = "f1",
                                   verbose = FALSE),
               flex = updog::flexdog(refvec = refvec,
                                     sizevec = nvec,
                                     ploidy = args$ploidy,
                                     model = "flex",
                                     verbose = FALSE),
               uniform = updog::flexdog(refvec = refvec,
                                        sizevec = nvec,
                                        ploidy = args$ploidy,
                                        model = "uniform",
                                        verbose = FALSE))


  ## Save output -----------------

  ## proportion correct
  pc_vec <- rep(NA, length = length(mout))
  names(pc_vec) <- paste0("pc_", names(mout))

  ## empirical estimate of proportion missed
  epm_vec <- rep(NA, length = length(mout))
  names(epm_vec) <- paste0("epm_", names(mout))

  ## estimated sequencing error rate
  seq_vec <- rep(NA, length = length(mout))
  names(seq_vec) <- paste0("seq_", names(mout))

  ## estimated bias parameters
  bias_vec <- rep(NA, length = length(mout))
  names(bias_vec) <- paste0("bias_", names(mout))

  ## estiamted overdispersion parameters
  od_vec <- rep(NA, length = length(mout))
  names(od_vec) <- paste0("od_", names(mout))

  for (index in seq_along(mout)) {
    pc_vec[index]   <- mean(mout[[index]]$geno == geno)
    seq_vec[index]  <- mout[[index]]$seq
    bias_vec[index] <- mout[[index]]$bias
    od_vec[index]   <- mout[[index]]$od
    epm_vec[index]  <- mout[[index]]$prop_mis
  }

  return_vec <- c(pc_vec,
                  epm_vec,
                  seq_vec,
                  bias_vec,
                  od_vec,
                  unlist(args))

  return(return_vec)
}

## Set up true priors for simulation study ------------------------------------
nvec <- rep(100, length = 30)
mean_val <- 4.5
ploidy      <- 6
allele_freq <- mean_val / ploidy
p1geno      <- 4
p2geno      <- 5
bb_od       <- 0.1
mu          <- mean_val
sigma       <- 0.5 ## sd of binomial is about 1.061, so underdispersed here.

pilist <- list()
pilist[[1]] <- dbinom(x = 0:ploidy, size = ploidy, prob = allele_freq)
pilist[[2]] <- updog::dbetabinom(x = 0:ploidy, size = ploidy, mu = allele_freq, rho = bb_od, log = FALSE)
pilist[[3]] <- dnorm(x = 0:ploidy, mean = mu, sd = sigma)
pilist[[3]] <- pilist[[3]] / sum(pilist[[3]])
pilist[[4]] <- 0:ploidy
pilist[[4]] <- pilist[[4]] / sum(pilist[[4]])
pilist[[5]] <- updog::get_q_array(ploidy = ploidy)[p1geno + 1, p2geno + 1, ]
pilist[[6]] <- c(1, 4, 1, 4, 1, 4, 8)
pilist[[6]] <- pilist[[6]] / sum(pilist[[6]])
pilist[[7]] <- rep(1 / (ploidy + 1), length = ploidy + 1)
pinames <- c("hw", "bb", "norm", "ash", "f1", "flex", "uniform")
names(pilist) <- pinames

saveRDS(object = pilist, file = "./output/prior_sims/pilist.RDS")

## Likelihood conditions ------------------------------------------------------
seq     <- 0.001
odvec   <- c(0, 0.005, 0.01)
biasvec <- c(1, 0.75, 0.5)
itermax <- 500

## Parameters for each replication -------------------------------------------
parvals <- expand.grid(seed      = seq_len(itermax),
                       od        = odvec,
                       bias      = biasvec,
                       geno_dist = pinames)
parvals$seq <- seq
parvals$ploidy <- ploidy

## randomize order so heavy computation doesn't cluster together --------------
set.seed(1)
parvals <- parvals[sample(seq_len(nrow(parvals))), ]

saveRDS(object = parvals, file = "./output/prior_sims/parvals.RDS")

## Set up cluster and run -----------------------------------------------------
cl <- parallel::makeCluster(nc)
doParallel::registerDoParallel(cl = cl)
stopifnot(foreach::getDoParWorkers() > 1) ## make sure cluster is set up.
cat("Running multithreaded computations with", nc, "threads.\n")
simout <- foreach(i = seq_len(nrow(parvals)), .combine = rbind) %dopar% {
  one_rep(args = parvals[i, ], nvec = nvec, pilist = pilist)
}
stopCluster(cl)

simout <- as.data.frame(simout)

simout$geno_dist <- levels(parvals$geno_dist)[simout$geno_dist]
stopifnot(simout$geno_dist == parvals$geno_dist)

saveRDS(object = simout, file = "./output/prior_sims/sims_out.RDS")
