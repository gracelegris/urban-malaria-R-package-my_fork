
#' Run reprioritization analysis for a given state
#'
#' This function extracts raster data, merges TPR data, calculates composite malaria risk scores,
#' ranks wards, and generates reprioritization maps.
#'
#' @param state_name Name of the state (e.g., "Kano")
#' @param shapefile_path Path to the state shapefile
#' @param tpr_data_path Path to the TPR data CSV file
#' @param itn_dir Path to the ITN distribution data
#' @param raster_paths Named list of paths to raster data for extraction
#' @param risk_factors Vector of covariate names to use in risk score calculation
#' @export

reprioritize <- function(state_name, shapefile_path, tpr_data_path, tpr_data_col_name, itn_dir,
                         raster_paths, urban_data_path, settlement_block_path, map_output_dir,
                         include_settlement_type, include_u5_tpr_data, scenarios) {

  # read in shapefile
  message("Reading in shapefile...")
  state_shapefile <- tryCatch({
    shapefile_file <- file.path(shapefile_path, state_name, paste0(state_name, ".shp"))
    shapefile <- sf::st_read(shapefile_file, quiet = TRUE)
    sf::st_make_valid(shapefile)
  }, error = function(e) {
    stop("Failed to load shapefile: ", e$message)
  })

  message("Extracting raster data...")
  extracted_data <- extract_raster_data(state_name, state_shapefile, raster_paths)

  # check for urban percentage data and prompt user to download it if they haven't already
  urban_data <- get_urban_percentage(urban_data_path)

  # add "Urban" variable to the urban percentage data if it does not yet exist
  urban_data <- add_urban_var(urban_data)

  # merge the extracted data with the urban percentage data, then clean up the column names
  message("Merging extracted data with urban percentage data...")
  extracted_data <- base::merge(extracted_data, urban_data, by = "WardCode", all.x = TRUE)
  extracted_data <- clean_merge(extracted_data)

  # merge the extracted data with the TPR data
  if(include_u5_tpr_data == "Yes" || include_u5_tpr_data == "yes") {
    message("Merging TPR data with extracted data...")
    # delete any duplicate columns
    extracted_data <- extracted_data[!duplicated(extracted_data), ]
    # apply spatial mean function to handle missing values in tpr data
    tpr_data <- get_spatial_means(tpr_data_path, state_shapefile, tpr_data_col_name)
    # merge
    extracted_data_plus <- tpr_merge(tpr_data, extracted_data, state_name)
    # for tpr values that are missing in the merged extracted data, impute the column average tpr
    extracted_data_plus <- add_mean_tpr(extracted_data_plus)
    extracted_data_plus <- clean_merge(extracted_data_plus)
  }

  # remove any observations that merged incorrectly
  extracted_data_plus <- clean_extracted_plus(extracted_data_plus)

  # check for settlement blocks data and prompt user to download it if they haven't already. If the user supplied them, merge them with the extracted data.
  if(include_settlement_type == "Yes" || include_settlement_type == "yes") {
    message("Getting settlement blocks data...")
    settlement_block_shp <- get_settlement_blocks(settlement_block_path)
    extracted_data_plus <- settlement_type_merge(settlement_block_shp, extracted_data_plus, state_name)
    extracted_data_plus <- clean_merge(extracted_data_plus)
  }

  # remove any columns that are exactly duplicated
  extracted_data_plus <- extracted_data_plus[!duplicated(extracted_data_plus), ]

  # save complete extracted data
  message("Saving completed extracted data...")
  output_dir <- raster_paths$output_dir
  # remove the geometry column before writing to CSV
  extracted_data_plus_no_geom <- extracted_data_plus
  extracted_data_plus_no_geom$geometry <- NULL
  write.csv(extracted_data_plus_no_geom, file = file.path(output_dir, paste0(state_name, "_extracted_data_plus.csv")), row.names = FALSE)

  # calculate composite scores
  message("Calculating composite malaria risk scores...")
  malaria_risk_scores <- calculate_malaria_risk_scores(extracted_data_plus, raster_paths, include_settlement_type, include_u5_tpr_data)

  # rank wards by risk score
  message("Ranking wards by risk score...")
  ranked_wards <- rank(malaria_risk_scores)

  # run reprioritization analysis
  message("Reprioritizing and creating maps...")
  maps <- create_reprioritization_map(state_name, state_shapefile, itn_dir, extracted_data_plus, ranked_wards,
                                      map_output_dir, include_settlement_type, include_u5_tpr_data, scenarios)

  message("Reprioritization process for ", state_name, " completed.")

  # create labeled reprioritization maps with orange LGA labels
  lga_maps <- create_state_reprioritization_maps(state_name, state_shapefile, shapefile_path, scenarios, map_output_dir)

  return(maps)
}
