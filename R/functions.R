#' Get urls for monthly gridded min and max temp
#'
#' @return urls for file download; function is hard coded for air temp min/max and precip
#' @export
#'
get_monthly_gridded_indices <- function(){

    # gridIndex <- getExportedValue(ns = "rdwd", "gridIndex")
    gridIndex <- rdwd:::gridIndex


    index_mean <- grep("grids_germany_monthly_air_temp_mean",   gridIndex, value=TRUE)
    index_max <- grep("grids_germany_monthly_air_temp_max",   gridIndex, value=TRUE)
    index_min <- grep("grids_germany_monthly_air_temp_min",   gridIndex, value=TRUE)
    index_precip <- grep("grids_germany_monthly_precipitation",   gridIndex, value=TRUE)
    index_evapo_p <- grep("grids_germany_monthly_evapo_p",   gridIndex, value=TRUE)



    return(list(temp_mean = index_mean,
                temp_max = index_max,
                temp_min = index_min,
                precip = index_precip
                evapo_p = index_evapo_p))


}

#' Get time info from file paths
#'
#' @param index character, url paths or file names for rdwd download / read-in
#'
#' @return Matrix with time info from input files/urls
#' @export
#'
index_year_mon <- function(index){

    time_string <- stringr::str_extract(string = index,
                                        pattern = "[0-9]{6}")

    year <- substr(time_string, 1,4)
    month <- as.numeric(substr(time_string, 5,7))

    return(cbind(year = year, month_n = month, month_char = month.abb[month]))
    # return(time_string)


}







#' Download gridded data based on indices
#'
#' @param index url file paths for download
#' @param dir_path folder to download files to
#' @param dl_sleep numeric, sys.sleep for download, so ftp doesn't kick; random number between 0 and \code{dl_sleep} is used.
#'
#' @return file paths
#' @export
#'
download_monthly_gridded <- function(index,
                                     dir_path,
                                     dl_sleep = 1){

    file_paths <- rdwd::dataDWD(file = index,
                  base=rdwd::gridbase,
                  joinbf=TRUE,
                  read=FALSE,
                  dir="./analysis/data/raw_data/dwd_gridded/",
                  quiet=FALSE,
                  sleep = dl_sleep,
                  force = TRUE)

    return(file_paths)




}



#' Time series extraction from gridded data
#'
#' Should work with multiple sites, but not tested (i.e. \code{lat = c(x,y,z)})).
#'
#' @param file_paths character, file names for read-in; these are returned from \code{\link{download_monthly_gridded}}.
#' @param lat numeric, latitude of site
#' @param lon numeric, longitude of site
#'
#' @return data.frame with time series for input files and site
#' @export
#'
get_time_series <- function(file_paths, lat, lon){


    year_mon <- index_year_mon(file_paths)


    dwd_data <- rdwd::readDWD(file_paths,
                              quiet = FALSE,
                              raster = TRUE)
    dwd_data_stack <- rdwd::projectRasterDWD(r = raster::stack(dwd_data,
                                                               quick = TRUE),
                                             proj = "seasonal",
                                             extent = "seasonal")



    dwd_extracted <- as.numeric(raster::extract(dwd_data_stack,
                                      data.frame(x = lon,
                                                 y = lat)))
    dimnames(dwd_extracted) <- NULL



    dwd_extracted_with_dates <- data.frame(value = dwd_extracted,
                                            year_mon)


    return(dwd_extracted_with_dates)

    }
