load('outputs/variables.Rdata')
city_distances <- readRDS('processed_data/distances/city_distance.Rds')
city_injuries <- readRDS('processed_data/whw_matrices/city_injuries.Rds')

## separate into those cities with whw and those without
cities_with_whw <- sapply(cities,function(x)'whw'%in%names(city_injuries[[x]]))

## start with cities with whw
## keep only injuries that have both distances

injury_table <- data.frame(mode1=character(),mode2=character(),dist1=numeric(),dist2=numeric(),city=character(),count=numeric(),years=numeric(),stringsAsFactors = F)
for(city in cities[cities_with_whw]){
  city_dist <- city_distances[[city]]
  city_dist <- city_dist[city_dist[,2]>0,]
  walk_to_pt_index <- which(city_dist[,1]=='walk_to_pt')
  walk_index <- which(city_dist[,1]=='walking')
  city_dist[walk_index,2] <- city_dist[walk_index,2] + city_dist[walk_to_pt_index,2]
  city_dist[walk_index,1] <- 'pedestrian'
  mode_names <- unlist(city_dist[,1])
  mode_dists <- unlist(city_dist[,2])
  city_inj <- city_injuries[[city]]$whw
  city_inj <- city_inj[rownames(city_inj)%in%mode_names,colnames(city_inj)%in%mode_names]
  
  for(mode1 in 1:ncol(city_inj)){
    mode1_name <- colnames(city_inj)[mode1]
    dist1 <- mode_dists[which(mode_names==mode1_name)]
    for(mode2 in 1:nrow(city_inj)){
      mode2_name <- rownames(city_inj)[mode2]
      dist2 <- mode_dists[which(mode_names==mode2_name)]
      count <- city_inj[mode2,mode1]
      injury_table[nrow(injury_table)+1,] <- c(mode1_name,mode2_name,dist1,dist2,city,count,city_weights[[city]])
    }
    if(!'pedestrian'%in%rownames(city_inj)){
      dist2 <- mode_dists[which(mode_names=='pedestrian')]
      injury_table[nrow(injury_table)+1,] <- c(mode1_name,'pedestrian',dist1,dist2,city,0,city_weights[[city]])
    }
    if(!'bicycle'%in%rownames(city_inj)){
      dist2 <- mode_dists[which(mode_names=='bicycle')]
      injury_table[nrow(injury_table)+1,] <- c(mode1_name,'bicycle',dist1,dist2,city,0,city_weights[[city]])
    }
  }
}

injury_table$dist1 <- as.numeric(injury_table$dist1)
injury_table$dist2 <- as.numeric(injury_table$dist2)
injury_table$count <- as.numeric(injury_table$count)
injury_table$years <- as.numeric(injury_table$years)



cas_modes <- unique(injury_table$mode1)
col_modes <- unique(injury_table$mode2)
pred_table <- expand.grid(city=cities,mode1=cas_modes,mode2=c(as.character(col_modes),'nov'))
pred_table$dist1 <- 0
pred_table$dist2 <- 0
pred_table$years <- 1
pred_table$count <- 0
for(city in cities){
  city_dist <- city_distances[[city]]
  city_dist <- city_dist[city_dist[,2]>0,]
  walk_to_pt_index <- which(city_dist[,1]=='walk_to_pt')
  walk_index <- which(city_dist[,1]=='walking')
  city_dist[walk_index,2] <- city_dist[walk_index,2] + city_dist[walk_to_pt_index,2]
  city_dist[walk_index,1] <- 'pedestrian'
  mode_names <- unlist(city_dist[,1])
  mode_dists <- unlist(city_dist[,2])
  match_cas_mode <- match(cas_modes,mode_names)
  city_cas_modes <- mode_names[match_cas_mode[!is.na(match_cas_mode)]]
  cas_mode_dists <- unlist(city_dist[match_cas_mode,2])
  match_col_mode <- match(col_modes,mode_names)
  city_col_modes <- mode_names[match_col_mode[!is.na(match_col_mode)]]
  col_mode_dists <- unlist(city_dist[match_col_mode,2])
  pred_table$years[pred_table$city==city] <- city_weights[[city]]
  
  for(mode1 in 1:length(mode_names)){
    mode_name <- mode_names[mode1]
    mode_dist <- mode_dists[mode1]
    pred_table$dist1[pred_table$city==city&pred_table$mode1==mode_name] <- mode_dist
    pred_table$dist2[pred_table$city==city&pred_table$mode2==mode_name] <- mode_dist
  }
  
  if('nov'%in%names(city_injuries[[city]])){
    city_inj <- city_injuries[[city]]$nov
    for(mode1 in 1:length(city_cas_modes)){
      mode1_name <- city_cas_modes[mode1]
      if(mode1_name%in%names(city_inj)){
        count <- city_inj[names(city_inj)==mode1_name]
        pred_table$count[pred_table$city==city&pred_table$mode1==mode1_name&pred_table$mode2=='nov'] <- count
      }
    }
  }
  
  if('whw'%in%names(city_injuries[[city]])){
    city_inj <- city_injuries[[city]]$whw
    city_inj <- city_inj[rownames(city_inj)%in%mode_names,colnames(city_inj)%in%mode_names]
    for(mode1 in 1:length(city_cas_modes)){
      mode1_name <- city_cas_modes[mode1]
      if(mode1_name%in%colnames(city_inj)){
        for(mode2 in 1:length(city_col_modes)){
          mode2_name <- city_col_modes[mode2]
          if(mode2_name%in%rownames(city_inj)){
            count <- city_inj[rownames(city_inj)==mode2_name,colnames(city_inj)==mode1_name]
            pred_table$count[pred_table$city==city&pred_table$mode1==mode1_name&pred_table$mode2==mode2_name] <- count
          }
        }
      }
    }
  }
}

pred_table$dist1 <- as.numeric(pred_table$dist1)/1e6
pred_table$dist2 <- as.numeric(pred_table$dist2)/1e6
pred_table$dist2[pred_table$mode2=='nov'] <- 1
pred_table$dist2[pred_table$mode2=='bus'] <- pred_table$dist2[pred_table$mode2=='bus']/10
pred_table$years <- as.numeric(pred_table$years)
injury_table <- subset(pred_table,dist1>0&dist2>0&city%in%cities[cities_with_whw])
pred_table <- subset(pred_table,dist1>0&dist2>0)

saveRDS(injury_table,'outputs/whw_table.Rds')
saveRDS(pred_table,'outputs/full_table.Rds')


