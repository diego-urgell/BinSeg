# Title     : Binary Segmentation Tests
# Objective : TODO
# Created by: diego.urgell
# Created on: 24/06/21

if(requireNamespace("changepoint", "gfpop"))
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


test_that(desc="Binary Segmentation + Negbin change in probability of success: Test 1 - Single changepoint", {
  data <- gfpop::dataGenerator(n=400, changepoints=c(0.50,  1), parameters=c(0.2, 0.65), type="negbin", size=50)
  graph <- gfpop::graph(
    gfpop::Edge(0, 1,"std", 0),
    gfpop::Edge(0, 0, "null"),
    gfpop::Edge(1, 1, "null"),
    gfpop::StartEnd(start = 0, end = 1)
  )
  ans <- BinSeg::binseg(data, "BS", "negbin", 1, 2)
  check_ans <- gfpop::gfpop(data = data, mygraph = graph, type = "negbin")$changepoints
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="Binary Segmentation + Negbin change in probability of success: Test 2 - Several changepoints", {
  data <- gfpop::dataGenerator(n=400, changepoints=c(0.25, 0.5, 0.75, 1),
                               parameters=c(0.2, 0.4, 0.65, 0.9), type="negbin", size=50)
  graph <- gfpop::graph(
    gfpop::Edge(0, 1,"std", 0),
    gfpop::Edge(1, 2, "std", 0),
    gfpop::Edge(2, 3, "std", 0),
    gfpop::Edge(0, 0, "null"),
    gfpop::Edge(1, 1, "null"),
    gfpop::Edge(2, 2, "null"),
    gfpop::Edge(3, 3, "null"),
    gfpop::StartEnd(start = 0, end = 3)
  )
  ans <- BinSeg::binseg(data, "BS", "negbin", 3, 2)
  check_ans <- gfpop::gfpop(data = data, mygraph = graph, type = "negbin")$changepoints
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="BinarySegmentation + Poisson change in rate: Test 1 - Single changepoint", {
  data <- gfpop::dataGenerator(n=500, changepoints=c(0.5, 1), parameters=c(10, 50), type="poisson")
  ans <- BinSeg::binseg(data, "BS", "poisson", 1, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Poisson")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="BinarySegmentation + Poisson change in rate: Test 2- Several changepoints", {
  data <- gfpop::dataGenerator(n=1000, changepoints=c(0.1, 0.23, 0.38, 0.5, 0.66, 0.82, 1),
                               parameters=c(10, 5, 15, 10, 50, 25, 35), type="poisson")
  ans <- BinSeg::binseg(data, "BS", "poisson", 6, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=6, test.stat="Poisson")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="BinarySegmentation + Poisson change in rate: Test 3 - Several changepoints - fewer in input", {
  data <- gfpop::dataGenerator(n=1000, changepoints=c(0.1, 0.23, 0.38, 0.5, 0.66, 0.82, 1),
                               parameters=c(10, 5, 15, 10, 50, 25, 35), type="poisson")
  ans <- BinSeg::binseg(data, "BS", "poisson", 3, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=3, test.stat="Poisson")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="BinarySegmentation + Poisson change in rate: Test 4 - No changepoint", {
  data <- gfpop::dataGenerator(n=10000, changepoints=1, parameters=50, type="poisson")
  ans <- BinSeg::binseg(data, "BS", "poisson", 1000, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=1000, test.stat="Poisson")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="BinarySegmetation + Exponential change in rate: Test 1 - Single changepoint", {
  data <- gfpop::dataGenerator(n = 400, changepoints = c(0.5, 1), parameters=c(10, 40), type="exp")
  ans <- BinSeg::binseg(data, "BS", "exponential", 1, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=1, test.stat="Exponential")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="BinarySegmentation + Exponential change in rate: Test 2- Several changepoints", {
  data <- gfpop::dataGenerator(n=1000, changepoints=c(0.1, 0.23, 0.38, 0.5, 0.66, 0.82, 1),
                               parameters=c(10, 5, 15, 10, 50, 25, 35), type="exp")
  ans <- BinSeg::binseg(data, "BS", "exponential", 6, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=6, test.stat="Exponential")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})

test_that(desc="BinarySegmentation + Exponential change in rate: Test 4 - No changepoint", {
  data <- gfpop::dataGenerator(n=10000, changepoints=1, parameters=50, type="exp")
  ans <- BinSeg::binseg(data, "BS", "exponential", 1000, 2)
  check_ans <- changepoint::cpt.meanvar(data=data, penalty="None", method="BinSeg", Q=1000, test.stat="Exponential")@cpts
  expect_equal(sort(ans[,"cpts"]), check_ans)
})