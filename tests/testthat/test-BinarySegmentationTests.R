# Title     : Binary Segmentation Tests
# Objective : TODO
# Created by: diego.urgell
# Created on: 24/06/21

if(requireNamespace("changepoint"))
library(testthat)
library(BinSeg)

set.seed(100)

test_that(desc="Binary Segmentation + Change in mean: Test 1 - Single changepoint",{
  data  <-  c(rnorm(10, 100, 10), rnorm(10, 50, 10))
  ans <- BinSeg::binseg(data, "BS", "mean_norm", 1, 1)
  check_ans <- binsegRcpp::binseg_normal(data, 2)[["end"]]
  expect_equal(sort(ans[,"cpts"]), sort(check_ans))
})

test_that(desc="Binary Segmentation + Change in mean: Test 2 - Two changepoints ",{
  data  <-  c(rnorm(10, 100, 10), rnorm(10, 200, 10), rnorm(10, 300, 10))
  ans <- BinSeg::binseg(data, "BS", "mean_norm", 2, 1)
  check_ans <- changepoint::cpt.mean(data=data, penalty="None", method="BinSeg", Q=2, test.stat="Normal")@cpts
  expect_equal(sort(ans[, "cpts"]), check_ans)
})

test_that(desc="Binary Segmentation + Change in mean: Test 3 - No change with large vector",{
  data  <-  rnorm(10000, 100, 10)
  ans <- BinSeg::binseg(data, "BS", "mean_norm", 500, 1)
  check_ans <- changepoint::cpt.mean(data=data, penalty="None", method="BinSeg", Q=500, test.stat="Normal")@cpts
  expect_equal(sort(ans[, "cpts"]), check_ans)
})


test_that(desc="Binary Segmentation + Change in mean and variace: Test 1 - Single changepoint in mean", {
  data  <-  c(rnorm(10, 100, 10), rnorm(10, 50, 10))
  ans <- BinSeg::binseg(data, "BS", "meanvar_norm", 1, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="Binary Segmentation + Change in mean and variace: Test 2 - Single changepoint in var", {
  data  <-  c(rnorm(10, 100, 200), rnorm(10, 100, 20))
  ans <- BinSeg::binseg(data, "BS", "meanvar_norm", 1, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="Binary Segmentation + Change in mean and variace: Test 3 - Two changepoints in mean and var", {
  data  <-  c(rnorm(10, 100, 100), rnorm(10, 0, 40), rnorm(10, -100, 60))
  ans <- BinSeg::binseg(data, "BS", "meanvar_norm", 2, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=2, test.stat="Normal")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="Binary Segmentation + Change in mean and variace: Test 4 - No possible segmentation", {
  data  <-  c(1.1, 1, 2, 2, 2)
  ans <- BinSeg::binseg(data, "BS", "meanvar_norm", 1, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="Binary Segmentation + Change in mean and variace: Test 5 - Big vector with no changepoint", {
  data  <-  rnorm(10000, 500, 100)
  ans <- BinSeg::binseg(data, "BS", "meanvar_norm", 500, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=500, test.stat="Normal")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="Binary Segmentation + Change in variace: Test 1 - Single Changepoint", {
  data  <-  c(rnorm(10, 100, 100), rnorm(10, 100, 0))
  ans <- BinSeg::binseg(data, "BS", "var_norm", 1, 2)
  check_ans <- changepoint::cpt.var(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="Binary Segmentation + Change in variace: Test 2 - Variance constraint", {
  data  <-  c(1.1, 1, 1, -5)
  ans <- BinSeg::binseg(data, "BS", "var_norm", 1, 2)
  check_ans <- changepoint::cpt.var(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="Binary Segmentation + Change in variace: Test 3 - Two changepoints in var", {
  data  <-  c(rnorm(10, 100, 100), rnorm(10, 100, 40), rnorm(10, 100, 60))
  ans <- BinSeg::binseg(data, "BS", "var_norm", 2, 2)
  check_ans <- changepoint::cpt.var(data=data, penalty="None", method="BinSeg", Q=2, test.stat="Normal")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})


test_that(desc="Binary Segmentation + Change in mean and variace: Test 4 - Big vector with no changepoint", {
  data  <-  rnorm(100000, 500, 100)
  ans <- BinSeg::binseg(data, "BS", "var_norm", 500, 2)
  check_ans <- changepoint::cpt.var(data=data, penalty="None", method="BinSeg", Q=500, test.stat="Normal")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})
