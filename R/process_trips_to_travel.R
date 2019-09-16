##

# for each city, take trips, get total travel, scale up by population.

# @RG: scaling up needs to be by demographic group.

## BOGOTA ##

# load trips
# @RG: confirm trip distances are km
trips <- read.csv('raw_data/trips/bogota_trips.csv')

# create distance column and mode column if missing
trips$stage_distance <- trips$DURATION/60 * trips$speed
trips$stage_mode <- trips$main_mode_eng

# load population
population <- read.csv('raw_data/population/population_bogota.csv')

# define modes
modes <- c('car','bicycle','motorcycle','truck','van','bus','walk')

# rename modes
trips$stage_mode <- tolower(trips$stage_mode)
trips$stage_mode[trips$stage_mode=='private car'] <- 'car'

# which modes are we missing?
print(unique(trips$stage_mode)[!unique(trips$stage_mode)%in%modes])

##!! @RG: checkpoint

# sum modes
summary_table <- data.frame(mode=modes,km=0)
##!! this needs to be by demographic group
for(i in 1:length(modes)) summary_table$km[i] <- sum(trips$stage_distance[trips$stage_mode==summary_table$mode[i]]) ##!! multiply by trip weight

# multiply by populations
##!! this needs to be by demographic group
summary_table$km <- summary_table$km * sum(population$population)

# write out
write.csv(summary_table,'processed_data/distances/bogota_travel.csv')
