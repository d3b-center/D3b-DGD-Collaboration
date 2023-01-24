# D3b DGD Collaboration

Hosts various code and workflows of mutual interest

## DGD Fusion Annotation
This is a workflow that annotates a DGD fusion file.
Currently, the Archer fusion panel is used and exported from a vm from Filemaker.
In order to make the outputs harmonized with our fusion results we:
1. Update HGNC gene symbols where possible
1. Format output to add `annots` and `FusionName` columns. `FusionName` is basically `Gene1A--Gene1B`
1. Annotate the formatted and updated file using fusionannotator, which is also used by STAR-Fusion

### Inputs:
 - Many input:
   - `output_basename`: Basename for the output TSV file
 - Update gene symbols
   - `hgnc_tsv`: Gene name [database TSV file](https://ftp.ebi.ac.uk/pub/databases/genenames/hgnc/tsv/hgnc_complete_set.txt) from HGNC.
  If omitted, this step will be skipped
   - `fusions_tsv`: Custom Fusions TSV file, i.e. fusion-dgd.tsv.gz }
   - `old_symbol`: Column name for the old gene symbol(s) in the HGNC TSV. Set to override script defaults
   - `new_symbol`: Column name for the new gene symbol(s) in the HGNC TSV. Set to override script defaults
   - `update_columns`: Column names from the Fusions TSV where to update gene names (e.g. -u foo bar blah). Set to override script defaults: `["FusionName","Gene1A","Gene1B"]`
 - Fusion standardization
   - `caller`: Caller used to produce input
 - Annotate fusions
   - `genome_tar`: STAR-Fusion CTAT Genome lib. Recommend [GRCh38_v39_CTAT_lib_Mar242022.CUSTOM.tar.gz](https://cavatica.sbgenomics.com/u/kfdrc-harmonization/kf-references/files/62853e7ad63f7c6d8d7ae5a8/)
   - `genome_untar_path`: This is what the path will be when genome_tar is unpackaged, if recommened used: GRCh38_v39_CTAT_lib_Mar242022.CUSTOM
   - `col_num`: column number in file of fusion name, 0-based array style. Use 24 for arriba v1.1, 30 for v2, 1 for DGD, default: 1

### Output
`annotated_fusion_tsv`: Standardized and annotated fusion results file