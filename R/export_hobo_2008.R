#' Export Onset Hobo data to Access Database
#'
#' This function uses the [raindancer](https://github.com/scoyoc/raindancer)
#'     package to processes data from Onset HOBO loggers used in the SEUG LTMVP
#'     from 2008-2019. It then exports the data to a Microsoft Access database.
#'
#' @param my_file A character string of the complete file path of your *.csv
#'     file.
#' @param my_db A connected database from \code{\link{RODBC}}.
#' @param import_table A character string of the name of the import log table.
#' @param raw_data_table A character string of the name of the raw data table.
#' @param prcp_data_table A character string of the name of the processed
#'     precipitation data table.
#' @param temp_rh_data_table A character string of the name of the processed
#'     temperature and relative humidity data table.
#' @param details_table A character string of the name of the logger details
#'     table.
#' @param verbose Logical. Show messages showing progress. Default is TRUE. If
#'     FALSE, messages are suppressed.
#' @param view Logical. Prints data to console before writing them to the
#'     database. Default is TRUE. If FALSE, data are not printed and there is no
#'     prompt before writing data to the database.
#'
#' @details This function uses two functions from the raindacer package.
#'     \code{\link[raindancer]{import_hobo_2008}} is usec to read Hobo data in
#'     into R, and then \code{\link[raindancer]{process_hobo}} is used to
#'     summarize the data. The processed data are then exported to a connected
#'     Microsoft Access database.
#'
#' @return Data is written to database tables. Objects are not returned.
#'
#' @seealso [raindancer](https://github.com/scoyoc/raindancer),
#'     \code{\link[raindancer]{import_hobo_2008}},
#'     \code{\link[raindancer]{raindance}}, \code{\link[raindancer]{sundance}},
#'     \code{\link[raindancer]{process_hobo}}, \code{\link{RODBC}},
#'     \code{\link[RODBC]{sqlSave}}, \code{\link[RODBC]{odbcConnectAccess2007}}
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library("raindancer")
#' library("dataprocessR")
#'
#' # Connect to DB
#' my_db <- RODBC::odbcConnectAccess2007("C:/path/to/database.accdb")
#'
#' # List files
#' my_dir <- "C:/path/to/data"
#' file_list <- list.files(my_dir, pattern = ".csv", full.names = TRUE,
#'                         recursive = FALSE)
#' # Select file
#' my_file <- file_list[10]
#'
#' # Process file and save to database
#' export_hobo_2008(my_file = my_file, my_db = my_db,
#'                  import_table = "tblWxImportLog",
#'                  raw_data_table = "tblWxData_raw",
#'                  prcp_data_table = "tblWxData_PRCP",
#'                  temp_rh_data_table = "tblWxData_TEMP_RH",
#'                  details_table = "tblWxLoggerDetails")
#' }
export_hobo_2008 <- function(my_file, my_db, import_table, raw_data_table,
                              prcp_data_table, temp_rh_data_table,
                              details_table, verbose = TRUE, view = TRUE){

  # Check if file has been processed
  if(import_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
     if(basename(my_file) %in% RODBC::sqlFetch(my_db, import_table)$FileName){
       stop("File has already been processed.")
       }
  }

  if(verbose == TRUE) message(glue::glue("Processing {basename(my_file)}"))
  #-- Process hobo file --
  dat <- raindancer::import_hobo_2008(my_file) |> raindancer::process_hobo()
  if(view == TRUE){
    print(dat)
    readline(prompt = "Press [enter] to export data to database.")
    }

  #-- Import Record --
  # Prep data
  file_info <- dat$file_info |>
    dplyr::mutate("ImportDate" = as.character(lubridate::today()))

  #-- Raw Data --
  # Prep data
  data_raw <- dat$data_raw |>
    dplyr::mutate("DateTime" = as.character(DateTime))
  # Export to DB
  if(verbose == TRUE) message("- Writing raw data to database")
  if(!raw_data_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
    RODBC::sqlSave(my_db, data_raw, tablename = raw_data_table,
                   append = FALSE, rownames = FALSE, colnames = FALSE,
                   safer = FALSE, addPK = TRUE, fast = TRUE)
    } else(
      RODBC::sqlSave(my_db, data_raw, tablename = raw_data_table,
                     append = TRUE, rownames = FALSE, colnames = FALSE,
                     addPK = TRUE, fast = TRUE)
      )

  #-- Data --
  # Prep data
  if(verbose == TRUE) message("- Writing processed data to database")
  if(file_info$Element == "PRCP"){
    prcp_dat <- dat$data |>
      dplyr::mutate("PlotID" = file_info$PlotID,
                    "DateTime" = as.character(DateTime,
                                              format = "%Y-%m-%d %H:%M:%S"))
    # Export to DB
    if(!prcp_data_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
      RODBC::sqlSave(my_db, prcp_dat, tablename = prcp_data_table,
                     append = FALSE, rownames = FALSE, colnames = FALSE,
                     safer = FALSE, addPK = TRUE, fast = TRUE)
      } else({
        RODBC::sqlSave(my_db, prcp_dat, tablename = prcp_data_table,
                     append = TRUE, rownames = FALSE, colnames = FALSE,
                     addPK = TRUE, fast = TRUE)
        })
    } else({
      tr_dat <- dat$data |>
        dplyr::mutate("PlotID" = file_info$PlotID,
                      "Date" = as.character(Date,
                                            format = "%Y-%m-%d %H:%M:%S"))
      # Export to DB
      if(!temp_rh_data_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
        RODBC::sqlSave(my_db, tr_dat, tablename = temp_rh_data_table,
                       append = FALSE, rownames = FALSE, colnames = FALSE,
                       safer = FALSE, addPK = TRUE, fast = TRUE)
        } else({
          RODBC::sqlSave(my_db, tr_dat, tablename = temp_rh_data_table,
                       append = TRUE, rownames = FALSE, colnames = FALSE,
                       addPK = TRUE, fast = TRUE)
          })
  })

  #-- Details --
  # Export to DB
  if(verbose == TRUE) message("- Writing logger details to database")
  if(!details_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
    RODBC::sqlSave(my_db, dat$details, tablename = details_table,
                   append = FALSE, rownames = FALSE, colnames = FALSE,
                   safer = FALSE, addPK = TRUE, fast = TRUE)
    } else(
      RODBC::sqlSave(my_db, dat$details, tablename = details_table,
                     append = TRUE, rownames = FALSE, colnames = FALSE,
                     addPK = TRUE, fast = TRUE)
      )

  # Export Import Record to DB
  if(verbose == TRUE) message("- Writing import log to database")
  if(!import_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
    RODBC::sqlSave(my_db, file_info, tablename = import_table,
                   append = FALSE, rownames = FALSE, colnames = FALSE,
                   safer = FALSE, addPK = TRUE, fast = TRUE)
    } else(RODBC::sqlSave(my_db, file_info, tablename = import_table,
                     append = TRUE, rownames = FALSE, colnames = FALSE,
                     addPK = TRUE, fast = TRUE)
      )
}
