# Test if weight matrix satisfy some conditions
# set seed to reproduce, since it sample from runif
set.seed(1)


# This test might not past now, since not using euclidean norm anymore
test_that("Correct output structure", {
  j <- 3
  p <- 12
  out <- create_weight(j=j, p=p, min_val=-j, max_val=j)
  expect_equal(class(out)[1], "matrix")
  row_norms <- apply(out, MARGIN = 1, FUN = function(x) sqrt(sum(x^2)))
  expect_equal(row_norms, rep(1, j))
})
