## code to prepare `data` dataset goes here
#Pour la rain en jour
directory <- system.file("data_ext","data_compile","pluviometrie_combine.csv",package="moveworkflow", mustWork=TRUE)
data_rain_jour <- read_file(directory) %>%
  subset(id_site == "amboise") %>%
  dplyr::group_by(lubridate::date(date_time)) %>%
  dplyr::summarise(sum(rain_mm))
#Pour la rain en minutes
directory <- system.file("data_ext","data_compile","pluviometrie_combine.csv",package="moveworkflow", mustWork=TRUE)
data_rain <- read_file(directory) %>%
  subset(id_site == "amboise") %>%
  mutate(date_time = ymd_hms(date_time))
#fixe le temps entre 2 valeurs
TB2V <- minutes(6)
#regarde si il y a des données qui manquent
table(diff(data_rain$date_time))
#Oui, pour une seul période. Comme on est en pluvio, remplacement par 0
#On remplace par 0
data_rain <- data.frame(date_time=seq(min(data_rain$date_time), max(data_rain$date_time), by="6 min"))%>%
  left_join(data_rain, by="date_time") %>%
  mutate(rain_mm = tidyr::replace_na(rain_mm,0))
#On créer un tableau à la minutes
data_rain_minute <- data.frame(date_time=seq(min(data_rain$date_time), max(data_rain$date_time), by="1 min"))
data_rain_minute$rain_mm <- rep(data_rain$rain_mm/6,each=6)[1:(length(data_rain$rain_mm)*6-((as.numeric(TB2V)/60)-1))]
data_rain_minute$id_side <- "amboise"
rm(data_rain)

##On charge le tableau feature ruisselometre
#directory <- system.file("data_ext","data_raw","other_data","features_sensor.csv",package="moveworkflow", mustWork=TRUE)
#sensor <- read_file(directory)
#fixe le temps entre 2 valeurs
TB2V <- minutes(5)
##On charge les données diver
#directory <- system.file("data_ext","data_correct","diver_correct.csv",package="moveworkflow", mustWork=TRUE)
#data_diver <- read_file(directory) %>%
 # left_join(sensor[c("id_sensor","value")], by="id_sensor") %>%
  #mutate(volume_l = (level_cm - value)*11.2) %>%
  #subset(id_plot == "A_1") %>%
  #select(-value) %>%
  #mutate(date_time = ymd_hms(date_time))
#On check si il n'y a pas de troue de donnée
table(diff(data_diver$date_time))
#Oui, pour plusieur période
#On ne remplace pas, on galère
data_diver <- data.frame(date_time=seq(min(data_diver$date_time), max(data_diver$date_time), by="5 min"))%>%
  left_join(data_diver, by="date_time")
#On créer un tableau à la minutes
data_diver_minute <- data.frame(date_time=seq(min(data_diver$date_time), max(data_diver$date_time), by="1 min"))
data_diver_minute$volume_l <- approx(data_diver$date_time,data_diver$volume_l,xout=data_diver_minute$date_time)$y
data_diver_minute$id_plot <- "A_1"
rm(data_diver)

#télécharger feature_ruisselometre
directory <- system.file("data_ext","data_raw","other_data","features_ruisselometre.csv",package="moveworkflow", mustWork=TRUE)
ruisselometre <- read_file(directory)
#On enlève la pluie qui est tombée dans les goutières
data_rain_minute <- data_rain_minute %>%
  mutate(v_gutter_l = rain_mm*select_feature(ruisselometre,"id_ruisselometre","area_gutter_m2","A_1"))
#On enlève la pluie tombée, au volume mesuré dans la cuve /minutes
#Je prépare le vecteur pour caler débit/minutes
#vector <- c(data_diver_minute$volume_l[2:length(data_diver_minute$volume_l)],0)
#data_diver_minute <- data_diver_minute %>%
  #mutate(volumeX2_l = vector) %>%
  #mutate(flow_l_min = volumeX2_l-volume_l) %>%
  left_join(data_rain_minute, by="date_time") %>%
  mutate(flow_runoff_l_min = flow_l_min - v_gutter_l) %>%
  subset(flow_l_min < 20 & flow_l_min>-10)

#Display les valeurs obtenue sur plotly pour vérifier les bétises
k <- plot_ly() %>%
add_lines(data = data_runoff, x = ~date_time, y = ~flow_l_min, split = ~id_runoff, yaxis = 'y1',
          # black color
          #line = list(color = 'rgba(0, 0, 0, 0.6)')
) %>%
  add_lines(data = data_diver, x = ~date_time, y = ~level_cm, name = 'diver_level_cm', yaxis = 'y1',
            # black color
            line = list(color = "red")
)


## Pour discuter avec Seb
##display instruments precision's
directory <- system.file("data_ext","data_raw","other_data","dates_to_check.csv", package="moveworkflow", mustWork=TRUE) #set directory
data_runoff <- read_file(directory) %>%  #charge dates for rectangles
  subset(id_plot == "A_1") %>%
  mutate(date_begin = lubridate::ymd_hm(date_begin), date_end = lubridate::ymd_hm(date_end))
directory <- system.file("data_ext","data_correct","rain_correct.csv", package="moveworkflow", mustWork=TRUE) #set directory
data_rain <- read_file(directory) %>% #charge data rain
  subset(id_site == "amboise") %>%
  mutate(date_time = ymd_hms(date_time)) %>%
  dplyr::group_by(date_time=lubridate::floor_date(date_time, lubridate::hours(1))) %>% #group_by hours
  dplyr::summarise(sum(rain_mm)) %>%
  dplyr::rename_with(~c("date_time","rain_mm"), everything()) %>%
  left_join(read_file(directory) %>% #add event number
              subset(id_site == "amboise") %>%
              mutate(date_time = ymd_hms(date_time)) %>%
              select(event,date_time),
            by = "date_time")
directory <- system.file("data_ext","data_raw","other_data","runoff_event.csv", package="moveworkflow", mustWork=TRUE)
data_runoff_ev <- read_file(directory) %>%
  mutate(begin_diver = lubridate::ymd_hm(begin_diver), debut_tipping = lubridate::ymd_hm(debut_tipping))
for (i in 1:length(rownames(data_runoff_ev))){
  data_runoff_ev$date_begin[i] <- as.character(max(data_runoff_ev$begin_diver[i], data_runoff_ev$debut_tipping[i], na.rm=TRUE))
}
data_runoff_ev <- data_runoff_ev %>%
  mutate(date_begin = ymd_hms(date_begin)) %>%
  subset(id_plot=="A_1") %>%
  subset(precision_r !="low")

rain_level <- plot_ly() %>%
  add_bars(data = data_rain,
           x = ~date_time, y = ~rain_mm,
           split=~event,
           yaxis = 'y2',
           marker = list(
             color = 'rgba(0, 0, 255, 0.6)'),
           orientation = 'v') %>%
  layout(
    title = paste("instruments conditions","A_1"),
    yaxis2 = list(title = 'Rain_mm', overlaying = 'y',
                  autorange = 'reversed',
                  showgrid = FALSE),
    xaxis = list(title = 'Date_time'),
    barmode = 'overlay',
    shapes = c(plot_rectangle(data_runoff,10), vline(data_runoff_ev$date_begin,"bleu"))
  )

vline <- function(date, color) {
  list_list <- list()
  for(i in 1:length(date)){
    date_x <- date[i]
    #color_x <- color[i]
    k<-list(
      type = "line",
      y0 = 0,
      y1 = 1,
      yref = "paper",
      x0 = date_x,
      x1 = date_x,
      line = list(color = 'dark', dash="dot")
    )
    list_list[[i]]<-k
  }
  return(list_list)
}
