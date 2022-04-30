#### Preamble ####
# Purpose: Clean the crime data downloaded from city wise websites 
# Author: Nayan Saxena
# Date: April 2022
# Contact: nayan.saxena@mail.utoronto.ca
# License: MIT

library(ggplot2)
library(plotly)
library(plyr)
library(flexdashboard)
library(RSocrata)
library(tidyverse)
library(tsbox) # transform data into time series
library(xts)
library(COVID19) # to get data about covid 19
library(forecast) #ariRI model
library(vars) #VAR and Causality
library(dygraphs)
library(leaflet)
library(htmlwidgets)

# local load and combine data
########################################################################
############################# COVID-DATA ###############################
########################################################################
#Load Chicago Data
covid19_CH <- covid19("USA", level = 3) %>%
  # this cook county contains chicago
  filter(administrative_area_level_3 == "Cook",
         administrative_area_level_2 == "Illinois" ) %>%
  # filter out days when confirmed is zero or one
  # becasue when it was 2 for a very long time
  filter(confirmed > 2)

# Load Providence data
covid19_RI <- covid19("USA", level = 2) %>%
  filter(administrative_area_level_2 == "Rhode Island") %>%
  # filter out days when confirmed is zero or one
  # becasue when it was 1 for a very long time
  filter(confirmed > 1)
## March 07 has 140 confirmed case which is impossible.
## Google shows that date had still 3 cumulative case
## Manual adjustment on row 5
covid19_RI$confirmed[5] = covid19_RI$confirmed[4]


# Load Boston Data
covid19_MA <- covid19("USA", level = 2) %>%
  filter(administrative_area_level_2 == "Massachusetts") %>%
  # filter out days when confirmed is zero or one
  # becasue when it was 1 for a very long time
  filter(confirmed > 1)

# Load LA data
# extract LA data from US data. 
covid19_LA <- covid19("USA", level = 3) %>%
  filter(administrative_area_level_3 == "Los Angeles",
         administrative_area_level_2 == "California") %>%
  # stayed at 1 for long time
  filter(confirmed > 1,
         date < "2020-06-12")

# Load Atlanta Data
covid19_AT <- covid19("USA", level = 3) %>%
  filter(administrative_area_level_2 == "Georgia",
         administrative_area_level_3 == 'Fulton') %>%
  # filter out days when confirmed is zero or one
  # becasue when it was 2 for a very long time
  filter(confirmed > 2)

# Load Seattle Data
covid19_SEA <- covid19("USA", level = 3) %>%
  # this cook county contains chicago
  filter(administrative_area_level_3 == "King",
         administrative_area_level_2 == "Washington" ) %>%
  # filter out days when confirmed is zero or one
  # becasue when it was 1 for a very long time
  filter(confirmed > 1)

# extract Pennsylvania data from US data. 
covid19_PA <- covid19("USA", level = 3) %>%
  filter(administrative_area_level_2 == "Pennsylvania",
         administrative_area_level_3 == "Philadelphia") %>%
  # filter out days when confirmed is zero
  filter(confirmed > 0)


########################################################################
############################# PHILLY @##################################
########################################################################
phil2021 <- read.csv("inputs/data/phil_2021.csv")
phil2021 <- subset (phil2021, select = -c( the_geom , cartodb_id, the_geom_webmercator ))
phil2020 <- read.csv("inputs/data/phil_2020.csv")
phil2020 <- subset (phil2020, select = -c( the_geom , cartodb_id, the_geom_webmercator ))
phil2019 <- read.csv("inputs/data/phil_2019.csv")
phil2018 <- read.csv("inputs/data/phil_2018.csv")
phil2017 <- read.csv("inputs/data/phil_2017.csv")
phil2016 <- read.csv("inputs/data/phil_2016.csv")
phil2015 <- read.csv("inputs/data/phil_2015.csv")

phil <- do.call("rbind", list(phil2021,phil2020, phil2019, phil2018, phil2017, phil2016, phil2015))

# add YEAR, MONTH, y_month
phil <- phil %>%
  mutate(date = as.Date(substr(dispatch_date_time, start = 1, stop = 10))) %>%
  mutate(y_month = substr(dispatch_date_time, start = 1, stop = 7)) %>%
  mutate(YEAR = substr(dispatch_date_time, start = 1, stop = 4)) %>%
  mutate(MONTH = substr(dispatch_date_time, start = 6, stop = 7))

#Rolled aggravted assaults into other assaults

phil$text_general_code <- gsub("Aggravated Assault No Firearm", "Other Assaults", phil$text_general_code)
phil$text_general_code <- gsub("Aggravated Assault Firearm", "Other Assaults", phil$text_general_code)

write.csv2(phil, 'outputs/paper/data/phil.csv',row.names = FALSE)

########################################################################
############################# CHICAGO ##################################
########################################################################

if (exists("chicago")) is.data.frame(get("chicago")) else chicago <- RSocrata::read.socrata(
  "https://data.cityofchicago.org/resource/ijzp-q8t2.csv?$where=year >= 2014",
  app_token = "hPU78MH7zKApdpUv4OVCInPOQ")

# add date
chicago <- chicago %>%
  mutate(Date = as.Date(substr(date, start = 1, stop = 10))) %>%
  mutate(y_month  = substr(date, start = 1, stop = 7)) %>%
  mutate(month = substr(date, start = 6, stop = 7))


write.csv2(chicago, 'outputs/paper/data/chicago.csv',row.names = FALSE)


########################################################################
############################# la #######################################
########################################################################

LA_2020 <- read.socrata(
  'http://data.lacity.org/resource/2nrs-mtv8.csv',
  app_token = "hPU78MH7zKApdpUv4OVCInPOQ")

# 2014-2019
LA_2014 <- read.socrata(
  "https://data.lacity.org/resource/63jg-8b9z.csv?$where=date_occ >=  '2014-01-01'",
  app_token = "hPU78MH7zKApdpUv4OVCInPOQ"
)

LA <- rbind(LA_2014, LA_2020)
remove(LA_2014)
remove(LA_2020)

# add date
LA <- LA %>%
  mutate(y_month  = substr(date_occ, start = 1, stop = 7)) %>%
  mutate(month = substr(date_occ, start = 6, stop = 7)) %>%
  mutate(year = substr(date_occ, start = 1, stop = 4))

LA$date_occ = as.Date(LA$date_occ)



write.csv2(LA, 'outputs/paper/data/la.csv',row.names = FALSE)

########################################################################
############################# SEATTLE    ###############################
########################################################################

if (exists("seattle")) is.data.frame(get("seattle")) else seattle <- RSocrata::read.socrata(
  "https://data.seattle.gov/api/views/tazs-3rd5/rows.csv?accessType=DOWNLOAD",
  app_token = "hPU78MH7zKApdpUv4OVCInPOQ")
seattle <- seattle %>%
  filter(substr(report_datetime, start = 1, stop = 4) >= '2014')

# add date
seattle <- seattle %>%
  mutate(y_month  = substr(report_datetime, start = 1, stop = 7)) %>%
  mutate(YEAR  = substr(report_datetime, start = 1, stop = 4)) %>%
  mutate(MONTH = substr(report_datetime, start = 6, stop = 7)) %>%
  mutate(Date = as.Date(substr(report_datetime, start = 1, stop = 10)))


write.csv2(seattle, 'outputs/paper/data/seattle.csv',row.names = FALSE)
########################################################################
############################# END  #####################################
########################################################################





