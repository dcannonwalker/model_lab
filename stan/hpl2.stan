#include kronecker.stan
data {
    int<lower=1> G;
    int<lower=1> N_g;
    int<lower=1> N;
    matrix[N_g, K] X_g;
    array[N] int<lower=0> y;
}
transformed data {
    matrix[G, G] I_G = diag_matrix(rep_vector(1, G));
    matrix[N_g, K] X_g_star;
    matrix[N, K * G] X;
    matrix[N, K * G] X_star;
    X_g_star[, K] = rep_vector(0, N_g);
    X = kronecker(I_G, X_g);
    X_star = kronecker(I_G, X_g_star);
}
parameters {
    array[G, K] beta;
}
transformed parameters {
    p1 = bernoulli_lpmf(1 | p);
    p0 = bernoulli_lpmf(0 | p);
    ll = rep_vector(p1, N) + poisson_log_lpmf(y | X * beta);
    ll_star = rep_vector(p0, N) + poisson_log_lpmf(y | X_star * beta);
}
