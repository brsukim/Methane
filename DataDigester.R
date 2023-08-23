
#Read in and clean-up data

library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(udunits2)

current_data <- read_csv("CH4_8.15.csv",
                         trim_ws = TRUE,
                         #0       10        20        30
                         #123456789012345678901234567890123456                     
                         show_col_types = FALSE)

current_data %>%
  filter(is.na(`Discard?`)) %>%
  select(-`Discard?`) -> good_data

# Removes all manipulated data which created variability that cannot be accounted for in the PCA
good_data <- good_data[good_data$Manipulation_V2 == "None", ]

# Unit Counts shows how many of each pre-converted unit there is
good_data %>%
  group_by(CH4_flux_unit_V2) %>%
  mutate(count = length(Study_number)) %>%
  select(CH4_flux_unit_V2, count) %>%
  unique(.) %>%
  arrange(desc(count)) -> unit_counts


# Standardizing soil moisture data

# Loop through each row
for (i in 1:nrow(good_data)) {
  # Check if the SM_unit is not missing and equals "VWC%"
  if (!is.na(good_data$SM_unit[i]) && good_data$SM_unit[i] == "VWC%") {
    # Set default values if PD or BD are missing
    pd_value <- ifelse(is.na(good_data$PD[i]), 2.65, good_data$PD[i])
    bd_value <- ifelse(is.na(good_data$BD[i]), 1.5, good_data$BD[i])
    
    # Calculate the new value using the formula
    new_value <- good_data$SM_value[i] / (1 - bd_value / pd_value)
    
    # Replace the existing value in SM_value
    good_data$SM_value[i] <- new_value
  }
}

#still some conversions to do

#filter out units that we aren't going to use at this time

good_data %>%
  select(Study_number, RN, CH4_annual, CH4_growingseason, CH4_monthly,
         `CH4-C_converted`, Season_converted, N, CH4_flux_unit,
         CH4_flux_unit_V2, SD_CH4_annual, SD_CH4_growingseason,
         SD_CH4_monthly) -> for_transformation






for_transformation %>%
  filter(! is.na(CH4_annual)) %>%
  mutate(period = "annual",
         flux = CH4_annual,
         flux_sd = SD_CH4_annual) %>%
  select(- c(CH4_annual,
             SD_CH4_annual,
             CH4_growingseason,
             SD_CH4_growingseason,
             CH4_monthly,
             SD_CH4_monthly)) -> annual

for_transformation %>%
  filter(! is.na(CH4_monthly)) %>%
  mutate(period = "monthly",
         flux = CH4_monthly,
         flux_sd = SD_CH4_monthly) %>%
  select(- c(CH4_annual,
             SD_CH4_annual,
             CH4_growingseason,
             SD_CH4_growingseason,
             CH4_monthly,
             SD_CH4_monthly))-> monthly

for_transformation %>%
  filter(! is.na(CH4_growingseason)) %>%
  mutate(period = "growing season",
         flux = CH4_growingseason,
         flux_sd = SD_CH4_growingseason) %>%
  select(- c(CH4_annual,
             SD_CH4_annual,
             CH4_growingseason,
             SD_CH4_growingseason,
             CH4_monthly,
             SD_CH4_monthly))-> growing_season

annual %>%
  bind_rows(monthly) %>%
  bind_rows(growing_season) %>%
  arrange(Study_number) %>%
  mutate(converted = ifelse(is.na(Season_converted),
                            `CH4-C_converted`,
                            Season_converted),
         converted = coalesce(converted, flux),
         cf = converted/flux,
         flux_sd = flux_sd*cf) %>%
  select(-c(`CH4-C_converted`, Season_converted)) -> combined

combined -> tidy_data

tidy_data %>%
  select(CH4_flux_unit_V2) %>%
  unique(.)

# 1 mg/m2/h         
# 2 kg/ha/yr        
# 3 μg/m2/h         
# 4 mg/m2/d         
# 5 mg/m2/yr        
# 6 g/m2/yr         
# 7 g/ha/d          
# 8 CH4 μmol/mol  #this is the only unit that we can't convert  
# 9 kg/hm2/yr       
# 10 μg/m2/s 
# Unit Conversion with Filtering

# Filter out rows where the original unit is not convertible
convertible_units <- c("mg/m2/h", "kg/ha/yr", "μg/m2/h", "mg/m2/d", 
                       "mg/m2/yr", "g/m2/yr", "g/ha/d", "μg/m2/s")

tidy_data %>%
  filter(CH4_flux_unit_V2 %in% convertible_units) %>%  # Only keep rows with convertible units
  mutate(stnd_flux = ud.convert(converted, CH4_flux_unit_V2, "mg/m2/d"),
         stnd_flux_sd = ud.convert(flux_sd, CH4_flux_unit_V2, "mg/m2/d")) %>%
  select(-c(flux, flux_sd, CH4_flux_unit, CH4_flux_unit_V2,
            converted, cf)) -> tidy_standard_unit_data

#put all fluxes and their error in mg CH4 per meter squared per hour

good_data %>%
  select(Study_number, RN, Study_midyear, Ecosystem_type, Latitude,
         Longitude, Elevation,
         SM_value, SM_sd, SM_depth) %>%
  right_join(tidy_standard_unit_data) -> final_data
final_data$Ecosystem_numeric <- as.numeric(as_factor(final_data$Ecosystem_type))
final_data$Period_numeric <- as.numeric(as_factor(final_data$period))

final_data <- final_data %>% select(-SM_sd , -SM_depth,-N, -Longitude, -Study_midyear, -RN, -stnd_flux_sd, -Ecosystem_type, -period)
write.csv(final_data, "final_data.csv", row.names = FALSE)

