# AERONET data download

## Data Description

As the development of retrieving algorithms, different versions of products were released since 2006. In general, higher version products could have more strict quality control processes. Therefore, higher version products were suggested to be applied in the data analysis. 

Due to the requirement of real-time visualization, the products inside each version were divided into different levels (level 1.0, 1.5 and 2.0). 

+ Level 1.0 - unscreened data but may not have final calibration applied
+ Level 1.5 - cloud-screened data but may not have final calibration applied. These data are not quality assured.
+ Level 2.0 - pre- and post-field calibration applied, cloud-screened, and quality-assured data 

Since 5 January 2018, Version 3 **AOD** (Aerosol Optical Depth), **SDA** (Spectral De-convolution Algorithm) and **INV** (Aerosol Microphysics and Radiative Properties) were released. 

## Data Download

For each of the produces, there are three ways to access the products:

- Web Service
- Download Tool (for each individual site)
- Download All Sites (for all sites)
  
The [`Web Service`](2) is very easily to be embedded in the automatic programs but is less efficient if you want to analysis all history data. `Download Tool` is relatively straight forward and well be very suitable if you only want to analysis several sites. On the contrary, `Download All Sites` is a all-in-one method but be attention, the download data file would be 26 GB for AOD data only. Be sure you have enough space to store all the AOD, SDA and INV data.

### Web Service

The AERONET products, which you can see through the data display web page (see [here](1)), can be easily downloaded through AERONET [`Web Service`](2). In this repository, we provided MATLAB functions to extract data through such web portal. Below are the three main product types that we are interested:

|Product|Description|Web Service|
|:-----:|:----------|:----|
|AOD|Direct products from measurements|https://aeronet.gsfc.nasa.gov/print_web_data_help_v3.html|
|SDA|Outputs from spectral De-convolution algorithm|https://aeronet.gsfc.nasa.gov/print_web_data_help_v3.html|
|INV|Aerosol microphysics and Radiative Properties|https://aeronet.gsfc.nasa.gov/print_web_data_help_v3_inv.html|

[1]: https://aeronet.gsfc.nasa.gov/cgi-bin/data_display_inv_v3?site=Punta_Arenas_UMAG&nachal=0&year=2020&month=7&day=16&aero_water=0&level=2&if_day=0&if_err=0&place_code=10&DATA_TYPE=76&year_or_month=0
[2]: https://aeronet.gsfc.nasa.gov/cgi-bin/print_web_data_inv_v3