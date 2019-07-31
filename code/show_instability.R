#########################
## Demonstrate instability of flexible genotype distribution
#########################

library(updog)
library(tidyverse)
uitsnp  <- read_csv(file = "./output/example_snps/uit_snp.csv")
refvec <- uitsnp$ref
sizevec <- uitsnp$size

fout_pen <- flexdog(refvec  = refvec,
                    sizevec = sizevec,
                    ploidy  = 4,
                    model   = "flex",
                    verbose = FALSE,
                    var_bias = 0.2^2)

pl <- plot(fout_pen)

ggsave(filename = "./output/figures/fix_flex.pdf",
       plot = pl,
       height = 2.5,
       width = 3.7,
       family = "Times")
