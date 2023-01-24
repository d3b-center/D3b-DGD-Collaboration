# This script wraps running annoFuse on DGD input

library(optparse)
library(readr)
library(annoFuse)

option_list <- list(
  make_option(
    opt_str = "--dgd_annot_std_fusions_tsv",
    type = "character",
    help = "File path of standardized and annotated DGD fusion tsv input file. Can be compressed or uncompressed",
  ),
  make_option(
    opt_str = "--output_basename",
    type = "character",
    default = "fusion_results",
    help = "Output basename to use as sample prefix"
  )
)

opts <- parse_args(OptionParser(option_list = option_list))
dgd_annot_std_fusions_tsv <- opts$dgd_annot_std_fusions_tsv
output_basename <- opts$output_basename

fusion_df <- read_tsv(dgd_annot_std_fusions_tsv)
# Add "Missing" DGD columns
fusionQCFiltered <- fusion_filtering_QC(
   standardFusioncalls = fusion_df,
   artifactFilter = "GTEx_Recurrent|DGD_PARALOGS|Normal|BodyMap|ConjoinG",
   junctionReadCountFilter = 0,
   spanningFragCountFilter = 0,
   readthroughFilter = FALSE
 )

geneListReferenceDataTab <- read.delim(
   system.file("extdata", "genelistreference.txt", package = "annoFuseData"),
   stringsAsFactors = FALSE
 )
 
fusionReferenceDataTab <- read.delim(
   system.file("extdata", "fusionreference.txt", package = "annoFuseData"),
   stringsAsFactors = FALSE
)

annotated_fusion_calls <- annotate_fusion_calls (fusionQCFiltered,
                                  geneListReferenceDataTab,
                                  fusionReferenceDataTab,
                                  checkReciprocal = TRUE)
write.table(annotated_fusion_calls, paste(output_basename, ".annoFuse_filter.tsv", sep=""), sep="\t",quote=FALSE,row.names = FALSE)