This folder contains the results of the [EMODnetBiocheck tool](https://github.com/EMODnet/EMODnetBiocheck) on the Genomics datasets that are identified as priority by Task 3.1. In order for the datasets to be published to [EMODnet Biology catalogue](https://emodnet.ec.europa.eu/geonetwork/srv/eng/catalog.search#/search?resultType=details&sortBy=sortDate&from=1&to=20) (and subsequently the DTO), we are checking if they meet the OBIS guidelines.

Several of those datasets have been analyzed by [MGnify](https://www.ebi.ac.uk/metagenomics) and harvested by [GBIF](https://www.gbif.org/publisher/ab733144-7043-4e88-bd4f-fca7bf858880). Those genomics datasets cannot be retrieved via an IPT resource URL, therefore the QC check needs to be done using the "loaded data tables" option.





**Questions**
*If genomics datasets analysed by MGnify and already published in GBIF do not pass the EMODnet QC, who will be responsible for correcting the issues? Would it be GBIF, MGnify, someone from Task 3.1 of DTO-BioFlow or EMODnet?*
It depends on what the issue would be:  
If there is required information that was not provided by the initial data provider (to ENA/NCBI), then it would be on the **data provider**.  
If there is required information not being provided by MGnify, then it would be on **MGnify**.  
If there is required information that is provided but not captured in the DarwinCore, then it would be on **GBIF** (or whoever is responsible for the conversion to DwC). 
But for each of these, it would require EMODnet Biology and/or WP3 partners to reach out to them and ask them to update the dataset. 

