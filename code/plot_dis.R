########################
## Plot Uitdewilligen dissimiliarity matrices
########################

library(tidyverse)
disdf <- as_tibble(readRDS("./output/example_snps/shir_dist.RDS"))

level_vec <- c("Uniform", "F1", "Hardy-Weinberg", "Beta-binomial",
               "Normal", "Unimodal", "General", "S1")
disdf %>%
  select(starts_with("prop")) %>%
  gather(key = "method_pair", value = "propsame") %>%
  mutate(method_pair = str_replace(method_pair, "^prop_", "")) %>%
  separate(col = method_pair, into = c("Prior1", "Prior2"), sep = "_") %>%
  group_by(Prior1, Prior2) %>%
  summarize(mean_prop = mean(propsame)) %>%
  ungroup() %>%
  mutate(Prior1 = recode(Prior1,
                         "s1"   = "S1",
                         "unif" = "Uniform",
                         "f1"   = "F1",
                         "hw"   = "Hardy-Weinberg",
                         "bb"   = "Beta-binomial",
                         "norm" = "Normal",
                         "ash"  = "Unimodal",
                         "flex" = "General"),
         Prior1 = parse_factor(Prior1, levels = level_vec),
         Prior2 = recode(Prior2,
                         "s1"   = "S1",
                         "unif" = "Uniform",
                         "f1"   = "F1",
                         "hw"   = "Hardy-Weinberg",
                         "bb"   = "Beta-binomial",
                         "norm" = "Normal",
                         "ash"  = "Unimodal",
                         "flex" = "General"),
         Prior2 = parse_factor(Prior2, levels = level_vec)) %>%
  ggplot(mapping = aes(x = Prior1, y = Prior2, fill = mean_prop)) +
  geom_tile() +
  scale_fill_gradient(low = "white", high = "steelblue") +
  theme_bw() +
  geom_text(aes(label = round(mean_prop, digits = 2))) +
  xlab("Prior 1") +
  ylab("Prior 2") +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
  scale_x_discrete(drop = FALSE) +
  scale_y_discrete(drop = FALSE) ->
  pl

ggsave(filename = "./output/figures/shir_propsame.pdf",
       plot = pl,
       height = 3.5,
       width = 4,
       family = "Times")

disdf %>%
  select(starts_with("dist")) %>%
  gather(key = "method_pair", value = "dist") %>%
  mutate(method_pair = str_replace(method_pair, "^dist_", "")) %>%
  separate(col = method_pair, into = c("Prior1", "Prior2"), sep = "_") %>%
  group_by(Prior1, Prior2) %>%
  summarize(mean_dist = mean(dist)) %>%
  ungroup() %>%
  mutate(Prior1 = recode(Prior1,
                         "s1"   = "S1",
                         "unif" = "Uniform",
                         "f1"   = "F1",
                         "hw"   = "Hardy-Weinberg",
                         "bb"   = "Beta-binomial",
                         "norm" = "Normal",
                         "ash"  = "Unimodal",
                         "flex" = "General"),
         Prior1 = parse_factor(Prior1, levels = level_vec),
         Prior2 = recode(Prior2,
                         "s1"   = "S1",
                         "unif" = "Uniform",
                         "f1"   = "F1",
                         "hw"   = "Hardy-Weinberg",
                         "bb"   = "Beta-binomial",
                         "norm" = "Normal",
                         "ash"  = "Unimodal",
                         "flex" = "General"),
         Prior2 = parse_factor(Prior2, levels = level_vec)) %>%
  ggplot(mapping = aes(x = Prior1, y = Prior2, fill = mean_dist)) +
  geom_tile() +
  scale_fill_gradient(low = "steelblue", high = "white") +
  theme_bw() +
  geom_text(aes(label = round(mean_dist, digits = 2))) +
  xlab("Prior 1") +
  ylab("Prior 2") +
  theme(legend.position = "none") +
  theme(axis.text.x = element_text(angle = 30, hjust = 1)) +
  scale_x_discrete(drop = FALSE) +
  scale_y_discrete(drop = FALSE) ->
  pl

ggsave(filename = "./output/figures/shir_dist.pdf",
       plot = pl,
       height = 3.5,
       width = 4,
       family = "Times")
