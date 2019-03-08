
library(methods)
library(dembase)
library(dplyr)
library(tidyr)
library(forcats)
library(ggplot2)
library(docopt)

'
Usage:
fig_life_expectancy.R [options]

Options:
--variant [default: Baseline]
' -> doc
opts <- docopt(doc)
variant <- opts$variant

filename_modelled <- sprintf("out/life_expectancy_modelled_%s.rds", variant)
life_exp_modelled <- readRDS(filename_modelled)

life_exp_direct <- readRDS("out/life_expectancy_direct.rds")

data_modelled <- life_exp_modelled %>%
    collapseIterations(prob = c(0.025, 0.5, 0.975)) %>%
    as.data.frame(direction = "long", stringsAsFactors = FALSE) %>%
    mutate(time = as.integer(time)) %>%
    mutate(quantile = fct_recode(quantile, lower = "2.5%", mid = "50%", upper = "97.5%")) %>%
    spread(key = quantile, value = value)

data_direct <- life_exp_direct %>%
    as.data.frame(direction = "long", stringsAsFactors = FALSE) %>%
    mutate(time = as.integer(time))

p <- ggplot(data_modelled, aes(x = time, y = mid, col = indigenous)) +
    facet_grid(rows = vars(sex), cols = vars(region)) +
    geom_point(shape = 1) +
    geom_linerange(aes(ymin = lower, ymax = upper)) +
    geom_point(aes(x = time, y = value, col = indigenous), data_direct, shape = 4) +
    theme(legend.title = element_blank(),
          legend.position = "top",
          axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1),
          text = element_text(size = 8)) +
    xlab("Year") +
    ylab("")

file <- sprintf("out/fig_life_expectancy_%s.pdf", variant)
graphics.off()
pdf(file,
    width = 4.8,
    height = 6)
plot(p)
dev.off()
