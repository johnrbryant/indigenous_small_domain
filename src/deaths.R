
library(methods)
library(dplyr)
library(readr)
library(forcats)
library(dembase)

deaths <- read_csv("data/DEATHS_INDIGENOUS_01032019121919871.csv") %>%
    filter(Measure == "Deaths") %>%
    select(sex = Sex,
           age = Age,
           indigenous = "Indigenous status",
           region = Region,
           time = Time,
           value = Value) %>%
    filter(age != "not stated") %>% ## only 75, so safe to discard
    mutate(age = cleanAgeGroup(age)) %>%
    mutate(sex = fct_recode(sex, Female = "Females", Male = "Males")) %>%
    dtabs(value ~ age + sex + region + indigenous + time) %>%
    Counts(dimscales = c(time = "Intervals"))

check_total <- read_csv("data/DEATHS_INDIGENOUS_01032019121919871.csv") %>%
    filter(Measure == "Deaths") %>%
    pull(Value) %>%
    sum()

stopifnot(all.equal(sum(deaths), check_total - 75))

saveRDS(deaths,
        file = "out/deaths.rds")
