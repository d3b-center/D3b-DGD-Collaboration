cwlVersion: v1.2
class: Workflow
id: dgd-fusion-annotator-wf
label: DGD Fusion Annotator Workflow
doc: "Formats and annotates DGD fusion files"


inputs:
  # multi
  output_basename: { type: string, doc: "Basename for the output TSV file" }
  # update gene symbols
  hgnc_tsv: { type: 'File?', doc: "Gene name database TSV file from HGNC. i.e. hgnc_complete_set.txt. If not provided, updated will be skipped" }
  input_tsv: { type: File, doc: "Input TSV file, i.e. fusion-dgd.tsv.gz" }
  old_symbol: { type: 'string?', doc: "Column name for the old gene symbol(s) in the HGNC TSV. Set to override script defaults" }
  new_symbol: { type: 'string?', doc: "Column name for the new gene symbol(s) in the HGNC TSV. Set to override script defaults" }
  update_columns: {type: 'string[]?', doc: "Column names from the Input TSV where to update gene names (e.g. -u foo bar blah). Set to override script defaults" }
  # fusion standardization
  caller: { type: ['null', {type: enum, name: caller, symbols: ["DGD", "STARFUSION", "ARRIBA", "CUSTOM"]}], doc: "Caller used to produce input",
    default: "DGD" }
  # annotate fusion
  genome_tar: {type: 'File', doc: "STAR-Fusion CTAT Genome lib", "sbg:suggestedValue": {
      class: File, path: 63cff818facdd82011c8d6fe, name: GRCh38_v39_fusion_annot_custom.tar.gz}}
  genome_untar_path: {type: 'string?', doc: "This is what the path will be when genome_tar is unpackaged", default: "GRCh38_v39_CTAT_lib_Mar242022.CUSTOM"}
  col_num: {type: 'int?', doc: "column number in file of fusion name, 0-based array style, use 24 for arriba v1.1, 30 for v2, 1 for DGD", default: 1}

outputs:
  annofuse_filtered_fusions_tsv: { type: File, outputSource: annoFuse/annofuse_filtered_fusions_tsv }

steps:
  update_gene_symbols:
    run: ../tools/update_gene_symbols.cwl
    when: $(inputs.hgnc_tsv != null)
    in:
      hgnc_tsv: hgnc_tsv
      input_tsv: input_tsv
      output_filename:
        source: output_basename
        valueFrom: |
          $(self + "_gene_sym_updated.tsv")
      old_symbol: old_symbol
      new_symbol: new_symbol
      update_columns: update_columns
    out: [updated_tsv]

  fusion_standardization:
    run: ../tools/fusion_standardization.cwl
    in:
      fusions_tsv:
        source: [update_gene_symbols/updated_tsv, input_tsv]
        pickValue: first_non_null
      caller: caller
      output_basename: output_basename
    out: [standardized_fusions]

  fusion_annotator:
    run: ../tools/fusion_annotator.cwl
    in:
      input_fusion_file: fusion_standardization/standardized_fusions
      genome_tar: genome_tar
      genome_untar_path: genome_untar_path
      col_num: col_num
      output_basename: output_basename
    out: [annotated_tsv]

  annoFuse:
    run: ../tools/dgd_annoFuse.cwl
    in:
      dgd_annot_std_fusions_tsv: fusion_annotator/annotated_tsv
      output_basename: output_basename
    out: [annofuse_filtered_fusions_tsv]

$namespaces:
  sbg: https://sevenbridges.com

hints:
  - class: 'sbg:AWSInstanceType'
    value: c5.2xlarge;ebs-gp2;400
    doc: "Chosen for speed and lower cost"
