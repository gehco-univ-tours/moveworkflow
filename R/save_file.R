#' save_file
#' a function to save dataframe in csv with correct features
#'
#' @param save_directory a folder directory
#' @param data_frame the data frame to save
#'
#' @return a .csv
#' @export
#'
save_file <- function(save_directory, data_frame){
  write.table(data_frame,paste(save_directory,"/",basename(directory),"_combine.csv", sep=""), row.names = FALSE, sep = ";", dec=".", fileEncoding="latin1")
  print("file saved")
}
