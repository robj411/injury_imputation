// Poisson model example


data {
  // Define variables in data
  // Number of observations (an integer)
  int<lower=0> N;
  // Number of beta parameters
  int<lower=0> p;
  // Number of modes
  int<lower=0> nModes;
  matrix[N,nModes]  mode_flag;
  
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
  int<lower=0> mc_y[nModes];
  int<lower=0> ba_y[nModes];
  int<lower=0> use_flag[N];
  int<lower=0> ba_flag[N];
  int<lower=0> mc_flag[N];
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
  vector[N] Xbeta;
  real <lower=0> mu[N];
  real <lower=0> ba_mu[nModes];
  real <lower=0> mc_mu[nModes];
  for(j in 1:nModes){
    ba_mu[j] = 0;
    mc_mu[j] = 0;
  }
  Xbeta = X * beta;
  for (i in 1:N) {
    // Linear predictor
    lp[i] = Xbeta[i] + offset[i];
    
    // Mean
    mu[i] = exp(lp[i]);
    
    if(ba_flag[i]){
      for(j in 1:nModes){
        if(mode_flag[i,j]){
          ba_mu[j] = ba_mu[j] + mu[i];
        }
      }
    }
    if(mc_flag[i]){
      for(j in 1:nModes){
        if(mode_flag[i,j]){
          mc_mu[j] = mc_mu[j] + mu[i];
        }
      }
    }
  }
}

model {
  // Prior part of Bayesian inference
  // Flat prior for mu (no need to specify if non-informative)
  
  
  // Likelihood part of Bayesian inference
  for (i in 1:N) {
    if(use_flag[i]){
      y[i] ~ poisson(mu[i]);
    }
  }
  for (i in 1:nModes) {
    mc_y[i] ~ poisson(mc_mu[i]);
    ba_y[i] ~ poisson(ba_mu[i]);
  }
}