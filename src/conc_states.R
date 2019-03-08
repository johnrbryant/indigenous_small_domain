
library(methods)
library(dembase)
library(dplyr)

conc_states <- data.frame(long = c("New South Wales",
                                   "Queensland",
                                   "South Australia",
                                   "Tasmania",
                                   "Victoria",
                                   "Western Australia",
                                   "Australian Capital Territory",
                                   "Northern Territory"),
                          short = c("NSW",
                                    "QLD",
                                    "SA",
                                    "TAS",
                                    "VIC",
                                    "WA",
                                    "ACT",
                                    "NT")) %>%
    Concordance()

saveRDS(conc_states,
        file = "out/conc_states.rds")
