
library(methods)
library(demest)
library(dplyr)
library(docopt)

'
Usage:
replicate_data.R [options]

Options:
--variant [default: baseline]
--seed [default: 0]
' -> doc
opts <- docopt(doc)
variant <- opts$variant
seed <- opts$seed %>% as.numeric()

set.seed(seed)

filename_est <- sprintf("out/model_%s.est", variant)
filename_replicate <- sprintf("out/replicate_data_%s.pred", variant)

exposure_actual <- fetch(filename_est,
                         where = "exposure")

labels_region_actual <- dimnames(exposure_actual)$region
labels_region_replicate <- paste(labels_region_actual, "replicate", sep = "_")

exposure_replicate <- exposure_actual %>%
    recodeCategories(dimension = "region",
                     old = labels_region_actual,
                     new = labels_region_replicate)
    
predictModel(filenameEst = filename_est,
             filenamePred = filename_replicate,
             along = "region",
             labels = labels_region_replicate,
             exposure = exposure_replicate)
