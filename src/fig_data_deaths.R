
library(methods)
library(dembase)
library(dplyr)

conc_states <- readRDS("out/conc_states.rds")

deaths <- readRDS("out/deaths.rds") %>%
    recodeCategories(dimension = "region",
                     concordance = conc_states)

graphics.off()
pdf("out/fig_data_deaths.pdf",
    width = 4.8,
    height = 4.8)
plot(deaths)
dev.off()
