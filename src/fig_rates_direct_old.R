
library(methods)
library(dembase)
library(dplyr)
library(ggplot2)
library(docopt)

'
Usage:
fig_rates_direct.R [options]

Options:
--sex [default: Female]
' -> doc
opts <- docopt(doc)
SEX <- opts$sex

times_plot <- c(2010, 2012, 2014, 2016)

deaths <- readRDS("out/deaths.rds")
population <- readRDS("out/population.rds")

rate <- (deaths / population) %>%
    as.data.frame(direction = "long", midpoints = "age")

deaths <- deaths %>%
    as.data.frame(direction = "long", midpoints = "age") %>%
    rename(death_count = count)

rate <- rate %>%
    left_join(deaths, by = c("age", "sex", "region", "indigenous", "time"))

data <- rate %>%
    filter(sex == SEX) %>%
    filter(time %in% times_plot)
    
p <- ggplot(data, aes(x = age, y = value, color = indigenous)) +
    facet_grid(rows = vars(region), cols = vars(time)) +
    geom_point(size = 0.8) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    theme(legend.title = element_blank(),
          legend.position = "top",
          text = element_text(size = 8)) +
    xlab("Age") +
    ylab("")

file <- sprintf("out/fig_rates_direct_%s.pdf", SEX)
graphics.off()
pdf(file,
    width = 4.8,
    height = 6)
plot(p)
dev.off()
