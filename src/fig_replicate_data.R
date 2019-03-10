
library(methods)
library(demest)
library(dplyr)
library(ggplot2)
library(docopt)

'
Usage:
fig_replicate_data.R [options]

Options:
--n_replicate[default: 19]
--sex [default: Female]
--indigenous [default: Indigenous]
--variant [default: Baseline]
' -> doc
opts <- docopt(doc)
n_replicate <- opts$n_replicate %>% as.integer()
SEX <- opts$sex
INDIGENOUS <- opts$indigenous
variant <- opts$variant

conc_states <- readRDS("out/conc_states.rds")

filename_est <- sprintf("out/model_%s.est", variant)
filename_replicate <- sprintf("out/replicate_data_%s.pred", variant)

y_actual <- fetch(filename_est, where = "y") %>%
    collapseDimension(dimension = "time") %>%
    recodeCategories(dimension = "region",
                     concordance = conc_states)

exposure <- fetch(filename_replicate, where = "exposure") %>%
    collapseDimension(dimension = "time")

y_replicate <- fetch(filename_replicate, where = "y", impute = TRUE) %>%
    thinIterations(n = n_replicate) %>%
    collapseDimension(dimension = "time")

rate_actual <- (y_actual / exposure) %>%
    as.data.frame(direction = "long", midpoints = "age") %>%
    mutate(dataset = "Actual")
    
rate_replicate <- (y_replicate / exposure) %>%
    as.data.frame(direction = "long", midpoints = "age") %>%
    mutate(dataset = paste("Replicate", iteration)) %>%
    select(-iteration)

levels_dataset <- c("Actual", paste("Replicate", seq_len(n_replicate)))
rate <- bind_rows(rate_actual, rate_replicate) %>%
    mutate(dataset = factor(dataset, levels = levels_dataset))

data <- rate %>%
    filter(sex == SEX) %>%
    filter(indigenous == INDIGENOUS)

p <- ggplot(data, aes(x = region, y = value, group = age)) +
    facet_wrap(vars(dataset)) +
    geom_point(shape = 1, size = 0.8, color = "dark grey") +
    geom_line(size = 0.3, color = "dark grey") +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    theme(text = element_text(size = 8),
          axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1)) +
    xlab("States and Territories") +
    ylab("")

file <- sprintf("out/fig_replicate_data_%s_%s_%s.pdf", SEX, INDIGENOUS, variant)
graphics.off()
pdf(file,
    width = 4.8,
    height = 5)
plot(p)
dev.off()
