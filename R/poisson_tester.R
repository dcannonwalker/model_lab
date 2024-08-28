library(cmdstanr)
file <- file.path("stan/poisson_tester.stan")
mod <- cmdstan_model(file)

X <- cbind(1, rep(c(0, 1), each = 50))
beta <- c(3, 0.8)
log_lambda <- X %*% beta
y <- rpois(nrow(X), exp(log_lambda))

stan_data <- list(
    X = X,
    N = nrow(X),
    K = ncol(X),
    y = y
)

fit <- mod$sample(stan_data, iter_warmup = 1e5, parallel_chains = 1, chains = 1)
