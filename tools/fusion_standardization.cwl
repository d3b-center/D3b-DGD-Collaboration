cwlVersion: v1.2
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
  - class: InitialWorkDirRequirement
    listing:
      - entryname: fusion_standardization_wrapper.R
        entry:
          $include: ../scripts/fusion_standardization_wrapper.R

baseCommand: [Rscript, fusion_standardization_wrapper.R]

inputs:
  fusions_tsv: { type: File, doc: "Input fusion TSV file, i.e. fusion-dgd.tsv.gz. Can be compressed or uncompressed",
    inputBinding: {position: 1, prefix: "--fusions_tsv"} }
  caller: { type: [{type: enum, name: caller, symbols: ["STARFUSION", "ARRIBA", "DGD", "CUSTOM"]}], doc: "Caller used to produce input",
    inputBinding: {position: 1, prefix: "--caller"} }
  tumorID: { type: 'string?', doc: "'Sample' ID to fill in. Recommended for STARFUSION, ARRIBA",
    inputBinding: {position: 1, prefix: "--tumorID"} }
  input_json_file: { type: 'File?', doc: "json file with FusionName,Gene1A,Gene1B,Gene2A,Gene2B,Fusion_Type,annots if CUSTOM and needs remapping",
    inputBinding: {position: 1, prefix: "--input_json_file"} }
  output_basename: { type: 'string?', doc: "Basename for the output TSV file",
        inputBinding: {position: 1, prefix: "--output_basename"} }

outputs:
  standardized_fusions:
    type: File
    outputBinding:
      glob: '*.tsv'