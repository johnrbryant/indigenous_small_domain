
library(demest)
library(dplyr)
library(docopt)

'
Usage:
model_baseline.R [options]

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
               time:indigenous ~ DLM(trend = NULL,
                                     damp = NULL),
               jump = 0.045)

Sys.time()
filename <- "out/model_baseline.est"
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


              


filename_est <- "out/model_baseline.est"
filename_pred <- "out/model_baseline.pred"
                          
predictModel(filenameEst = filename_est,
             filenamePred = filename_pred,
             along = "region",
             labels = LETTERS[1:5])

rate <- fetch(filename_pred, c("mod", "li", "ra")) %>%
    as.data.frame(direction = "long", midpoints = "age", stringsAsFactors = FALSE) %>%
    filter(time == "2016" & iteration <= 10 & sex == "Female" & indigenous == "Indigenous")

xyplot(value ~ age | iteration,
       data = rate,
       type = "b",
      groups = region)
