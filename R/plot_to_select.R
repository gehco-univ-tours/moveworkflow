#' plot_to_select
#' a function to visual select run_off event
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
plot_to_select <- function(name_plot){
  directory <- system.file("data_ext","data_correct","diver_correct.csv",package="moveworkflow", mustWork=TRUE)
  data_ruisselometre <- read_file(system.file("data_ext","data_raw","other_data","features_ruisselometre.csv",package="moveworkflow", mustWork=TRUE)) #charge feature ruisselometre
  data_diver <- read_file(directory) %>%
    subset(id_plot == name_plot) %>%
    mutate(date_time = ymd_hms(date_time)) #charge data diver
  name_site <- select_feature(data_ruisselometre,"id_plot","site",name_plot)
  directory <- system.file("data_ext","data_correct","rain_correct.csv",package="moveworkflow", mustWork=TRUE)
  data_pluvio <- read_file(directory) %>%
    subset(id_site == name_site) %>%
    mutate(date_time = ymd_hms(date_time)) #charge data rain
  k <- plot_ly() %>% #add volume diver
    add_lines(data = data_diver, x = ~date_time, y = ~level_cm, name = 'diver_level_cm', yaxis = 'y1',
              # black color
              line = list(color = 'rgba(0, 0, 0, 0.6)')
    ) %>% #add rain
    add_bars(data = data_pluvio, x = ~date_time, y = ~v_rain_mm, name = 'Rain_mm', yaxis = 'y2',
             marker = list(
               # dark blue color
               color = 'rgba(0, 0, 255, 0.6)'),
             orientation = 'v') %>%
    layout(
      title = paste("Volume variation in", name_plot),
      yaxis = list(title = 'diver_level_cm'#,
                   #range = c(0,100)
      ),
      yaxis2 = list(title = 'Rain_mm', overlaying = 'y', side = 'right',
                    autorange = 'reversed',
                    showgrid = FALSE#,
                    #range = c(max(Amboise_rain$rain_fall), 0)
      ),
      xaxis = list(title = 'Date_time'),
      barmode = 'overlay'
    )
  print(k)
}
