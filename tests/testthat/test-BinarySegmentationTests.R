# Title     : Binary Segmentation Tests
# Objective : TODO
# Created by: diego.urgell
# Created on: 24/06/21

library(testthat)
library(BinSeg)

set.seed(28938379)

test_that(desc="Small test for Binary Segmentation + Change in mean",{
  data  <-  c(rnorm(10, 100, 10), rnorm(10, 50, 10))
  ans <- BinSeg::binseg(data, "BS", "NormMean", 1)
  expect_equal(ans[["cpts"]], 9)
})
