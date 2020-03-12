
# download data --------------------------------------------------------------


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

file_paths <- tereno.misc::download_monthly_gridded(index = idxs$precip[1:3],
                                                    dir_path = "./analysis/data/raw_data/dwd_gridded/")


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



