#' add_time_if_missing
#' a function which add time to dates of midnight
#'
#' @param date a date
#'
#' @return a date
#' @export
#'
#' @examples
#' date <- c("2024-12-03 14:50:01", "2024-12-03", "2024-12-03 14:50:24")
#' lapply(date, add_time_if_missing)
add_time_if_missing <- function(date) {
  if (nchar(date) == 10) {
    date <- paste(date, "00:00:00")
  }
  return(date)
}
