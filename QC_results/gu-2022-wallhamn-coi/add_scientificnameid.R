setwd("/Users/christina/Downloads/dwca-gu-2022-wallhamn-coi-v1/")


############################LOAD LIBRARIES #######################################
library(vegan); packageVersion("vegan")
library(ecodist); packageVersion("ecodist")
library(GGally); packageVersion("GGally")
library(phyloseq); packageVersion("phyloseq")
library(ggplot2); packageVersion("ggplot2")
library(tidyverse); packageVersion("tidyverse")
library(RColorBrewer); packageVersion("RColorBrewer")
library(DECIPHER); packageVersion("DECIPHER")
library(microViz); packageVersion("microViz")
library(ape); packageVersion("ape")
library(decontam); packageVersion("decontam")
library(DT); packageVersion("DT")
library(naniar); packageVersion("naniar")

library(dplyr)

########################################################################################
########################################################################################
########################################################################################

#import the occurrence table (or else biotic data)
occurrence <- read.csv("occurrence.txt", sep = "\t", header=TRUE, row.names = 1)

#select only the taxonomy related columns
taxonomy <- select(occurrence, scientificName, kingdom, phylum, 
                   class, order, family, genus, specificEpithet,
                   infraspecificEpithet)


#RETRIEVE APHIA IDs
#be careful here, run just the next line of code
#not more
species_for_worms_Aphia <- match_taxa(species_for_worms_list, ask=TRUE)
#the function will ask you if it finds ambihuous names
#you will need resolve them by typing the correct numbers 
#corresponding to the correct species names

#  135263 Aurelia        Lamarck, 1816 accepted   exact 
#  122386 Carinina       Hubrecht, 1885           accepted   exact     
#  106485 Oithona        Baird, 1843           accepted   exact     
#  129625 Spio           Fabricius, 1785         accepted   exact     
#  982 Terebellidae   Johnston, 1846            accepted   exact     

#there may be species for which no match was found
species_for_worms_Aphia <- species_for_worms_Aphia %>% drop_na()
#if no species rows are deleted, ok
#if some rows are deleted, let me know

#split the column scientificNameID
split_into_multiple <- function(column, pattern = ", ", into_prefix){
  cols <- str_split_fixed(column, pattern, n = Inf)
  # Sub out the ""'s returned by filling the matrix to the right, with NAs which are useful
  cols[which(cols == "")] <- NA
  cols <- as.tibble(cols)
  # name the 'cols' tibble as 'into_prefix_1', 'into_prefix_2', ..., 'into_prefix_m' 
  # where m = # columns of 'cols'
  m <- dim(cols)[2]
  
  names(cols) <- paste(into_prefix, 1:m, sep = "_")
  return(cols)
}

species_for_worms_Aphia <- species_for_worms_Aphia %>% 
  bind_cols(split_into_multiple(.$scientificNameID, ":", "scientificNameID")) %>% 
  # selecting those that start with 'type_' will remove the original 'type' column
  select(scientificName, match_type, starts_with("scientificNameID_"))

colnames(species_for_worms_Aphia)[colnames(species_for_worms_Aphia) == "scientificNameID_5"] ="aphiaID"
species_for_worms_Aphia <- select(species_for_worms_Aphia, scientificName, aphiaID)
