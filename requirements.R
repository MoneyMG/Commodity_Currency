p <- c("plotly","ggplot2","tidyverse", 'tidyquant', 'slider', 'bslib', 'forcats', 'plm', 'broom') 
new.packages <- p[!(p %in% installed.packages()[, "Package"])]
if (length(new.packages)) {
  install.packages(new.packages, dependencies = TRUE)
}