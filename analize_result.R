library(stringr)
library(log4r)
library(openxlsx)

# setup
logger <- create.logger()
logfile(logger) <- file.path('output.log')
level(logger) <- "DEBUG"

# reports' name
report_names <- NULL
report_file_names <- list.files("scripts/", pattern = ".+analysis_report.R")
report_file_names <- apply(data.frame(report_file_names), 1, FUN = strsplit, ".", fixed = TRUE) # todo
for (i in c(1:length(report_file_names))){report_names[i] <- report_file_names[[i]][[1]][1]}
print(report_names)

# database's name # todo: connect db and get all the name
# org_short_names = c("beaconaco", "general", "cvalleycjr")
source("get_org.R")
org_short_names <-  ret
print(org_short_names)

result <- data.frame()
count_successful <- 0

for (i in 1:length(report_names)){
  for (j in 1:length(org_short_names)){
    report_name <- report_names[i]
    org_short_name <- org_short_names[j]
    # run the system command
    script = sprintf("Rscript scripts/main.R -n %s -p '{\"org_short_name\": [\"%s\"], \"start_month_number\": \"201001\", \"end_month_number\":\"201712\", \"report_start_date\": \"2010-01-01\", \"report_end_date\":\"2017-01-01\"}' -o %s -d Data/r-output/ 2>&1",report_name, org_short_name, org_short_name)
    
    # get the output ( Have alreazdy piped the stderr to stdout)
    section <- paste(system(script, intern = TRUE), collapse = " ")
    
    # Check the status
    if (grepl("Error", section, fixed = TRUE)){
      status <- section
      # TODO: using regx here
      # status <- str_match(paste(section, collapse = " "), "Error\\s(\\w+|\\W)+?\\.")[1]
    }else{
      status <- "Successful"
      count_successful <- count_successful + 1
    }
    info(logger, status)
    result[i, j] <- status
  }
}

# Save to XLSX file
names(result) <- org_short_names
result$reportName <- report_names
result2 <- result[,c("reportName", names(result)[1:length(names(result))-1])] 


wb <- createWorkbook()
sheet1 <- "Summary"
addWorksheet(wb, sheet1)
# Add header
writeData(wb, sheet1, 
          x = paste("Check all combinatioin of scripts and db"), startCol = 1, startRow = 1)
styleList <- common_excel_style_list()
styleHeading1 <- createStyle(fontSize = 16, textDecoration = "bold", fontColour = "midnightblue")
addStyle(wb, sheet1, styleHeading1, rows = 1, cols = 1)

# Content
addStyle(wb, sheet1, createStyle(fontSize = 14, fontColour = "midnightblue"), rows = c(2:100), cols = c(1:ncol(result2)))
setColWidths(wb, sheet1, cols = c(1:ncol(result2)), widths = "60")
writeDataTable(wb, sheet1, result2, startCol = 1, startRow = 3, firstColumn = TRUE)
saveWorkbook(wb, "my_result.xlsx", overwrite = TRUE)


