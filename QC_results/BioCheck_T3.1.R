getwd()
setwd("/Users/christina/EMBRC Dropbox/Christina Pavloudi/DTO-BioFlow/D3.4/")

R.Version()
citation()

#install.packages("devtools")
#devtools::install_github("EMODnet/EMODnetBiocheck")
library(EMODnetBiocheck)
library(dplyr)
library(EML)

################################################################################
################################################################################
################################################################################

#Load data
#For IPT resources (recommended)
#loopcheckIPTdataset ("http://ipt.iobis.org/training/archive?r=biofun_2009", tree="yes")

loopcheckIPTdataset ("https://www.gbif.se/ipt/resource?r=gu-2022-wallhamn-coi", tree="yes")
loopcheckIPTdataset ("https://www.gbif.se/ipt/resource?r=gu-2022-wallhamn-18s", tree="yes")
loopcheckIPTdataset ("https://nzobisipt.niwa.co.nz/resource?r=pacman_suva_edna", tree="yes")


#For loaded data tables (to use on unpublished datasets 
#or if no IPT resource is available)

# Read the XML file
Meta <- read_eml("MGYS00004404/meta.xml", from = "xml")
class(Meta)

#Event_field <- as.data.frame(Meta$core)
#Occurrence_field <- as.data.frame(Meta$extension)

Meta <- as.data.frame(Meta)
Meta <- t(Meta)
Meta <- as.data.frame(Meta)
Meta <- tibble::rownames_to_column(Meta, "fields")
Meta <- Meta %>% 
  dplyr::rename(ParameterURL = V1)

Event_field <- Meta %>% 
  filter(startsWith(as.character(fields), 'core.field.term'))
Event_field <- Event_field  %>%
  mutate(colnames = ParameterURL)
Event_field$colnames <- gsub("http://rs.tdwg.org/dwc/terms/" , '', Event_field$colnames)

first_row_event_field = data.frame(fields = c("core"), 
                                   ParameterURL = c(""), 
                                   colnames = c("eventID"),
                                   row.names = c("0"))
Event_field <- bind_rows(first_row_event_field, Event_field)

Event <- read.table("MGYS00004404/event.txt", sep = ",", header=FALSE)
Event$V3 <- gsub("&quot;" , '', Event$V3)
colnames(Event) <- Event_field$colnames

Occurrence_field <- Meta %>% 
  filter(startsWith(as.character(fields), 'extension.field.term'))
Occurrence_field <- Occurrence_field  %>%
  mutate(colnames = ParameterURL)
Occurrence_field$colnames <- gsub("http://rs.tdwg.org/dwc/terms/" , '', Occurrence_field$colnames)

first_row_occurrence_field = data.frame(fields = c("extension"), 
                                   ParameterURL = c(""), 
                                   colnames = c("extensionID"),
                                   row.names = c("0"))
Occurrence_field <- bind_rows(first_row_occurrence_field, Occurrence_field)

Occurrence <- read.table("MGYS00004404/occurrence.txt", sep = ",", header=FALSE)

colnames(Occurrence) <- Occurrence_field$colnames
Occurrence$basisOfRecord[Occurrence$basisOfRecord == 'MATERIAL_SAMPLE'] <- 'MaterialSample'

Occurrence <- Occurrence %>%
  mutate(across(everything(), ~ifelse(.=="", NA, as.character(.))))



IPTreport <- checkdataset(Event = Event, Occurrence = Occurrence, tree = TRUE)
write.table(IPTreport$plot_coordinates, "MGYS00004404/IPTreport_coordinates_MGYS00004404.tsv", quote = FALSE, na = "", sep = "\t", row.names = FALSE)  
write.table(IPTreport$dtb$eventerror_table, "MGYS00004404/IPTreport_eventerror_table_MGYS00004404.tsv", quote = FALSE, na = "", sep = "\t", row.names = FALSE)  
write.table(IPTreport$dtb$occurrenceerror_table, "MGYS00004404/IPTreport_occurrenceerror_table_MGYS00004404.tsv", quote = FALSE, na = "", sep = "\t", row.names = FALSE)  
write.table(IPTreport$dtb$general_issues, "MGYS00004404/IPTreport_general_issues_MGYS00004404.tsv", quote = FALSE, na = "", sep = "\t", row.names = FALSE)  



################################################################################
################################################################################
################################################################################
