# dataprocessR

This package processes plant and ground cover data collected in the field and imports them to the Southeast Utah Group (SEUG) Long-term Vegetation Monitoring Program (LTVMP) database. Plant cover and frequency and ground cover data are collected in the field using paper datasheets, then transcribed into Excel workbooks. This package imports the workbook files into R, restructures the data, then exports them to the database. Onset data loggers collect temperature, relative humidity, and precipitation data that are exported to comma delimited files (\*.csv) using the HOBOware application from Onset. The [raindancer](https://github.com/scoyoc/raindancer) package is used to import these data into R and summarize them; this package then exports the processed data to the SEUG LTVMP database.

**Version:** 1.0.0

**Depends:** R (\>= 4.0)

**Imports:** dplyr, glue, lubridate, raindancer, RODBC, stringr, tibble, tidyr

**Author & Maintainer:** [Matthew Van Scoyoc](https://github.com/scoyoc)

**Issues:** <https://github.com/scoyoc/dataprocessR/issues>

**License:** MIT + file [LICENSE](https://github.com/scoyoc/dataprocessR/blob/master/LICENSE.md)

**URL:** <https://github.com/scoyoc/dataprocessR>

**Documentation:** [Vignette](https://github.com/scoyoc/dataprocessR/blob/master/doc/dataprocessR_pdf.pdf) and man pages.

## Installation

``` r
devtools::install_github("scoyoc/dataprocessR", build_vignettes = TRUE)
```

## Examples

``` r
library("dataprocessR")

# Connect to DB ----
my_db <- RODBC::odbcConnectAccess2007("C:/path/to/database.accdb")

# Process weather data ----
#-- List files
wx_dir <- "C:/path/to/data"
wx_files <- list.files(wx_dir, pattern = ".csv", full.names = TRUE,
                       recursive = FALSE)
#-- Process a single file
export_hobo(my_file = wx_files[1], my_db = my_db,
            import_table = "tblWxImportLog",
            raw_data_table = "tblWxData_raw",
            prcp_data_table = "tblWxData_PRCP",
            temp_rh_data_table = "tblWxData_TEMP_RH",
            details_table = "tblWxLoggerDetails")

#-- Batch process several files
lapply(wx_files[2:10], function(this_file){
  export_hobo(my_file = this_file, my_db = my_db,
              import_table = "tblWxImportLog",
              raw_data_table = "tblWxData_raw",
              prcp_data_table = "tblWxData_PRCP",
              temp_rh_data_table = "tblWxData_TEMP_RH",
              details_table = "tblWxLoggerDetails",
              view = FALSE)
})

# Process plant and ground cover data ----
#-- List files
veg_dir <- "C:/pate/to/data"
veg_files <- list.files(veg_dir, pattern = ".xls", full.names = TRUE, 
                        recursive = FALSE)

#-- Process a single file
export_xls(my_xls = veg_files[1], my_db = my_db,
           data_table = tblData_FreqCov,
           sampling_event_table = tblSamplingEvent,
           import_table = tblImportRecord)

#-- Batch process several files
lapply(veg_files[2:10], function(this_xls){
  export_xls(my_xls = this_xls, my_db = my_db,
             data_table = tblData_FreqCov,
             sampling_event_table = tblSamplingEvent,
             import_table = tblImportRecord,
             view = FALSE)
})

# Close database ----
RODBC::odbcClose(my_db); rm(my_db)
```

## List of Functions

-   `export_hobo_2008`: processes data from Onset HOBO loggers used from 2008-2019.

-   `export_hobo`: processes data from Onset HOBO loggers used from 2020-present.

-   `export_xls`: read Excel workbooks into R and exports the data to the SEUG LTVMP database.

-   `import_xls`: imports SEUG long-term vegetation monitoring data from Microsoft Excel workbooks into R.
