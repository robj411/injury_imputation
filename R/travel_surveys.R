
#####Colombia--Bogota (Use this one)####
##In the previous version, stages were used, but there is no benefit as the stages for public transport hardly reports walking
###added duration in the raw excel file (Viaje) as the column 'duration'-- calculated from the clock time of start and end
setwd('V:/Studies/MOVED/HealthImpact/Data/TIGTHAT/Colombia/Bogota/Travel')
trips<- read.csv('encuesta 2015 - viajes.csv')
lookup_mode_name<-read.csv('V:/Studies/MOVED/HealthImpact/Data/TIGTHAT/Colombia/Bogota/Travel/spanish_english_modes.csv')
##to map the mode names in trip file to that of stage file; both files have different names
#lookup<- read.csv('V:/Studies/MOVED/HealthImpact/Data/TIGTHAT/Colombia/Bogota/Travel/lookup_mediotransporte_main_mode.csv')

trips<- subset(trips, select=c('ID_ENCUESTA',  'NUMERO_PERSONA', 'NUMERO_VIAJE','MEDIO_PREDOMINANTE','DURATION','FACTOR_AJUSTE'))
for (i in 1: nrow(trips))
{
  
  trips$factor_adjust[i]<- as.numeric(strsplit(as.character(trips$FACTOR_AJUSTE[i]), ',')[[1]][1])+(as.numeric(strsplit(as.character(trips$FACTOR_AJUSTE[i]), ',')[[1]][2]))/10^nchar(as.numeric(strsplit(as.character(trips$FACTOR_AJUSTE[i]), ',')[[1]][2]))
  trips$factor_adjust[i]
}

trips$trip_id<- NA
trips$trip_id<- paste0(trips$ID_ENCUESTA, trips$NUMERO_PERSONA, trips$NUMERO_VIAJE)
trips$person_id<- NA
trips$person_id<- paste0(trips$ID_ENCUESTA, trips$NUMERO_PERSONA)

trips<- subset(trips, select=c('trip_id', 'MEDIO_PREDOMINANTE', 'DURATION','person_id', 'factor_adjust'))


##adding the person-level variables
person<-read.csv('encuesta 2015 - personas.csv')
person$person_id<- NA
person$person_id<- paste0(person$ID_ENCUESTA, person$NUMERO_PERSONA)
person<- subset(person, select=c('person_id','SEXO', 'EDAD', 'FE_TOTAL'))
person$FE_TOTAL<-as.character(person$FE_TOTAL)
for (i in 1:nrow(person))
{
  person$weights[i]<- as.numeric(strsplit(as.character(person$FE_TOTAL[i]), ',')[[1]][1])+(as.numeric(strsplit(as.character(person$FE_TOTAL[i]), ',')[[1]][2]))/10^nchar(as.numeric(strsplit(as.character(person$FE_TOTAL[i]), ',')[[1]][2]))
}

trips<- trips %>% left_join(person, by="person_id")

trips<- trips[,-8]

names(trips)[8]<-"person_weight"
names(trips)[5]<-"trip_weight"
trips<- trips %>% left_join(lookup_mode_name, by="MEDIO_PREDOMINANTE")
trips<- trips[,-2]
head(trips)

write.csv(trips, 'C:/Users/goelr/Work/injury_imputation/raw_data/trips/bogota_trips.csv')
