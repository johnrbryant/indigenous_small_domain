
library(methods)
library(demest)
library(demlife)
library(dplyr)


deaths <- readRDS("out/deaths.rds")
population <- readRDS("out/population.rds")

rate <- deaths / population

life_exp <- rate %>%
    LifeTable() %>%
    lifeExpectancy()

saveRDS(life_exp,
        file = "out/life_expectancy_direct.rds")
