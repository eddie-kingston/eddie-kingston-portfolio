library(dplyr) # type install.packages("dplyr") in the console if you don't have this package installed already

######################## SECTION 1 - Downloading Historicals
source <- "S:/Historical Inquiries"
target <- "S:/Eddie" # Replace my name with yours

guid_list <- toupper(c("709852a3-92af-4b72-a7bd-2cf67ec88ac3","5ce4564a-4eb6-4326-be4e-77dfd4df08c8","f1d713d3-e69f-41e2-b346-864e4d1c0839")) # Put the GUIDs inside the quotation marks. If fewer than 3, delete any unnecessary commas
# and quotation marks. If more than 3, add commas and quotation marks when necessary.
years <- c("2022 and Older", "2023", "2024","2025","2026+")


# If necessary, uncomment line 14 below and only select the necessary year indices. 1 is "2022 and Older", 2 is "2023", etc.
# For example, if a PM only wants 2024 and younger, write:
# years <- years[c(3,4,5)]


process_guids <- function(guid, year) {
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

lapply(guid_list, function(guid) {
  lapply(years, function(year) {
    process_guids(guid, year)
  })
})

######################## SECTION 2 - Merging QIs into one
mergers  <- function(pat) {
  folder1 <- target
  list.files(folder1, full.names = TRUE, pattern = pat) # combines all the files we want
}

# Combines all files with same starting name
file_comb <- function(univ) {
  merge <- mergers(paste0(univ,"*"))
  combined_file <- data.frame()
  for (file in merge) {
    file_path <- paste0(file) 
    file_data <- read.csv(file_path)
    combined_file <- rbind(combined_file,file_data)
  }
  write.csv(combined_file, file = file.path(paste0("S:/Eddie"),paste0(univ,"_QIs_Combined.csv"))) # Change my name to yours

}

lapply(guid_list, function(guid) {
  file_comb(guid)
}
)

######################## SECTION 3 - Filtering QIs
# Here you can filter QIs to fit whatever parameters the PM is asking for.
# The most common requests we tend to get are for specific grad years and GPAs. We already filtered grad years, so for GPAs,

LA <- read.csv("S:/Eddie/F1D713D3-E69F-41E2-B346-864E4D1C0839_QIs_Combined.csv") # Replace school with the actual name of the file
NY <- read.csv("S:/Eddie/5CE4564A-4EB6-4326-BE4E-77DFD4DF08C8_QIs_Combined.csv")
miami <- read.csv("S:/Eddie/709852A3-92AF-4B72-A7BD-2CF67EC88AC3_QIs_Combined.csv")

LA <- LA %>%
  filter(captureDate >= "2023-09-01")

NY <- NY %>%
  filter(captureDate >= "2023-09-01")

miami <- miami %>%
  filter(captureDate >= "2023-09-01")

write.csv(LA, "S:/Eddie/New_York_Film_Academy_-_Los_Angeles_September_QIs.csv")
write.csv(NY, "S:/Eddie/New_York_Film_Academy_-_New_York_September_QIs.csv")
write.csv(miami, "S:/Eddie/New_York_Film_Academy_-_Miami_September_QIs.csv")

######################## SECTION 4 - Downloading and Filtering Prospects
source(file.path(Sys.getenv('HOME'), 'Github/BizOps/is_scripts/prospect_request_builder.R'))
pull_niche_data() # this might take up to 30 minutes if not loaded already


# Change these if needed; default is all time (1900-today)
start_date <- '2023-09-01'
end_date <- Sys.Date()
guid_list <- toupper(c("709852a3-92af-4b72-a7bd-2cf67ec88ac3","5ce4564a-4eb6-4326-be4e-77dfd4df08c8","f1d713d3-e69f-41e2-b346-864e4d1c0839"))
salesforce_id_list <- c('','')


pull_sent_prospects_account(guid_list, date_start = start_date, date_end = end_date)
# In case this doesn't work and you have multiple GUIDs, uncomment lines 97, 98, and 99 below:

# lapply(guid_list, function(guid) {
# pull_sent_prospects_account(guid_list, date_start = start_date, date_end = end_date)
# })

school <- read.csv("S:/in-market-leads/pulling_sent_prospects/.csv") # Fill in the file name and rename it as appropriate

# If necessary, uncomment line 105 and fill in any relevant filters
school_filter <- school 
# %>% filter() # Fill in any necessary filters, for example: filter(HighSchoolGPA >= 3.0)

write.csv(school_filter, "S:/Eddie/school_Filtered.csv") # Again, replace every instance of school with the actual name
