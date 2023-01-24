cwlVersion: v1.2
class: CommandLineTool
id: dgd-annoFuse
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 4000
    coresMin: 2
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/annofuse:0.91.0'
  - class: InitialWorkDirRequirement
    listing:
      - entryname: dgd_annofuse.R
        entry:
          $include: ../scripts/dgd_annofuse.R

baseCommand: [Rscript, dgd_annofuse.R]

inputs:
  dgd_annot_std_fusions_tsv: { type: File, doc: "Standardized and annotated DGD fusion tsv input file. Can be compressed or uncompressed",
    inputBinding: {position: 1, prefix: "--dgd_annot_std_fusions_tsv"} }
  output_basename: { type: 'string?', doc: "Basename for the output TSV file",
    inputBinding: {position: 1, prefix: "--output_basename"} }

outputs:
  annofuse_filtered_fusions_tsv:
    type: File
    outputBinding:
      glob: '*.tsv'