
#####Colombia--Bogota (Use this one)#### (N persons = 91765)
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

###Brazil-- Sao Paulo#### (N persons = 24534)
setwd('V:/Studies/MOVED/HealthImpact/Data/TIGTHAT/Brazil/Sao Paulo/Pesquisa Origem Destino 2012')
trips<-read.csv('Mobilidade_2012_v0.csv')
str(trips)
trips<-subset(trips, select=c("ID_PESS", "ID_DOM", "N_VIAG", "DURACAO", "DISTANCIA","MODOPRIN", "SEXO", "IDADE", "FE_VIA" , "MOTIVO_D" , "MOTIVO_O"))
trips$female<-0
trips$female[which(trips$SEXO==2)]<-1
trips$city<- "Sao Paulo"
trips$urban<-1  
trips$country<-"Brazil"
trips$year<-2012
unique(trips$MODOPRIN)

for (i in 1: nrow(trips))
{
  
  
  if (!(is.na(trips$MOTIVO_D[i])) & trips$MOTIVO_D[i] == 8  & trips$MOTIVO_O[i]<4 & ! (is.na(trips$MOTIVO_O[i])) )
  {
    trips$purpose[i]<- 1
  }
  else if (! (is.na(trips$MOTIVO_D[i])) & trips$MOTIVO_D[i]<4)
  {
    trips$purpose[i]<-1
  }
  else 
  {
    trips$purpose[i]<-0
  }
}

trips$mode<-'NA'
trips$mode[which(trips$MODOPRIN==1)]<-"Omnibus" 
trips$mode[which(trips$MODOPRIN==2)]<-"Omnibus" 
trips$mode[which(trips$MODOPRIN==3)]<-"Omnibus" 
trips$mode[which(trips$MODOPRIN==4)]<-"Omnibus" 
trips$mode[which(trips$MODOPRIN==5)]<-"Bus" 
trips$mode[which(trips$MODOPRIN==6)]<-"Car" 
trips$mode[which(trips$MODOPRIN==7)]<-"Car" 
trips$mode[which(trips$MODOPRIN==8)]<-"Taxi" 
trips$mode[which(trips$MODOPRIN==9)]<-"Minibus/van" 
trips$mode[which(trips$MODOPRIN==10)]<-"Minibus/van" 
trips$mode[which(trips$MODOPRIN==11)]<-"Minibus/van" 
trips$mode[which(trips$MODOPRIN==12)]<-"Metro" 
trips$mode[which(trips$MODOPRIN==13)]<-"Tram" 
trips$mode[which(trips$MODOPRIN==14)]<-"Motorcycle" 
trips$mode[which(trips$MODOPRIN==15)]<-"Bicycle" 
trips$mode[which(trips$MODOPRIN==16)]<-"Walk" 
trips$mode[which(trips$MODOPRIN==17)]<-"Other" 
trips<- trips[which(!is.na(trips$N_VIAG)),]
trips$DISTANCIA<- trips$DISTANCIA/1000
trips<-subset(trips, select=c("ID_DOM", "ID_PESS", "female", "IDADE",  "N_VIAG","DISTANCIA", "DURACAO", "mode", "FE_VIA" , "purpose"))
colnames(trips)<-c("hh_ID", "ind_ID","female","age" ,"trip_ID", "trip_distance","trip_time", "trip_main_mode", "weight_trip", "trip_purpose")


####Brazil-- Belo Horizonte###### (N persons = 100656)
setwd('V:/Studies/MOVED/HealthImpact/Data/TIGTHAT/Brazil/Belo Horizonte/Travel survey')
trips<-read.table('dbo_TB_VIAGENS_INTERNAS_RMBH.txt', header = TRUE, sep=",")
persons<- read.table('dbo_TB_DOMICILIO_PESSOA_ENTREGA.txt', header = TRUE, sep=",")
hh_weights<- read.table('dbo_TB_FATOR_EXPANSÂO_DOMICÍLIO.txt', header = TRUE, sep=",")

###there are no stages, therefore, walking to and from public transport is not included
### we have a process coded in the ITHIM-R which adds this walking in such cases (Ali does it once we provide him the data)

##create unique person id
persons$id_person<- paste0(persons$ID_DOMICILIO, "_", persons$ID_PESSOA)
##selecting the variables needed for individuals (personid, sex, age)
persons<- subset(persons, select=c("id_person","DS_SEXO","IDADE"))
persons$female<-0
persons$female[which(persons$DS_SEXO=="Feminino")]<-1
##removing the sexo variables
persons<- persons[,-2]

##create trip and person id
trips$id_trip<- paste0(trips$Domicilio, "_", trips$Pessoa, "_", trips$Identificação)
trips$id_person<- paste0(trips$Domicilio, "_", trips$Pessoa)

##calculate trip duration
trips$trip_duration <- NA
trips$trip_duration <- (as.numeric(substr(trips$TEMPO.DE.DESLOCAMENTO, 12,13)))*60 + as.numeric(substr(trips$TEMPO.DE.DESLOCAMENTO, 15,16))

##allocating mode names in english
lookup<- as.data.frame((unique(trips$DS_SH_MEIO_TRANSPORTE)))
lookup<- cbind(lookup, c("bus", "car", "walk", "metro", "bus", "car", "motorcycle", "other", "truck", "bicycle", "taxi"))
names(lookup)<- c("DS_SH_MEIO_TRANSPORTE", "mode_eng")
trips <- trips %>% left_join(lookup, by="DS_SH_MEIO_TRANSPORTE")

##renaming the sex
trips$female<-0
trips$female[which(trips$Sexo=="Feminino")]<-1


trips %>% group_by(mode_eng) %>% summarise(n())

###checking for data quality
##trip rate
nrow(trips)/nrow(persons)
##trip rate for older than 15 (it goes up from 1.39 to 1.42)
nrow(trips[which(trips$Idade>15),])/nrow(persons[which(persons$IDADE>15),])
##duration per capita (seems lower value than expected)
sum(trips$trip_duration)/nrow(persons)
##average trip duration per mode
trips %>% group_by(mode_eng) %>% summarise(mean(trip_duration))

##number of unique people who made a trip
length(unique(trips$id_person))
##dividing this by the total number of people-- 59% of total sample made a trip, which brings down the average trip rate per capita
length(unique(trips$id_person))/nrow(persons)

##selecting the variables needed for trips (this one unusually has sex and age (idade) included in the trips file)
trips<- subset(trips, select=c("id_person", "id_trip","trip_duration","mode_eng", "Idade", "female", "Fator.expansão"))
names(trips)[7]<-"trip_weight"

##it seems that persons file has no weight variable, in which case we may have to get rid of the weight variable in the trip file also (Fator.expans?o)
##selecting persons which did not make any trip, to add to the trip file
persons<-persons[which(!(persons$id_person %in% unique(trips$id_person))),]
#renaming age variable same as trip
names(persons)[2]<-"Idade"

##adding all the other columns

persons$id_trip<- NA
persons$trip_duration<- NA
persons$mode_eng<- NA
#persons$Idade<- NA

##settings the sequence same as trips
persons<- subset(persons, select=c("id_person", "id_trip","trip_duration","mode_eng", "Idade", "female"))

trips<- rbind(trips, persons)

write.csv(trips,'V:/Studies/MOVED/HealthImpact/Data/TIGTHAT/Brazil/Belo Horizonte/ITHIM R data/trips.csv')

