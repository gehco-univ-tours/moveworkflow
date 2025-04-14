## code to prepare `data` dataset goes here

#' cut_data
#' a function cut tipping dataframe into event
#'
#' @param name_plot name of ruisselometre to display
#' @importFrom dplyr mutate
#' @importFrom plotly plot_ly
#' @importFrom plotly add_lines
#' @importFrom plotly add_bars
#' @importFrom plotly layout
#'
#' @return a plot
#' @export
#'
MTI = hours(6)
TB2V = 6
cut_data <- function(data_frame,MTI,TB2V)
  data_ev = data.frame()
k = 1
line = 0
col = 1
while(!is.na(data_rain$rain_fall[k])){
  while(!is.na(data_rain[k,2]) && data_rain[k,2] == 0){ # serching a positive value
    k = k + 1
  }
  if(!is.na(data_rain$rain_fall[k]) && data_rain$rain_fall[k]>0){
    line = line+1
    data_ev[line,col] <- data_rain[k,2] # write the first value on a line
    rownames(data_ev)[line]<- as.character(data_rain[k,1])
    time_last_value = data_rain[k,1]
    k=k+1
    col=col+1
    t = data_rain[k,1]-time_last_value  # Calculate time between two values
    while(t<=MTI && !is.na(t)){ # MTI = minimum time inter-event
      if (data_rain[k,2] == 0){ # if rain = 0, write value and update t
        data_ev[line,col] = data_rain[k,2]
        k=k+1
        col=col+1
        t = data_rain[k,1] - time_last_value
      } else { # if rain > 0, write value, update time last value dans update t
        data_ev[line,col] = data_rain[k,2]
        time_last_value = data_rain[k,1]
        k=k+1
        col=col+1
        t = data_rain[k,1] - time_last_value
      }
    }
    col=1
    i=data_rain[k,1]
    remove(t)
    remove(time_last_value)
  }
}








