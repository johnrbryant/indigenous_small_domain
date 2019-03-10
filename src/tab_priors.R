
library(methods)
library(demest)
library(dplyr)
library(xtable)
library(docopt)

'
Usage:
tab_priors.R [options]

Options:
--variant [default: Baseline]
' -> doc
opts <- docopt(doc)
variant <- opts$variant

filename <- sprintf("out/model_%s.est", variant)

df <- describePriors(filename)
label <- sprintf("tab:priors_%s", variant)
xt <- xtable(df,
             label = label,
             caption = "Priors for main effects and interactions")
file <- sprintf("out/tab_priors_%s.tex", variant)
print(xt,
      file = file,
      caption.placement = "top",
      include.rownames = FALSE)
