#' type_files
#' a function which allows to set preset parameters when download rowdataframe
#'
#' @param type_file two choice, "txt" or "CSV"
#'
#' @return a list of preset files parameters
#' @export
#'
#' @examples
#' file <- "txt"
#' type_files(file)

type_files <- function(type_file){
  carac_file <- list()
  if(type_file == "CSV"){
    header <- TRUE
    separator <- ";"
    skiprows_max <- 51
    decimal <- ","
    encoding <- "latin1"
    name_datetime = "Date.time"
    col_name <- c("date_time", "level_cm", "temp_c")
  }else if(type_file == "txt"){
    header <- TRUE
    separator <- ";"
    skiprows_max <- 1
    decimal <- "."
    encoding <- "UFT-8"
    name_datetime <- "Date.Heure..GMT.01.00"
    col_name <- c("row_name", "date_time", "value")
  }else{
    print("type_file not found")
  }
  carac_file[["header"]] <- header
  carac_file[["separator"]] <- separator
  carac_file[["skiprows_max"]] <- skiprows_max
  carac_file[["decimal"]] <- decimal
  carac_file[["encoding"]] <- encoding
  carac_file[["name_datetime"]] <- name_datetime
  carac_file[["col_name"]] <- col_name
  return(carac_file)
}
