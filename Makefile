
N_BURNIN = 10000
N_SIM = 10000
N_CHAIN = 4
N_THIN = 40
SEED = 0
N_REPLICATE = 19

.PHONY: all
all: all_fig.pdf \
     abstract_long.pdf


## Prepare data

out/deaths.rds : src/deaths.R \
                 data/DEATHS_INDIGENOUS_01032019121919871.csv
	Rscript $<

out/population.rds : src/population.R \
                     data/DEATHS_INDIGENOUS_01032019121919871.csv
	Rscript $<

out/conc_states.rds : src/conc_states.R
	Rscript $<


## Graphs of data

out/fig_data_deaths.pdf : src/fig_data_deaths.R \
                          out/deaths.rds \
                          out/conc_states.rds
	Rscript $<

out/fig_data_population.pdf : src/fig_data_population.R \
                              out/population.rds \
                              out/conc_states.rds
	Rscript $<


## Graphs of direct estimates of rates

out/fig_rates_direct_2010.pdf : src/fig_rates_direct.R \
                                out/deaths.rds \
                                out/population.rds
	Rscript $< --time 2010

out/fig_rates_direct_2016.pdf : src/fig_rates_direct.R \
                                out/deaths.rds \
                                out/population.rds
	Rscript $< --time 2016


## Model

out/model_Baseline.est : src/model_baseline.R \
                         out/deaths.rds \
                         out/population.rds
	Rscript $< --n_burnin $(N_BURNIN) \
                   --n_sim $(N_SIM) \
                   --n_chain $(N_CHAIN) \
                   --n_thin $(N_THIN) \
                   --seed $(SEED)


## Table of priors

out/tab_priors_Baseline.tex : src/tab_priors.R \
                              out/model_Baseline.est
	Rscript $< --variant Baseline



## Replicate data

out/replicate_data_Baseline.pred : src/replicate_data.R \
                                   out/conc_states.rds \
                                   out/model_Baseline.est
	Rscript $< --variant Baseline  --seed $(SEED)


## Life expectancy

out/life_expectancy_direct.rds : src/life_expectancy_direct.R \
                                 out/deaths.rds \
                                 out/population.rds
	Rscript $<

out/life_expectancy_modelled_Baseline.rds : src/life_expectancy_modelled.R \
                                            out/model_Baseline.est
	Rscript $< --variant Baseline


## Graphs of modelled estimates of rates

out/fig_rates_modelled_2010_Baseline.pdf : src/fig_rates_modelled.R \
                                           out/model_Baseline.est
	Rscript $< --time 2010 --variant Baseline

out/fig_rates_modelled_2016_Baseline.pdf : src/fig_rates_modelled.R \
                                           out/model_Baseline.est
	Rscript $< --time 2016 --variant Baseline


## Graphs of replicate data

out/fig_replicate_data_Female_Indigenous_Baseline.pdf : src/fig_replicate_data.R \
                                                        out/model_Baseline.est \
                                                        out/replicate_data_Baseline.pred \
                                                        out/conc_states.rds
	Rscript $< --n_replicate $(N_REPLICATE) \
                   --sex Female \
                   --indigenous Indigenous \
                   --variant Baseline

out/fig_replicate_data_Male_Indigenous_Baseline.pdf : src/fig_replicate_data.R \
                                                      out/model_Baseline.est \
                                                      out/replicate_data_Baseline.pred \
                                                      out/conc_states.rds
	Rscript $< --n_replicate $(N_REPLICATE) \
                   --sex Male \
                   --indigenous Indigenous \
                   --variant Baseline

out/fig_replicate_data_Female_Non-Indigenous_Baseline.pdf : src/fig_replicate_data.R \
                                                            out/model_Baseline.est \
                                                            out/replicate_data_Baseline.pred \
                                                            out/conc_states.rds
	Rscript $< --n_replicate $(N_REPLICATE) \
                   --sex Female \
                   --indigenous Non-Indigenous \
                   --variant Baseline

out/fig_replicate_data_Male_Non-Indigenous_Baseline.pdf : src/fig_replicate_data.R \
                                                          out/model_Baseline.est \
                                                          out/replicate_data_Baseline.pred \
                                                          out/conc_states.rds
	Rscript $< --n_replicate $(N_REPLICATE) \
                   --sex Male \
                   --indigenous Non-Indigenous \
                   --variant Baseline


## Graphs of life expectancy

out/fig_life_expectancy_Baseline.pdf : src/fig_life_expectancy.R \
                                       out/life_expectancy_modelled_Baseline.rds
	Rscript $< --variant Baseline



## Documents

all_fig.tex : all_fig.Rnw
	Rscript -e "knitr::knit('$<')"

all_fig.pdf : all_fig.tex \
              out/fig_data_deaths.pdf \
              out/fig_data_population.pdf \
              out/fig_rates_direct_2010.pdf \
              out/fig_rates_direct_2016.pdf \
              out/fig_rates_modelled_2010_Baseline.pdf \
              out/fig_rates_modelled_2016_Baseline.pdf \
              out/fig_replicate_data_Female_Indigenous_Baseline.pdf \
              out/fig_replicate_data_Male_Indigenous_Baseline.pdf \
              out/fig_replicate_data_Female_Non-Indigenous_Baseline.pdf \
              out/fig_replicate_data_Male_Non-Indigenous_Baseline.pdf \
              out/fig_life_expectancy_Baseline.pdf
	pdflatex -interaction=batchmode all_fig
	pdflatex -interaction=batchmode all_fig


abstract_long.tex : abstract_long.Rnw
	Rscript -e "knitr::knit('$<')"

abstract_long.pdf : abstract_long.tex \
                    abstract_long.bib \
                    out/fig_rates_direct_2016.pdf \
                    out/tab_priors_Baseline.tex \
                    out/fig_rates_modelled_2016_Baseline.pdf \
                    out/fig_replicate_data_Female_Indigenous_Baseline.pdf \
                    out/fig_life_expectancy_Baseline.pdf
	pdflatex -interaction=batchmode abstract_long
	bibtex -terse abstract_long
	pdflatex -interaction=batchmode abstract_long
	pdflatex -interaction=batchmode abstract_long



## Clean up

.PHONY: clean
clean:
	rm -rf out
	mkdir -p out

.PHONY: cleantex
cleantex:
	rm -f *.aux *.log *.toc *.blg *.bbl *.synctex.gz *.idx *.lof *.lot *.tex


