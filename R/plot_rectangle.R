#' plot_rectangle
#' a function to add a rectangle to a plotly
#'
#' @param data_frame data_frame to add rectangle
#' @param max_x hight of rectangle
#'
#' @return a list to add to plotly
#' @export
#'
plot_rectangle <- function (data_frame, max_x){
  l=0
  list_list <- list()
  for (i in 1:length(rownames(data_frame))){
    color <- data_frame$color[i]
    x0 <- data_frame$date_begin[i]
    x1 <- data_frame$date_end[i]
    k<-list(
      type = "rect",
      y0 = 0,
      y1 = max_x,
      fillcolor=color,
      line=list(color=color),
      x0 = x0,
      x1 = x1,
      opacity = 0.2
    )
    l=l+1
    list_list[[l]]<-k
  }
  return(list_list)
}
