# Title     : TODO
# Objective : TODO
# Created by: diego.urgell
# Created on: 23/06/21

data  <-  c(rnorm(100, 50, 10), rnorm(100, 10, 10))
ans <- binseg(data, "BS", "NormMean", 1)

# TODO: DEBUG