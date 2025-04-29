#' diver_correct
#' a function to correct diver data, with their baro_diver data
#'
#' @param name_plot name plot to correct
#' @importFrom dplyr select
#' @importFrom dplyr rename
#' @importFrom dplyr left_join
#' @importFrom dplyr mutate
#' @importFrom lubridate ymd_hms
#'
#' @return a data_frame
#' @export
#'
diver_correct <- function(name_plot){
  directory <- system.file("data_ext","data_compile","diver_combine.csv",package="moveworkflow", mustWork=TRUE) #set file path
  data_ruisselometre <- read_file(system.file("data_ext","data_raw","other_data","features_ruisselometre.csv",package="moveworkflow", mustWork=TRUE)) #charge ruisselometre features
  data_diver <- read_file(directory) %>%
    subset(id_plot == name_plot) %>%
    mutate(date_time = ymd_hms(date_time)) #charge data_file to correct
  name_baro <- paste("Baro",select_feature(data_ruisselometre,"id_plot","site",name_plot), sep="_") #set name of baro_diver by match in data_ruisselometre_features
  data_baro <- read_file(directory) %>%
    subset(id_plot == name_baro) %>%
    select(date_time, level_cm) %>%
    rename(baro_level_cm = level_cm) %>%
    mutate(date_time = ymd_hms(date_time)) #charge data_file of baro_diver
  data_correct <- data_diver %>%
    left_join(data_baro, by = "date_time") %>%
    mutate(level_cm = level_cm - baro_level_cm) %>% #correct data by baro_diver
    select(-baro_level_cm) %>%
    subset(level_cm>-20 & level_cm<120) #remove invalid data
  print("correction_done")
  return(data_correct)
}
