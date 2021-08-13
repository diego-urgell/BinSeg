# Title     : TODO
# Objective : TODO
# Created by: diego.urgell
# Created on: 02/08/21

set.seed(300)

test_that(desc="Test coef method against binsegRcpp",{
  data  <-  c(rnorm(10, 0, 10), rnorm(10, 100, 10), rnorm(10, 200, 10),
              rnorm(10, 300, 10))
  ans <- BinSeg::BinSegModel(data, "BS", "mean_norm", 3, 1)
  expect_equal(sort(ans@models_summary[["cpts"]]), c(10, 20, 30, 40))
  expect_type(ans@models_summary, "list")
  expect_equal(ans@models_summary[["invalidates_index"]][1], as.numeric(NA))
  expect_equal(ans@models_summary[["invalidates_after"]][1], as.numeric(NA))
  expect_equal(ans@models_summary[["after_mean"]][1], as.numeric(NA))
})