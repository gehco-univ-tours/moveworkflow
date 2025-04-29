#' save_file
#' a function to save a dataframe in csv with project features
#'
#' @param save_directory a folder directory
#' @param data_frame the data frame to save
#' @param date_time a character vector with POSIX.CT column names
#' @param name_file the name of the file to save
#' @importFrom dplyr mutate
#' @importFrom dplyr all_of
#'
#' @return a .csv
#' @export
#'
save_file <- function(save_directory, data_frame, date_time, name_file){
  data_frame <- data_frame %>%
    mutate(across(all_of(date_time),~format(.,"%Y-%m-%d %H:%M:%S"))) #put the POSIX.CT value in character
  write.table(data_frame,paste(save_directory,"/",name_file, sep=""), row.names = FALSE, sep = ";", dec=".", fileEncoding="latin1")
  print("file saved")
}
