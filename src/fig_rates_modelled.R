
library(methods)
library(demest)
library(dplyr)
library(tidyr)
library(forcats)
library(ggplot2)
library(docopt)

'
Usage:
fig_rates_modelled.R [options]

Options:
--time [default: 2016]
--variant [default: Baseline]
' -> doc
opts <- docopt(doc)
TIME <- opts$time %>% as.integer()
variant <- opts$variant

filename <- sprintf("out/model_%s.est", variant)

rate <- fetch(filename,
              where = c("model", "likelihood", "rate")) %>%
    collapseIterations(prob = c(0.025, 0.5, 0.975)) %>%
    as.data.frame(direction = "long", midpoints = "age") %>%
    mutate(quantile = fct_recode(quantile,
                                 lower = "2.5%",
                                 mid = "50%",
                                 upper = "97.5%")) %>%
    spread(key = quantile, value = value)

data <- rate %>%
    filter(time == TIME)

p <- ggplot(data, aes(x = age, y = mid, color = indigenous)) +
    facet_grid(rows = vars(sex), cols = vars(region)) +
    geom_point(size = 0.7) +
    geom_linerange(aes(ymin = lower, ymax = upper)) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    theme(legend.title = element_blank(),
          legend.position = "top",
          text = element_text(size = 8)) +
    xlab("Age") +
    ylab("")

file <- sprintf("out/fig_rates_modelled_%s_%s.pdf", TIME, variant)
graphics.off()
pdf(file,
    width = 4.8,
    height = 5)
plot(p)
dev.off()
