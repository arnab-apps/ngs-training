if (!require("dplyr", quietly = TRUE))
  install.packages("dplyr")

library(dplyr)

# Set your working directory to the directory where the data was downloaded
# or any other suitable folder with the data
setwd("C:/Users/ghosh/Downloads")

# Downloaded data. CHANGE THE FILE NAME ACCORDINGLY
tar_gz_file = "gdc_download_20240109_134313.650403.tar.gz"

# Uncompress the downloaded data in 
untar(tar_gz_file, exdir = "gdc_data")

# Read mutation data in a data frame
mut_data = read.table(list.files(path = "gdc_data", pattern = ".gz$",full.names = T, recursive = T)[1],
                      header = TRUE, comment.char = "#", sep = "\t", quote = "")

# Explore the column headers
colnames(mut_data)
head(mut_data)

# List of genes that are mutated in the particular patient
unique(mut_data$Hugo_Symbol)
table(mut_data$Variant_Type)
table(mut_data$Variant_Classification)

# Non silent mutations in genes
mut_data %>% filter(Variant_Classification != "Silent") %>% select(Hugo_Symbol)

# Explore if the patient had non-silent somatic mutation in particular gene

mut_data %>% filter(Hugo_Symbol == "TP53") %>% 
  filter(Variant_Classification != "Silent") %>% 
  select("Hugo_Symbol", "HGVSp_Short",  "Variant_Classification")

# Mutation classes
table(mut_data %>% filter(Variant_Type=="SNP") %>%
  mutate(nt_change = paste(Reference_Allele, Tumor_Seq_Allele2, sep = ">")) %>%
  select(nt_change)
)

# Explore multi-patient somatic mutation data
# Download data
download.file("https://raw.githubusercontent.com/arnab-apps/ngs-training/main/data/gdc_hnsc_bot.maf.gz", 
              destfile = "gdc_hnsc_bot.maf.gz", mode = "wb")

# Read data
gdc_bot_data = read.table("gdc_hnsc_bot.maf.gz",
                          header = TRUE, comment.char = "#", sep = "\t", quote = "")
# Visualise number of mutations per patient
par(mar = c(8,4,4,2))
barplot(table(gdc_bot_data %>% select(Tumor_Sample_Barcode)), las = 2,
        cex.names = 0.5, ylab = "Numer of somatic mutations")

# Breakup of mutations by mutational class
barplot(table(gdc_bot_data %>% select(Variant_Classification, Tumor_Sample_Barcode)),
        las = 2, cex.names = 0.5, ylab = "Numer of somatic mutations",
        col = rainbow(length(unique(gdc_bot_data$Variant_Classification))))
legend("topright",  cex = 0.8, bty = "n", ncol = 2,
       fill = rainbow(length(unique(gdc_bot_data$Variant_Classification))),
       legend = rownames(table(gdc_bot_data %>% select(Variant_Classification, Tumor_Sample_Barcode))))

# Exploring top 20 recurrently mutated genes
head(sort(table(gdc_bot_data %>% filter(Variant_Classification != "Silent") %>% 
  filter(Variant_Classification != "Intron") %>% select(Hugo_Symbol)
), decreasing = T), 20)

# Exploration of type of somatic mutations in top recurrently mutated gene
gdc_bot_data %>% filter(Hugo_Symbol == "TP53") %>% 
  select(Hugo_Symbol, Variant_Classification, HGVSp_Short, Tumor_Sample_Barcode)
