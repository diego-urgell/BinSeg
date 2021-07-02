# Title     : Binary Segmentation Tests
# Objective : TODO
# Created by: diego.urgell
# Created on: 24/06/21

library(testthat)
library(BinSeg)

set.seed(1)


test_that(desc="Binary Segmentation + Change in mean: Test 1",{
  data  <-  c(rnorm(10, 100, 10), rnorm(10, 50, 10))
  ans <- BinSeg::binseg(data, "BS", "NormMean", 1, 1)
  expect_equal(ans[["cpts"]], 9)
})


test_that(desc="Binary Segmentation + Change in mean and variace: Test 1", {
  data  <-  c(rnorm(10, 100, 10), rnorm(10, 50, 10))
  ans <- BinSeg::binseg(data, "BS", "NormMeanVar", 1, 2)
  expect_equal(ans[["cpts"]], 9)
})


test_that(desc="Binary Segmentation + Change in mean and variace: Test 2", {
  data  <-  c(rnorm(10, 100, 200), rnorm(10, 100, 20))
  ans <- BinSeg::binseg(data, "BS", "NormMeanVar", 1, 2)
  expect_equal(ans[["cpts"]], 9)
})


test_that(desc="Binary Segmentation + Change in mean and variace: Test 3", {
  data  <-  c(rnorm(10, 100, 100), rnorm(10, 0, 40))
  ans <- BinSeg::binseg(data, "BS", "NormMeanVar", 1, 2)
  expect_equal(ans[["cpts"]], 9)
})
