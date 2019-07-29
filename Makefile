# ADJUST THESE VARIABLES AS NEEDED TO SUIT YOUR COMPUTING ENVIRONMENT
# -------------------------------------------------------------------
# This variable specifies the number of threads to use for the
# parallelization. This could also be specified automatically using
# environment variables. For example, in SLURM, SLURM_CPUS_PER_TASK
# specifies the number of CPUs allocated for each task.
nc = 12

# R scripting front-end. Note that makeCluster sometimes fails to
# connect to a socker when using Rscript, so we are using the "R CMD
# BATCH" interface instead.
rexec = R CMD BATCH --no-save --no-restore

# AVOID EDITING ANYTHING BELOW THIS LINE
# --------------------------------------

fig_dir = ./output/figures

## example snps where flexible and uniform priors don't work ----------
example_snp_plots = $(fig_dir)/shir_snp.pdf \
                    $(fig_dir)/uit_snp.pdf

## Uitdewilligen SNPs with low read-depth -----------------------------
uit_snps = ./output/example_snps/uit_sub_ref.RDS \
	   ./output/example_snps/uit_sub_size.RDS

shir_snps = ./output/example_snps/shir_sub_size.RDS \
	    ./output/example_snps/shir_sub_ref.RDS

## Output of ./code/prior_sims.R --------------------------------------
simout = ./output/prior_sims/parvals.RDS \
         ./output/prior_sims/pilist.RDS \
         ./output/prior_sims/sims_out.RDS

## Graphical summaries of prior simulations ---------------------------
simplots = ./output/figures/bias_plots/bias_Beta-binomial.pdf \
           ./output/figures/bias_plots/bias_F1.pdf \
           ./output/figures/bias_plots/bias_General.pdf \
           ./output/figures/bias_plots/bias_Hardy-Weinberg.pdf \
           ./output/figures/bias_plots/bias_Normal.pdf \
           ./output/figures/bias_plots/bias_Uniform.pdf \
           ./output/figures/bias_plots/bias_Unimodal.pdf \
           ./output/figures/epm_plots/epm_Beta-binomial.pdf \
           ./output/figures/epm_plots/epm_F1.pdf \
           ./output/figures/epm_plots/epm_General.pdf \
           ./output/figures/epm_plots/epm_Hardy-Weinberg.pdf \
           ./output/figures/epm_plots/epm_Normal.pdf \
           ./output/figures/epm_plots/epm_Uniform.pdf \
           ./output/figures/epm_plots/epm_Unimodal.pdf \
           ./output/figures/od_plots/od_Beta-binomial.pdf \
           ./output/figures/od_plots/od_F1.pdf \
           ./output/figures/od_plots/od_General.pdf \
           ./output/figures/od_plots/od_Hardy-Weinberg.pdf \
           ./output/figures/od_plots/od_Normal.pdf \
           ./output/figures/od_plots/od_Uniform.pdf \
           ./output/figures/od_plots/od_Unimodal.pdf \
           ./output/figures/pc_plots/pc_Beta-binomial.pdf \
           ./output/figures/pc_plots/pc_F1.pdf \
           ./output/figures/pc_plots/pc_General.pdf \
           ./output/figures/pc_plots/pc_Hardy-Weinberg.pdf \
           ./output/figures/pc_plots/pc_Normal.pdf \
           ./output/figures/pc_plots/pc_Uniform.pdf \
           ./output/figures/pc_plots/pc_Unimodal.pdf \
	   ./output/figures/epm_summary.pdf \
           ./output/figures/pc_summary.pdf


real_plots = ./output/figures/shir_propsame.pdf \
             ./output/figures/shir_dist.pdf \
	     ./output/figures/shir_both.pdf



all : example sims normal f1comp unicomp realdata


#####
## Code for example recipe
#####

# Download Uitdewilligen data -----------------------------------------
./data/journal.pone.0062355.s007.GZ :
	wget --directory-prefix=data --no-clobber https://doi.org/10.1371/journal.pone.0062355.s007
	cp ./data/journal.pone.0062355.s007 ./data/journal.pone.0062355.s007.GZ

# Extract example SNP from Uitdewilligen data
./output/example_snps/uit_snp.csv $(uit_snps) : ./code/extract_uit.R ./data/journal.pone.0062355.s007.GZ
	mkdir -p ./output/example_snps
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

# Download the Shirasawa data -----------------------------------------
./data/KDRIsweetpotatoXushu18S1LG2017.vcf.gz :
	wget --directory-prefix=data --no-clobber ftp://ftp.kazusa.or.jp/pub/sweetpotato/GeneticMap/KDRIsweetpotatoXushu18S1LG2017.vcf.gz

# Extract example SNP from Shirasawa data -----------------------------
./output/example_snps/shir_snp.csv $(shir_snps) : ./code/extract_shir.R ./data/KDRIsweetpotatoXushu18S1LG2017.vcf.gz
	mkdir -p ./output/example_snps
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

# Fit updog with uniform and flex priors on both snps, plot results ---
$(example_snp_plots) : ./code/plot_example.R ./output/example_snps/uit_snp.csv ./output/example_snps/shir_snp.csv
	mkdir -p $(fig_dir)
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

# Fit flexdog with stronger penalty on bias, show fixes results -------
./output/figures/fix_flex.pdf : ./code/show_instability.R ./output/example_snps/uit_snp.csv
	mkdir -p $(fig_dir)
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout


# Create figures of example SNPs ---------------------------------------
.PHONY : example
example : $(example_snp_plots) ./output/figures/fix_flex.pdf


######
## Code for realdata recipe
######

./output/example_snps/shir_dist.RDS : ./code/fit_shir.R $(shir_snps)
	mkdir -p ./output/example_snps
	mkdir -p ./output/rout
	$(rexec) '--args nc=$(nc)' $< output/rout/$(basename $(notdir $<)).Rout

$(real_plots) : ./code/plot_dis.R ./output/example_snps/shir_dist.RDS
	mkdir -p $(fig_dir)
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

.PHONY : realdata
realdata : $(real_plots)

######
## Code for sims recipe
######

$(simout) : ./code/prior_sims.R
	mkdir -p ./output/prior_sims/
	mkdir -p ./output/rout
	$(rexec) '--args nc=$(nc)' $< output/rout/$(basename $(notdir $<)).Rout

./output/figures/possible_priors.pdf : ./code/plot_priors.R $(simout)
	mkdir -p $(fig_dir)
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

$(simplots) : ./code/plot_sims.R $(simout)
	mkdir -p $(fig_dir)
	mkdir -p $(fig_dir)/bias_plots
	mkdir -p $(fig_dir)/epm_plots
	mkdir -p $(fig_dir)/od_plots
	mkdir -p $(fig_dir)/pc_plots
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

.PHONY : sims
sims : $(simplots) ./output/figures/possible_priors.pdf


######
## Code for normal recipe
######

./output/figures/norm_approx.pdf : ./code/normal_flexibility.R
	mkdir -p $(fig_dir)
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

.PHONY : normal
normal : ./output/figures/norm_approx.pdf

#####
## Code for f1comp recipe
#####

./output/figures/f1_post_means.pdf ./output/computation/f1_approaches.txt : ./code/compare_f1_ways.R
	mkdir -p $(fig_dir)
	mkdir -p ./output/computation
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

.PHONY : f1comp
f1comp : ./output/figures/f1_post_means.pdf ./output/computation/f1_approaches.txt


#####
## Code for unicomp recipe
#####

./output/figures/unimodal_post_means.pdf ./output/computation/unimodal_approaches.txt : ./code/compare_unimodal_ways.R
	mkdir -p $(fig_dir)
	mkdir -p ./output/computation
	mkdir -p ./output/rout
	$(rexec) $< ./output/rout/$(basename $(notdir $<)).Rout

.PHONY : unicomp
unicomp : ./output/figures/unimodal_post_means.pdf ./output/computation/unimodal_approaches.txt 


#####
## Clean up to reset simulations
#####

.PHONY : clean
clean :
	rm -rf ./output/computation
	rm -rf ./output/example_snps
	rm -rf ./output/figures
	rm -rf ./output/prior_sims
	rm -rf ./output/rout
