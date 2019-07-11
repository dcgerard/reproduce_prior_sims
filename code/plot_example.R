########################
## Plot example of bad behavior by flexible and uniform priors
########################

## Read in data ---------------------------------------------------------------
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(updog))
library(ggthemes)
shirsnp <- read_csv(file = "./output/example_snps/shir_snp.csv")
uitsnp  <- read_csv(file = "./output/example_snps/uit_snp.csv")
shirsnp$data <- "Shirasawa"
shirsnp$ploidy <- 6
uitsnp$data  <- "Uitdewilligen"
uitsnp$ploidy <- 4

## Fit flexible, uniform, and normal updog to shirasawa data ------------------
flex_out <- flexdog(refvec  = shirsnp$ref,
                    sizevec = shirsnp$size,
                    ploidy  = 6,
                    model   = "flex")
shirsnp$flex_geno <- flex_out$geno

uniform_out <- flexdog(refvec  = shirsnp$ref,
                       sizevec = shirsnp$size,
                       ploidy  = 6,
                       model   = "uniform")
shirsnp$uniform_geno <- uniform_out$geno

norm_out <- flexdog(refvec  = shirsnp$ref,
                    sizevec = shirsnp$size,
                    ploidy  = 6,
                    model   = "norm")
shirsnp$norm_geno <- norm_out$geno

shir_bias_vec <- c(flex    = flex_out$bias,
                   uniform = uniform_out$bias,
                   norm    = norm_out$bias)

shir_seq_vec <- c(flex    = flex_out$seq,
                  uniform = uniform_out$seq,
                  norm    = norm_out$seq)

## Fit flexible, uniform, and normal updog to uitdewilligen data --------------
flex_out <- flexdog(refvec  = uitsnp$ref,
                    sizevec = uitsnp$size,
                    ploidy  = 4,
                    model   = "flex")
uitsnp$flex_geno <- flex_out$geno

uniform_out <- flexdog(refvec  = uitsnp$ref,
                       sizevec = uitsnp$size,
                       ploidy  = 4,
                       model   = "uniform")
uitsnp$uniform_geno <- uniform_out$geno

norm_out <- flexdog(refvec  = uitsnp$ref,
                    sizevec = uitsnp$size,
                    ploidy  = 4,
                    model   = "norm")
uitsnp$norm_geno <- norm_out$geno

uit_bias_vec <- c(flex    = flex_out$bias,
                  uniform = uniform_out$bias,
                  norm    = norm_out$bias)

uit_seq_vec <- c(flex    = flex_out$seq,
                 uniform = uniform_out$seq,
                 norm    = norm_out$seq)

## Get attributes -------------------------------------------------------------
get_exp <- function(bias, seq, ploidy) {
  fep <- (1 - seq) * (0:ploidy) / ploidy + seq * (1 - (0:ploidy) / ploidy)
  prob <- fep / ((1 - fep) * bias + fep)
}

shir_attdf <- tibble(bias  = shir_bias_vec,
                     seq   = shir_seq_vec,
                     prior = names(shir_bias_vec),
                     data  = "Shirasawa")
probsout <- mapply(shir_attdf$bias, shir_attdf$seq, FUN = get_exp, MoreArgs = list(ploidy = 6))
rownames(probsout) <- paste0("G", 0:6)
probsout <- as.data.frame(t(probsout))
probsout$prior <- shir_attdf$prior
shir_attdf <- left_join(shir_attdf, probsout, by = "prior")

shir_maxval <- max(max(shirsnp$ref, na.rm = TRUE),
                   max(shirsnp$size - shirsnp$ref, na.rm = TRUE))
shir_attdf %>%
  select(-bias, -seq, -data) %>%
  gather(starts_with("G"), key = "Genotype", value = "Expectation") %>%
  mutate(xstart = 0,
         ystart = 0,
         xend = pmin(shir_maxval * (1 - Expectation) / Expectation, shir_maxval),
         yend = pmin(shir_maxval * Expectation / (1 - Expectation), shir_maxval),
         prior = recode(prior,
                        "flex" = "B. General",
                        "norm" = "D. Normal",
                        "uniform" = "C. Uniform"),
         prior = factor(prior, levels = c("A. Raw", "B. General", "C. Uniform", "D. Normal"))) ->
    shir_attdf_long


uit_attdf <- tibble(bias  = uit_bias_vec,
                    seq   = uit_seq_vec,
                    prior = names(uit_bias_vec),
                    data  = "Uitdewilligen")

probsout <- mapply(uit_attdf$bias, uit_attdf$seq, FUN = get_exp, MoreArgs = list(ploidy = 4))
rownames(probsout) <- paste0("G", 0:4)
probsout <- as.data.frame(t(probsout))
probsout$prior <- uit_attdf$prior
uit_attdf <- left_join(uit_attdf, probsout, by = "prior")

uit_maxval <- max(max(uitsnp$ref, na.rm = TRUE),
                   max(uitsnp$size - uitsnp$ref, na.rm = TRUE))
uit_attdf %>%
  select(-bias, -seq, -data) %>%
  gather(starts_with("G"), key = "Genotype", value = "Expectation") %>%
  mutate(xstart = 0,
         ystart = 0,
         xend = pmin(uit_maxval * (1 - Expectation) / Expectation, uit_maxval),
         yend = pmin(uit_maxval * Expectation / (1 - Expectation), uit_maxval),
         prior = recode(prior,
                        "flex" = "B. General",
                        "norm" = "D. Normal",
                        "uniform" = "C. Uniform"),
         prior = factor(prior, levels = c("A. Raw", "B. General", "C. Uniform", "D. Normal"))) ->
  uit_attdf_long

## Gather snp data and plot --------------------------------------------------
shirsnp %>%
  mutate(na_geno = NA) %>%
  select(ref, size, contains("geno")) %>%
  gather(contains("geno"), key = "prior", value = "Genotype") %>%
  mutate(prior = str_replace(prior, "_geno", ""),
         prior = recode(prior,
                        "na"   = "A. Raw",
                        "flex" = "B. General",
                        "norm" = "D. Normal",
                        "uniform" = "C. Uniform"),
         prior = factor(prior, levels = c("A. Raw", "B. General", "C. Uniform", "D. Normal")),
         Genotype = factor(Genotype, levels = 6:0)) ->
  shirsnp_long


shirsnp_long %>%
  ggplot(aes(x = size - ref, y = ref, color = Genotype)) +
  facet_wrap(. ~ prior) +
  geom_point(size = 0.8) +
  theme_bw() +
  scale_color_colorblind(drop = FALSE, na.value = "grey40") +
  theme(strip.background = element_rect(fill = "white")) +
  xlab("Alternative Count") +
  ylab("Reference Count") +
  xlim(0, shir_maxval) +
  ylim(0, shir_maxval) +
  geom_segment(data = shir_attdf_long,
               mapping = aes(x = xstart,
                             y = ystart,
                             xend = xend,
                             yend = yend),
               color = "grey50",
               lty = 2) ->
  pl

ggsave(filename = "./output/figures/shir_snp.pdf", plot = pl, width = 6, height = 4, family = "Times")


## Same for uit
uitsnp %>%
  mutate(na_geno = NA) %>%
  select(ref, size, contains("geno")) %>%
  gather(contains("geno"), key = "prior", value = "Genotype") %>%
  mutate(prior = str_replace(prior, "_geno", ""),
         prior = recode(prior,
                        "na"   = "A. Raw",
                        "flex" = "B. General",
                        "norm" = "D. Normal",
                        "uniform" = "C. Uniform"),
         prior = factor(prior, levels = c("A. Raw", "B. General", "C. Uniform", "D. Normal")),
         Genotype = factor(Genotype, levels = 4:0)) ->
  uitsnp_long


uitsnp_long %>%
  ggplot(aes(x = size - ref, y = ref, color = Genotype)) +
  facet_wrap(. ~ prior) +
  geom_point(size = 0.8) +
  theme_bw() +
  scale_color_colorblind(drop = FALSE, na.value = "grey40") +
  theme(strip.background = element_rect(fill = "white")) +
  xlab("Alternative Count") +
  ylab("Reference Count") +
  xlim(0, uit_maxval) +
  ylim(0, uit_maxval) +
  geom_segment(data = uit_attdf_long,
               mapping = aes(x = xstart,
                             y = ystart,
                             xend = xend,
                             yend = yend),
               color = "grey50",
               lty = 2) ->
  pl

ggsave(filename = "./output/figures/uit_snp.pdf", plot = pl, width = 6, height = 4, family = "Times")

