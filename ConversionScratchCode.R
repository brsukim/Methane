
#Code for converting units in CH4 database

data <- read.csv("Methane/CH4data2023 - Sheet1.csv")

library(dplyr)
library(tidyr)
library(stringr)
library(readr)

data %>%
  group_by(CH4_flux_unit) %>%
  mutate(count = length(Pub.Year)) %>%
  select(CH4_flux_unit, count) %>%
  unique(.) %>%
  arrange(desc(count)) -> counts

print(counts$CH4_flux_unit)

data %>%
  filter(CH4_flux_unit %in% c("mg CH4 m-2 hr-1",
                              "mg CH4 m−2 h−1",
                              "mg CH4 m2 h1")) -> mg_m2_h_dat


74/334 * 100
#almost a quarter are in mg CH4 per meter squared per hour

#ug to mg, g to mg, kg to mg
#0.001; 1,000; 1,000,000

#mol C to mg CH4
#mol C * (1 mol CH4/1 mol C) * (16.04 g CH4/1 mol CH4) * (1,000 mg/g) = 16,040

#nmol to mol
#0.000000001 (10^-9)

#hectare to meter square, acre to meter square
#1,000; 4046.86

#seconds to hours, days to hours, years to hours
#0.000278; 24; 8760

#only need to run once
#install.packages("udunits2")
library(udunits2)

alt_data <- read_csv("Methane/CH4_alt.csv",
                                  #0       10        20        30
                                 #1234567890123456789012345678901234                     
                     col_types = "ccdddcdccccdddcccddddccddddddccccc",
                     trim_ws = TRUE)

colnames(alt_data)

alt_data %>%
  filter(unit != "") %>%
  group_by(Study_number) %>%
  select(2:23,31:34) -> wide_fluxes

alt_data %>%
  filter(unit != "") %>%
  group_by(Study_number) %>%
  select(2:17,24:34) -> errors

# stashing for later, to convert SD
# pivot_longer(cols = SD_CH4_annual:SD_CH4_monthly,
#              names_to = "Meas_period_error",
#              values_to = "Error") %>%

wide_fluxes %>%
pivot_longer(cols = CH4_annual:CH4_monthly,
               names_to = "Meas_period",
               values_to = "Flux") %>%
  filter(! is.na(Flux)) -> fluxes

fluxes$period <- ""
fluxes[fluxes$Meas_period == "CH4_annual",]$period <- "annual"
fluxes[fluxes$Meas_period == "CH4_growingseason",]$period <- "growing_season"
fluxes[fluxes$Meas_period == "CH4_monthly",]$period <- "monthly"

fluxes %>%
  select(Study_number, unit, period, Flux) -> for_conversion

unique(for_conversion$unit)
# [1] "ug/m2/h"       "mg CH4-C/m2/h" "kg CH4-C/m2/h" "mg/m2/h"      
# [5] "mg/m2/y"       "ug/m2/y"       "g/m2/season"   "mg/m2/d"      
# [9] "g/ha/d"        "g/m2/y"  

units <- c("ug/m2/h", "mg CH4-C/m2/h", "kg CH4-C/m2/h", "mg/m2/h",
           "mg/m2/y", "ug/m2/y", "g/m2/season", "mg/m2/d",
           "g/ha/d","g/m2/y")

convertible <- list()

for (x in units) {ud.are.convertible(x, "mg/m2/h") -> convertible
  print(convertible)
}

for_conversion %>%
  filter(!unit %in% c("mg CH4-C/m2/h", "kg CH4-C/m2/h",
                      "mg/m2/y", "ug/m2/y", "g/m2/season",
                      "g/m2/y")) %>%
  mutate(converted = ud.convert(Flux, unit, "mg/m2/h")) -> try_it

#convert y into yr
for_conversion %>%
  mutate(unit = (str_replace_all(unit, "y", "yr"))) -> for_conversion2

units2 <- c("ug/m2/h", "mg CH4-C/m2/h", "kg CH4-C/m2/h", "mg/m2/h",
           "mg/m2/yr", "ug/m2/yr", "g/m2/season", "mg/m2/d",
           "g/ha/d","g/m2/yr")

convertible2 <- list()

for (x in units2) {ud.are.convertible(x, "mg/m2/h") -> convertible2
  print(convertible2)
}

for_conversion2 %>%
  filter(!unit %in% c("mg CH4-C/m2/h", "kg CH4-C/m2/h","g/m2/season")) %>%
  mutate(converted = ud.convert(Flux, unit, "mg/m2/h")) -> try_it2







