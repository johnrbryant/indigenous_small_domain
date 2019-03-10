
library(demest)
library(dplyr)
library(docopt)

'
Usage:
model_Baseline.R [options]

Options:
--n_burnin [default: 5]
--n_sim [default: 5]
--n_chain [default: 4]
--n_thin [default: 1]
--seed [default: 0]
' -> doc
opts <- docopt(doc)
n_burnin <- opts$n_burnin %>% as.integer()
n_sim <- opts$n_sim %>% as.integer()
n_chain <- opts$n_chain %>% as.integer()
n_thin <- opts$n_thin %>% as.integer()
seed <- opts$seed %>% as.numeric()


deaths <- readRDS("out/deaths.rds")
population <- readRDS("out/population.rds")

model <- Model(y ~ Poisson(mean ~ (age * sex + region + time) * indigenous),
               age ~ DLM(damp = NULL,
                         covariates = Covariates(infant = TRUE)),
               time ~ DLM(damp = NULL),
               time:indigenous ~ DLM(trend = NULL,
                                     damp = NULL),
               jump = 0.045)

Sys.time()
filename <- "out/model_Baseline.est"
estimateModel(model,
              y = deaths,
              exposure = population,
              filename = filename,
              nBurnin = n_burnin,
              nSim = n_sim,
              nChain = n_chain,
              nThin = n_thin)
Sys.time()

options(width = 120)
fetchSummary(filename)
