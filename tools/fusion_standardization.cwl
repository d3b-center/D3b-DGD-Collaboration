cwlVersion: v1.0
class: CommandLineTool
id: fusion-standardization
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 4000
    coresMin: 2
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/annofuse:0.91.0'

baseCommand: [Rscript, -e]

arguments:
  - position: 1
    shellQuote: false
    valueFrom: |-
      '
      library(readr)
      library(annoFuse)
      dgd_df<-read_tsv("$(inputs.fusions_tsv.path)")
      placeholder <- c("Gene2A", "Gene2B")
      dgd_df[ , placeholder] <- "NA"
      dgd_df[ , "annots"] <- ""
      dgd_std_df<-fusion_standardization(dgd_df, caller="CUSTOM")
      write.table(dgd_std_df,"$(inputs.output_basename)_standardized.tsv",sep="\t",quote=FALSE,row.names = FALSE)
      '

inputs:
  fusions_tsv: { type: File, doc: "Custom Fusions TSV file, i.e. fusion-dgd.tsv.gz" }
  output_basename: { type: string, doc: "Basename for the output TSV file" }

outputs:
  output_annotated_fusions:
    type: File
    outputBinding:
      glob: '*.tsv'