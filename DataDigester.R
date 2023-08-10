
#Read in and clean-up data

library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(udunits2)

current_data <- read_csv("Methane/CH4_7.29.csv",
                         trim_ws = TRUE,
                         #0       10        20        30
                         #123456789012345678901234567890123456                     
                         col_types = "ccdddcdccccdddcccddddddccddddddccccc")

current_data %>%
  filter(is.na(`Discard?`)) %>%
  select(-`Discard?`) -> good_data

good_data %>%
  group_by(CH4_flux_unit_V2) %>%
  mutate(count = length(Study_number)) %>%
  select(CH4_flux_unit_V2, count) %>%
  unique(.) %>%
  arrange(desc(count)) -> unit_counts

#still some conversions to do

good_data %>%
  group_by(Manipulation_V2) %>%
  mutate(count = length(Study_number)) %>%
  select(Manipulation_V2, count) %>%
  unique(.) %>%
  arrange(desc(count)) -> manipulation_counts

#"Fertilization + Precipitation as well as Precipitation + Fertilization

#filter out units that we aren't going to use at this time

good_data %>%
  select(Study_number, RN, CH4_annual, CH4_growingseason, CH4_monthly,
         `CH4-C_converted`, Season_converted, N, CH4_flux_unit,
         CH4_flux_unit_V2, SD_CH4_annual, SD_CH4_growingseason,
         SD_CH4_monthly) -> for_transformation

#current csv has zeros for Study # 23035 where NA's should be in Season_converted
for_transformation[for_transformation$Study_number == "23035",]$Season_converted <- NA

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

combined %>%
  filter(complete.cases(.)) -> tidy_data

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

#put all fluxes and their error in mg CH4 per meter squared per hour
tidy_data %>%
  mutate(stnd_flux = ud.convert(converted, CH4_flux_unit_V2, "mg/m2/h"),
         stnd_flux_sd = ud.convert(flux_sd, CH4_flux_unit_V2, "mg/m2/h")) %>%
  select(-c(flux, flux_sd, CH4_flux_unit, CH4_flux_unit_V2,
            converted, cf))-> tidy_standard_unit_data

current_data %>%
  select(Study_number, RN, Study_midyear, Ecosystem_type,
         Manipulation_V2, Manipulation_level, Latitude,
         Longitude, Elevation, Soil_type, Soil_drainage,
         SM_value, SM_sd, SM_depth, SM_unit,
         `same timescale as flux? (T/F)`, `if False, timescale`) %>%
  right_join(tidy_standard_unit_data) -> final_data