#' add_column
#' a function to add a column to a data frame
#'
#' @param data_frame data_frame to add column names
#' @param col_names a character vector with names of columns to add
#'
#' @return a data_frame with news columns
#' @export
#'
add_column <- function(data_frame, col_names){
  for(i in col_names){
    data_frame[[i]] <- NA
  }
  return(data_frame)
}
