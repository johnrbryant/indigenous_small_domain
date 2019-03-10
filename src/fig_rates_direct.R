
library(methods)
library(demest)
library(dplyr)
library(ggplot2)
library(docopt)

'
Usage:
fig_rates_direct.R [options]

Options:
--time [default: 2016]
' -> doc
opts <- docopt(doc)
TIME <- opts$time %>% as.integer()

deaths <- readRDS("out/deaths.rds")
population <- readRDS("out/population.rds")

rate <- (deaths / population) %>%
    as.data.frame(direction = "long", midpoints = "age")

data <- rate %>%
    filter(time == TIME)

p <- ggplot(data, aes(x = age, y = value, color = indigenous)) +
    facet_grid(rows = vars(sex), cols = vars(region)) +
    geom_point(size = 0.7) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    theme(legend.title = element_blank(),
          legend.position = "top",
          text = element_text(size = 8)) +
    xlab("Age") +
    ylab("")

file <- sprintf("out/fig_rates_direct_%s.pdf", TIME)
graphics.off()
pdf(file,
    width = 4.8,
    height = 5)
plot(p)
dev.off()
