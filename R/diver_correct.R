#' diver_correct
#' a function to correct dievr level, with their baro_diver
#'
#' @param name_plot a name plot to correct
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
  directory <- system.file("data_ext","data_compile","diver_combine.csv",package="moveworkflow", mustWork=TRUE)
  data_ruisselometre <- read_file(system.file("data_ext","data_raw","other_data","features_ruisselometre.csv",package="moveworkflow", mustWork=TRUE))
  data_diver <- read_file(directory) %>%
    subset(id_plot == name_plot) %>%
    mutate(date_time = ymd_hms(date_time))
  name_baro <- paste("Baro",select_feature(data_ruisselometre,"id_ruisselometre","site",name_plot), sep="_")
  data_baro <- read_file(directory) %>%
    subset(id_plot == name_baro) %>%
    select(date_time, level_cm) %>%
    rename(baro_level_cm = level_cm) %>%
    mutate(date_time = ymd_hms(date_time))
  data_correct <- data_diver %>%
    left_join(data_baro, by = "date_time") %>%
    mutate(level_cm = level_cm - baro_level_cm) %>%
    select(-baro_level_cm) %>%
    subset(level_cm>-20 & level_cm<100)
  return(data_correct)
}
