#' type_rain
#' a function to know if rain_ev have lead to a runoff_ev
#'
#' @param plot the plot name
#' @importFrom dplyr mutate
#' @importFrom dplyr filter
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 geom_boxplot
#' @importFrom ggplot2 ggtitle
#' @importFrom ggplot2 aes
#'
#' @return a list with a data_frame with rain_ev to imput data and a plot of rain_ev
#' @export
#'
type_rain <- function(plot){
  directory <- system.file("data_ext","data_raw","other_data","features_ruisselometre.csv", package="moveworkflow", mustWork=TRUE) #set directory
  features_plot <- read_file(directory)  #charge features ruisselometre
  #set site
  site <- select_feature(features_plot, "id_plot", "site", plot)
  directory <- system.file("data_ext","data_output","rain_ev.csv", package="moveworkflow", mustWork=TRUE) #set directory
  data_rain_ev <- read_file(directory) %>%  #charge rain_event
    subset(id_site == site) %>%
    mutate(date_begin = ymd_hms(date_begin), date_end=ymd_hms(date_end))
  directory <- system.file("data_ext","data_correct","runoff_measured.csv", package="moveworkflow", mustWork=TRUE) #set directory
  data_runoff <- read_file(directory) %>% #charge data_runoff
    subset(id_plot == plot)
  #set runoff = yes, to rain_event
  for (i in 1:length(rownames(data_rain_ev))){
    if (any(data_rain_ev$id_event[i] == unique(data_runoff$id_rain_event))){
      data_rain_ev$runoff[i] <- "yes"
    }else{
      data_rain_ev$runoff[i] <- "maybe"
    }
  }
  #create two data frame, to sumup yes ou maybe
  data_rain_yes <- data_rain_ev %>%
    subset(runoff == "yes")
  data_rain_maybe <- data_rain_ev %>%
    subset(runoff == "maybe")
  #charge data_date
  directory <- system.file("data_ext","data_raw","other_data","dates_to_check.csv", package="moveworkflow", mustWork=TRUE) #set directory
  data_date <- read_file(directory) %>%
    subset(id_plot == plot & color=="green") %>%
    mutate(date_begin = lubridate::ymd_hm(date_begin), date_end=lubridate::ymd_hm(date_end))
  data_rain_no <- data.frame()
  #set runoff no, to rain_event
  for(i in 1:length(rownames(data_date))){
    data_rain_maybe_sub <- data_rain_maybe %>%
      filter(date_begin >= data_date$date_begin[i] & date_begin <= data_date$date_end[i])
    if(length(data_rain_maybe_sub$date_begin) > 0){
    data_rain_maybe_sub$runoff <- "no"
    data_rain_no <- data_rain_no %>%
      rbind(data_rain_maybe_sub)
    }
  }
  #create a new dataframe, with correct value (no/maybe/yes)
  for (i in 1:length(rownames(data_rain_ev))){
    if (any(data_rain_ev$id_event[i] == unique(data_rain_no$id_event))){
      data_rain_ev$runoff[i] <- "no"
    }else if (any(data_rain_ev$id_event[i] == unique(data_runoff$id_rain_event))){
      data_rain_ev$runoff[i] <- "yes"
    }else{
      data_rain_ev$runoff[i] <- "maybe"
    }
  }
  data_rain_ev <- data_rain_ev %>%
    mutate(months = months(date_begin)) %>%
    mutate(date = lubridate::date(date_begin))
  ##save file
  save_directory <- system.file("data_ext","data_output",package="moveworkflow",mustWork=TRUE)
  name_file <- paste(plot,"_rain_event.csv",sep="")
  save_file(save_directory,data_rain_ev,c("date_begin","date_end"),name_file) #save with
  k <- ggplot(data=data_rain_ev, aes(x=runoff , y=h_rain_mm))+
    geom_boxplot()+
    ggtitle(label=paste(plot,"rain_event, leading to runoff"))
  min_value <- min(data_rain_ev$h_rain_mm[data_rain_ev$runoff == "yes"])
  data_rain_ev <- data_rain_ev %>%
    subset(runoff == "maybe") %>%
    subset(h_rain_mm >= min_value)
  print(k)
  return(data_rain_ev)
}
