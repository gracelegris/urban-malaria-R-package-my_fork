
# directories
Drive <- file.path(gsub("[\\]", "/", gsub("Documents", "", gsub("OneDrive", "", Sys.getenv("HOME")))))
Drive <- file.path(gsub("[//]", "/", Drive))
DriveDir <- file.path(Drive, "Urban Malaria Proj Dropbox", "urban_malaria")

DataDir <- file.path(DriveDir, "data")
StateShpDir <- file.path(DriveDir, "data/nigeria/nigeria_shapefiles/shapefiles/ShinyApp_shapefiles/all_reprioritization_nmep_states/STATES")
ITNDir <- file.path(DataDir, "nigeria/ITN_distribution")
RastersDir <- file.path(DriveDir, "data/nigeria/Raster_files")
YusufShpDir <- file.path(DriveDir, "data/nigeria/NMEP_nigeria_shapefiles/states")

PackageDataDir <- file.path(DriveDir, "data/nigeria/R_package_data")

# final function call for each state:

# YOBE
results <- reprioritize(
  state_name = "Yobe",
  shapefile_path = file.path(PackageDataDir, "shapefiles"),
  tpr_data_path = file.path(PackageDataDir, "TPR/yobetpr_updated.csv"),
  tpr_data_col_name = "u5_tpr_rdt",
  itn_dir = file.path(PackageDataDir, "ITN/pbi_distribution_Yobe_clean.xlsx"),
  raster_paths = list(
    h2o_distance_path = file.path(RastersDir, "distance_to_water_bodies/distance_to_water.tif"),
    evi_path = file.path(RastersDir, "Updated_Covariates", "2023-24_EVI_MOD13A1"),
    flood_path = file.path(RastersDir, "Flooding", "flooding_2023"),
    output_dir = file.path(PackageDataDir, "extractions")
  ),
  urban_data_path = file.path(PackageDataDir, "urban_percentage/yobe_urban_percentage.geojson"),
  settlement_block_path = file.path(DataDir, "nigeria/building_footprints/nigeria_footprints/nigeria blocks/Nigeria_Blocks_V1.shp"),
  map_output_dir = file.path(DriveDir, "projects/urban_microstratification/NetSmartR/outputs"),
  include_settlement_type = "Yes",
  include_u5_tpr_data = "Yes",
  scenarios = c(20, 30, 50, 75)
)

# KATSINA
results <- reprioritize(
  state_name = "Katsina",
  shapefile_path = file.path(PackageDataDir, "shapefiles"),
  tpr_data_path = file.path(PackageDataDir, "TPR/katsinatpr_updated.csv"),
  tpr_data_col_name = "u5_tpr_rdt",
  itn_dir = file.path(PackageDataDir, "ITN/pbi_distribution_Katsina_clean.xlsx"),
  raster_paths = list(
    h2o_distance_path = file.path(RastersDir, "distance_to_water_bodies/distance_to_water.tif"),
    evi_path = file.path(RastersDir, "Updated_Covariates", "2023-24_EVI_MOD13A1"),
    flood_path = file.path(RastersDir, "Flooding", "flooding_2023"),
    output_dir = file.path(PackageDataDir, "extractions")
  ),
  urban_data_path = file.path(PackageDataDir, "urban_percentage/katsina_urban_percentage.geojson"),
  settlement_block_path = file.path(DataDir, "nigeria/building_footprints/nigeria_footprints/nigeria blocks/Nigeria_Blocks_V1.shp"),
  map_output_dir = file.path(DriveDir, "projects/urban_microstratification/NetSmartR/outputs"),
  include_settlement_type = "Yes",
  include_u5_tpr_data = "Yes",
  scenarios = c(20, 30, 50, 75)
)

# DELTA
results <- reprioritize(
  state_name = "Delta",
  shapefile_path = file.path(PackageDataDir, "shapefiles"),
  tpr_data_path = file.path(PackageDataDir, "TPR/deltatpr_updated.csv"),
  tpr_data_col_name = "u5_tpr_rdt",
  itn_dir = file.path(PackageDataDir, "ITN/pbi_distribution_Delta_clean.xlsx"),
  raster_paths = list(
    h2o_distance_path = file.path(RastersDir, "distance_to_water_bodies/distance_to_water.tif"),
    evi_path = file.path(RastersDir, "Updated_Covariates", "2023-24_EVI_MOD13A1"),
    flood_path = file.path(RastersDir, "Flooding", "flooding_2023"),
    output_dir = file.path(PackageDataDir, "extractions")
  ),
  urban_data_path = file.path(PackageDataDir, "urban_percentage/delta_urban_percentage.geojson"),
  settlement_block_path = file.path(DataDir, "nigeria/building_footprints/nigeria_footprints/nigeria blocks/Nigeria_Blocks_V1.shp"),
  map_output_dir = file.path(DriveDir, "projects/urban_microstratification/NetSmartR/outputs"),
  include_settlement_type = "Yes",
  include_u5_tpr_data = "Yes",
  scenarios = c(20, 30, 50, 75)
)

# NIGER
results <- reprioritize(
  state_name = "Niger",
  shapefile_path = file.path(PackageDataDir, "shapefiles"),
  tpr_data_path = file.path(PackageDataDir, "TPR/nigertpr_updated.csv"),
  tpr_data_col_name = "u5_tpr_rdt",
  itn_dir = file.path(PackageDataDir, "ITN/pbi_distribution_Niger_clean.xlsx"),
  raster_paths = list(
    h2o_distance_path = file.path(RastersDir, "distance_to_water_bodies/distance_to_water.tif"),
    evi_path = file.path(RastersDir, "Updated_Covariates", "2023-24_EVI_MOD13A1"),
    flood_path = file.path(RastersDir, "Flooding", "flooding_2023"),
    output_dir = file.path(PackageDataDir, "extractions")
  ),
  urban_data_path = file.path(PackageDataDir, "urban_percentage/niger_urban_percentage.geojson"),
  settlement_block_path = file.path(DataDir, "nigeria/building_footprints/nigeria_footprints/nigeria blocks/Nigeria_Blocks_V1.shp"),
  map_output_dir = file.path(DriveDir, "projects/urban_microstratification/NetSmartR/outputs"),
  include_settlement_type = "Yes",
  include_u5_tpr_data = "Yes",
  scenarios = c(20, 30, 50, 75)
)

# TARABA
results <- reprioritize(
  state_name = "Taraba",
  shapefile_path = file.path(PackageDataDir, "shapefiles"),
  tpr_data_path = file.path(PackageDataDir, "TPR/tarabatpr_updated.csv"),
  tpr_data_col_name = "u5_tpr_rdt",
  itn_dir = file.path(PackageDataDir, "ITN/pbi_distribution_Taraba_clean.xlsx"),
  raster_paths = list(
    h2o_distance_path = file.path(RastersDir, "distance_to_water_bodies/distance_to_water.tif"),
    evi_path = file.path(RastersDir, "Updated_Covariates", "2023-24_EVI_MOD13A1"),
    flood_path = file.path(RastersDir, "Flooding", "flooding_2023"),
    output_dir = file.path(PackageDataDir, "extractions")
  ),
  urban_data_path = file.path(PackageDataDir, "urban_percentage/taraba_urban_percentage.geojson"),
  settlement_block_path = file.path(DataDir, "nigeria/building_footprints/nigeria_footprints/nigeria blocks/Nigeria_Blocks_V1.shp"),
  map_output_dir = file.path(DriveDir, "projects/urban_microstratification/NetSmartR/outputs"),
  include_settlement_type = "Yes",
  include_u5_tpr_data = "Yes",
  scenarios = c(20, 30, 50, 75)
)

# KADUNA
results <- reprioritize(
  state_name = "Kaduna",
  shapefile_path = file.path(PackageDataDir, "shapefiles"),
  tpr_data_path = file.path(PackageDataDir, "TPR/kadunatpr_updated.csv"),
  tpr_data_col_name = "u5_tpr_rdt",
  itn_dir = file.path(PackageDataDir, "ITN/pbi_distribution_Kaduna_clean.xlsx"),
  raster_paths = list(
    h2o_distance_path = file.path(RastersDir, "distance_to_water_bodies/distance_to_water.tif"),
    evi_path = file.path(RastersDir, "Updated_Covariates", "2023-24_EVI_MOD13A1"),
    flood_path = file.path(RastersDir, "Flooding", "flooding_2023"),
    output_dir = file.path(PackageDataDir, "extractions")
  ),
  urban_data_path = file.path(PackageDataDir, "urban_percentage/kaduna_urban_percentage.geojson"),
  settlement_block_path = file.path(DataDir, "nigeria/building_footprints/nigeria_footprints/nigeria blocks/Nigeria_Blocks_V1.shp"),
  map_output_dir = file.path(DriveDir, "projects/urban_microstratification/NetSmartR/outputs"),
  include_settlement_type = "Yes",
  include_u5_tpr_data = "Yes",
  scenarios = c(20, 30, 50, 75)
)

# OSUN
results <- reprioritize(
  state_name = "Osun",
  shapefile_path = file.path(PackageDataDir, "shapefiles"),
  tpr_data_path = file.path(PackageDataDir, "TPR/osuntpr_updated.csv"),
  tpr_data_col_name = "u5_tpr_rdt",
  itn_dir = file.path(PackageDataDir, "ITN/pbi_distribution_Osun_clean.xlsx"),
  raster_paths = list(
    h2o_distance_path = file.path(RastersDir, "distance_to_water_bodies/distance_to_water.tif"),
    evi_path = file.path(RastersDir, "Updated_Covariates", "2023-24_EVI_MOD13A1"),
    flood_path = file.path(RastersDir, "Flooding", "flooding_2023"),
    output_dir = file.path(PackageDataDir, "extractions")
  ),
  urban_data_path = file.path(PackageDataDir, "urban_percentage/osun_urban_percentage.geojson"),
  settlement_block_path = file.path(DataDir, "nigeria/building_footprints/nigeria_footprints/nigeria blocks/Nigeria_Blocks_V1.shp"),
  map_output_dir = file.path(DriveDir, "projects/urban_microstratification/NetSmartR/outputs"),
  include_settlement_type = "Yes",
  include_u5_tpr_data = "Yes",
  scenarios = c(20, 30, 50, 75)
)

# KWARA
results <- reprioritize(
  state_name = "Kwara",
  shapefile_path = file.path(PackageDataDir, "shapefiles"),
  tpr_data_path = file.path(PackageDataDir, "TPR/kwaratpr_updated.csv"),
  tpr_data_col_name = "u5_tpr_rdt",
  itn_dir = file.path(PackageDataDir, "ITN/pbi_distribution_Kwara_clean.xlsx"),
  raster_paths = list(
    h2o_distance_path = file.path(RastersDir, "distance_to_water_bodies/distance_to_water.tif"),
    evi_path = file.path(RastersDir, "Updated_Covariates", "2023-24_EVI_MOD13A1"),
    flood_path = file.path(RastersDir, "Flooding", "flooding_2023"),
    output_dir = file.path(PackageDataDir, "extractions")
  ),
  urban_data_path = file.path(PackageDataDir, "urban_percentage/kwara_urban_percentage.geojson"),
  settlement_block_path = file.path(DataDir, "nigeria/building_footprints/nigeria_footprints/nigeria blocks/Nigeria_Blocks_V1.shp"),
  map_output_dir = file.path(DriveDir, "projects/urban_microstratification/NetSmartR/outputs"),
  include_settlement_type = "Yes",
  include_u5_tpr_data = "Yes",
  scenarios = c(20, 30, 50, 75)
)

# ADAMAWA
results <- reprioritize(
  state_name = "Adamawa",
  shapefile_path = file.path(PackageDataDir, "shapefiles"),
  tpr_data_path = file.path(PackageDataDir, "TPR/adamawatpr_updated.csv"),
  tpr_data_col_name = "u5_tpr_rdt",
  itn_dir = file.path(PackageDataDir, "ITN/pbi_distribution_Adamawa_clean.xlsx"),
  raster_paths = list(
    h2o_distance_path = file.path(RastersDir, "distance_to_water_bodies/distance_to_water.tif"),
    evi_path = file.path(RastersDir, "Updated_Covariates", "2023-24_EVI_MOD13A1"),
    flood_path = file.path(RastersDir, "Flooding", "flooding_2023"),
    output_dir = file.path(PackageDataDir, "extractions")
  ),
  urban_data_path = file.path(PackageDataDir, "urban_percentage/adamawa_urban_percentage.geojson"),
  settlement_block_path = file.path(DataDir, "nigeria/building_footprints/nigeria_footprints/nigeria blocks/Nigeria_Blocks_V1.shp"),
  map_output_dir = file.path(DriveDir, "projects/urban_microstratification/NetSmartR/outputs"),
  include_settlement_type = "Yes",
  include_u5_tpr_data = "Yes",
  scenarios = c(20, 30, 50, 75)
)

