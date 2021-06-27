# Title     : TODO
# Objective : TODO
# Created by: diego.urgell
# Created on: 23/06/21

data  <-  c(rnorm(10, 100, 10), rnorm(10, 50, 10))
ans <- binseg(data, "BS", "NormMean", 1)

data  <-  c(rnorm(10, 100, 10), rnorm(10, 50, 10), rnorm(10, 0, 10))
ans <- binseg(data, "BS", "NormMean", 10)