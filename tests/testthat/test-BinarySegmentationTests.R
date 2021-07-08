# Title     : Binary Segmentation Tests
# Objective : TODO
# Created by: diego.urgell
# Created on: 24/06/21

library(testthat)
library(BinSeg)

set.seed(1)


test_that(desc="Binary Segmentation + Change in mean: Test 1",{
  data  <-  c(rnorm(10, 100, 10), rnorm(10, 50, 10))
  ans <- BinSeg::binseg(data, "BS", "mean_norm", 1, 1)
  check_ans <- changepoint::cpt.mean(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts[1]
  expect_equal(ans[["cpts"]], check_ans)
})

test_that(desc="Binary Segmentation + Change in mean: Test 2",{
  data  <-  c(rnorm(10, 300, 0), rnorm(10, 200, 0), rnorm(10, 100, 0))
  ans <- BinSeg::binseg(data, "BS", "mean_norm", 2, 1)
  check_ans <- changepoint::cpt.mean(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts[1]
  expect_equal(ans[["cpts"]], check_ans)
})


test_that(desc="Binary Segmentation + Change in mean and variace: Test 1", {
  data  <-  c(rnorm(10, 100, 10), rnorm(10, 50, 10))
  ans <- BinSeg::binseg(data, "BS", "meanvar_norm", 1, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts[1]
  expect_equal(ans[["cpts"]], check_ans)
})


test_that(desc="Binary Segmentation + Change in mean and variace: Test 2", {
  data  <-  c(rnorm(10, 100, 200), rnorm(10, 100, 20))
  ans <- BinSeg::binseg(data, "BS", "meanvar_norm", 1, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts[1]
  expect_equal(ans[["cpts"]], check_ans)
})


test_that(desc="Binary Segmentation + Change in mean and variace: Test 3", {
  data  <-  c(rnorm(10, 100, 100), rnorm(10, 0, 40))
  ans <- BinSeg::binseg(data, "BS", "meanvar_norm", 1, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts[1]
  expect_equal(ans[["cpts"]], check_ans)
})


test_that(desc="Binary Segmentation + Change in mean and variace: Test 4", {
  data  <-  c(1.1, 1, 2, 2, 2)
  ans <- BinSeg::binseg(data, "BS", "meanvar_norm", 1, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts[1]
  expect_equal(ans[["cpts"]], check_ans)
})

test_that(desc="Binary Segmentation + Change in variace: Test 1", {
  data  <-  c(rnorm(10, 100, 100), rnorm(10, 100, 0))
  ans <- BinSeg::binseg(data, "BS", "var_norm", 1, 2)
  check_ans <- changepoint::cpt.var(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts[1]
  expect_equal(ans[["cpts"]], check_ans)
})

test_that(desc="Binary Segmentation + Change in variace: Test 2", {
  data  <-  c(1.1, 1, 1, -5)
  ans <- BinSeg::binseg(data, "BS", "var_norm", 1, 2)
  check_ans <- changepoint::cpt.var(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Normal")@cpts[1]
  expect_equal(ans[["cpts"]], check_ans)
})
