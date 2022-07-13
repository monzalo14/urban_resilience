library(tidyverse)
library(sf)
library(atakrig)
library(rgdal)
library(vroom)

#modelo de kriging para datos de area

#leer agebs ---- 
map <- read_sf("00a.shp") %>% filter(CVE_ENT=="09") #del marco geoestadistico 2020

#leer unos datos de lluvia; esto habría que iterarlo para cada fecha  ---- 

tusbesosfrioscomola    <- vroom::vroom(file = "data/output_20200615.csv") #mi cumpleaños! 
dondestanlasestaciones <- vroom::vroom(file = "data/tabla_estaciones_meteo_con_agebs_clean.csv")

lluvia <- left_join(tusbesosfrioscomola , dondestanlasestaciones, by=c("ID"="no_id"))
lluvia %>% group_by(clave) %>% tally() #lecturas por hora, agreguémoslas 

#agregamos a 24 h 

lluvia.24 <- lluvia %>% group_by(clave, CVEGEO) %>% summarise(precipitacion_total = sum(PRECTOTCORR))

#hagamos un mapita ---- 

left_join(map, lluvia.24) %>% 
  ggplot() + 
  aes(fill=precipitacion_total) + 
  geom_sf()

# vamos a preparar el modelo con los datos que si se tienen observaciones ----

observaciones.sf <- right_join(map, lluvia.24)

# convertir en SPDF ----

observaciones.spdf <- observaciones.sf %>%  as(., 'Spatial')

#discretizar los poligonos -----
observaciones.spdf.discre <- discretizePolygon(observaciones.spdf, 
                                               cellsize=1500, 
                                               id="CVEGEO", 
                                               value="precipitacion_total"
)

# el variograma ----

pointsv.lluvia <- deconvPointVgm(observaciones.spdf.discre, #aqui hay oportunidad de optimizar, pero no hay tiempo
                                 model="Exp", #si le pongo Gaussiano está más jefe el fit, pero no jala lo que sigue : | 
                                 ngroup=12, 
                                 rd=0.75, 
                                 fig=TRUE)

## cross validation ----
pred.cv <- ataKriging.cv(observaciones.spdf.discre, 
                         nfold=length(observaciones.sf),
                         pointsv.lluvia)
names(pred.cv)[6] <- "obs"

summary(pred.cv[,c("obs","pred","var")])
cor(pred.cv$obs, pred.cv$pred)			# Pearson correlation
mean(abs(pred.cv$obs - pred.cv$pred))	# MAE
sqrt(mean((pred.cv$obs - pred.cv$pred)^2))	# RMSE

#ahora vamos a sacar los poligonos para los que no tenemos observaciones ---- 

predictionLocations.df <- 
  left_join(map, lluvia.24) %>% filter(is.na(precipitacion_total)) %>% select(-clave, -precipitacion_total)

predictionLocations.spdf <- predictionLocations.df %>%  as(., 'Spatial')



pred.discrete <- 
  discretizePolygon(predictionLocations.spdf, 
                    cellsize = 1000, #si le pongo 1500 como arriba, falla; y si le pongo muy bajo (100), se rompe en el paso de pred
                    id="CVEGEO"
  )

pred <- ataKriging(observaciones.spdf.discre, pred.discrete, pointsv.lluvia$pointVariogram)


# y ahora lo integramos en un sf para que sea más manejable ----


my_sf <- bind_rows(observaciones.sf, predictionLocations.df)

my_sf %>% 
  ggplot() + 
  geom_sf(aes(fill=precipitacion_total))

my_sf.full <- 
  left_join(my_sf, pred, by=c("CVEGEO"="areaId"))

my_sf.full <- 
  my_sf.full %>% 
  mutate(predicted = !is.na(pred) ) %>% 
  mutate(obs = coalesce(precipitacion_total, pred))

my_sf.full %>% 
  ggplot() + 
  aes(fill=obs) + 
  geom_sf(lwd=0.1) + 
  scale_fill_viridis_c("secret!", option = "B")

#y hacemos el writeout

output_file <- "output_20200615_inferido.csv"

my_sf.full %>% 
  as_tibble() %>% 
  select(-geometry) %>% 
  vroom_write(file = output_file) #
