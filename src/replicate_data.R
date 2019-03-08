
library(methods)
library(demest)
library(dplyr)
library(docopt)

'
Usage:
replicate_data.R [options]

Options:
--variant [default: Baseline]
--seed [default: 0]
' -> doc
opts <- docopt(doc)
variant <- opts$variant
seed <- opts$seed %>% as.numeric()

set.seed(seed)

conc_states <- readRDS("out/conc_states.rds")

filename_est <- sprintf("out/model_%s.est", variant)
filename_replicate <- sprintf("out/replicate_data_%s.pred", variant)

exposure <- fetch(filename_est, where = "exposure") %>%
    recodeCategories(dimension = "region",
                     concordance = conc_states)

labels_pred <- dimnames(exposure)$region

predictModel(filenameEst = filename_est,
             filenamePred = filename_replicate,
             along = "region",
             labels = labels_pred,
             exposure = exposure)
