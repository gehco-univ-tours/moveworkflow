#' type_rain
#' a function to know if rain_ev have lead to a runoff_ev
#'
#' @param plot the plot name
#' @importFrom dplyr mutate
#' @importFrom dplyr filter
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 geom_boxplot
#' @importFrom ggplot2 ggtitle
#' @importFrom lubridate ymd
#'
#' @return a list with a data_frame with rain_ev to imput data and a plot of rain_ev
#' @export
data_10_days <- function(plot_name){
plot="A_1"
date = seq.Date(ymd("2024_04_01"), ymd("2025_03_31"), by = "days")
data_days <- data.frame(date_time = date)
##charge feature ruisselometre
directory <- system.file("data_ext","data_raw","other_data","features_ruisselometre.csv", package="moveworkflow", mustWork=TRUE) #set directory
features_plot <- read_file(directory)  #charge features ruisselometre
##add v_rain_mm
site <- select_feature(features_plot, "id_plot", "site", plot)
directory <- system.file("data_ext","data_output","rain_ev.csv", package="moveworkflow", mustWork=TRUE) #set directory
data_rain_ev <- read_file(directory) %>%  #charge rain
  subset(id_site == site) %>%
  mutate(date_begin = ymd_hms(date_begin)) %>%
  mutate(date = date(date_begin)) %>%
  group_by(date) %>%
  summarise(v_rain_mm = sum(v_rain_mm))
data_days <- data_days %>%
  left_join(data_rain_ev, by=c("date_time" = "date"))
##add v_runoff_mm
directory <- system.file("data_ext","data_output","runoff.csv", package="moveworkflow", mustWork=TRUE) #set directory
data_runoff <- read_file(directory) %>% #charge data_runoff
  subset(id_plot == plot) %>%
  mutate(date = date(ymd_hms(begin_r))) %>%
  group_by(date) %>%
  summarise(v_runoff_mm = sum(v_runoff_mm))
data_days <- data_days %>%
  left_join(data_runoff, by=c("date_time" = "date"))
##add cu_input and TS (don't work)
directory <- system.file("data_ext","data_raw","other_data","data_ITK.csv")
data_ITK <- read_file(directory)
##add flux : MES and CU
}
