cwlVersion: v1.2
class: CommandLineTool
id: update-gene-symbols
requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    ramMin: 4000
    coresMin: 2
  - class: DockerRequirement
    dockerPull: 'python:3.9.16-slim-bullseye'
  - class: InitialWorkDirRequirement
    listing:
      - entryname: update_gene_symbols.py
        entry:
          $include: ../scripts/update_gene_symbols.py

baseCommand: [python3, update_gene_symbols.py]

stdout: "new_entries.log"

inputs:
  hgnc_tsv: { type: File, doc: "Gene name database TSV file from HGNC. i.e. hgnc_complete_set.txt",
    inputBinding: {position: 1, prefix: "--hgnc_tsv"} }
  input_tsv: { type: File, doc: "Input TSV file, i.e. fusion-dgd.tsv.gz",
    inputBinding: {position: 1, prefix: "--input_tsv"} }
  output_filename: { type: string, doc: "Name for the output TSV file. Adding gz will output compressed",
    inputBinding: {position: 1, prefix: "--output_filename"} }
  old_symbol: { type: 'string?', doc: "Column name for the old gene symbol(s) in the HGNC TSV. Set to override script defaults",
    inputBinding: {position: 1, prefix: "--old_symbol"} }
  new_symbol: { type: 'string?', doc: "Column name for the new gene symbol(s) in the HGNC TSV. Set to override script defaults",
    inputBinding: { position: 1, prefix: "--new_symbol"} }
  update_columns: { type: 'string[]?', doc: "Space-separated column names from the Input TSV where to update gene names (e.g. -u foo bar blah). Set to override script defaults",
    inputBinding: { position: 1, prefix: "--update_columns", shellQuote: false} }
  fake_columns: { type: 'string[]?', doc: "Column names to use as the header for the Input TSV. Set to override script using first line of Input TSV as header or if file has no header (e.g. -z foo bar blah).",
    inputBinding: { position: 1, prefix: "--fake_columns", shellQuote: false} }
  retain_records: { type: 'boolean?', inputBinding: { position: 1, prefix: "--retain_records" }, doc: "When updating a record with a new gene name, keep the original record." }
  explode_records: { type: 'boolean?', inputBinding: { position: 1, prefix: "--explode_records" }, doc: "Return all available updated names. Will create additional records for each additional new gene name." }

outputs:
  updated_tsv:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)
  new_entries_log:
    type: stdout
