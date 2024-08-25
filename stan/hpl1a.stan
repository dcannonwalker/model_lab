functions {
    #include kronecker.stan
}
data {
    int<lower=1> G;
    int<lower=1> N_g;
    int<lower=1> N;
    int<lower=1> K;
    matrix[N_g, K] X_g;
    array[N] int<lower=0> y;
    int<lower=0, upper=1> run_estimation;
    array[K] real<lower=0> a_sig2;
    array[K] real<lower=0> b_sig2;
    real<lower=0> a_mu_offset; // location
    real<lower=0> b_mu_offset; // scale
    real<lower=0> a_sig2_offset; // shape
    real<lower=0> b_sig2_offset; // scale
}
transformed data {
    matrix[G, G] I_g = diag_matrix(rep_vector(1, G));
    matrix[N, K * G] X;
    matrix[N, G] X_offset;
    X = kronecker(I_g, X_g);
    X_offset = kronecker(I_g, rep_matrix(1, N_g, 1));
}
parameters {
    vector[G] log_offset; // log scale offset or intercept
    vector[K * G] beta;
    vector[K] mu;
    vector<lower=0>[K] sig2;
    real mu_offset;
    real<lower=0> sig2_offset;
}
transformed parameters {
    vector[N] log_lambda;
    vector[K * G] mu_long;
    vector[K * G] sig2_long;
    log_lambda = X_offset * log_offset + X * beta;
    for (g in 1:G) {
        mu_long[(K * (g - 1) + 1):(K * g)] = mu;
        sig2_long[(K * (g - 1) + 1):(K * g)] = sig2;
    }
}
model {
    beta ~ normal(mu_long, sig2_long);
    mu ~ normal(0, 1);
    sig2 ~ inv_gamma(a_sig2, b_sig2);
    log_offset ~ normal(mu_offset, sig2_offset);
    mu_offset ~ normal(a_mu_offset, b_mu_offset);
    sig2_offset ~ inv_gamma(a_sig2_offset, b_sig2_offset);
    if (run_estimation == 1) {
        y ~ poisson_log(log_lambda);
    }
}
generated quantities {
    array[N] int y_sim;
    y_sim = poisson_log_rng(log_lambda);
}
