############################
## Compare unimodal optimization ways
############################

library(updog)
library(tidyverse)
data("snpdat")


snpvec <- unique(snpdat$snp)

emlist <- list()
cvlist <- list()

emtime_vec <- rep(NA, length = length(snpvec))
cvtime_vec <- rep(NA, length = length(snpvec))

for (index in seq_along(snpvec)) {

  current_snp <- snpvec[index]
  snpdat %>%
    filter(snp == current_snp) ->
    subsnp

  emtime <- system.time(
    emout   <- flexdog(refvec = subsnp$counts,
                       sizevec = subsnp$size,
                       ploidy = 6,
                       model = "ash",
                       use_cvxr = FALSE)
  )

  cvxrtime <- system.time(
    cvxrout <- flexdog(refvec = subsnp$counts,
                       sizevec = subsnp$size,
                       ploidy = 6,
                       model = "ash",
                       use_cvxr = TRUE)
  )

  emlist[[index]] <- emout
  cvlist[[index]] <- cvxrout
  emtime_vec[index] <- emtime["elapsed"]
  cvtime_vec[index] <- cvxrtime["elapsed"]
}

tabdat <- tibble(SNP = snpvec, `Weighted EM (sec)` = emtime_vec, `CVXR (sec)` = cvtime_vec)

writeLines(knitr::kable(tabdat), con = "./output/computation/unimodal_approaches.txt")

totdf <- bind_rows(
  tibble(snp = snpvec[1], wem = emlist[[1]]$postmean, cv = cvlist[[1]]$postmean),
  tibble(snp = snpvec[2], wem = emlist[[2]]$postmean, cv = cvlist[[2]]$postmean),
  tibble(snp = snpvec[3], wem = emlist[[3]]$postmean, cv = cvlist[[3]]$postmean))

ggplot(totdf, aes(x = wem, y = cv)) +
  facet_grid(.~snp) +
  geom_point() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  geom_abline(slope = 1, intercept = 0, lty = 2, col = 2) +
  xlab("Posterior Mean Genotypes (Weighted EM)") +
  ylab("Posterior Mean Genotypes (CVXR)") ->
  pl

ggsave(filename = "./output/figures/unimodal_post_means.pdf",
       height = 2.4,
       width = 6,
       family = "Times")




