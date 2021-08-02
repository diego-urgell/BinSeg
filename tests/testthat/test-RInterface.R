# Title     : TODO
# Objective : TODO
# Created by: diego.urgell
# Created on: 02/08/21

set.seed(300)

test_that(desc="Test coef method against binsegRcpp",{
  data  <-  c(rnorm(10, 0, 10), rnorm(10, 100, 10), rnorm(10, 200, 10),
              rnorm(10, 300, 10))
  ans <- BinSeg::BinSeg(data, "BS", "mean_norm", 3, 1)
  check_ans <- binsegRcpp::binseg_normal(data, 4)
  ans_coef <- coef(ans)
  check_ans_coef <-coef(check_ans)
  expect_equal(sort(ans@models_summary[["cpts"]]), sort(check_ans[["end"]]))
  expect_equal(ans_coef, check_ans_coef)
})