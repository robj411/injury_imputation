library(ithimr)
rm(list=ls())
#cities <- c('accra','sao_paulo','delhi','bangalore', 'santiago', 'belo_horizonte', 'buenos_aires', 'mexico_city','bogota',
#            'vizag')
load('variables.Rdata')
# cities <- c('accra','sao_paulo','buenos_aires')


# cities <- c('accra')

# 

# Problematic injuries dataset for bogota - hence being excluded

min_age <- 15
max_age <- 69

all_inputs <- read.csv('../ITHIM-R/all_city_parameter_inputs.csv',stringsAsFactors = F)

#all_inputs$cape_town <- all_inputs$accra
#all_inputs$vizag <- all_inputs$sao_paulo

parameter_names <- all_inputs$parameter
parameter_starts <- which(parameter_names!='')
parameter_stops <- c(parameter_starts[-1] - 1, nrow(all_inputs))
parameter_names <- parameter_names[parameter_names!='']
parameter_list <- list()
compute_mode <- 'constant'
for(i in 1:length(parameter_names)){
  parameter_list[[parameter_names[i]]] <- list()
  parameter_index <- which(all_inputs$parameter==parameter_names[i])
  if(all_inputs[parameter_index,2]=='')  {
    parameter_list[[parameter_names[i]]] <- lapply(cities,function(x) {
      city_index <- which(colnames(all_inputs)==x)
      val <- all_inputs[parameter_index,city_index]
      ifelse(val%in%c('T','F'),val,as.numeric(val))
    })
    names(parameter_list[[parameter_names[i]]]) <- cities
  }else if(all_inputs[parameter_index,2]=='constant'){
    indices <- 0
    if(compute_mode=='sample') indices <- 1:2
    parameter_list[[parameter_names[i]]] <- lapply(cities,function(x) {
      city_index <- which(colnames(all_inputs)==x)
      val <- all_inputs[parameter_index+indices,city_index]
      ifelse(val=='',0,as.numeric(val))
    })
    names(parameter_list[[parameter_names[i]]]) <- cities
  }else{
    parameter_list[[parameter_names[i]]] <- lapply(cities,function(x) {
      city_index <- which(colnames(all_inputs)==x)
      if(any(all_inputs[parameter_starts[i]:parameter_stops[i],city_index]!='')){
        sublist_indices <- which(all_inputs[parameter_starts[i]:parameter_stops[i],city_index]!='')
        thing <- as.list(as.numeric(c(all_inputs[parameter_starts[i]:parameter_stops[i],city_index])[sublist_indices]))
        names(thing) <- c(all_inputs[parameter_starts[i]:parameter_stops[i],2])[sublist_indices]
        thing
      }
    }
    )
    names(parameter_list[[parameter_names[i]]]) <- cities
  }
}

for(i in 1:length(parameter_list)) assign(names(parameter_list)[i],parameter_list[[i]])



##################################################################

# constant parameters for DAY_TO_WEEK_TRAVEL_SCALAR
day_to_week_scalar <- 7

# constant parameters for MMET_CYCLING
mmet_cycling <- 4.63
# constant parameters for MMET_WALKING
mmet_walking <- 2.53
# constant parameters for SIN_EXPONENT_SUM
sin_exponent_sum <- 1.7
# constant parameters for CASUALTY_EXPONENT_FRACTION
cas_exponent <- 0.5
# add mc fleet to sp

#################################################
## without uncertainty
toplot <- matrix(0,nrow=5,ncol=length(cities)) #5 scenarios, 4 cities
ithim_objects <- list()
city_distances <- list()
city_injuries <- list()
city_weights <- list()
for(city in cities){
  print(city)
  ithim_objects[[city]] <- run_ithim_setup(DIST_CAT = c("0-1 km", "2-5 km", "6+ km"),
                                           ADD_WALK_TO_BUS_TRIPS = F,
                                           CITY = city,
                                           AGE_RANGE = c(min_age,max_age),
                                           ADD_TRUCK_DRIVERS = F,
                                           MAX_MODE_SHARE_SCENARIO = T,
                                           ADD_BUS_DRIVERS = F,
                                           ADD_MOTORCYCLE_FLEET = add_motorcycle_fleet[[city]],
                                           emission_inventory = emission_inventories[[city]],
                                           speeds = speeds[[city]],
                                           
                                           FLEET_TO_MOTORCYCLE_RATIO = fleet_to_motorcycle_ratio[[city]],
                                           MMET_CYCLING = mmet_cycling, 
                                           MMET_WALKING = mmet_walking, 
                                           DAY_TO_WEEK_TRAVEL_SCALAR = day_to_week_scalar,
                                           SIN_EXPONENT_SUM= sin_exponent_sum,
                                           CASUALTY_EXPONENT_FRACTION = cas_exponent,
                                           PA_DOSE_RESPONSE_QUANTILE = F,  
                                           AP_DOSE_RESPONSE_QUANTILE = F,
                                           INJURY_REPORTING_RATE = injury_reporting_rate[[city]],  
                                           CHRONIC_DISEASE_SCALAR = chronic_disease_scalar[[city]],  
                                           PM_CONC_BASE = pm_conc_base[[city]],  
                                           PM_TRANS_SHARE = pm_trans_share[[city]],  
                                           BACKGROUND_PA_SCALAR = background_pa_scalar[[city]],
                                           BUS_WALK_TIME = bus_walk_time[[city]])
  city_distances[[city]] <- ithim_objects[[city]]$true_dist[,1:2]
  
  INJURY_TABLE_TYPES <- names(INJURY_TABLE)
  whw_temp <- list()
  for(type in INJURY_TABLE_TYPES){
    whw_temp[[type]] <- sapply(unique(INJURY_TABLE[[type]]$cas_mode),function(x)
      sapply(unique(INJURY_TABLE[[type]]$strike_mode),function(y){
        subtab <- subset(INJURY_TABLE[[type]],cas_mode==x&strike_mode==y)
        sum(subtab$count,na.rm=T)
        }))
    if(type=='whw'){
      colnames(whw_temp[[type]]) <- unique(INJURY_TABLE[[type]]$cas_mode)
      rownames(whw_temp[[type]]) <- unique(INJURY_TABLE[[type]]$strike_mode)
    }else{
      names(whw_temp[[type]]) <- unique(INJURY_TABLE[[type]]$cas_mode)
    }
  }
  ## assumes the same weight for all types 
  city_weights[[city]] <- mean(INJURY_TABLE[[type]]$weight)
  city_injuries[[city]] <- whw_temp
  print(whw_temp)
}

saveRDS(city_distances,'processed_data/distances/city_distance.Rds')
saveRDS(city_injuries,'processed_data/whw_matrices/city_injuries.Rds')


save('cities','city_weights',file='variables.Rdata')
