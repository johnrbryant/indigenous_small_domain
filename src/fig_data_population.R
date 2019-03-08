
library(methods)
library(dembase)
library(dplyr)

conc_states <- readRDS("out/conc_states.rds")

population <- readRDS("out/population.rds") %>%
    recodeCategories(dimension = "region",
                     concordance = conc_states)

graphics.off()
pdf("out/fig_data_population.pdf",
    width = 4.8,
    height = 4.8)
plot(population)
dev.off()
