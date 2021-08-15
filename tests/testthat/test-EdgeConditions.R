# Title     : TODO
# Objective : TODO
# Created by: diego.urgell
# Created on: 02/08/21

test_that("Change in mean + Single data point -> Zero cost and trivial mean", {
  ans <- BinSeg::BinSegModel(100, "BS", "mean_norm", 1)
  expect_equal(logLik(ans), 0)
  expect_equal(ans@models_summary[["before_mean"]], 100)
})

test_that("Change in mean and variance + Two data points -> Trivial params", {
  ans <- BinSeg::BinSegModel(c(100, 50), "BS", "meanvar_norm", 1, 2)
  expect_equal(ans@models_summary[["before_mean"]], 75)
  expect_equal(ans@models_summary[["before_var"]], 625)
})

test_that(desc="Binary Segmentation + Change in mean and variace: Test 4 - No possible segmentation", {
  data  <-  c(1.1, 1, 2, 2, 2)
  ans <- BinSeg::BinSegModel(data, "BS", "meanvar_norm", 1, 2)
  expect_equal(sort(cpts(ans)), 5)
})

test_that(desc="Binary Segmentation + Change in variace: Test 2 - Variance constraint", {
  data  <-  c(1.1, 1, 1, -5)
  ans <- BinSeg::BinSegModel(data, "BS", "var_norm", 1, 2)
  expect_equal(sort(cpts(ans)), 4)
})

