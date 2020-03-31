
# download data --------------------------------------------------------------

# using function
idxs <- tereno.misc::get_monthly_gridded_indices()



### MIN TEMP

file_paths <- tereno.misc::download_monthly_gridded(index = idxs$temp_min[1:3],
                                      dir_path = "./analysis/data/raw_data/dwd_gridded/")


min_time_series <- tereno.misc::get_time_series(file_paths = file_paths,
                             lon = 13.192137,
                             lat = 53.331034)




### MAX TEMP

file_paths <- tereno.misc::download_monthly_gridded(index = idxs$temp_max[1:3],
                                                    dir_path = "./analysis/data/raw_data/dwd_gridded/")


max_time_series <- tereno.misc::get_time_series(file_paths = file_paths,
                                                lon = 13.192137,
                                                lat = 53.331034)



### PRECIP

file_paths <- tereno.misc::download_monthly_gridded(index = idxs$precip[1:500],
                                                    dir_path = "./analysis/data/raw_data/dwd_gridded/",
                                                    dl_sleep = 0.2)


precip_time_series <- tereno.misc::get_time_series(file_paths = file_paths,
                                                lon = 13.192137,
                                                lat = 53.331034)


## on single files:

list_data <- lapply(file_paths,
                    function(file){
                        tereno.misc::get_time_series(file_paths = file,
                                                     lon = 13.192137,
                                                     lat = 53.331034)
})






# wrangling ---------------------------------------------------------------

library(data.table)
precip_dt <- data.table::as.data.table(precip_time_series)
precip_dt <- precip_dt[ ,`:=`(year = as.numeric(as.character(year)),
                       month_n = as.numeric(month_n))][
                           order(year, month_n)]



# plotting ----------------------------------------------------------------

library(ggplot2)
precip_dt %>%
    ggplot(aes(x = year, y = value, color = value)) +
    geom_line() +
    geom_point() +
    scale_color_binned(n.breaks = 5)







# new workflow ------------------------------------------------------------



# using grep
gridIndex <- rdwd:::gridIndex
evapo_p_daily <- grep("grids_germany_daily_evapo_p",   gridIndex, value=TRUE)



## get the the right years / months
library(dplyr)

year_info <- as.data.frame(tereno.misc::index_year_mon(evapo_p_daily),
                           stringsAsFactors = FALSE) %>%
    dplyr::mutate_at(1:2, as.numeric)


# year_select <- which(year_info$year > 2005 & year_info$year < 2007)
year_select <- which(year_info$year > 2005 & year_info$year < 2007 & year_info$month_n == 6)

evapo_p_daily[year_select]


file_paths <- tereno.misc::download_monthly_gridded(index = evapo_p_daily[year_select],
                                                    dir_path = "./analysis/data/raw_data/dwd_gridded/")



# create folder to store intermediate data,

temporary_dest <- tempdir()

do.call(utils::untar, list(tarfile = file_paths, exdir = temporary_dest))

unzipped_rasters <- list.files(temporary_dest,pattern = ".asc$",
                               full.names = TRUE)


# read raster
evapo_p_daily_stack <- raster::stack(unzipped_rasters,
                     quick = TRUE)

# set correct CRS
raster::crs(evapo_p_daily_stack) <- "+init=epsg:31467"

# for lat lon
evapo_p_daily_stack <- raster::projectRaster(evapo_p_daily_stack,
                                             crs = "+init=epsg:4326")




# extract values
dwd_extracted <- as.numeric(raster::extract(evapo_p_daily_stack,
                                            data.frame(x = 13.192137,
                                                       y = 53.331034)))
dimnames(dwd_extracted) <- NULL



dwd_extracted_with_dates <- cbind(data.frame(value = dwd_extracted),
                                  tereno.misc::index_year_mon_day(unzipped_rasters))


# this may work somehow if we can figure out the read-in below
# rdwd::readDWD(file_paths[1], binary = TRUE, exdir = sub(".tgz$", "", file_paths))
# rdwd::readDWD(file = sub(".tgz$", "", file_paths),
              # raster = TRUE)
