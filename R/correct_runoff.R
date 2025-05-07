#' correct_runoff
#' a function to combined runoff event or rain event
#'
#' @param plot_mane name of the plot to correct
#' @param num_event a character vector of the id_event to combined
#' @param data the data frame to correct
#'
#' @return a data_frame with news lines
#' @export
#'
correct_runoff <- function(data, plot_name, num_event){
  ##calculate runoff event
  data_runoff <- data %>% #charge runoff file and delete line to combine
    mutate(begin_r = ymd_hms(begin_r)) %>%
    mutate(end_r = ymd_hms(end_r)) %>%
    subset(!(data_runoff$id_plot == plot_name & data_runoff$id_rain_event == num_event))
  directory <- system.file("data_ext","data_compile","runoff.csv", package="moveworkflow", mustWork=TRUE) #set directory
  data_correct <- read_file(directory) %>% #charge runoff event to combine
    subset(id_plot == plot_name) %>%
    subset(id_rain_event == num_event) %>%
    mutate(begin_r = ymd_hms(begin_r)) %>%
    mutate(end_r = ymd_hms(end_r))
  #Calculate new features
  new_line <- data_correct[1,]
  new_line$begin_r = min(data_correct$begin_r, na.rm=TRUE)
  new_line$end_r = max(data_correct$end_r, na.rm=TRUE)
  new_line$v_runoff_l = sum(data_correct$v_runoff_l, na.rm=TRUE)
  new_line$inc_abs_v_runoff = sum(data_correct$inc_abs_v_runoff, na.rm=TRUE)
  new_line$inc_rel_v_runoff = (new_line$inc_abs_v_runoff/new_line$v_runoff_l)*100
  #Add new line to runoff data frame
  data_runoff <- data_runoff %>%
    rbind(new_line)
  return(data_runoff)
  }
