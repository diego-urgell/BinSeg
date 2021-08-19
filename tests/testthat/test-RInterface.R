# Title     : TODO
# Objective : TODO
# Created by: diego.urgell
# Created on: 02/08/21

library(BinSeg)
set.seed(300)

psd <- function(x) {
  sqrt(sum((x - mean(x))^2) / (length(x)))
}

fixed_mean_psd <- function(x, mean){
  sqrt(sum((x - mean)^2) / (length(x)))
}

check_resid <- function(object, ncpts=nrow(object@models_summary)){

  dist <- dist(object)
  obj_coef <- coef(object, ncpts)
  resids <- resid(object)
  data <- object@data

  resid_func <- function(start, end){
    if (dist == "mean_norm"){ # Cost function per segment.
      resid_times_sd <- resids[start:end] * sd(data)
      resid_original_data <- resid_times_sd + mean(data[start:end])
    }
    else if (dist == "var_norm"){
      resid_times_sd <- resids[start:end] * fixed_mean_psd(data[start:end], mean(data))
      resid_original_data <- resid_times_sd + mean(data)
    }
    else if (dist == "meanvar_norm"){
      resid_times_sd <- resids[start:end] * psd(data[start:end])
      resid_original_data <- resid_times_sd + mean(data[start:end])
    }
    else if (dist == "poisson"){
      resid_times_sd <- resids[start:end] * sqrt(mean(data[start:end]))
      resid_original_data <- resid_times_sd + mean(data[start:end])
    }
    return(resid_original_data)
  }

  for(i in 1:ncpts){
    start <-  obj_coef[["start"]][i]
    end <- obj_coef[["end"]][i]
    resids[start:end] <- resid_func(start, end)
  }

  return(resids)
}

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
  expect_equal(length(resid(ans)), length(data))
  expect_equal(length(plot_model$layers), 2)
  expect_s3_class(plot_model$layers[[1]]$geom, "GeomLine")
  expect_equal(length(plot_diagnostic$layers), 1)
  expect_s3_class(plot_diagnostic$layers[[1]]$geom, "GeomLine")
  expect_error(plot(ans, ncpts=1:10),
               "Segments must be a vector of unique integers between 1 and 4")
  expect_error(plot(ans, y_axis=1:10),
               "The provided y_index vector must have the length as the data vector")

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

test_that("Less segments because of zero variance", {
  vec <- c(1, 2, 1, 2, 3, 3, 2)
  expect_warning(BinSeg::BinSegModel(vec, "BS", "meanvar_norm", 3, 2),
    "The amount of changepoints found is smaller than the expected number. It was not possible to further partition the data since the remaining segments all have zero variance.")
})

test_that("Resid for mean norm", {
  vec <- rnorm(200, 200, 100)
  ans <- BinSeg::BinSegModel(vec,  "BS", "mean_norm", 15)
  expect_equal(round(vec,10), (round(check_resid(ans), 10)))
})

test_that("Resid for meanvar norm", {
  vec <- rnorm(200, 200, 100)
  ans <- BinSeg::BinSegModel(vec,  "BS", "meanvar_norm", 15, 2)
  expect_equal(round(vec,10), (round(check_resid(ans), 10)))
})

test_that("Resid for var norm", {
  vec <- rnorm(200, 200, 100)
  ans <- BinSeg::BinSegModel(vec,  "BS", "var_norm", 15, 2)
  expect_equal(round(vec,10), (round(check_resid(ans), 10)))
})

test_that("Resid for poisson", {
  vec <- rpois(500, 50)
  ans <- BinSeg::BinSegModel(vec,  "BS", "poisson", 15, 2)
  expect_equal(round(vec,10), (round(check_resid(ans), 10)))
})

test_that("Resid for exponential", {
  vec <- rexp(500, 50)
  ans <- BinSeg::BinSegModel(vec,  "BS", "exponential", 15, 2)
  expect_error(check_resid(ans), "The resid method is not yet implemented for these distributions")
})

test_that("Resid for negbin", {
  vec <- rnbinom(500, 50, 0.5)
  ans <- BinSeg::BinSegModel(vec,  "BS", "negbin", 15, 2)
  expect_error(check_resid(ans), "The resid method is not yet implemented for these distributions")
})