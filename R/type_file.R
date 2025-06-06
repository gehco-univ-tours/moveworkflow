#' type_files
#' a function which allows to preset some parameters for a dataframe download
#'
#' @param type_file Three choices : "txt" or "CSV" or "csv"
#'
#' @return a list of preset files parameters
#' @export
#'
#' @examples
#' file <- "txt"
#' type_files(file)
type_files <- function(type_file){
  feature_file <- list()
  if(type_file == "CSV"){
    header <- TRUE
    separator <- ";"
    skiprows_max <- 51
    last_row <- -2
    decimal <- ","
    encoding <- "latin1"
    name_datetime = "Date.time"
    col_name <- c("date_time", "level_cm", "temp_c","id_sensor")
  }else if(type_file == "txt"){
    header <- TRUE
    separator <- ";"
    skiprows_max <- 1
    last_row <- 0
    decimal <- ","
    encoding <- "latin1"
    name_datetime <- "Date.Heure..GMT.01.00"
    col_name <- c("row_name", "date_time", "value","id_sensor")
  }else if(type_file == "csv"){
    header <- TRUE
    separator <- ";"
    skiprows_max <- 0
    last_row <- 0
    decimal <- "."
    encoding <- "latin1"
    name_datetime <- "date_time"
    col_name <- c()
  }else{
    print("type_file not found")
  }
  feature_file[["header"]] <- header
  feature_file[["separator"]] <- separator
  feature_file[["skiprows_max"]] <- skiprows_max
  feature_file[["decimal"]] <- decimal
  feature_file[["encoding"]] <- encoding
  feature_file[["name_datetime"]] <- name_datetime
  feature_file[["col_name"]] <- col_name
  feature_file[["last_row"]] <- last_row
  return(feature_file)
}
