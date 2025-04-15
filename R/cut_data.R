#' cut_data
#' a function to cut tipping data into event
#'
#' @param data_frame to data frame to cut
#' @param MTI a duration corresponding to minimum time inter-event
#' @importFrom dplyr mutate
#'
#' @return a raw event data_frame
#' @export
#'
cut_data <- function(data_frame,MTI){
  data_ev = data.frame()
data_ev <- data_ev %>%
  mutate("id_event" =NA) %>%
  mutate("date_begin" = NA) %>%
  mutate("date_end" = NA) %>%
  mutate("value" = NA)
k = 1
line = 0
col = 1
while(k < length(rownames(data_frame))){
  while(data_frame[k,2] == 0 && !is.na(data_frame[k,2])){ # serching a positive value
    k = k + 1
  }
  if(data_frame[k,2]>0 && !is.na(data_frame[k,2])){
    line = line+1
    col=5
    data_ev[line, "date_begin"] <- data_frame$date_time[k]
    data_ev[line, "id_event"] <- paste("event","_",line,sep="")
    data_ev[line,col] <- data_frame[k,2] # write the first value on a line
    time_last_value = data_frame$date_time[k]
    t = difftime(data_frame$date_time[k+1],time_last_value) # Calculate time between two values
    k=k+1
    col=col+1
    while(t <= MTI && !is.na(t)){# MTI = minimum time inter-event
      if (data_frame[k,2] == 0){ # if rain = 0, write value and update t
        data_ev[line,col] = data_frame[k,2]
        t = difftime(data_frame$date_time[k+1],time_last_value)
        k=k+1
        col=col+1
      } else { # if rain > 0, write value, update time last value dans update t
        data_ev[line,col] = data_frame[k,2]
        time_last_value = data_frame$date_time[k]
        t = difftime(data_frame$date_time[k+1],time_last_value)
        k=k+1
        col=col+1
      }
    }
  }
  data_ev[line, "date_end"]<-data_frame$date_time[k-1]
}
data_ev <- data_ev %>%
  mutate(date_begin = ymd_hms(date_begin), date_end = ymd_hms(date_end))
return(data_ev)
}
