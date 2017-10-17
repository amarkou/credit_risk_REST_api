#Use the R package Plumber to create a RESTful API

#install.packages(plumber)
library(plumber)

r <- plumb("ml_credit_model.R")
r$run(port=7000)
