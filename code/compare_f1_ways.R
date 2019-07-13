#########################
## Show faster to use modified F1 distribution
#########################

library(updog)
library(tidyverse)
data("snpdat")


s1_iterate <- function(refvec, sizevec, ploidy) {
  lmat <- cbind(0:ploidy, 0:ploidy)
  qarray <- updog::get_q_array(ploidy = ploidy)

  llike <- -Inf
  fkeep <- NULL
  for(index in seq_len(nrow(lmat))) {
    cat("Index", index, "of", nrow(lmat), "\n")
    prior_vec <- qarray[lmat[index, 1] + 1, lmat[index, 2] + 1, ]
    fout <- flexdog(refvec    = refvec,
                    sizevec   = sizevec,
                    ploidy    = ploidy,
                    model     = "custom",
                    prior_vec = prior_vec,
                    verbose   = FALSE)
    if (fout$llike > llike) {
      llike <- fout$llike
      fkeep <- fout
    }
  }
  return(fkeep)
}


snpvec <- unique(snpdat$snp)

alt_list <- list()
mix_list <- list()
alt_time_vec <- rep(NA, length(snpvec))
mix_time_vec <- rep(NA, length(snpvec))

for (index in seq_along(snpvec)) {
  current_snp <- snpvec[index]
  snpdat %>%
    filter(snp == current_snp) ->
    snp1

  mix_time <- system.time(
    fout <- flexdog(refvec = snp1$counts, sizevec = snp1$size, ploidy = 6, model = "s1")
  )

  it_time <- system.time(
    alt_f1 <- s1_iterate(refvec = snp1$counts, sizevec = snp1$size, ploidy = 6)
  )

  alt_list[[index]] <- alt_f1
  mix_list[[index]] <- fout
  alt_time_vec[index] <- it_time["elapsed"]
  mix_time_vec[index] <- mix_time["elapsed"]
}

tabdat <- tibble(SNP = snpvec, `Single EM (sec)` = mix_time_vec, `Multiple EM (sec)` = alt_time_vec)
writeLines(knitr::kable(tabdat), con = "./output/computation/f1_approaches.txt")

tot_df <- bind_rows(
  tibble(snp = snpvec[1], single = mix_list[[1]]$postmean, multi = alt_list[[1]]$postmean),
  tibble(snp = snpvec[2], single = mix_list[[2]]$postmean, multi = alt_list[[2]]$postmean),
  tibble(snp = snpvec[3], single = mix_list[[3]]$postmean, multi = alt_list[[3]]$postmean))

ggplot(tot_df, aes(x = single, y = multi)) +
  facet_grid(.~snp) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, lty = 2, col = 2) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  xlab("Posterior Mean Genotype (Single EM)") +
  ylab("Posterior Mean Genotype (Multiple EMs)") +
  scale_x_continuous(breaks = 4:6) ->
  pl

ggsave("./output/figures/f1_post_means.pdf",
       width = 6,
       height = 2.7,
       family = "Times")
