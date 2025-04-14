#' select_feature
#' a function select a features with a match
#'
#' @param select_col name of colonne where is the feature
#' @param match_col name of colonne to match
#' @param feature name of the feature to match
#' @param data_frame name of the data_frame
#' @importFrom dplyr mutate
#'
#' @return a value
#' @export
#'
select_feature<- function(data_frame, select_col, match_col, feature){
  value <- data_frame[match_col][data_frame[select_col] == feature]
  return(value)
}
