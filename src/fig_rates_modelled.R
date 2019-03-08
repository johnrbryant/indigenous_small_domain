
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
--sex [default: Female]
--indigenous [default: Indigenous]
--variant [default: Baseline]
' -> doc
opts <- docopt(doc)
SEX <- opts$sex
INDIGENOUS <- opts$indigenous
variant <- opts$variant

deaths <- readRDS("out/deaths.rds")
population <- readRDS("out/population.rds")

filename <- sprintf("out/model_%s.est", variant)

rate_direct <- (deaths / population) %>%
    as.data.frame(direction = "long", midpoints = "age") %>%
    mutate(type = "Direct") %>%
    mutate(lower = value,
           upper = value)

rate_modelled <- fetch(filename,
                       where = c("model", "likelihood", "rate")) %>%
    collapseIterations(prob = c(0.025, 0.5, 0.975)) %>%
    as.data.frame(direction = "long", midpoints = "age") %>%
    mutate(type = "Modelled") %>%
    mutate(quantile = fct_recode(quantile,
                                 lower = "2.5%",
                                 value = "50%",
                                 upper = "97.5%")) %>%
    spread(key = quantile, value = value)


rate <- bind_rows(rate_direct, rate_modelled) %>%
    filter(sex == SEX) %>%
    filter(indigenous == INDIGENOUS) %>%
    filter(time %in% c(2010, 2012, 2014, 2016))
    

p <- rate %>%
    ggplot(aes(x = age)) +
    facet_grid(rows = vars(region),
               cols = vars(time)) +
    geom_point(aes(y = value),
               color = "dark orange",
               size = 0.7,
               data = filter(rate, type == "Direct")) +
    scale_shape_manual(values = 4) +
    geom_linerange(aes(ymin = lower, ymax = upper),
                   data = filter(rate, type == "Modelled"),
                   color = "dark blue") +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    theme(legend.title = element_blank(),
          legend.position = "top",
          text = element_text(size = 8)) +
    xlab("Age") +
    ylab("")

file <- sprintf("out/fig_rates_modelled_%s_%s_%s.pdf", SEX, INDIGENOUS, variant)
graphics.off()
pdf(file,
    width = 4.8,
    height = 6)
plot(p)
dev.off()
