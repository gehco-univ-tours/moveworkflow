combin_files <- function (directory, feature_file){
  file_paths <- list.files(path = directory, pattern = paste("\\.",type_file,"$",sep=""), full.names = TRUE)
  if(length(feature_file > 0)){
    file_list <- list()
    for (file in file_paths){
      print(paste("Selected file :", file))
      n_row <- length(readLines(file))
      data_file <- read.table(file, header=feature_file$header, sep=feature_file$separator, dec=feature_file$decimal,
                              skip = feature_file$skiprows_max, nrows = n_row-feature_file$skiprows_max,
                              fileEncoding = feature_file$encoding)
      data_file[[feature_file$datetime_field_output]] <- convert_date_posixct(data_file[feature_file$datetime_field_output][,1])
      data_file <- data_file[1:3]
      colnames(data_file) <- feature_file$col_name
      file_list <- append(file_list, list(data_file))
    }
    if (length(file_list) > 0){
      compiled_data <- do.call(rbind, file_list)
      compiled_data <- compiled_data %>%
        distinct() %>%
        arrange(date_time)
    }else{
      print("Set file list failed")
    }
    write.table(compiled_data, paste(basename(directory),"_combine_W.csv", sep=""), row.names = FALSE, sep = ";", dec=".", fileEncoding = "latin1")
    print("files_combined")
  }else{
    print(paste("No", type_file, "files found"))
  }
}
