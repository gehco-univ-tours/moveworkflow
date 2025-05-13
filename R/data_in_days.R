#' data_in_days
#' a function to compile all data in a daily data frame
#'
#' @param plot_name the plot name
#' @importFrom dplyr mutate
#' @importFrom dplyr group_by
#' @importFrom dplyr summarise
#' @importFrom dplyr left_join
#' @importFrom dplyr rename_with
#' @importFrom lubridate ymd_hms
#' @importFrom lubridate ymd
#'
#' @return a daily data_frame data
#' @export
data_in_days <- function(plot_name){
#create the daily dataframe
date <- seq.Date(ymd("2024_04_01"), ymd("2025_03_31"), by = "days")
data_days <- data.frame(date_time = date)
##charge feature ruisselometre
directory <- system.file("data_ext","data_raw","other_data","features_ruisselometre.csv", package="moveworkflow", mustWork=TRUE) #set directory
features_plot <- read_file(directory)  #charge features ruisselometre
##add v_rain_mm
site <- select_feature(features_plot, "id_plot", "site", plot_name)
directory <- system.file("data_ext","data_output","rain_ev.csv", package="moveworkflow", mustWork=TRUE) #set directory
data_rain_ev <- read_file(directory) %>%  #charge rain
  subset(id_site == site) %>%
  mutate(date_begin = ymd_hms(date_begin)) %>%
  mutate(date = date(date_begin)) %>%
  group_by(date) %>%
  summarise(h_rain_mm = sum(h_rain_mm))
data_days <- data_days %>%
  left_join(data_rain_ev, by=c("date_time" = "date"))
##add v_runoff_mm
directory <- system.file("data_ext","data_output","runoff.csv", package="moveworkflow", mustWork=TRUE) #set directory
data_runoff <- read_file(directory) %>% #charge data_runoff
  subset(id_plot == plot_name) %>%
  mutate(begin_r = lubridate::dmy_hm(begin_r)) %>%
  mutate(end_r = lubridate::dmy_hm(end_r)) %>%
  mutate(date_begin_rain = lubridate::dmy_hm(date_begin_rain)) %>%
  mutate(date_end_rain = lubridate::dmy_hm(date_end_rain)) %>%
  mutate(date = date(ymd_hms(date_begin_rain))) %>%
  group_by(date) %>%
  summarise(h_runoff_mm = sum(new_h_runoff_mm))
data_days <- data_days %>%
  left_join(data_runoff, by=c("date_time" = "date"))
##add cu_input and TS
directory <- system.file("data_ext","data_raw","other_data","data_ITK.csv", package="moveworkflow", mustWork=TRUE)
data_ITK <- read_file(directory) %>%
  mutate(date = ymd(date)) %>%
  subset(id_ruisselometre == plot_name) %>%
  select(date,dose_cu_plot_g_ha) %>%
  group_by(date) %>%
  summarise(dose_cu_g_ha = sum(dose_cu_plot_g_ha, na.rm =TRUE))
data_days <- data_days %>%
  left_join(data_ITK, by=c("date_time" = "date"))
data_ITK <- read_file(directory)%>%
  mutate(date = ymd(date)) %>%
  subset(id_ruisselometre == plot_name) %>%
  select(date,TS) %>%
  subset(TS!="")
data_days <- data_days %>%
  left_join(data_ITK, by=c("date_time" = "date"))
##add flux : MES and CU
names_col <- c("mass_MES_kg_ha", "mass_cu_total_g_ha", "mass_cu_dissolved_g_ha",
               "inc_abs_v_runoff_mm", "inc_abs_mass_MES",
               "inc_abs_mass_cu_total", "inc_abs_mass_cu_dissolved")
for (i in names_col){
directory <- system.file("data_ext","data_output","runoff.csv", package="moveworkflow", mustWork=TRUE) #set directory
data_runoff <- read_file(directory) %>% #charge data_runoff
  subset(id_plot == plot_name) %>%
  mutate(begin_r = lubridate::dmy_hm(begin_r)) %>%
  mutate(end_r = lubridate::dmy_hm(end_r)) %>%
  mutate(date_begin_rain = lubridate::dmy_hm(date_begin_rain)) %>%
  mutate(date_end_rain = lubridate::dmy_hm(date_end_rain)) %>%
  mutate(inc_abs_v_runoff_mm = new_h_rain_mm * (new_inc_abs_CR/100)) %>%
  mutate(date = date(ymd_hms(date_begin_rain))) %>%
  group_by(date) %>%
  summarise(sum(.data[[i]]))
data_days <- data_days %>%
  left_join(data_runoff, by=c("date_time" = "date"))
}
data_days <- data_days %>%
  dplyr::rename_with(~names_col, .cols = c(6:12))
return(data_days)
}
