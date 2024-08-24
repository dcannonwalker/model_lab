library(cmdstanr)
file <- file.path("stan/hpl1a.stan")
mod <- cmdstan_model(file)

hpl1_data <- list(
    G = 100,
    N_g = 8,
    N = 800,
    K = 4,
    y = rpois(800, lambda = 10),
    X_g = cbind(1, rep(c(0, 1), each = 4),
                rep(c(0, 1, 0, 1), each = 2), c(rep(0, 6), rep(1, 2))),
    run_estimation = 0,
    a_sig2 = rep(10, 4),
    b_sig2 = rep(10, 4)
)

sim_out <- mod$sample(data = hpl1_data, iter_warmup = 100,
                      iter_sampling = 1000, parallel_chains = 4)
sim_out$summary(variables = "sig2")

y_sim <- sim_out$draws(variables = "y_sim")
y_sim_single <- c(y_sim[1, 1, ])

hpl1_data$y <- y_sim_single
hpl1_data$run_estimation <- 1

fit <- mod$pathfinder(data = hpl1_data, single_path_draws = 400, num_paths = 100)
fit$summary(variables = "mu")
mu_sim <- sim_out$draws(variables = "mu")
c(mu_sim[1, 1, ])
