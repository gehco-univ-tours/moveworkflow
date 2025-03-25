#' Convert_date_posixct
#' a function witch allows to detected differents dates formats, used in row_data MOVE
#'
#' @param date a vecteur of date_time with the same date format
#'
#' @return a vecteur of date_time in posixct
#' @importFrom lubridate ymd_hms
#' @importFrom lubridate dmy_hm
#' @importFrom lubridate dmy_hms
#' @importFrom base grep
#' @importFrom base any
#' @export
#'
#' @examples
#' date <- c("03/12/24 14:50:01", "03/12/24 14:50:12", "03/12/24 14:50:24")
#' convert_date_posixct(date)

convert_date_posixct <- function(date){
  if (any(grepl("^\\d{4}/\\d{2}/\\d{2} \\d{2}:\\d{2}:\\d{2}$", date))) {
    posix_date <- ymd_hms(date)
  } else if (any(grepl("^\\d{2}/\\d{2}/\\d{4} \\d{2}:\\d{2}$", date))) {
    posix_date <- dmy_hm(date)
  } else if (any(grepl("^\\d{2}/\\d{2}/\\d{2} \\d{2}:\\d{2}:\\d{2}$", date))) {
    posix_date <- dmy_hms(date)
  }else {
    posix_date <- "failed to transforme"
  }

  return(posix_date)
}
