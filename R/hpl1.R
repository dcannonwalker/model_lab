library(cmdstanr)
file <- file.path("stan/hpl1.stan")
mod <- cmdstan_model(file)

hpl1_data <- list(
    G = 10,
    N_g = 8,
    K = 4,
    y = rpois(80, lambda = 10),
    X_g = cbind(1, rep(c(0, 1), each = 4),
                rep(c(0, 1, 0, 1), each = 2), c(rep(0, 6), rep(1, 2))),
    run_estimation = 0,
    a_sig2 = rep(10, 4),
    b_sig2 = rep(10, 4)
)

sim_out <- mod$sample(data = hpl1_data, iter_warmup = 100,
                      iter_sampling = 1000)
sim_out$summary(variables = "sig2")

sim_out$draws()

hist(1 / rgamma(1000, 20, 20))
