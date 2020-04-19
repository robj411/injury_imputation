rm(list=ls())
library(rstan)
library(parallel)
library(tableone)
setwd('~/overflow_dropbox/injury_imputation/')
source('test_script.R')



pred_table <- readRDS('outputs/full_table.Rds')
injury_table <- readRDS('outputs/whw_table.Rds')

## Load model
fileName <- "stan_files/regression.stan"
stan_code <- readChar(fileName, file.info(fileName)$size)
options(mc.cores = parallel::detectCores())


## Run glm
glm1 <- glm(formula = count ~ mode1+mode2+city + offset(0.5*log(dist1)+0.5*log(dist2)+log(years)),
            family  = poisson(link = "log"),
            data    = injury_table)
#summary(glm1)

## Get model matrix
modMat <- as.data.frame(model.matrix(glm1))
modMat$offset <- 0.5*log(injury_table$dist1)+0.5*log(injury_table$dist2)+log(injury_table$years)
names(modMat) <- c("intercept", "ped1",'mc1', "bus1", "bc1",'ar1','truck1','mc2','bc2','ped2','bus2','truck2','nov','sp',
                   'delhi','bangalore','santiago','bh','bogota','vizag','offset')

dat   <- as.list(modMat)
dat$N <- nrow(modMat)
dat$p <- ncol(modMat) - 1

dat$y <- injury_table$count
    
dat$X <- modMat[,-ncol(modMat)]
## Run stan
resStan <- stan(model_code = stan_code, data = dat,
                chains = 3, iter = 4000, warmup = 1000, thin = 10)

## Show traceplot
#traceplot(resStan, pars = c("beta"), inc_warmup = TRUE)

## Frequentist
#tableone::ShowRegTable(glm1, exp = FALSE)

## Bayesian
#print(resStan, pars = c("beta"))
results_list <- summary(resStan, pars = c("beta"), probs=c(0.025,0.975))$summary
cbind(names(modMat)[-ncol(modMat)],results_list)

    

#####################################################


## Run glm
glm1 <- glm(formula = count ~ mode1+mode2+city + offset(0.5*log(dist1)+0.5*log(dist2)+log(years)),
            family  = poisson(link = "log"),
            data    = pred_table)

## Get model matrix
modMat <- as.data.frame(model.matrix(glm1))
modMat$offset <- 0.5*log(pred_table$dist1)+0.5*log(pred_table$dist2)+log(pred_table$years)
names(modMat) <- c("intercept", "ped1",'mc1', "bus1", "bc1",'ar1','truck1','mc2','bc2','ped2','bus2','truck2','nov','sp',
                   'delhi','bangalore','santiago','bh','ba','mc','bogota','vizag','offset')

dat   <- as.list(modMat)
dat$N <- nrow(modMat)
dat$p <- ncol(modMat) - 1
dat$use_flag <- pred_table$city%in%cities[cities_with_whw]
dat$mc_flag <- pred_table$city=='mexico_city'
dat$ba_flag <- pred_table$city=='buenos_aires'
mode_order <- unique(subset(pred_table,city%in%cities[!cities_with_whw]&mode2=='nov')$mode1)
dat$mode_flag <- as.data.frame(sapply(mode_order,function(x) pred_table$mode1==x))
dat$nModes <- length(mode_order)
dat$y <- pred_table$count
dat$mc_y <- sapply(mode_order,function(x)subset(pred_table,city=='buenos_aires'&mode2=='nov'&mode1==x)$count)
dat$ba_y <- sapply(mode_order,function(x)subset(pred_table,city=='mexico_city'&mode2=='nov'&mode1==x)$count)

dat$X <- modMat[,-ncol(modMat)]

## Load model
fileName <- "stan_files/synth.stan"
stan_code <- readChar(fileName, file.info(fileName)$size)
options(mc.cores = parallel::detectCores())

## Run stan
resStan <- stan(model_code = stan_code, data = dat,
                chains = 3, iter = 4000, warmup = 1000, thin = 10)

## Show traceplot
#traceplot(resStan, pars = c("beta"), inc_warmup = TRUE)

## Frequentist
#tableone::ShowRegTable(glm1, exp = FALSE)

## Bayesian
#print(resStan, pars = c("beta"))
results_list <- summary(resStan, pars = c("beta"), probs=c(0.025,0.975))$summary
#cbind(names(modMat)[-ncol(modMat)],results_list)


Xbeta <- summary(resStan, pars = c("Xbeta"), probs=c(0.025,0.975))$summary[,1]+dat$offset

ba_pred <- sapply(1:length(mode_order),function(x)exp(Xbeta[dat$ba_flag&dat$mode_flag[,x]]))
colnames(ba_pred) <- mode_order
rownames(ba_pred) <- pred_table$mode2[dat$ba_flag&dat$mode_flag[,1]]

mc_pred <- sapply(1:length(mode_order),function(x)exp(Xbeta[dat$mc_flag&dat$mode_flag[,x]]))
colnames(mc_pred) <- mode_order
rownames(mc_pred) <- pred_table$mode2[dat$mc_flag&dat$mode_flag[,1]]


####################################################


save(list=ls(),file='outputs/workspace.Rdata')
