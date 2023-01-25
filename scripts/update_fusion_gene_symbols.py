#!/usr/bin/env python3

"""Using the HGNC Gene Name Database TSV, update any old gene names in the custom fusions TSV

A lightweight program to iterate through the custom fusions file and check all requested columns
that contain gene names against the HGNC database. The program does this simply by creating
a dict from the records in the HGNC file. That dict has old gene names as the keys and any
associated new gene names are stored in the value as a list. As the program iterates through
the custom fusions file it will update the columns as requested using simple key lookups on
the created dict. Outputs are written line by line to an output file that can be compressed
if named GZ.

Typical usage example:
    update_fusion_gene_symbols.py -g hgnc_complete_set.txt -f fusion-dgd.tsv.gz -o test.tsv.gz
"""

import argparse
import gzip
import sys

def get_args():
    """Parse the arguments

    Args:
        None

    Returns:
        A namespace object with the arguments for this program
    """
    parser = argparse.ArgumentParser()
    optional = parser._action_groups.pop()
    required = parser.add_argument_group("required arguments")
    required.add_argument(
            "-g",
            "--hgnc_tsv",
            required=True,
            help="Gene name database TSV file from HGNC: hgnc_complete_set.txt")
    optional.add_argument(
            "-p",
            "--old_symbol",
            default="prev_symbol",
            help="Column name for the old gene symbol(s) in the HGNC TSV. Default: %(default)s")
    optional.add_argument(
            "-n",
            "--new_symbol",
            default="symbol",
            help="Column name for the new gene symbol in the HGNV TSV. Default: %(default)s")
    required.add_argument(
            "-f",
            "--fusions_tsv",
            required=True,
            help="Custom fusions TSV file: fusion-dgd.tsv.gz")
    optional.add_argument(
            "-u",
            "--update_columns",
            nargs='+',
            default=["FusionName","Gene1A","Gene1B"],
            help="Space-separated column names from the Fusions TSV where to update gene names \
                    (e.g. -u foo bar blah). Default: %(default)s")
    required.add_argument(
            "-o",
            "--output_filename",
            required=True,
            help="Name for the output TSV file")
    parser._action_groups.append(optional)
    return parser.parse_args()

def hgnc_tsv_to_dict(hgnc_file, old_sym, new_sym):
    """Creates dict for gene name conversion.

    Iterates through the HGNC TSV and creates a dict where old gene symbols
    are the keys and a list of associated new gene symbols are the values.

    Args:
        hgnc_file: An unopened TSV file containing the HGNC gene name information
        old_sym: String name of the column in the TSV that contains the old symbols
        new_sym: String name of the column in the TSV that contains the new symbols

    Returns:
        sym_dict: A dict mapping keys to the old gene names and values to associated
        new gene names
    """
    sym_dict = {}
    with open(hgnc_file, 'rt', encoding="utf-8") as f:
        header = f.readline().strip().split('\t')
        old_sym_index = header.index(old_sym)
        new_sym_index = header.index(new_sym)
        for line in f:
            split_line = line.strip().split('\t')
            # TSV adds quotes around entries where there are multiple old symbols; remove them
            old_sym_info = split_line[old_sym_index].replace('"','')
            new_sym_info = split_line[new_sym_index]
            # If there's no info on old symbols, return to the for loop
            if old_sym_info == '':
                continue
            # Build the dict either by appending the existing list or creating a new one
            for old_symbol in old_sym_info.split('|'):
                if old_symbol in sym_dict:
                    sym_dict[old_symbol].append(new_sym_info)
                else:
                    sym_dict[old_symbol] = [new_sym_info]
    return sym_dict

def update_fusions_tsv(fusions_file, sym_dict, update_columns, out_file):
    """Reads lines of the fusions_file, updates the genes, and writes to an output

    Iterates through the custom fusions file and feeds each line to the line processor.
    Takes the output of the line processor and writes that to the output file.

    Args:
        fusions_file: An unopened TXT or TXT.GZ file that contains Custom Fusion information
        sym_dict: A dict with old symbol keys and corresponding value list of new symbols
        update_columns: A list of columnnames in the fusions_file that must be updated
        out_file: A string filename (files ending in GZ will be compressed) for the output

    Returns:
        None
    """
    with (gzip.open if fusions_file.endswith("gz") else open)(fusions_file, "rt", encoding="utf-8") as f:
        with (gzip.open if out_file.endswith("gz") else open)(out_file, "wt", encoding="utf-8") as w:
            header = f.readline().strip().split('\t')
            w.write('\t'.join(header) + '\n')
            for line in f:
                updated_line = update_fusion_line(line.strip(), sym_dict, header, update_columns)
                w.write(updated_line + '\n')

def update_fusion_line(fusion_line, sym_dict, header, update_columns):
    """Take a fusion line and update the requested columns, return the line

    Given a single line from the custom fusions file, this function is tasked with identifying
    which columns to alter and invoking the gene name updater appropriately. In most cases,
    it expects only a single gene name to be present in a given column. In this case, it will
    simply use the gene name updater to get the new gene name (if there is one). It will also
    check for fusions by string checking for '--'. If it does identify a fusion it will split
    those gene names and send both off to be processed individually. It will then reanneal them
    with the fusion notation ('--'). Once it has the new entry it will update the column, repeating
    until it is out of column names.

    Args:
        fusion_line: A string record from the Custom Fusion file. Represents a single line
        sym_dict: A dict with old symbol keys and corresponding value list of new symbols
        update_columns: A list of columnnames in the fusions_file that must be updated
        header: A list containing the columnnames from the fusions_file header

    Returns:
        The fusion_line with updated gene names where requested (update_columns)
    """
    split_fuse = fusion_line.split('\t')
    for colname in update_columns:
        col_index = header.index(colname)
        if '--' in split_fuse[col_index]:
            genea, geneb = split_fuse[col_index].split('--')
            new_genea = update_gene_name(genea, sym_dict)
            new_geneb = update_gene_name(geneb, sym_dict)
            new_entry = '--'.join([new_genea, new_geneb])
        else:
            gene = split_fuse[col_index]
            new_entry = update_gene_name(gene, sym_dict)
        split_fuse[col_index] = new_entry
    return '\t'.join(split_fuse)

def update_gene_name(old_gene, sym_dict):
    """Given an gene name and a symbol dict, update the gene name, if possible

    Core component of the updating mechanism: Put simply, if the old gene name is a key
    in the sym_dict, return the corresponding value. WARNING: The HGNC file sometimes
    provides multiple new gene names for an old name. We don't have a solution for this
    at the moment so the program should crash if it encounters this scenario.

    Args:
        old_gene: A string name for the old_gene
        sym_dict: A dict with old symbol keys and corresponding value list of new symbols

    Returns:
        new_gene: A string corresponding to the new gene name

    Raises:
        SystemExit: When we encounter an old gene name with more than one corresponding
        new gene name.
    """
    if old_gene in sym_dict:
        # TODO: figure out how to deal with old genes that have multiple new gene names
        if len(sym_dict[old_gene]) > 1:
            sys.exit(f"Error updating gene {old_gene}. HGNC has multiple options: {sym_dict[old_gene]}")
        # There should only be single item arrays now so we can just take the first item
        new_gene = sym_dict[old_gene][0]
    else:
        # The gene name has not been changed, therefore we can just pass the old gene name through
        new_gene = old_gene
    return new_gene

def main():
    """
    Choo choo
    """
    args = get_args()
    sym_dict = hgnc_tsv_to_dict(args.hgnc_tsv, args.old_symbol, args.new_symbol)
    update_fusions_tsv(args.fusions_tsv, sym_dict, args.update_columns, args.output_filename)

if __name__ == "__main__":
    main()
