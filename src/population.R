
library(methods)
library(dplyr)
library(readr)
library(forcats)
library(dembase)

population <- read_csv("data/DEATHS_INDIGENOUS_01032019121919871.csv") %>%
    filter(Measure == "Population") %>%
    select(sex = Sex,
           age = Age,
           indigenous = "Indigenous status",
           region = Region,
           time = Time,
           value = Value) %>%
    mutate(age = cleanAgeGroup(age)) %>%
    mutate(sex = fct_recode(sex, Female = "Females", Male = "Males")) %>%
    dtabs(value ~ age + sex + region + indigenous + time) %>%
    Counts(dimscales = c(time = "Intervals"))

check_total <- read_csv("data/DEATHS_INDIGENOUS_01032019121919871.csv") %>%
    filter(Measure == "Population") %>%
    pull(Value) %>%
    sum()

stopifnot(all.equal(sum(population), check_total))

saveRDS(population,
        file = "out/population.rds")
