# Install using install.packages("salesforcer") in the console if you haven't already
library(salesforcer)

source <- "S:/Historical Inquiries" 
target <- "S:/Historical QI Logs" 

# Find GUIDs
bulk_list <- sf_query(paste0("SELECT GUID__c, Name
                        FROM Prospect_Order_Form__c 
                        WHERE Quote_or_Order__c = 'Order'
                        AND Bulk_or_Subscription__c = 'Bulk'
                        AND RecordType.Name = 'Inquiries'
                        AND Status__c = 'Pending Fulfillment'
                        AND (Account__r.Reporting_Type__c = '2 year college'
                                  OR Account__r.Reporting_Type__c = '4 year college'
                                  OR Account__r.Reporting_Type__c = 'College Network'
                                  OR Account__r.Reporting_Type__c = 'Graduate School')"))


# Comment out the line below if you need to manually add Grad L2 GUIDs in the c() function, separated by commas.
# bulk_list <- append(bulk_list$GUID__c, c())

years <- c("2022 and Older", "2023", "2024", "2025", "2026+", "Grad Schools")

# Find which POFs are transfers and which are not and split the bulk list accordingly
transfer_extract <- rep(0,length(bulk_list$Name))
transfer_yes_or_no <- rep(0,length(bulk_list$Name))
for (i in 1:length(bulk_list$Name)) {
  transfer_extract[i] <- sub(".*\\b(Transfer)\\b.*", "\\1", bulk_list$Name[i])
  ifelse(transfer_extract[i] == "Transfer", transfer_yes_or_no[i] <- TRUE, transfer_yes_or_no[i] <- FALSE)
}
bulk_list <- cbind(bulk_list,transfer_yes_or_no)
bulk_list_transfer <- subset(bulk_list, transfer_yes_or_no == TRUE)
bulk_list_no_transfer <- subset(bulk_list, transfer_yes_or_no == FALSE)


# Processing functions that cycle through all years and GUIDs. If GUID exists in a folder corresponding to a certain year, copy it to 
# Historical QI Logs and rename it so that the file name has that year at the end
process_transfer <- function(guid) {
  folder_path_transfer <- file.path(source, "adult_transfer")
  pattern_transfer <- guid
  file.list_transfer <- list.files(folder_path_transfer, pattern = pattern_transfer)
  
  if (length(file.list_transfer > 0)) {
    file.copy(file.path(folder_path_transfer, file.list_transfer), target)
    
    # Modify the file names
    new_file_names_transfer <- gsub(".csv", "_Transfer.csv", file.list_transfer)
    file.rename(file.path(target, file.list_transfer), file.path(target, new_file_names_transfer))
  }
}

process_no_transfer <- function(guid, year) {
  folder_path <- file.path(source, year)
  pattern <- guid
  file.list <- list.files(folder_path, pattern = pattern)
  
  if (length(file.list) > 0) {
    file.copy(file.path(folder_path, file.list), target)
    
    # Modify the file names
    new_file_names <- gsub(".csv", paste0("_", gsub(" ", "_", year), ".csv"), file.list)
    file.rename(file.path(target, file.list), file.path(target, new_file_names))
  }
}

# Apply the function to all combinations of GUIDs and years
lapply(bulk_list_transfer$GUID__c, function(guid) {
  process_transfer(guid)
})

lapply(bulk_list_no_transfer$GUID__c, function(guid) {
  lapply(years, function(year) {
    process_no_transfer(guid, year)
  })
})
