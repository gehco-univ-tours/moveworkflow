#' read_file
#' a function to read csv dateframe with correct features
#'
#' @param read_directory the file directory
#'
#' @return a dataframe
#' @export
#'
read_file <- function(read_directory){
  read.csv(read_directory, header=TRUE, sep=";",dec=".")
}
