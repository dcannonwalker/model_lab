# include kronecker.stan
data {
    int<lower=1> G;
    int<lower=1> N_g;
    int<lower=1> N;
    int<lower=1> K;
    matrix[N_g, K] X_g;
    vector[N] y;
}
transformed data {
    matrix[N, K * G] X;
    X =
}
parameters {
    vector[K * G] beta;
    vector[K] mu;
    vector<lower=0>[K] sig2;
}
model {

}
