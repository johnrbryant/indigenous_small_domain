
library(methods)
library(demest)
library(demlife)
library(dplyr)
library(docopt)

'
Usage:
life_expectancy_modelled.R [options]

Options:
--variant [default: Baseline]
' -> doc
opts <- docopt(doc)
variant <- opts$variant

filename_est <- sprintf("out/model_%s.est", variant)

rate <- fetch(filename_est, where = c("model", "likelihood", "rate"))

life_exp <- rate %>%
    LifeTable() %>%
    lifeExpectancy()

file <- sprintf("out/life_expectancy_modelled_%s.rds", variant)
saveRDS(life_exp,
        file = file)
