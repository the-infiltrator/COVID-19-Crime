## Analysing the effects of COVID-19 on Crime in the United States

#### *A deep dive into criminal activity during the pandemic*

This repo contains the code and the associated model cards for a manuscript examining the issue of criminal activity during the pandemic. The COVID-19 pandemic caused the various state-level governments in the United States to issue stay-at-home orders in early 2020. These policy measures resulted in sweeping impacts on the everyday life of people with mostly negative implications.  The more negative implications of the pandemic have generally eclipsed the more positive aspects such as the reduction of crime rates by 37% worldwide [@boman2021global], and also the noticeable drop in carbon emissions [@bauwens2020impact] and elevation of air quality around the world—in turn reducing pollution-related respiratory issues  [@dutheil2020covid]. While crime rates globally have gone down, it is also important to take a granular look at the crime data to observe which types of crimes have been most affected,
and further, examine if there is a significant correlation between crime rates and COVID-19 cases — which is precisely the goal of this study. We achieve our goal of analyzing the pandemic data in conjunction with crime data obtained from the official city websites through time series modeling and also exploratory data analysis focusing on the criminal activity in key US cities such as Chicago,  Los Angeles, Philadelphia, and Seattle.  Each city has been chosen specifically to reflect different American aspects, geographical as well as socio-economic, to enable us to form more generalizable as well as granular conclusions.

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

### Data Access

The primary data set used is publicly available from the the R, COVID-19 Data Hub containing a daily summary of COVID-19 cases, deaths, recovered, tests, vaccinations, and hospitalizations for 230+ countries, 760+ regions, and 12000+ administrative divisions of lower level including policy measures, mobility, and geospatial data. Furthermore, we use city data for each city involved in our study to examine the crime rates across the pandemic. 
