##########################
## Plot the prior distributions used in the simulation study
##########################

library(tidyverse)
pilist <- readRDS("./output/prior_sims/pilist.RDS")
pidf <- as_tibble(pilist)
pidf$genotype <- 0:6

factor_order_vec <- c("Uniform",
                      "F1",
                      "Hardy-Weinberg",
                      "Beta-binomial",
                      "Normal",
                      "Unimodal",
                      "General")

pidf %>%
  select(-uniform) %>%
  gather(-genotype, key = "Prior", value = "Probability") %>%
  mutate(Prior = recode(Prior,
                        "hw" = "Hardy-Weinberg",
                        "bb" = "Beta-binomial",
                        "norm" = "Normal",
                        "ash" = "Unimodal",
                        "f1" = "F1",
                        "flex" = "General",
                        "uniform" = "Uniform"),
         Prior = parse_factor(Prior, levels = factor_order_vec)) ->
  pidf_long

ggplot(pidf_long, aes(x    = genotype,
                      xend = genotype,
                      y    = 0,
                      yend = Probability)) +
  geom_segment(lineend = "round", lwd = 2) +
  facet_wrap(.~Prior) +
  xlab("Genotype") +
  ylab("Probability") +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  scale_x_continuous(breaks = 0:6) ->
  pl

ggsave(filename = "./output/figures/possible_priors.pdf",
       plot     = pl,
       height   = 4,
       width    = 6,
       family   = "Times")
