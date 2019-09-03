########################
## Plot results of the simulation study
########################

## Read in sims output --------------------------------------------------------
library(tidyverse)
library(ggthemes)
sims <- as_tibble(readRDS("./output/prior_sims/sims_out.RDS"))

## Format sims for tidy data --------------------------------------------------
factor_order_vec <- c("Uniform",
                      "F1",
                      "Hardy-Weinberg",
                      "Beta-binomial",
                      "Normal",
                      "Unimodal",
                      "General")

sims %>%
  select(-ploidy, -seq) %>%
  rename(od_real = od,
         bias_real = bias) %>%
  gather(pc_hw:od_uniform, key = "type_prior", value = "value") %>%
  separate(col = type_prior, into = c("Type", "Prior"), sep = "_") %>%
  spread(key = Type, value = value) %>%
  mutate(issame = geno_dist == Prior,
         geno_dist = recode(geno_dist,
                            "hw"      = "Hardy-Weinberg",
                            "bb"      = "Beta-binomial",
                            "norm"    = "Normal",
                            "ash"     = "Unimodal",
                            "f1"      = "F1",
                            "flex"    = "General",
                            "uniform" = "Uniform"),
         Prior = recode(Prior,
                        "hw"      = "Hardy-Weinberg",
                        "bb"      = "Beta-binomial",
                        "norm"    = "Normal",
                        "ash"     = "Unimodal",
                        "f1"      = "F1",
                        "flex"    = "General",
                        "uniform" = "Uniform"),
         geno_dist = parse_factor(geno_dist, levels = factor_order_vec),
         Prior = parse_factor(Prior, levels = factor_order_vec)) ->
  simslong

## Plot Proportion correct ----------------------------------------------------
for (index in seq_along(factor_order_vec)) {
  current_geno_dist <- factor_order_vec[index]
  simslong %>%
    filter(geno_dist == current_geno_dist) %>%
    ggplot(aes(x = Prior, y = pc, color = issame)) +
    geom_boxplot(outlier.size = 0.5) +
    facet_grid(od_real ~ bias_real) +
    guides(color = FALSE) +
    scale_color_colorblind() +
    theme_bw() +
    theme(strip.background = element_rect(fill = "white"),
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    xlab("Assumed Prior") +
    ylab("Proportion Correct") ->
    pl
  ggsave(filename = paste0("./output/figures/pc_plots/pc_", current_geno_dist, ".pdf"),
         plot = pl,
         height = 7,
         width = 6,
         family = "Times")
}

## Plot estimated bias against true bias --------------------------------------
simslong %>%
  select(od_real, bias_real) %>%
  distinct() ->
  smalldf
for (index in seq_along(factor_order_vec)) {
  current_geno_dist <- factor_order_vec[index]
  simslong %>%
    filter(geno_dist == current_geno_dist) %>%
    ggplot(aes(x = Prior, y = bias, color = issame)) +
    geom_boxplot(outlier.size = 0.5) +
    facet_grid(od_real ~ bias_real) +
    guides(color = FALSE) +
    scale_color_colorblind() +
    theme_bw() +
    theme(strip.background = element_rect(fill = "white"),
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    xlab("Assumed Prior") +
    ylab("Estimated Bias") +
    geom_hline(data = smalldf, mapping = aes(yintercept = bias_real), alpha = 1/2, lwd = 1, col = "blue") +
    scale_y_log10() ->
    pl
  ggsave(filename = paste0("./output/figures/bias_plots/bias_", current_geno_dist, ".pdf"),
         plot = pl,
         height = 7,
         width = 6,
         family = "Times")
}



## Plot estimated od against true od --------------------------------------
logit_fun <- function(x) {
  log(x / (1 - x))
}
for (index in seq_along(factor_order_vec)) {
  current_geno_dist <- factor_order_vec[index]
  simslong %>%
    filter(geno_dist == current_geno_dist) %>%
    mutate(logit_od = logit_fun(od)) %>%
    ggplot(aes(x = Prior, y = logit_od, color = issame)) +
    geom_boxplot(outlier.size = 0.5) +
    facet_grid(od_real ~ bias_real) +
    guides(color = FALSE) +
    scale_color_colorblind() +
    theme_bw() +
    theme(strip.background = element_rect(fill = "white"),
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    xlab("Assumed Prior") +
    ylab("logit(Overdispersion Estimate)") +
    geom_hline(data = smalldf, mapping = aes(yintercept = logit_fun(od_real)), alpha = 1/2, lwd = 1, col = "blue") ->
    pl
  ggsave(filename = paste0("./output/figures/od_plots/od_", current_geno_dist, ".pdf"),
         plot = pl,
         height = 7,
         width = 6,
         family = "Times")
}

## Plot estimated proportion missed minus proportion missed
simslong %>%
  mutate(pm = 1 - pc,
         diff = pm - epm) ->
  simslong
for (index in seq_along(factor_order_vec)) {
  current_geno_dist <- factor_order_vec[index]
  simslong %>%
    filter(geno_dist == current_geno_dist) %>%
    ggplot(aes(x = Prior, y = diff, color = issame)) +
    geom_boxplot(outlier.size = 0.5) +
    facet_grid(od_real ~ bias_real) +
    guides(color = FALSE) +
    scale_color_colorblind() +
    theme_bw() +
    theme(strip.background = element_rect(fill = "white"),
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    xlab("Assumed Prior") +
    ylab("Proportion Missed - Estimated Proportion Missed") +
    geom_hline(yintercept = 0, alpha = 1/2, lwd = 1, col = "blue") ->
    pl
  ggsave(filename = paste0("./output/figures/epm_plots/epm_", current_geno_dist, ".pdf"),
         plot = pl,
         height = 7,
         width = 6,
         family = "Times")
}




###############################
## Plot proportion correct and empirical proportion missed for just when
## no bias and no od
###############################

simslong %>%
  filter(od_real == 0, bias_real == 1) %>%
  ggplot(aes(x = Prior, y = pc, col = issame)) +
  geom_boxplot(outlier.size = 0.5) +
  facet_wrap(.~geno_dist, ncol = 4) +
  guides(color = FALSE) +
  scale_color_colorblind() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white"),
        axis.text.x = element_text(angle = 60, hjust = 1)) +
  xlab("Assumed Prior") +
  ylab("Proportion Correct") ->
  pl

ggsave(filename = "./output/figures/pc_summary.pdf",
       plot = pl,
       height = 7,
       width = 12,
       family = "Times")

simslong %>%
  filter(od_real == 0, bias_real == 1) %>%
  ggplot(aes(x = Prior, y = diff, col = issame)) +
  geom_boxplot(outlier.size = 0.5) +
  facet_wrap(.~geno_dist, ncol = 4) +
  guides(color = FALSE) +
  scale_color_colorblind() +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white"),
        axis.text.x = element_text(angle = 60, hjust = 1)) +
  xlab("Assumed Prior") +
  ylab("Proportion Missed - Estimated Proportion Missed") +
  geom_hline(yintercept = 0, alpha = 1/2, lwd = 1, col = "blue") ->
  pl

ggsave(filename = "./output/figures/epm_summary.pdf",
       plot = pl,
       height = 7,
       width = 12,
       family = "Times")
