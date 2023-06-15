# D3b DGD Collaboration

Hosts various code and workflows of mutual interest

## DGD Fusion Annotation
This is a workflow that annotates a DGD fusion file.
Currently, the Archer fusion panel is used and exported from a vm from Filemaker.
In order to make the outputs harmonized with our fusion results we:
1. Update HGNC gene symbols where possible
1. Format output to add `annots` and `FusionName` columns. `FusionName` is basically `Gene1A--Gene1B`
1. Annotate the formatted and updated file using fusionannotator, which is also used by STAR-Fusion
1. Filter/annotate additionally with annoFuse

### Inputs:
 - Many input:
   - `output_basename`: Basename for the output TSV file
 - Update gene symbols
   - `hgnc_tsv`: Gene name [database TSV file](https://ftp.ebi.ac.uk/pub/databases/genenames/hgnc/tsv/hgnc_complete_set.txt) from HGNC.
  If omitted, this step will be skipped
   - `input_tsv`: Custom Fusions TSV file, i.e. fusion-dgd.tsv.gz }
   - `old_symbol`: Column name for the old gene symbol(s) in the HGNC TSV. Set to override script defaults
   - `new_symbol`: Column name for the new gene symbol(s) in the HGNC TSV. Set to override script defaults
   - `update_columns`: Column names from the Input TSV where to update gene names (e.g. -u foo bar blah). Set to override script defaults: `["FusionName","Gene1A","Gene1B"]`
   - `fake_columns`: Column names to use as the header for the Input TSV. Set to override script using first line of Input TSV as header or if file has no header (e.g. -z foo bar blah). 
 - Fusion standardization
   - `caller`: Caller used to produce input
 - Annotate fusions
   - `genome_tar`: Tar ball with files listed [here](https://github.com/FusionAnnotator/FusionAnnotator/blob/9cd889a87c838243555f14beabfc677f539084a3/FusionAnnotator#L85-L95) from STAR-Fusion CTAT Genome lib. Recommend [GRCh38_v39_fusion_annot_custom.tar.gz](https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/files/63cff818facdd82011c8d6fe/)
   - `genome_untar_path`: This is what the path will be when genome_tar is unpackaged, if recommened used: GRCh38_v39_CTAT_lib_Mar242022.CUSTOM
   - `col_num`: column number in file of fusion name, 0-based array style. Use 24 for arriba v1.1, 30 for v2, 1 for DGD, default: 1

### Output
`annofuse_filtered_fusions_tsv`: Standardized, annotated and annoFuse filtered fusion results file