# Test if correctly creating correlation matrix
exp_out <- matrix(
  c(1, 0.5, 0.5,
    0.5, 1, 0.5,
    0.5, 0.5, 1),
  nrow = 3, ncol = 3, byrow = TRUE
)


test_that("Correct output structure", {
  out <- create_sigma(rho=0.5, j=3)
  expect_equal(class(out)[1], "matrix")
  expect_equal(out, exp_out)
})

test_that("Correct input types and values", {
  expect_error(create_sigma(rho = 1, j=1))
  expect_error(create_sigma(rho = 2, j=2))
  expect_error(create_sigma(rho="a", j="a"))
  expect_error(create_sigma(rho=list(1), j=list(1)))
})
