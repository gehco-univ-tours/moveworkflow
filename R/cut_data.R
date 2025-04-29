#' cut_data
#' a function to cut tipping data into event
#'
#' @param data_frame to data frame to cut
#' @param MIT a duration corresponding to minimum time inter-event
#' @importFrom dplyr mutate
#'
#' @return the input data frame with event and a data frame of event
#' @export
#'
cut_data <- function(data_frame,MIT){
  data_ev = data.frame()
data_ev <- data_ev %>%
  mutate("id_event" =NA) %>%
  mutate("date_begin" = NA) %>%
  mutate("date_end" = NA) %>%
  mutate("value" = NA) #create the event dataframe
vector_date_time <- format(data_frame$date_time,"%Y-%m-%d %H:%M:%S")
k = 1
line = 0
col = 1
while(k < length(rownames(data_frame))){
  while(data_frame[k,2] == 0 && !is.na(data_frame[k,2])){ # searching a positive value
    k = k + 1
  }
  print("positive value found")
  if(data_frame[k,2]>0 && !is.na(data_frame[k,2])){
    line = line+1
    col=5
    data_ev[line, "date_begin"] <- vector_date_time[k] #write begin of the event
    data_ev[line, "id_event"] <- paste("event","_",line,sep="") #write id_number of event
    data_ev[line,col] <- data_frame[k,2] # write the first value on a line
    time_last_value = data_frame$date_time[k]
    t = difftime(data_frame$date_time[k+1],time_last_value) # Calculate time between the last positive value and the value check
    k=k+1
    col=col+1
    while(t <= MIT && !is.na(t)){# check if time between the last positive value and the value check is >= MIT. If not, it's a different event
      if (data_frame[k,2] == 0){ # if rain = 0, write value and update t
        data_ev[line,col] = data_frame[k,2]
        t = difftime(data_frame$date_time[k+1],time_last_value)
        k=k+1
        col=col+1
      } else { # if rain > 0, write value, update t and time last value positive
        data_ev[line,col] = data_frame[k,2]
        time_last_value = data_frame$date_time[k]
        t = difftime(data_frame$date_time[k+1],time_last_value)
        k=k+1
        col=col+1
      }
    }
    print(paste("event",line,"done"))
    print("change event")
  }
  data_ev[line, "date_end"]<- vector_date_time[k-1] #write the last date_time positive value
}
#processing data_event
data_ev <- data_ev %>%
  mutate(date_begin = ymd_hms(date_begin), date_end = ymd_hms(date_end))
#write events in the input data_frame
print("events writting in data_frame")
i=1
  for (i in 1:nrow(data_ev)){
    print(data_ev$id_event[i])
    data_frame$id_event[data_frame$date_time>=data_ev$date_begin[i] & # Add event n° in data frame
                      data_frame$date_time<=data_ev$date_end[i]] <- data_ev$id_event[i]
  }
#create a list with the two data frame to return
list <- list(data_ev,data_frame)
return(list)
}
