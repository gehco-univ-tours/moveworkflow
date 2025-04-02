#' Combine_files
#' a function witch combine dataframes with same setting
#'
#' @param directory a directory with files
#' @param type_file the end of files (ex .CSV or .txt)
#'
#' @return a dataframe of combined files
#' @importFrom dplyr arrange
#' @importFrom dplyr sym
#' @importFrom dplyr bind_rows
#' @export
#'
combine_files <- function (directory, type_file){
  file_paths <- list.files(path = directory, pattern = paste("\\.",type_file,"$",sep=""), full.names = TRUE)
  if(length(feature_file) > 0){
    file_list <- list()
    file = file_paths[1]
    for (file in file_paths){
      print(paste("Selected file :", file))
      n_row <- length(readLines(file))
      data_file <- read.table(file, header=feature_file$header, sep=feature_file$separator, dec=feature_file$decimal,
                              skip = feature_file$skiprows_max, nrows = n_row-feature_file$skiprows_max+feature_file$last_row,
                              fileEncoding = feature_file$encoding)
      data_file[[feature_file$name_datetime]] <- sapply(data_file[feature_file$name_datetime][,1], FUN=add_time_if_missing)
      data_file[[feature_file$name_datetime]] <- convert_date_posixct(data_file[feature_file$name_datetime][,1])
      data_file$id_file <- paste(strsplit(basename(file),"_")[[1]][1],strsplit(basename(file),"_")[[1]][2],sep="_")
      file_list <- append(file_list, list(data_file))
    }
    if (length(file_list) > 0){
      compiled_data <- do.call(bind_rows, file_list)
      compiled_data <- compiled_data %>%
      arrange(!!sym(feature_file$name_datetime))
    }else{
      print("Set file list failed")
    }
    return(compiled_data)
    print("files_combined")
  }else{
    print(paste("No", type_file, "files found"))
  }
}
