#' second_correct
#' a function to combined rain event
#'
#' @param data the data frame to correct
#' @importFrom lubridate ymd_hms
#' @importFrom dplyr mutate
#' @importFrom dplyr filter
#'
#' @return a data_frame with news CR
#' @export
#'
second_correct <- function(data){
  directory <- system.file("data_ext","data_correct","rain_ev.csv", package="moveworkflow", mustWork=TRUE) #set directory
    data_rain <- read_file(directory) %>%
      mutate(date_begin = ymd_hms(date_begin)) %>%
      mutate(date_end = ymd_hms(date_end))
  for(i in 1:length(rownames(data_runoff))){
    if(data_runoff$precision_r[i] == "good"){
      begin_r <- data_runoff$begin_r[i]
      end_r <- data_runoff$end_r[i]
      site <- data_runoff$id_site[i]
      plot <- data_runoff$id_plot[i]
      data_rain_sub <- data_rain %>%
        subset(id_site == site) %>%
        filter(date_begin <= end_r) %>%
        filter(date_begin >= begin_r)
      rain_sum <- data_runoff$h_rain_mm[i]+sum(data_rain_sub$h_rain_mm)
      pourc <- rain_sum/data_runoff$h_rain_mm[i]
      if(pourc>1.15){
        data_runoff$new_h_rain_mm[i] <- rain_sum
        data_runoff$date_end_rain[i] <- format(max(data_rain_sub$date_end),"%Y-%m-%d %H:%M:%S")
        data_runoff$duration_rain_h[i] <- as.numeric(difftime(data_runoff$date_end_rain[i], data_runoff$date_begin_rain[i], units="hours"))
        data_runoff$Imax_mm_h[i] <- NA
        data_runoff$Imean_mm_h[i] <- NA
        data_runoff$new_CR[i] <- (data_runoff$h_runoff_mm[i]/data_runoff$new_h_rain_mm[i])*100
        data_runoff$drainage_h[i] <- as.numeric(difftime(data_runoff$end_r[i], data_runoff$date_end_rain[i], units="hours"))
      }else{
        data_runoff$new_h_rain_mm[i] <- NA
        data_runoff$new_CR[i] <- NA
      }
    }else{
    data_runoff$new_h_rain_mm[i] <- NA
    data_runoff$new_CR[i] <- NA
    }
  }
    return(data_runoff)
}
