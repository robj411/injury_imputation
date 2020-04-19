// Poisson model example


data {
  // Define variables in data
  // Number of observations (an integer)
  int<lower=0> N;
  // Number of beta parameters
  int<lower=0> p;
  
  // Covariates
  matrix[N,p]  X;
  //vector[N]    y;
  //real intercept[N];
  //real cycle[N];
  //real motor[N];
  
  // offset
  real offset[N];
  
  // Count outcome
  int<lower=0> y[N];
}

parameters {
  // Define parameters to estimate
  //real beta[p];
  vector[p] beta;
  //real<lower=0> sigma;
}

transformed parameters  {
  //
  real lp[N];
  real <lower=0> mu[N];
  vector[N] Xbeta;
  Xbeta = X * beta;
  for (i in 1:N) {
    // Linear predictor
    lp[i] = Xbeta[i] + offset[i];
    
    // Mean
    mu[i] = exp(lp[i]);
  }
}

model {
  // Prior part of Bayesian inference
  // Flat prior for mu (no need to specify if non-informative)
  
  
  // Likelihood part of Bayesian inference
  y ~ poisson(mu);
}