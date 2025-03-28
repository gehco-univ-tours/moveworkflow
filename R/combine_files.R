#' Combine_files
#' a function witch combine dataframes with same setting
#'
#' @param directory a directory with files
#' @param type_file the end of files (ex .CSV or .txt)
#'
#' @return a dataframe of combined files
#' @importFrom dplyr distinct
#' @importFrom dplyr arrange
#' @importFrom dplyr mutate
#' @export
#'
combine_files <- function (directory, type_file){
  file_paths <- list.files(path = directory, pattern = paste("\\.",type_file,"$",sep=""), full.names = TRUE)
  if(length(feature_file) > 0){
    file_list <- list()
    for (file in file_paths){
      print(paste("Selected file :", file))
      n_row <- length(readLines(file))
      data_file <- read.table(file, header=feature_file$header, sep=feature_file$separator, dec=feature_file$decimal,
                              skip = feature_file$skiprows_max, nrows = n_row-feature_file$skiprows_max+feature_file$last_row,
                              fileEncoding = feature_file$encoding)
      data_file[[feature_file$name_datetime]] <- convert_date_posixct(data_file[feature_file$name_datetime][,1])
      data_file <- data_file[1:3]
      colnames(data_file) <- feature_file$col_name
      file_list <- append(file_list, list(data_file))
    }
    if (length(file_list) > 0){
      compiled_data <- do.call(rbind, file_list)
      compiled_data <- compiled_data %>%
        distinct() %>%
        mutate(date_time = sapply(date_time, add_time_if_missing)) %>%
        arrange(date_time)
    }else{
      print("Set file list failed")
    }
    write.table(compiled_data, paste(basename(directory),"_combine.csv", sep=""), row.names = FALSE, sep = ";", dec=".", fileEncoding = "latin1")
    print("files_combined")
  }else{
    print(paste("No", type_file, "files found"))
  }
}
