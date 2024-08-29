library(cmdstanr)
file <- file.path("stan/hpl2.stan")
mod <- cmdstan_model(file)
