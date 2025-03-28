#' Set_file_path
#' a function to help writting a file path
#'
#' @param directory the path of package's root
#' @param folders_names a vector of folders names
#'
#' @return a path using folders names
#' @export
#'
#' @examples
#' directory <- system.file(package="moveworkflow", mustWork=TRUE)
#' file_names <- c("inst","data_ext","data_raw","A_1_diver")
#' set_file_path(directory, file_names)
set_file_path <- function(directory, folders_names){
  file_path <- paste("/",folders_names, collapse = "/",sep="")
  file_path <- paste(directory,file_path, sep="")
  return(file_path)
}
