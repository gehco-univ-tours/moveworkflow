#' flow_runoff
#' a function to create a data frame with the flow of runoff
#'
#' @param name_plot a name plot to calculculate the flow
#' @importFrom dplyr select
#' @importFrom dplyr left_join
#' @importFrom dplyr mutate
#' @importFrom lubridate ymd_hms
#'
#' @return a data_frame
#' @export
#'
flow_runoff <- function (name_plot){
  #charge and filter data runoff_event
directory <- system.file("data_ext","data_raw","other_data","level_variation_event.csv",package="moveworkflow", mustWork=TRUE)
data_runoff_event <- readr::read_csv2(directory) %>%
  subset(id_ruisselometre == "A_1") %>%
  subset((precision_r == "good" | precision_r == "medium") & sonde_diver == "yes") %>%
  mutate(begin_diver = ymd_hm(begin_diver), end_diver = ymd_hm(end_diver))
  #charge and filter data diver
directory <- system.file("data_ext","data_correct","diver_correct.csv",package="moveworkflow", mustWork=TRUE)
data_diver <- read_file(directory) %>%
  subset(id_plot == "A_1") %>%
  mutate(date_time = ymd_hms(date_time))
  #cut diver data, to juste select runoff event
data_runoff <- data.frame()
for (i in 1:length(data_runoff_event$begin_diver)){
  date_begin <- data_runoff_event$begin_diver[i]
  date_end <- data_runoff_event$end_diver[i]
  data_select <- data_diver %>%
    subset(date_time < date_end & date_time > date_begin)
  data_select$id_runoff <- data_runoff_event$id_run_off_ev[i]
  data_runoff <- rbind(data_runoff,data_select)
}
  #correct data diver with offset and z_diver
directory <- system.file("data_ext","data_raw","other_data","features_sensor.csv",package="moveworkflow", mustWork=TRUE)
sensor <- read_file(directory)
data_runoff <- data_runoff %>%
  left_join(sensor[c("id_sensor","value")], by="id_sensor") %>%
  mutate(volume_l = (level_cm - value)*11.2) %>%
  select(-value)
  #calculate a flow
vector <- c(data_runoff$volume_l[2:length(data_runoff$volume_l)],0)
data_runoff <- data_runoff %>%
  mutate(volumeX2_l = vector) %>%
  mutate(flow_l_min = volumeX2_l-volume_l)
  #calculate a flow cumul
data_runoff <- data_runoff %>%
  mutate(v_cumul_l = cumsum(data_runoff$flow_l_min)) %>%
  subset(flow_l_min>-700)
}
