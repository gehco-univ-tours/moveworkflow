#' match_date
#' a function to match a rain event with a runoff event
#'
#' @param begin_r a date_time
#' @param date_time_rain a vector of date_time
#'
#' @return a date_time matched
#' @export
#'
match_date <- function(begin_r, date_time_rain){ # function to match a r event with a rain event
  date_time_rain <- date_time_rain[date_time_rain<=begin_r]
  if(length(date_time_rain)==0){
    k <- NA
  }else{
    k <- date_time_rain[which.min(abs(difftime(date_time_rain, begin_r)))]
  }
  return(k)
}
