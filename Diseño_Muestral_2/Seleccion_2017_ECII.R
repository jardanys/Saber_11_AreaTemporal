########### Dise�o Muestral Bietapico ###################
################## ESTMAS ######################## 
#2017
#UPM ESTMAS: Colegios
#USM MAS: Estudiantes 

library(dplyr)
setwd("D:/Documents/MEA/SAE/Estudio_Caso_II/Modelo_Area_Temporal_Yu_Rao_Saber_Antioquia/Base_Datos_2")
Marcoest_saber2017_Aquia <- readRDS("saber2017_Aquia.rds")
names(Marcoest_saber2017_Aquia)
length(unique(Marcoest_saber2017_Aquia$COLE_COD_MCPIO_UBICACION))
length(unique(Marcoest_saber2017_Aquia$COLE_COD_DANE_ESTABLECIMIENTO))
length(unique(Marcoest_saber2017_Aquia$ESTU_AREA_RESIDE ))
length(unique(Marcoest_saber2017_Aquia$COLE_CODIGO_ICFES))
cole <- Marcoest_saber2017_Aquia %>% group_by(COLE_CODIGO_ICFES) %>% summarise(tx = n())
sum(cole$tx)

library(stratification)
set.seed(12345)
# Estratificaci�n - Selecci�n de Estratos y tama�o  
indica_estrato <- strata.LH(cole$tx,Ls = 5, CV = 0.03)
indica_estrato

cortes <- c(min(cole$tx), indica_estrato$bh, max(cole$tx))

cole$estrato_cole <- cut(cole$tx, breaks = cortes, include.lowest = T, right = F,
                         label = paste0("Estrato", 1:5))

cole<- arrange(cole, tx)


library(sampling)
library(dplyr)

# Organizaci�n Base de Datos y Tama�os
set.seed(12345)
# MAS - Selecci�n de la Muestra

tamano_estrato <- data.frame(estrato_cole = paste0("estrato_cole", 1:5), nh =
                               indica_estrato$nh)

set.seed(12345)
indica_mue <- sampling::strata(cole, stratanames = "estrato_cole", size = tamano_estrato$nh,
                               method = "srswr", description = T)



tamanoPoblaciOnal_estrato <- data.frame(estrato_cole = paste0("estrato_col", 1:5), Nh =
                                          indica_estrato$Nh)
set.seed(12345)
mue_cole <- sampling::getdata(cole, indica_mue)
mue_cole <- mue_cole[c("estrato_cole", "COLE_CODIGO_ICFES")]

#muestra <- getdata(Marcoest_saber2015_Aquia, indica_mue)
#muestra <- merge(muestra, tamanoPoblaciOnal_estrato)
#muestra <- merge(muestra, tamano_estrato)

Tamanos_cole <- data.frame(estrato_cole = paste0("Estrato",1:5), Nh = indica_estrato$Nh, nh = indica_estrato$nh)

marco_cole <- merge(Marcoest_saber2017_Aquia, mue_cole, all.y = T, by = "COLE_CODIGO_ICFES") 
marco_cole <- merge(marco_cole, Tamanos_cole, by = "estrato_cole" )
names(marco_cole)


# Seleccionar estudiantes (MAS)
names(marco_cole)
length(unique(marco_cole$COLE_CODIGO_ICFES))
length(unique(marco_cole$COLE_COD_DANE_ESTABLECIMIENTO))

length(marco_cole$COLE_COD_DANE_ESTABLECIMIENTO)
length(marco_cole$ESTU_COD_RESIDE_MCPIO)
length(marco_cole$COLE_CODIGO_ICFES)

names(marco_cole)
consulta_estud <- marco_cole %>% group_by(COLE_COD_MCPIO_UBICACION, COLE_CODIGO_ICFES) %>% 
  summarise(Num_est = n()) %>% arrange(-Num_est)

sum(consulta_estud$Num_est)
summary(consulta_estud$Num_est)
set.seed(12345)
consulta_estud$n_i <- ceiling(consulta_estud$Num_est * 0.6)
sum(consulta_estud$n_i)

## Estudiantes por Colegios () 
consulta_estud <- consulta_estud %>% arrange(COLE_CODIGO_ICFES)

names(consulta_estud)[3] <- c("N_i")
muestra <- marco_cole %>% arrange(COLE_CODIGO_ICFES)
names(marco_cole)
## COLE_COD_ICFES
### estduaientes y Colegio al que pertenecen
set.seed(12345)
indica_mueestu <- sampling::strata(muestra, stratanames = "COLE_CODIGO_ICFES",
                                   size = consulta_estud$n_i,
                                   method = "srswor", description = T)


EC2muestraXest2017 <- muestra[indica_mueestu$ID_unit,]  

EC2muestraXest2017 <- merge(EC2muestraXest2017,  consulta_estud)
length(unique(EC2muestraXest2017$COLE_CODIGO_ICFES))
length(unique(EC2muestraXest2017$COLE_COD_MCPIO_UBICACION))

setwd("D:/Documents/MEA/SAE/Estudio_Caso_II/Modelo_Area_Temporal_Yu_Rao_Saber_Antioquia/Muestra_2")
saveRDS(EC2muestraXest2017, "muestra2Etapas_2017.RDS")

library(survey)
# Dise�o Muestral 
names(EC2muestraXest2017)
diseno_muestral <- svydesign(ids = ~ COLE_CODIGO_ICFES + ESTU_CONSECUTIVO,
                             strata = ~ estrato_cole,
                             fpc = ~ Nh + N_i, data = EC2muestraXest2017,
                             nest = T)

svymean(~PUNT_GLOBAL, diseno_muestral)
100 * cv(svymean(~PUNT_GLOBAL, diseno_muestral))

max(EC2muestraXest2017$PUNT_GLOBAL)
mean(EC2muestraXest2017$PUNT_GLOBAL)
mean(Marcoest_saber2017_Aquia$PUNT_GLOBAL)           
max(Marcoest_saber2017_Aquia$PUNT_GLOBAL)

svytotal(~PUNT_GLOBAL, diseno_muestral)
100 * cv(svytotal(~Estudiantes, diseno_muestral))

sum(weights(diseno_muestral))
nrow(Marcoest_saber2017_Aquia)
