
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
--variant [default: baseline]
--seed [default: 0]
' -> doc
opts <- docopt(doc)
n_replicate <- opts$n_replicate %>% as.integer()
SEX <- opts$sex
INDIGENOUS <- opts$indigenous
variant <- opts$variant
seed <- opts$seed %>% as.numeric()

set.seed(seed)

filename_est <- sprintf("out/model_%s.est", variant)
filename_replicate <- sprintf("out/replicate_data_%s.pred", variant)

y_actual <- fetch(filename_est,
                  where = "y") %>%
    collapseDimension(dimension = "time")

exposure_actual <- fetch(filename_est,
                         where = "exposure") %>%
    collapseDimension(dimension = "time")

y_replicate <- fetch(filename_replicate,
                     where = "y",
                     impute = TRUE) %>%
    thinIterations(n = n_replicate) %>%
    collapseDimension(dimension = "time")

labels_region_replicate <- dimnames(y_replicate)$region
labels_region_actual <- dimnames(exposure_actual)$region

y_replicate <- y_replicate %>%
    recodeCategories(dimension = "region",
                     old = labels_region_replicate,
                     new = labels_region_actual)

rate_actual <- (y_actual / exposure_actual) %>%
    as.data.frame(direction = "long", midpoints = "age") %>%
    mutate(variant = "Actual")
    
rate_replicate <- (y_replicate / exposure_actual) %>%
    as.data.frame(direction = "long", midpoints = "age") %>%
    mutate(variant = paste("Replicate", iteration)) %>%
    select(-iteration)

levels_variant <- c("Actual", paste("Replicate", seq_len(n_replicate)))
rate <- bind_rows(rate_actual, rate_replicate) %>%
    mutate(variant = factor(variant, levels = levels_variant))

data <- rate %>%
    filter(sex == SEX) %>%
    filter(indigenous == INDIGENOUS)

p <- ggplot(data, aes(x = region, y = value, group = age)) +
    facet_wrap(vars(variant)) +
    geom_point(shape = 1) +
    geom_line(size = 0.3) +
    scale_y_log10(labels = function(x) format(x, scientific = FALSE)) +
    theme(text = element_text(size = 8)) +
    xlab("State or Territory") +
    ylab("")


file <- sprintf("out/fig_replicate_data_%s_%s.pdf", SEX, INDIGENOUS)
graphics.off()
pdf(file,
    width = 4.8,
    height = 6)
plot(p)
dev.off()
