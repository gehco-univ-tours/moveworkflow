#' plot_to_see
#' a function to plot a graphs to see run off events
#'
#' @param name_plot name of ruisselometre to see
#' @param date_begin date begin of x axes
#' @param date_end date ed of x axes
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' @importFrom plotly add_lines
#' @importFrom plotly plot_ly
#' @importFrom plotly add_bars
#' @importFrom plotly layout
#'
#' @return a plot
#' @export
#'
plot_to_see <- function(name_plot, date_begin, date_end){
  directory <- system.file("data_ext","data_raw","other_data","features_ruisselometre.csv", package="moveworkflow", mustWork=TRUE)
  data_ruisselometre <- read_file(directory)
  directory <- system.file("data_ext","data_correct","rain_correct.csv", package="moveworkflow", mustWork=TRUE) #set directory
  data_rain <- read_file(directory) %>%  #charge rain file
    subset(id_site == select_feature(data_ruisselometre,"id_plot","site",name_plot)) %>%
    mutate(date_time = ymd_hms(date_time))
  directory <- system.file("data_ext","data_correct","diver_correct.csv", package="moveworkflow", mustWork=TRUE) #set directory
  data_diver <- read_file(directory) %>%  #charge diver file
    subset(id_plot == name_plot) %>%
    mutate(date_time = ymd_hms(date_time))
  directory <- system.file("data_ext","data_output","runoff.csv",package="moveworkflow", mustWork=TRUE)
  data_runoff <- read_file(directory) %>%
    subset(id_plot == name_plot) %>%
    select(begin_diver, end_diver) %>%
    mutate(color = "red") %>%
    subset(!is.na(begin_diver)) %>%
    mutate(date_begin = ymd_hms(begin_diver)) %>%
    mutate(date_end = ymd_hms(end_diver))
    k <- plot_ly() %>%
        add_lines(data = data_diver,
                  x = ~date_time, y = ~level_cm, name = name_plot, yaxis = 'y1',
                  # black color
                  line = list(color = "black")
        ) %>%
      add_bars(data = data_rain,
               x = ~date_time, y = ~v_rain_mm,
               split = ~id_event, yaxis = 'y2',
               marker = list(
               #dark blue color
               color = 'rgba(0, 0, 255, 0.6)'),
               orientation = 'v') %>%
      layout(
        title = paste("Plot of", name_plot),
        yaxis = list(title = 'Diver_level_cm',
                     range = c(0,120)),
        yaxis2 = list(title = 'Rain_mm', overlaying = 'y', side = 'right',
                      autorange = 'reversed',
                      showgrid = FALSE,
                      range = c(50,0)),
        xaxis = list(title = 'Date_time',
                     range = c(date_begin, date_end)),
        barmode = 'overlay',
        shapes = c(plot_rectangle(data_runoff,100))
      )
}
