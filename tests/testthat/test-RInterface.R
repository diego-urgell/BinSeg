# Title     : TODO
# Objective : TODO
# Created by: diego.urgell
# Created on: 02/08/21

set.seed(300)

test_that(desc="Test the methods from the BinSeg class",{
  data  <-  c(rnorm(10, 0, 10), rnorm(10, 100, 10), rnorm(10, 200, 10),
              rnorm(10, 300, 10))
  ans <- BinSeg::BinSegModel(data, "BS", "mean_norm", 3, 1)
  ans_coef <- coef(ans)
  plot_model <- plot(ans)
  plot_diagnostic <- plotDiagnostic(ans)
  expect_equal(sort(ans@models_summary[["cpts"]]), c(10, 20, 30, 40))
  expect_type(ans@models_summary, "list")
  expect_equal(ans@models_summary[["invalidates_index"]][1], as.numeric(NA))
  expect_equal(ans@models_summary[["invalidates_after"]][1], as.numeric(NA))
  expect_equal(ans@models_summary[["after_mean"]][1], as.numeric(NA))
  expect_equal(algo(ans), "BS")
  expect_equal(dist(ans), "mean_norm")
  expect_equal(class(ans_coef), c("data.table", "data.frame"))
  expect_equal(nrow(ans_coef), 10)
  expect_named(ans_coef, c("segments", "start", "end", "mean"))
  expect_equal(length(logLik(ans)), 4)
  #expect_equal(resid(data), length(data))
  expect_equal(length(plot_model$layers), 2)
  expect_s3_class(plot_model$layers[[1]]$geom, "GeomLine")
  expect_equal(length(plot_diagnostic$layers), 1)
  expect_s3_class(plot_diagnostic$layers[[1]]$geom, "GeomLine")
})

test_that("Test BinSegInfo method", {
  info <- BinSegInfo()
  expect_type(info, "list")
  expect_equal(length(info), 2)
  expect_type(info[[1]], "character")
})

test_that("String vector", {
  vec <- c("a", "b", "c", "d")
  expect_error(BinSeg::BinSegModel(vec, "BS", "norm_mean", 1),
               "Only numeric data allowed")
})

test_that("Test for NA",{
  vec <- c(1, 2, 3 ,NA, 5)
  expect_error(BinSeg::BinSegModel(vec, "BS", "norm_mean", 1),
               "NA is not allowed")
})

test_that("Empty input", {
  vec <- numeric(0L)
  expect_error(BinSeg::BinSegModel(vec, "BS", "norm_mean", 1),
               "At least one datapoint is needed")
})

test_that("Wrong algorithm", {
  vec <- c(1, 2, 3)
  expect_error(BinSeg::BinSegModel(vec, "gfpop", "norm_mean", 1),
               "The selected algorithm is not currently implemented. Use BinSegInfo\\(\\) to check the available algorithms")
})

test_that("Wrong distribution", {
  vec <- c(1, 2, 3)
  expect_error(BinSeg::BinSegModel(vec, "BS", "binomial", 1),
               "The selected distribution is not currently implemented. Use BinSegInfo\\(\\) to check the available distributions")
})

test_that("String ncpts", {
  vec <- c(1, 2, 3)
  expect_error({BinSeg::BinSegModel(vec, "BS", "mean_norm", "a")},
               "The number of changepoints \\(numCpts\\) must be a numeric value.")
})

test_that("Small cpts", {
  vec <- c(1, 2, 3)
  expect_error(BinSeg::BinSegModel(vec, "BS", "mean_norm", 0),
               "Need at least one segment to perform changepoint anaylsis")
})

test_that("Too many segments mean_norm", {
  vec <- c(1, 2, 3, 4, 5)
  expect_error(BinSeg::BinSegModel(vec, "BS", "mean_norm", 6, 1),
               "Too many segments. Given the length of data vector and the distribution, the maximum number of segments is 5")
})

test_that("Too many segments meanvar_norm", {
  vec <- c(1, 2, 3, 4, 5)
  expect_error(BinSeg::BinSegModel(vec, "BS", "meanvar_norm", 6, 1),
               "Too many segments. Given the length of data vector and the distribution, the maximum number of segments is 2")
})

test_that("String segment length", {
  vec <- c(1, 2, 3, 4, 5)
  expect_error(BinSeg::BinSegModel(vec, "BS", "mean_norm", 5, "a"),
              "The minimum segment length must be a numeric value")
})

test_that("Small segment length mean_norm", {
  vec <- c(1, 2, 3, 4, 5)
  expect_error(BinSeg::BinSegModel(vec, "BS", "mean_norm", 5, 0),
               "The minumum segment length must be a least 1.")
})

test_that("Small segment length meanvar_norm", {
  vec <- c(1, 2, 3, 4, 5)
  expect_error(BinSeg::BinSegModel(vec, "BS", "meanvar_norm", 2, 1),
               "For this distribution, the minimum segment length must be at least 2 given the change in variance")
})

test_that("Incompatible segment length and number of changepoints", {
  vec <- c(1,2, 3, 4, 5, 6, 7, 8, 9, 10)
  expect_error(BinSeg::BinSegModel(vec, "BS", "meanvar_norm", 4, 5),
               "Given the minimum segment length and the length of the data, it is no possible to obtain the desired number of segments")
})

# TODO: Write tests for data validation, finish resid and test, test cost funtions with R code, set contributions