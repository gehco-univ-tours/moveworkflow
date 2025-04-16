
<!-- README.md is generated from README.Rmd. Please edit that file -->

# moveworkflow

<!-- badges: start -->
<!-- badges: end -->

The goal of moveworkflow is to …

## Installation

You can install the development version of moveworkflow from
[GitHub](https://github.com/) with:

``` r
## Set timezone system
Sys.setenv(TZ = "UTC")

## Combined diver
feature_file <- type_files("CSV")
save_directory <-system.file("data_ext","data_compile","diver",package="moveworkflow", mustWork=TRUE)
name_diver <- c("A_1_diver","A_2_diver","A_3_diver","Baro_amboise","N_F_diver","N_A_diver","Baro_noizay")
for (i in name_diver){
  directory <- system.file("data_ext","data_raw",i,package="moveworkflow", mustWork=TRUE)
  data_combine <- combine_files(directory, "CSV") %>% 
    dplyr::select(1:4) %>% 
    dplyr::rename_with(~feature_file$col_name, everything()) %>%
    dplyr::distinct(date_time, .keep_all = TRUE) %>% 
    dplyr::arrange(date_time)
  name_file <- paste(basename(directory),"_combine.csv",sep="")
  save_file(save_directory,data_combine,"date_time",name_file)
}

##Compiled all
directory <- system.file("data_ext","data_compile","diver",package="moveworkflow", mustWork=TRUE)
feature_file <- type_files("csv")
col_name <- c("date_time", "level_cm", "id_sensor", "id_plot")
data_combine <- combine_files(directory, "csv") %>% 
  dplyr::select(-temp_c) %>% 
  dplyr::rename_with(~col_name, everything()) %>% 
  dplyr::arrange(date_time)
save_directory <-system.file("data_ext","data_compile",package="moveworkflow", mustWork=TRUE)
name_file <- paste(basename(directory),"_combine.csv",sep="")
save_file(save_directory,data_combine,date_time,name_file)
```

``` r
## Combined tipping
feature_file <- type_files("txt")
save_directory <-system.file("data_ext","data_compile","tipping",package="moveworkflow", mustWork=TRUE)
name_tipping <- c("A_1_tipping","A_2_tipping","A_3_tipping","N_F_tipping","N_A_tipping")
for (i in name_tipping){
  directory <- system.file("data_ext","data_raw",i,package="moveworkflow", mustWork=TRUE)
  data_combine <- combine_files(directory, "txt") %>% 
    dplyr::select(1:3,id_file) %>% 
  dplyr::rename_with(~feature_file$col_name, everything()) %>%
  dplyr::select(-row_name) %>% 
  dplyr::mutate(value = as.numeric(gsub(",","",value))) %>%
  base::subset(!is.na(value)) %>% 
  dplyr::arrange(date_time)
  name_file <- paste(basename(directory),"_combine.csv",sep="")
  save_file(save_directory,data_combine,"date_time",name_file)
}

##Compiled all
directory <- system.file("data_ext","data_compile","tipping",package="moveworkflow", mustWork=TRUE)
feature_file <- type_files("csv")
col_name <- c("date_time", "value", "id_sensor", "id_plot")
data_combine <- combine_files(directory, "csv") %>% 
  dplyr::rename_with(~col_name, everything()) %>% 
  dplyr::arrange(date_time)
save_directory <-system.file("data_ext","data_compile",package="moveworkflow", mustWork=TRUE)
name_file <- paste(basename(directory),"_combine.csv",sep="")
save_file(save_directory,data_combine,"date_time",name_file)
```

``` r
## Correction of diver data by atmospherics pressure
name_plot <- c("A_1","A_2","A_3","N_A","N_F")
for (i in name_plot){
  data_diver <- diver_correct(i)
  save_directory <- system.file("data_ext","data_correct","diver",package="moveworkflow", mustWork=TRUE)
  name_file <- paste(i,"diver_correct.csv",sep="_")
  save_file(save_directory,data_diver,"date_time",name_file)
}
directory <- system.file("data_ext","data_correct","diver",package="moveworkflow",mustWork=TRUE)
data_combine <- combine_files(directory, "csv") %>% 
  dplyr::select(-id_file)
save_directory <- system.file("data_ext","data_correct",package="moveworkflow",mustWork=TRUE)
name_file <- paste(basename(directory),"_correct.csv",sep="")
save_file(save_directory,data_combine,date_time,name_file)
```

``` r
## combine noizay rain
feature_file <- type_files("txt")
directory <- system.file("data_ext","data_raw","pluviometrie","noizay",package="moveworkflow", mustWork=TRUE)
col_name <- c("row_name","date_time","sum","rain_mm")
data_combine <- combine_files(directory, "txt") %>%  
    dplyr::select(1:4) %>% 
    dplyr::rename_with(~col_name, everything()) %>% 
    dplyr::select(-row_name,-sum) %>% 
    tidyr::drop_na(rain_mm) %>% 
    dplyr::arrange(date_time)
name_file <- paste(basename(directory),"pluviometrie","_compile.csv",sep="")
save_directory <-system.file("data_ext","data_compile","pluviometrie",package="moveworkflow", mustWork=TRUE)
save_file(save_directory,data_combine,"date_time",name_file)

## Select amboise station
directory <- system.file("data_ext","data_raw","pluviometrie","amboise","amboise_rain.csv",package="moveworkflow", mustWork=TRUE)
data_rain <- read_file(directory) %>% 
  subset(NOM_USUEL == "AMBOISE")%>% 
  dplyr::select(AAAAMMJJHHMN, RR)%>%
  dplyr::mutate(date_time = lubridate::ymd_hm(AAAAMMJJHHMN)+lubridate::hours(1), rain_mm=RR)%>%
  dplyr::select(-AAAAMMJJHHMN, -RR) %>%
  subset(date_time >= "2024-04-01 00:00:00") %>% 
  tidyr::drop_na(rain_mm) %>% 
  dplyr::arrange(date_time)
name_file <- paste("amboise","pluviometrie","_compile.csv",sep="")
save_directory <-system.file("data_ext","data_compile","pluviometrie",package="moveworkflow", mustWork=TRUE)
save_file(save_directory,data_rain,"date_time",name_file)

## Combine data_rain
directory <-system.file("data_ext","data_compile","pluviometrie",package="moveworkflow", mustWork=TRUE)
feature_file <- type_files("csv")
data_combine <- combine_files(directory, "csv") %>% 
  dplyr::mutate(id_file = stringr::str_remove(id_file, "_pluviometrie")) %>% 
  dplyr::rename("id_site"=id_file)
name_file <- paste(basename(directory),"_combine.csv",sep="")
save_directory <-system.file("data_ext","data_compile",package="moveworkflow", mustWork=TRUE)
save_file(save_directory,data_combine,"date_time",name_file)
```

``` r
## Display diver level, to select runoff event
name_plot <- c("N_A")
for (i in name_plot){
  plot_to_select(i)
}
## Cut tipping
name_plot <- c("A_1","A_2","A_3","N_A","N_F")
directory <- system.file("data_ext","data_compile","tipping_combine.csv",package="moveworkflow", mustWork=TRUE)
MIT <- lubridate::hours(6)
feature_ruisselometre <- read_file(system.file("data_ext","data_raw","other_data","features_ruisselometre.csv",package="moveworkflow", mustWork=TRUE))
feature_sensor <- read_file(system.file("data_ext","data_raw","other_data","features_sensor.csv",package="moveworkflow", mustWork=TRUE))
for (i in name_plot){
data_frame <- read_file(directory) %>%
  subset(id_plot == i)
data_cut <- cut_data(data_frame, MIT) %>% 
  dplyr::rowwise() %>%
  mutate(value = sum(!is.na(dplyr::c_across(c(-date_begin,-date_end,-id_event,-value))))) %>%
  dplyr::ungroup() %>% 
  mutate(runoff_l = (value * select_feature(feature_sensor,"id_sensor","value",select_feature(feature_ruisselometre,"id_ruisselometre","id_tipping",i)))/1000)%>% 
  select(date_begin,date_end,id_event,runoff_l) 
save_directory <- system.file("data_ext","data_correct","tipping",package="moveworkflow", mustWork=TRUE)
  name_file <- paste(i,"tipping_correct.csv",sep="_")
  save_file(save_directory,data_cut,c("date_begin","date_end"),name_file)
}

##Compil tipping to complet runoff event
directory <- system.file("data_ext","data_correct","tipping",package="moveworkflow", mustWork=TRUE)
feature_file <- type_files("csv")
feature_file[["name_datetime"]] <- "date_begin"
data_combine <- combine_files(directory,"csv") %>% 
  mutate(date_end = ymd_hms(date_end)) %>% 
  subset(runoff_l>30) %>% 
  rename(id_plot=id_file)
save_directory <- system.file("data_ext","data_correct",package="moveworkflow", mustWork=TRUE)
name_file <- paste("tipping","correct.csv",sep="_")
save_file(save_directory,data_combine,c("date_begin","date_end"),name_file)
```

``` r
## Cut pluviometrie
name_plot <- c("amboise","noizay")
directory <- system.file("data_ext","data_compile","pluviometrie_combine.csv",package="moveworkflow", mustWork=TRUE)
MIT <- lubridate::hours(6)
for (i in name_plot){
  if(i == "amboise"){
    TB2V <- lubridate::minutes(6)
  }else{
    TB2V <- lubridate::minutes(5)
  }
data_frame <- read_file(directory) %>%
  subset(id_site == i)
data_cut <- cut_data(data_frame, MIT) %>%
  mutate(date_end = date_end-MIT+TB2V) %>% 
  dplyr::rowwise() %>%
  mutate(rain_mm = sum(!is.na(dplyr::c_across(c(-date_begin,-date_end,-id_event,-value))) & dplyr::c_across(c(-date_begin,-date_end,-id_event,-value))>0)*0.2) %>%
  dplyr::ungroup() %>%
  select(date_begin,date_end,id_event,rain_mm)
save_directory <- system.file("data_ext","data_correct","pluviometrie",package="moveworkflow", mustWork=TRUE)
  name_file <- paste(i,basename(save_directory),"correct.csv",sep="_")
  save_file(save_directory,data_cut,c("date_begin","date_end"),name_file)
}

##Compil pluviometrie correct
directory <- system.file("data_ext","data_correct","pluviometrie",package="moveworkflow", mustWork=TRUE)
feature_file <- type_files("csv")
feature_file[["name_datetime"]] <- "date_begin"
data_combine <- combine_files(directory,"csv") %>% 
  mutate(date_end = ymd_hms(date_end)) %>% 
  dplyr::mutate(id_file = stringr::str_remove(id_file, "_pluviometrie")) %>% 
  rename(id_site=id_file)
save_directory <- system.file("data_ext","data_correct",package="moveworkflow", mustWork=TRUE)
name_file <- paste("pluviometrie","correct.csv",sep="_")
save_file(save_directory,data_combine,c("date_begin","date_end"),name_file)
```

``` r
## Display plot and select periode
```
