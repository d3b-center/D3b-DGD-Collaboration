cwlVersion: v1.0
class: CommandLineTool
id: update-gene-symbols
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 4000
    coresMin: 2
  - class: DockerRequirement
    dockerPull: 'pgc-images.sbgenomics.com/d3b-bixu/hotspots:0.1.0'
  - class: InitialWorkDirRequirement
    listing:
      - entryname: update_fusion_gene_symbols.py
        entry:
          $include: ../scripts/update_fusion_gene_symbols.py

baseCommand: [python3, update_fusion_gene_symbols.py]

inputs:
  hgnc_tsv: { type: File, doc: "Gene name database TSV file from HGNC. i.e. hgnc_complete_set.txt",
    inputBinding: {position: 1, prefix: "--hgnc_tsv"} }
  fusions_tsv: { type: File, doc: "Custom Fusions TSV file, i.e. fusion-dgd.tsv.gz",
    inputBinding: {position: 1, prefix: "--fusions_tsv"} }
  output_filename: { type: string, doc: "Name for the output TSV file. Adding gz will output compressed",
    inputBinding: {position: 1, prefix: "--output_filename"} }
  old_symbol: { type: 'string?', doc: "Column name for the old gene symbol(s) in the HGNC TSV. Set to override script defaults",
    inputBinding: {position:1, prefix: "--old_symbol"} }
  new_symbol: { type: 'string?', doc: "Column name for the new gene symbol(s) in the HGNC TSV. Set to override script defaults",
    inputBinding: {position:1, prefix: "--new_symbol"} }
  update_columns: {type: 'string?', doc: "Space-separated column names from the Fusions TSV where to update gene names (e.g. -u foo bar blah). Set to override script defaults",
    inputBinding: {position:1, prefix: "--update_columns", shellQuote: false} }

outputs:
  updated_fusion_tsv:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
