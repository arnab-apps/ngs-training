library(dplyr)

# Set your working directory to the directory where the data was downloaded
# or any other suitable folder with the data
setwd("C:/Users/ghosh/Downloads")

# Downloaded data. CHANGE THE FILE NAME ACCORDINGLY
tar_gz_file = "gdc_download_20240109_134313.650403.tar.gz"

# Uncompress the downloaded data in 
untar("gdc_download_20240108_131437.776735.tar.gz", exdir = "gdc_data")

# Read mutation data in a data frame
mut_data = read.table(list.files(path = "gdc_data", pattern = ".gz$",full.names = T, recursive = T)[1],
                      header = TRUE, comment.char = "#", sep = "\t")

# Explore the column headers
colnames(mut_data)
head(mut_data)

# List of genes that are mutated in the particular patient
unique(mut_data$Hugo_Symbol)
table(mut_data$Variant_Type)
table(mut_data$Variant_Classification)

# Non silent mutations in genes
mut_data %>% filter(Variant_Classification != "Silent") %>% select(Hugo_Symbol)

# Mutation classes
table(mut_data %>% filter(Variant_Type=="SNP") %>%
  mutate(nt_change = paste(Reference_Allele, Tumor_Seq_Allele2, sep = ">")) %>%
  select(nt_change)
)