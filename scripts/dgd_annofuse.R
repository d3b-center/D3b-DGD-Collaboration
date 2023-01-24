library(readr)
library(annoFuse)

fusion_df <- read_tsv('TEST_REF.annotated.tsv')
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
write.table(annotated_fusion_calls, paste("TEST_annoFuse_filtered.tsv", sep=""), sep="\t",quote=FALSE,row.names = FALSE)