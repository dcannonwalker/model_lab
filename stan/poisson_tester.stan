data {
    int<lower=1> N;
    int<lower=1> K;
    matrix[N, K] X;
    array[N] int<lower=0> y;
}
parameters {
    vector[K] beta;
}
transformed parameters {
    vector[N] lp;
    vector[N] log_lambda;
    log_lambda = X * beta;
    // for (i in 1:N) {
    //     // real log_lambda = X[i, ] * beta;
    //     lp[i] = poisson_log_lpmf(y[i] | log_lambda);
    // }
}
model {
    beta ~ normal(0, 1);
    y ~ poisson_log(log_lambda);
    // target += sum(lp);
    // for (i in 1:N) {
    //     target += lp[i];
    // }
}
