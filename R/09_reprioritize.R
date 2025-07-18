# ==========================================================================================================================================
## Script Name: Create Reprioritization Maps
# Author: Grace Legris, Research Data Analyst
# Date: 01/30/25
# Purpose: Creates and saves final reprioritization maps using composite scores.
# ==========================================================================================================================================

#' Prioritize Wards Based on Population and Ranking
#'
#' This function selects wards for reprioritization based on their population and malaria risk ranking.
#' Wards are added sequentially (skipping those classified as "Rural" or with missing classification)
#' until the cumulative population of selected wards reaches or exceeds the specified target percentage.
#'
#' @param data A data frame containing ward-level data. It must include:
#'   \itemize{
#'     \item A population column (specified by \code{population_col}).
#'     \item A ranking column (specified by \code{rank_col}).
#'     \item A classification column (specified by \code{class_col}) indicating urban/rural status.
#'     \item A ward identifier column (specified by \code{ward_col}).
#'   }
#' @param population_col A character string specifying the name of the population column in \code{data}.
#' @param rank_col A character string specifying the name of the ranking column in \code{data}.
#' @param class_col A character string specifying the name of the classification column (e.g., urban/rural) in \code{data}.
#' @param ward_col A character string specifying the name of the ward identifier column in \code{data}.
#' @param target_percentage A numeric value (default is 30) representing the target percentage of the total population
#'   that the selected wards should cumulatively cover.
#'
#' @return A data frame containing:
#'   \itemize{
#'     \item \code{SelectedWards}: The names/identifiers of the selected wards.
#'     \item \code{WardCode}: The ward codes (if available).
#'     \item \code{WardPopulation}: The population for each selected ward.
#'     \item \code{WardPercentage}: The percentage of the total population represented by each ward.
#'     \item \code{CumulativePopulation}: The cumulative population sum of the selected wards.
#'     \item \code{CumulativePercentage}: The cumulative population percentage relative to the total population.
#'   }
#'
#' @details The function first filters out rows with missing population or ranking values and sorts the data
#' based on the ranking. It then iteratively adds wards (skipping those with missing or "Rural" classification)
#' until the cumulative population of the selected wards meets or exceeds the \code{target_percentage}.
#'
#' @examples
#' \dontrun{
#' # Assuming combined_data is a data frame with the required columns:
#' prioritized <- prioritize_wards(
#'   data = combined_data,
#'   population_col = "Population",
#'   rank_col = "rank",
#'   class_col = "classification_30",
#'   ward_col = "WardName",
#'   target_percentage = 30
#' )
#' print(prioritized)
#' }
#'
#' @export
prioritize_wards <- function(data, population_col, rank_col, class_col, ward_col, lga_col, target_percentage = 30) {
  total_population <- sum(data[[population_col]], na.rm = TRUE)

  selected_wards <- c()
  cumulative_population <- 0
  ward_populations <- c()
  ward_percentages <- c()
  WardCode_x <- c()
  lga_names <- c()

  # print the wards that will be filtered out
  filtered_out <- data[is.na(data[[population_col]]) | is.na(data[[rank_col]]), ]
  if (nrow(filtered_out) > 0) {
    message("Filtered out the following wards in scenario ", class_col, " due to missing population or rank:")
    print(filtered_out[[ward_col]])
  }

  # filter out rows with missing population or rank values
  data_sorted <- data[!is.na(data[[population_col]]) & !is.na(data[[rank_col]]), ]
  data_sorted <- data_sorted[order(data_sorted[[rank_col]]), ]

  for (i in 1:nrow(data_sorted)) {
    ward <- data_sorted[i, ]

    # skip if classification column is missing or if the ward is classified as "Rural"
    if (is.na(ward[[class_col]]) || ward[[class_col]] == "Rural") {
      next
    }

    selected_wards <- c(selected_wards, ward[[ward_col]])
    lga_names <- c(lga_names, ward[[lga_col]])
    ward_population <- ward[[population_col]]
    cumulative_population <- cumulative_population + ward_population
    current_percentage <- (ward_population / total_population) * 100
    WardCode_x <- c(WardCode_x, ward$WardCode)

    ward_populations <- c(ward_populations, ward_population)
    ward_percentages <- c(ward_percentages, round(current_percentage, 2))

    # stop when the cumulative population reaches or exceeds the target percentage
    if (!is.na(current_percentage) && (cumulative_population / total_population) * 100 >= target_percentage) {
      break
    }
  }

  # create a result dataframe
  result <- data.frame(
    SelectedWards = selected_wards,
    LGA = lga_names,
    WardCode = WardCode_x,
    WardPopulation = ward_populations,
    WardPercentage = ward_percentages,
    CumulativePopulation = cumsum(ward_populations),
    CumulativePercentage = round(cumsum(ward_populations) / total_population * 100, 2)
  )

  return(result)
}


#' Merge Test Positivity Rate Data with Extracted Data
#'
#' This function reads a CSV file containing malaria test positivity rate (TPR) data and merges it with the
#' extracted covariate data based on the ward name.
#'
#' @param tpr_data_path A character string specifying the file path to the TPR data CSV.
#' @param extracted_data A data frame containing extracted covariate data. This data frame must include a column
#'   named \code{WardName} that will be used to merge with the TPR data.
#'
#' @return A data frame resulting from a left join of \code{extracted_data} with the selected TPR column
#'   (\code{u5_tpr_rdt}) from the TPR data.
#'
#' @details The function selects only the \code{WardName} and \code{u5_tpr_rdt} columns from the TPR data
#' and performs a left join with \code{extracted_data} based on the \code{WardName} column.
#'
#' @examples
#' \dontrun{
#' merged_data <- merge("path/to/tpr_data.csv", extracted_data)
#' head(merged_data)
#' }
#'
#' @import dplyr
#' @export
tpr_merge <- function(tpr_data, extracted_data, state_name, tpr_data_col_name) {

  extracted_data <- extracted_data %>% mutate(WardCode = as.character(WardCode))
  tpr_data <- tpr_data %>% mutate(WardCode = as.character(WardCode))
  extracted_data_plus <- extracted_data %>%
    left_join(tpr_data %>% dplyr::select(WardCode, WardName, LGA, tpr_data_col_name), by = "WardCode")
}

get_spatial_means <- function(tpr_data_path, state_shapefile, tpr_data_col_name = NULL) {

  data <- read.csv(tpr_data_path)

  if (is.null(tpr_data_col_name)) {
    cols_to_process <- names(data)[sapply(data, function(x) any(is.na(x)))]
  } else {
    cols_to_process <- tpr_data_col_name
  }

  # create neighbor structure using shapefile data
  w <- spdep::poly2nb(state_shapefile, queen = TRUE)

  for (current_col in cols_to_process) {
    col_data <- data[[current_col]]
    missing_indices <- which(is.na(col_data))

    print(paste("Processing column:", current_col))
    print(paste("Number of NAs:", length(missing_indices)))

    for (index in missing_indices) {
      neighbor_indices <- w[[index]]
      neighbor_values <- col_data[neighbor_indices]
      imputed_value <- mean(neighbor_values, na.rm = TRUE)

      if (is.na(imputed_value)) {
        # fallback to column mean
        imputed_value <- mean(col_data, na.rm = TRUE)

        # print the ward name if available
        if ("ward" %in% names(data)) {
          ward_name <- data$ward[index]
          print(paste("Warning: Neighbor values all NA for ward:", ward_name,
                      "- using overall mean for imputation."))
        } else {
          print(paste("Warning: Neighbor values all NA for index", index,
                      "- using overall mean for imputation."))
        }
      }

      col_data[index] <- imputed_value
      print(paste("Imputed value for index", index, ":", imputed_value))
    }

    # only update the NAs in the original data
    data[[current_col]][missing_indices] <- col_data[missing_indices]
  }

  return(data)
}

add_mean_tpr <- function(extracted_data_plus, tpr_data_col_name) {
  # calculate the mean TPR, excluding NA values
  mean_tpr <- mean(extracted_data_plus[[tpr_data_col_name]], na.rm = TRUE)

  # impute missing values with the mean TPR
  extracted_data_plus[[tpr_data_col_name]][is.na(extracted_data_plus[[tpr_data_col_name]])] <- mean_tpr

  return(extracted_data_plus)
}

settlement_type_merge <- function(settlement_block_shp, extracted_data, state_name) {

  # filter settlement blocks shapefile
  settlement_block_shp <- settlement_block_shp %>%
    dplyr::filter(state == state_name, landuse == 'Residential')

  extracted_data_shp <- st_as_sf(extracted_data)

  # ensure CRS alignment
  if (st_crs(extracted_data_shp) != st_crs(settlement_block_shp)) {
    settlement_block_shp <- st_transform(settlement_block_shp, st_crs(extracted_data_shp))
  }

  # spatial join to assign settlement type
  settlement_data <- st_join(extracted_data_shp, settlement_block_shp, join = sf::st_overlaps)

  # disable s2 geometry processing
  sf_use_s2(FALSE)

  # clean and format settlement data
  settlement_type_data <- settlement_data %>%
    dplyr::select(WardCode, WardName, settlement_type = type) %>%
    dplyr::group_by(WardCode, WardName, settlement_type) %>%
    dplyr::summarise(number = n(), .groups = "drop") %>%
    tidyr::pivot_wider(names_from = settlement_type, values_from = number, values_fill = 0) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      A = ifelse("A" %in% names(.), A, 0),  # ensure 'A' exists
      B = ifelse("B" %in% names(.), B, 0),  # ensure 'B' exists
      M = ifelse("M" %in% names(.), M, 0),  # ensure 'M' exists
      total_settlement = sum(c_across(where(is.numeric))),
      proportion_poor_settlement = ifelse(total_settlement > 0, (A + B + M) / total_settlement, 0)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::select(WardCode, WardName, settlement_type = proportion_poor_settlement)

  # merge with extracted data
  extracted_data_plus <- extracted_data %>%
    left_join(settlement_type_data, by = "WardCode")

  return(extracted_data_plus)
}


#' Create and Save Reprioritization Maps Using Composite Scores
#'
#' This function generates reprioritization maps for a given state by combining spatial data,
#' extracted covariate data, ITN distribution data, and ranked ward information. It produces a malaria risk map
#' based on composite scores and reprioritization maps under multiple urban classification scenarios.
#'
#' @param state_name A character string representing the name of the state for which maps are created.
#' @param shp_dir A character string specifying the file path to the state's shapefile (e.g., GeoJSON or SHP).
#' @param itn_dir A character string specifying the file path to the ITN distribution data (Excel file).
#' @param extracted_data A data frame containing extracted covariate data for wards. Must include columns such as \code{WardCode}, \code{WardName}, and \code{urbanPercentage}.
#' @param ranked_wards A data frame containing ward ranking information. Must include columns such as \code{WardName} and \code{rank}.
#' @param map_output_dir A character string specifying the directory where the final maps will be saved.
#' @param include_settlement_type A character string ("Yes" or "No") indicating whether to include settlement type in the composite score variables.
#' @param include_u5_tpr_data A character string ("Yes" or "No") indicating whether to include under-5 TPR (Test Positivity Rate) data in the composite score variables.
#' @param scenarios A numeric vector specifying urban classification thresholds to use for reprioritization. Defaults to \code{c(20, 30, 50, 75)}.
#'
#' @return A list containing:
#'   \itemize{
#'     \item \code{risk_map}: A ggplot object representing the malaria risk map.
#'     \item \code{reprioritization_map}: A ggplot grob (grid object) combining multiple reprioritization maps for selected scenarios.
#'   }
#'
#' @details The function performs the following steps:
#' \enumerate{
#'   \item Loads spatial data (state shapefile), extracted covariate data, and ITN distribution data.
#'   \item Creates urban/rural classification scenarios based on varying urban percentage thresholds (e.g., 20%, 30%, 50%, 75%).
#'   \item Cleans and merges covariate, ranking, and ITN population data into a comprehensive dataset.
#'   \item Runs the \code{prioritize_wards} function for each urban classification scenario to identify reprioritized wards.
#'   \item Generates a malaria risk map using composite scores and reprioritization maps for each urban classification scenario using ggplot2.
#'   \item Arranges reprioritization maps into a grid layout and saves both the risk map and reprioritization map grid as PDF files.
#' }
#'
#' @note
#' - This function assumes that external files (shapefiles, ITN data, etc.) are properly formatted and accessible via provided file paths.
#' - The custom function \code{map_theme()} must be defined in your package or script to apply consistent styling to maps.
#'
#' @examples
#' \dontrun{
#' result_maps <- create_reprioritization_map(
#'   state_name = "Kano",
#'   shp_dir = "path/to/state_shapefile.geojson",
#'   output_dir = "path/to/output_directory",
#'   itn_dir = "path/to/itn_data.xlsx",
#'   extracted_data = extracted_covariates,
#'   ranked_wards = ranked_data,
#'   map_output_dir = "path/to/map_output_directory",
#'   include_settlement_type = "Yes",
#'   include_u5_tpr_data = "No"
#' )
#'
#' # To view the risk map:
#' print(result_maps$risk_map)
#'
#' # To view the reprioritization map grid:
#' grid::grid.draw(result_maps$reprioritization_map)
#'
#' # Maps are saved in the specified output directory as PDF files.
#'}
#'
#' @import dplyr
#' @import ggplot2
#' @import gridExtra
#' @import grid
#' @importFrom sf st_read
#' @importFrom readxl read_xlsx
#' @export
create_reprioritization_map <- function(state_name, state_shapefile, itn_dir,
                                        extracted_data_plus, ranked_wards, map_output_dir,
                                        include_settlement_type, include_u5_tpr_data, scenarios) {

  # load and clean variables
  state_variables <- extracted_data_plus %>%
    distinct(WardCode, .keep_all = TRUE) %>%
    dplyr::select(WardCode, WardName, urbanPercentage) %>%
    mutate(
      classification_20 = ifelse(urbanPercentage > 20, "Urban", "Rural"),
      classification_30 = ifelse(urbanPercentage > 30, "Urban", "Rural"),
      classification_50 = ifelse(urbanPercentage > 50, "Urban", "Rural"),
      classification_75 = ifelse(urbanPercentage > 75, "Urban", "Rural")
    )

  # read in ITN data
  state_itn_data <- read_excel(itn_dir)

  # merge data
  combined_wards <- left_join(state_variables, ranked_wards, by = c("WardCode"))
  combined_wards2 <- left_join(combined_wards, state_itn_data, by = c("WardName.x" = "Ward"))

  # delete any duplicate columns
  combined_wards2 <- combined_wards2[!duplicated(combined_wards2), ]

  # define the state-specific folder path
  state_folder <- file.path(map_output_dir, state_name)

  # check if the folder exists, if not, create it (results will be saved here)
  if (!dir.exists(state_folder)) {
    dir.create(state_folder)
  }

  # run prioritized wards only for user-selected scenarios, get number of reprioritized wards in each scenario
  prioritized_wards <- list()
  num_reprioritized_wards <- list()
  if (20 %in% scenarios) {
    prioritized_wards[["20"]] <- prioritize_wards(combined_wards2, "Population", "rank", "classification_20", "WardName.x", "LGA", 30)
    num_reprioritized_wards[["20"]] <- nrow(prioritized_wards[["20"]])
    write.csv(file = file.path(state_folder, paste0(state_name, "_prioritized_20.csv")), x = prioritized_wards[["20"]])
  }
  if (30 %in% scenarios) {
    prioritized_wards[["30"]] <- prioritize_wards(combined_wards2, "Population", "rank", "classification_30", "WardName.x", "LGA", 30)
    num_reprioritized_wards[["30"]] <- nrow(prioritized_wards[["30"]])
    write.csv(file = file.path(state_folder, paste0(state_name, "_prioritized_30.csv")), x = prioritized_wards[["30"]])
  }
  if (50 %in% scenarios) {
    prioritized_wards[["50"]] <- prioritize_wards(combined_wards2, "Population", "rank", "classification_50", "WardName.x", "LGA", 30)
    num_reprioritized_wards[["50"]] <- nrow(prioritized_wards[["50"]])
    write.csv(file = file.path(state_folder, paste0(state_name, "_prioritized_50.csv")), x = prioritized_wards[["50"]])
  }
  if (75 %in% scenarios) {
    prioritized_wards[["75"]] <- prioritize_wards(combined_wards2, "Population", "rank", "classification_75", "WardName.x", "LGA", 30)
    num_reprioritized_wards[["75"]] <- nrow(prioritized_wards[["75"]])
    write.csv(file = file.path(state_folder, paste0(state_name, "_prioritized_75.csv")), x = prioritized_wards[["75"]])
  }

  # write list of variables included in composite score calculations (add to caption on maps)
  variable_labels <- list(
    evi_path = "EVI", ndvi_path = "NDVI", rainfall_path = "Rainfall", h2o_distance_path = "Distance to Water Bodies",
    elevation_path = "Elevation", rh_2023 = "Relative Humidity (2023)", rh_2024 = "Relative Humidity (2024)",
    temp_2023 = "Temperature (2023)", temp_2024 = "Temperature (2024)",
    housing_quality_path = "Housing Quality", ndwi_path = "NDWI", ndmi_path = "NDMI", pfpr_path = "PfPR",
    lights_path = "Night-Time Lights", surface_soil_wetness_path = "Surface Soil Wetness",
    flood_path = "Flooding"
  )

  # check which files exist and collect their labels
  existing_variables <- sapply(names(raster_paths), function(var) {
    if (file.exists(raster_paths[[var]])) {
      return(variable_labels[[var]])
    } else {
      return(NULL)
    }
  }, USE.NAMES = FALSE)

  # remove NULL values from the list
  existing_variables <- existing_variables[!sapply(existing_variables, is.null)]

  # if user said "yes" to including settlement type and u5 tpr data, add them to covariate list
  if (include_settlement_type == "Yes" || include_settlement_type == "yes") {
    existing_variables <- c(existing_variables, "Settlement Type")
  }
  if (include_u5_tpr_data == "Yes" || include_u5_tpr_data == "yes") {
    existing_variables <- c(existing_variables, "U5 TPR (RDT)")
  }

  # create risk map using composite scores
  risk_map <- ggplot() +
    geom_sf(data = state_shapefile %>% left_join(combined_wards2, by = c("WardName" = "WardName.x")),
            aes(geometry = geometry, fill = rank)) +
    scale_fill_gradient(name = "Rank", low = "lightyellow", high = "red", na.value = "grey") +
    labs(title = paste("Malaria Risk Map of", state_name, "State"),
         caption = paste0("Variables included in composite score: ",
                          paste(existing_variables, collapse = ", "))) +
    map_theme()

  # create reprioritization maps for selected scenarios
  reprioritization_maps <- lapply(names(prioritized_wards), function(s) {
    ggplot() +
      geom_sf(data = state_shapefile %>%
                left_join(prioritized_wards[[s]], by = c("WardName" = "SelectedWards")),
              aes(geometry = geometry,
                  fill = ifelse(is.na(WardPopulation), "Not Reprioritized", "Reprioritized"))) +
      scale_fill_manual(values = c("Not Reprioritized" = "#F1F2F2",
                                   "Reprioritized" = "#00AEEF"),
                        name = "Status") +
      labs(
        title = paste0(s, "% Urban Scenario"),
        subtitle = paste(num_reprioritized_wards[[s]], "Reprioritized Wards"),
        caption = paste0(
          "Variables included in composite score:\n",
          paste(existing_variables, collapse = ", ")
      )) +
      map_theme() +
      theme(legend.position = "none",
            plot.subtitle = element_text(hjust = 0.5))

  })

  # arrange selected reprioritization maps in a grid and export as pdf
  map_grid <- do.call(grid.arrange, c(reprioritization_maps, list(nrow = 2, ncol = 2)))

  final_grid <- grid.arrange(
    map_grid,
    top = textGrob(paste("Reprioritization Scenarios in", state_name),
                   gp = gpar(fontsize = 12, fontface = "bold", hjust = 0.5))
  )

  # save the plots in the state-specific folder
  ggsave(filename = file.path(state_folder, paste0(state_name, "_risk_map.pdf")),
         plot = risk_map, width = 12, height = 8)

  ggsave(filename = file.path(state_folder, paste0(state_name, "_reprioritization_maps.pdf")),
         plot = final_grid, width = 12, height = 8)

  return(list(risk_map = risk_map, reprioritization_map = final_grid))
}
