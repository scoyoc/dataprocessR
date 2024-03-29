% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/export_xls.R
\name{export_xls}
\alias{export_xls}
\title{Export LTVMP data to database}
\usage{
export_xls(
  my_xls,
  my_db,
  data_table,
  sampling_event_table,
  import_table,
  verbose = TRUE,
  view = TRUE
)
}
\arguments{
\item{my_xls}{A character string of the complete file path of the *.xls
file.}

\item{my_db}{A connected database from \code{\link{RODBC}}.}

\item{data_table}{A character string of the name of the frequency and cover
data table.}

\item{sampling_event_table}{A character string of the name of the sampling
event table.}

\item{import_table}{A character string of the name of the import log.}

\item{verbose}{Optional. Prints messages to the console showing function
progress. Default is TRUE. If FALSE, messages are suppressed.}

\item{view}{Optional. Prints data to console before writing them to the
database. Default is TRUE. If FALSE, data are not printed and there is no
prompt before writing data to the database.}
}
\value{
Data is written to database tables. Objects are not returned.
}
\description{
This function uses \code{\link{import_xls}} to read the Excel workbooks into
R, then exports the components returned by \code{\link{import_xls}} to
tables in the SEUG LTVMP database.
}
\details{
This function uses \code{\link{import_xls}} to import LTVMP data
into R and then export it to a connected Microsoft Access database.
}
\examples{
\dontrun{
library("dataprocessR")

# Connect to DB
my_db <- RODBC::odbcConnectAccess2007("C:/path/to/database.accdb")

# List files
my_dir <- "C:/path/to/data"
file_list <- list.files(my_dir, pattern = ".xls", full.names = TRUE,
                        recursive = FALSE)

# Process file and save to database
export_xls(my_xls = file_list[1], my_db = my_db,
           data_table = "tblData_FreqCov",
           sampling_event_table = "tblSamplingEvent",
           import_table = "tblImportRecord")
}
}
\seealso{
\code{\link{import_xls}}, \code{\link{RODBC}},
\code{\link[RODBC]{sqlSave}}, \code{\link[RODBC]{odbcConnectAccess2007}}
}
