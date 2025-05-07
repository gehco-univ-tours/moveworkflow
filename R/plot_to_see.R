#' plot_to_see
#' a function to plot a graphs to see run off events
#'
#' @param name_plot name of ruisselometre to see
#' @param date_begin date begin of x axes
#' @param date_end date ed of x axes
#' @importFrom dplyr mutate
#' @importFrom dplyr select
#' @importFrom dplyr group_by
#' @importFrom dplyr summarise
#' @importFrom dplyr ungroup
#' @importFrom dplyr arrange
#' @importFrom dplyr left_join
#' @importFrom plotly add_lines
#' @importFrom plotly plot_ly
#' @importFrom plotly add_bars
#' @importFrom plotly layout
#' @importFrom lubridate ymd_hm
#' @importFrom lubridate ymd_hms
#' @importFrom lubridate date
#' @importFrom lubridate hour
#' @importFrom lubridate ymd_h
#' @importFrom lubridate dmy
#'
#' @return a plot
#' @export
#'
plot_to_see <- function(name_plot, date_begin, date_end){
  directory <- system.file("data_ext","data_raw","other_data","features_ruisselometre.csv", package="moveworkflow", mustWork=TRUE)
  data_ruisselometre <- read_file(directory) #charge ruisselometre file
  directory <- system.file("data_ext","data_correct","rain_correct.csv", package="moveworkflow", mustWork=TRUE) #set directory
  data_rain <- read_file(directory) %>%  #charge rain file
    subset(id_site == select_feature(data_ruisselometre,"id_plot","site",name_plot)) %>%
    mutate(date_time = ymd_hms(date_time)) %>%
    group_by(date_hours = paste(date(date_time),hour(date_time))) %>%
    summarise(rain_mm = sum(v_rain_mm), event = unique(id_event)[!is.na(unique(id_event))]) %>%
    ungroup() %>%
    mutate(date_hours=ymd_h(date_hours)) %>%
    arrange(date_hours)
  ### for colors
  directory <- system.file("data_ext","data_raw","other_data","data_ru.csv", package="moveworkflow", mustWork=TRUE) #set directory
  data_ru <- read_file(directory) %>%   #charge ru file
    mutate(date_time = dmy(date_time))
  directory <- system.file("data_ext","data_raw","other_data","dates_to_check.csv", package="moveworkflow", mustWork=TRUE) #set directory
  data_record <- read_file(directory) %>%  #charge dates for data_record
    subset(id_plot == name_plot) %>%
    mutate(date_begin = ymd_hm(date_begin), date_end = ymd_hm(date_end)) %>%
    left_join(data.frame(color = c("green","red","orange"), status = c("working", "not_working", "incomplet")), by="color")
  directory <- system.file("data_ext","data_output","runoff.csv",package="moveworkflow", mustWork=TRUE)
  data_runoff <- read_file(directory) %>%
    subset(id_plot == name_plot) %>%
    select(begin_r, end_r) %>%
    mutate(color = "darkblue") %>%
    mutate(begin_r = ymd_hms(begin_r)) %>%
    mutate(end_r = ymd_hms(end_r))
  ### create the plot
    k <- plot_ly() %>%
        add_lines(data = data_ru,
                  x = ~date_time, y = ~pourc_ru, name = "ru_%", yaxis = 'y1',
                  # black color
                  line = list(color = "black")
        ) %>%
      add_bars(data = data_rain,
               x = ~date_hours, y = ~rain_mm,
               split = ~event, yaxis = 'y2',
               marker = list(
               #dark blue color
               color = 'rgba(0, 0, 255, 0.6)'),
               orientation = 'v') %>%
      layout(
        title = paste("Plot of", name_plot),
        showlegend=FALSE,
        yaxis = list(title = 'pourcentage_RU',
                     range = c(0,1.4)),
        yaxis2 = list(title = 'Rain_mm', overlaying = 'y', side = 'right',
                      autorange = 'reversed',
                      showgrid = FALSE,
                      range = c(50,0)),
        xaxis = list(title = 'Date_time',
                     range = c(date_begin, date_end)),
        barmode = 'overlay',
        shapes = c(c(plot_rectangle(data_record, 0.2, 1.2)),
                   c(plot_rectangle(data_runoff %>%
                           mutate(date_begin = begin_r) %>%
                           mutate(date_end = end_r),0.5,0.9))
        )

      )
}
