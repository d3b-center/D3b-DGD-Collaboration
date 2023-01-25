# This script wraps usage of the fusion standardization function as it requires a dataframe input
library(optparse)
library(readr)
library(annoFuse)


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
    placeholder <- c("Gene2A", "Gene2B", "LeftBreakpoint", "RightBreakpoint")
    fusion_df[ , placeholder] <- ""
    # cols required for fusion qc filtering
    ct_cols <- c('JunctionReadCount', 'SpanningFragCount')
    fusion_df[ , ct_cols] <- 0
    # annots needs to go here, as last blank column gets filled by fusion annotator
    fusion_df[, "annots"] <- ""

    fusion_std_df<-fusion_standardization(fusion_df, caller="CUSTOM")
} else{
    fusion_std_df<-fusion_standardization(fusion_df, caller=caller, tumorID=tumorID, input_json_file=input_json_file)
}
write.table(fusion_std_df, paste(output_basename, "_standardized.tsv", sep=""), sep="\t",quote=FALSE,row.names = FALSE)

