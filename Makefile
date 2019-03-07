
N_BURNIN = 10000
N_SIM = 10000
N_CHAIN = 4
N_THIN = 40
SEED = 0

.PHONY: all
all: out/fig_rates_direct_female.pdf \
     out/fig_rates_direct_male.pdf \
     out/fig_rates_direct_modelled_female_indigenous_baseline.pdf \
     out/fig_rates_direct_modelled_male_indigenous_baseline.pdf \
     out/fig_rates_direct_modelled_female_nonindigenous_baseline.pdf \
     out/fig_rates_direct_modelled_male_nonindigenous_baseline.pdf

## Prepare data

out/deaths.rds : src/deaths.R \
                 data/DEATHS_INDIGENOUS_01032019121919871.csv
	Rscript $<

out/population.rds : src/population.R \
                     data/DEATHS_INDIGENOUS_01032019121919871.csv
	Rscript $<


## Graphs of direct estimates of rates

out/fig_rates_direct_female.pdf : src/fig_rates_direct.R \
                                  out/deaths.rds \
                                  out/population.rds
	Rscript $< --sex Female

out/fig_rates_direct_male.pdf : src/fig_rates_direct.R \
                                out/deaths.rds \
                                out/population.rds
	Rscript $< --sex Male


## Model

out/model_baseline.est : src/model_baseline.R \
                         out/deaths.rds \
                         out/population.rds
	Rscript $< --n_burnin $(N_BURNIN) \
                   --n_sim $(N_SIM) \
                   --n_chain $(N_CHAIN) \
                   --n_thin $(N_THIN) \
                   --seed $(SEED)

## Replicate data

out/replicate_data_baseline.pred : src/replicate_data.R \
                                   out/model_baseline.est
	Rscript $< --variant baseline  --seed $(SEED)



## Graphs of modelled estimates of rates

out/fig_rates_direct_modelled_female_indigenous_baseline.pdf : src/fig_rates_direct_modelled.R \
                                                               out/deaths.rds \
                                                               out/population.rds \
                                                               out/model_baseline.est
	Rscript $< --sex Female --indigenous Indigenous --variant baseline

out/fig_rates_direct_modelled_male_indigenous_baseline.pdf : src/fig_rates_direct_modelled.R \
                                                             out/deaths.rds \
                                                             out/population.rds \
                                                             out/model_baseline.est
	Rscript $< --sex Male --indigenous Indigenous --variant baseline

out/fig_rates_direct_modelled_female_nonindigenous_baseline.pdf : src/fig_rates_direct_modelled.R \
                                                                  out/deaths.rds \
                                                                  out/population.rds \
                                                                  out/model_baseline.est
	Rscript $< --sex Female --indigenous Non-Indigenous --variant baseline

out/fig_rates_direct_modelled_male_nonindigenous_baseline.pdf : src/fig_rates_direct_modelled.R \
                                                                out/deaths.rds \
                                                                out/population.rds \
                                                                out/model_baseline.est
	Rscript $< --sex Male --indigenous Non-Indigenous --variant baseline


## Graphs of replicate data

out/fig_replicate_data_female_indigenous_baseline.pdf : src/fig_replicate_data.R \
                                                        out/deaths.rds \
                                                        out/population.rds \
                                                        out/model_baseline.est
	Rscript $< --sex Female --indigenous Indigenous --variant baseline


## Clean up

.PHONY: clean
clean:
	rm -rf out
	mkdir -p out

