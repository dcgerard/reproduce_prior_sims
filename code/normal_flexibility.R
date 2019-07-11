######################
## Demonstrate flexibility of normal prior
######################


library(updog)
library(tidyverse)
library(ggthemes)
ploidy <- 6

qarray <- updog::get_q_array(ploidy = 6)
targetdf <- tibble(uniform = rep(1 / (ploidy + 1), ploidy + 1),
                   f1 = qarray[2, 3, ],
                   hw = dbinom(x = 0:ploidy, size = ploidy, prob = 0.25),
                   bb = dbetabinom(x = 0:ploidy, size = ploidy, mu = 0.25, rho = 0.1, log = FALSE))


# par is a vector of length 2. The first element is the mean of the normal,
# the second element is the log standard deviation (NOT variance) of the normal.
# pivec is the target distribution.
obj_fun <- function(par, pivec) {
  mu      <- par[1]
  sigma   <- exp(par[2])
  ploidy  <- length(pivec) - 1
  normvec <- dnorm(x = 0:ploidy, mean = mu, sd = sigma, log = FALSE)
  normvec <- normvec / sum(normvec)
  return(-sum(pivec * log(normvec)))
}


norm_mat <- matrix(NA, nrow = nrow(targetdf), ncol = ncol(targetdf))
colnames(norm_mat) <- paste0("norm_", names(targetdf))

for (index in seq_len(ncol(targetdf))) {
  pivec <- targetdf[, index, drop = TRUE]
  muinit <- sum((0:ploidy) * pivec)
  logsdinit <- log(sqrt(sum(((0:ploidy) - muinit) ^ 2 * pivec)))

  oout <- optim(par = c(muinit, logsdinit), fn = obj_fun, pivec = pivec)

  fitted_vec <- dnorm(x = 0:ploidy, mean = oout$par[1], sd = exp(oout$par[2]), log = FALSE)
  fitted_vec <- fitted_vec / sum(fitted_vec)
  norm_mat[, index] <- fitted_vec
}


norm_df <- as_tibble(norm_mat)
names(targetdf) <- paste0("target_", names(targetdf))
totdf <- bind_cols(targetdf, norm_df)


## Plot results ---------------------------------------------------------------
totdf %>%
  mutate(genotype = 0:(n() - 1)) %>%
  gather(-genotype, key = "type_dist", value = "prop") %>%
  separate(col = type_dist, into = c("type", "dist")) %>%
  mutate(type = recode(type,
                       "target" = "Target",
                       "norm" = "Normal"),
         dist = recode(dist,
                       "uniform" = "Uniform",
                       "f1" = "F1",
                       "hw" = "Hardy-Weinberg",
                       "bb" = "Beta-binomial"),
         dist = parse_factor(dist, levels = c("Uniform", "F1", "Hardy-Weinberg", "Beta-binomial")),
         type = parse_factor(type, levels = c("Target", "Normal"))) ->
  totlong


totlong$genotype[totlong$type == "Normal"] <- totlong$genotype[totlong$type == "Normal"] + 0.15

ggplot(totlong, aes(x     = genotype,
                    xend  = genotype,
                    y     = 0,
                    yend  = prop,
                    color = type)) +
  facet_wrap(.~dist) +
  geom_segment(lwd = 1.5, lineend = "round") +
  scale_color_colorblind(name = "Distribution") +
  scale_x_continuous(breaks = 0:ploidy) +
  theme_bw() +
  theme(strip.background = element_rect(fill = "white")) +
  xlab("Genotype") +
  ylab("Probability") ->
  pl

ggsave(filename = "./output/figures/norm_approx.pdf",
       plot     = pl,
       height   = 4,
       width    = 6,
       family   = "Times")
