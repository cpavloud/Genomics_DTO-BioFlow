# ============================================================
'R code for DTO-BioFlow project

Christina Pavloudi
christina.pavloudi@embrc.eu
https://cpavloud.github.io/mysite/

	Copyright (C) 2025 Christina Pavloudi
  
    This script is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
  
    This script is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.'

# =============================================================

############################LOAD LIBRARIES #######################################

library(dplyr)
library(obistools)
library(tidyverse)

########################################################################################
########################################################################################
########################################################################################

#import the occurrence table (or else biotic data)
occurrence <- read.csv("occurrence.txt", sep = "\t", header=TRUE, row.names = 1)

#convert the rownames into an rownames column
occurrence <- tibble::rownames_to_column(occurrence, "rownames")

#subset the rows with Unassigned scientificName
occurrence_unassigned <- occurrence %>% dplyr::filter(scientificName == "Unassigned")
#add a scientificNameID column
occurrence_unassigned <- occurrence_unassigned %>% mutate(scientificNameID = NA)

#select the rest of the occurrences
occurrence_assigned <- anti_join(occurrence, occurrence_unassigned)

#select only the taxonomy related columns
taxonomy <- select(occurrence_assigned, rownames,scientificName, kingdom, phylum, 
                   class, order, family, genus, specificEpithet,
                   infraspecificEpithet)

#replace empty cells with NA
taxonomy[taxonomy == ''] <- NA

#correct columns
taxonomy$infraspecificEpithet <- sub('XXX', NA, taxonomy$infraspecificEpithet)
taxonomy$infraspecificEpithet <- sub('XX', NA, taxonomy$infraspecificEpithet)

#add a taxonname column
taxonomy <- taxonomy %>%
  mutate(taxonname = case_when(grepl("_XX", genus) ~ specificEpithet,
                              grepl("_X", genus) ~ specificEpithet, 
                              genus == "Ichthyophorba" ~ paste(specificEpithet, infraspecificEpithet), 
                              specificEpithet == "X" ~ genus, 
                              grepl("BOLD", scientificName) ~ paste(genus, specificEpithet)))

#separate the taxonomy files
BOLD <- taxonomy[startsWith(as.character(taxonomy$scientificName), 'BOLD'),]
rest <- anti_join(taxonomy, BOLD)

#create a list with the unique taxa from the rest data table
rest_for_worms <- select(rest, scientificName)
rest_for_worms <- unique(rest_for_worms)

rest_for_worms_list <- list()
for (i in rest_for_worms) {
  rest_for_worms_list <- append(rest_for_worms_list, i)
}
rest_for_worms_list <- as.character(rest_for_worms_list)

#create a list with the unique taxa from the BOLD data table
BOLD_for_worms <- select(BOLD, taxonname)
BOLD_for_worms <- unique(BOLD_for_worms)

BOLD_for_worms_list <- list()
for (i in BOLD_for_worms) {
  BOLD_for_worms_list <- append(BOLD_for_worms_list, i)
}
BOLD_for_worms_list <- as.character(BOLD_for_worms_list)


#RETRIEVE APHIA IDs
rest_for_worms_Aphia <- match_taxa(rest_for_worms_list, ask=TRUE)
BOLD_for_worms_Aphia <- match_taxa(BOLD_for_worms_list, ask=TRUE)

#the function will ask you if it finds ambihuous names
#you will need resolve them by typing the correct numbers 
#corresponding to the correct species names

#1  126892 Gobius niger   Linnaeus, 1758 accepted   exact     
#1  138225 Musculus       Röding, 1798 accepted   exact     
#2  122817 Oerstedia dorsalis (Abildgaard, 1806) accepted exact     

#there is one species in the occcurrence data frame with a non-valid name
#subsequently in the BOLD data frame
#Lepthyphantes leprosus should be corrected to Leptyphantes leprosus
BOLD$taxonname <- sub('Lepthyphantes leprosus', 'Leptyphantes leprosus', BOLD$taxonname)

#merge the AphiaIDs with the taxonomy tables
BOLD <- merge(BOLD, BOLD_for_worms_Aphia, by.x = 'taxonname', by.y = 'scientificName')
rest <- merge(rest, rest_for_worms_Aphia, by.x = 'scientificName', by.y = 'scientificName')

#merge the two data frames
BOLD_rest <- rbind(BOLD, rest)
#select just the columns of interest
BOLD_rest <- select(BOLD_rest, rownames, scientificNameID)
BOLD_rest <- BOLD_rest  %>% remove_rownames %>% column_to_rownames(var="rownames")

#merge the BOLD_rest with the original occurrence assigned table
occurrence_assigned <- occurrence_assigned  %>% remove_rownames %>% column_to_rownames(var="rownames")
occurrence_assigned <- cbind(occurrence_assigned, BOLD_rest)

occurrence_unassigned <- occurrence_unassigned  %>% remove_rownames %>% column_to_rownames(var="rownames")
occurrence <- occurrence  %>% remove_rownames %>% column_to_rownames(var="rownames")


#merge the two data frames to create the updated occcurrence table
occurrence_updated <- rbind(occurrence_assigned, occurrence_unassigned)

