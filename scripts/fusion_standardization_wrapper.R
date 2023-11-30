# This script wraps usage of the fusion standardization function as it requires a dataframe input
library(optparse)
library(readr)
library(annoFuse)
library(dplyr)


option_list <- list(
  make_option(
    opt_str = "--fusions_tsv",
    type = "character",
    help = "File path of fusion tsv input file. Can be compressed or uncompressed",
  ),
  make_option(
    opt_str = "--caller",
    type = "character",
    help = "Caller used to produce input. 'STARFUSION', 'ARRIBA', 'DGD', or 'CUSTOM'"
  ),
  make_option(
    opt_str = "--tumorID",
    type = "character",
    default = "tumorID",
    help = "'Sample' ID to fill in"
  ),
  make_option(
    opt_str = "--input_json_file",
    type = "character",
    help = "json file with FusionName,Gene1A,Gene1B,Gene2A,Gene2B,Fusion_Type,annots if CUSTOM and needs remapping"
  ),
  make_option(
    opt_str = "--output_basename",
    type = "character",
    default = "fusion_results",
    help = "Output basename to use as sample prefix"
  )
)
opts <- parse_args(OptionParser(option_list = option_list))
fusions_tsv <- opts$fusions_tsv
caller <- opts$caller
tumorID <- opts$tumorID
input_json_file <- opts$input_json_file
output_basename <- opts$output_basename

fusion_df<-read_tsv(fusions_tsv)
if (caller == "DGD" ){
    # all required for annoFuse downstream
    ## rename existing
    colnames(fusion_df)[colnames(fusion_df) %in% c("kf_biospecimen_id", "5_prime_gene", "3_prime_gene")] <- c("Sample", "Gene1A", "Gene1B")
    ## create fusion names
    fusion_df[, "FusionName"] <- paste(fusion_df$Gene1A, fusion_df$Gene1B, sep="--")
    ## Fillers
    placeholder <- c("Gene2A", "Gene2B", "LeftBreakpoint", "RightBreakpoint", "annots")
    fusion_df[ , placeholder] <- ""
    fusion_df[, "Fusion_Type"] <- "Not available"
    # cols required for fusion qc filtering
    ct_cols <- c('JunctionReadCount', 'SpanningFragCount')
    fusion_df[ , ct_cols] <- 0
    fusion_std_df<-fusion_standardization(fusion_df, caller="CUSTOM")
    # reorg columns for better matching with old format
    fusion_std_df <- fusion_std_df %>% select(Sample, FusionName, Fusion_Type, Gene1A, Gene1B, Gene2A, Gene2B, LeftBreakpoint, RightBreakpoint, JunctionReadCount, SpanningFragCount, `5_prime_transcript`, `5_prime_region`, `3_prime_transcript`, `3_prime_region`, variant_tier, annots)
} else{
    fusion_std_df<-fusion_standardization(fusion_df, caller=caller, tumorID=tumorID, input_json_file=input_json_file)
}
# output using a hack from https://stackoverflow.com/questions/16430845/removing-backticks-in-r-output
report <- capture.output(write.table(fusion_std_df, sep="\t",quote=FALSE,row.names = FALSE))
cat(gsub("`", "", report), sep = "\n", file = paste(output_basename, "_standardized.tsv", sep=""))

