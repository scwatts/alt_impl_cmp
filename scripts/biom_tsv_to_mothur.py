#!/usr/bin/env python3
import argparse
import pathlib


def get_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('--input_fp', required=True, type=pathlib.Path,
            help='Input bio tsv filepath')

    # Check that input exists
    args = parser.parse_args()
    if not args.input_fp.exists():
        parser.error('Input file %s does not exist' % args.input_fp)
    return args


def main():
    # Get commandline arguments
    args = get_arguments()

    # Read data
    with args.input_fp.open('r') as fh:
        line_token_gen = (line.rstrip().split() for line in fh)
        samples = next(line_token_gen)[1:]
        otu_names, otu_counts = zip(*[(name, counts) for name, *counts in line_token_gen])
        otu_counts_row_m = zip(*otu_counts)

    # Write data
    otu_num = len(otu_names)
    header = ['label', 'Group', 'numOtus', *otu_names]
    print(*header, sep='\t')
    for i, counts in enumerate(otu_counts_row_m):
        print('1', i, otu_num, *(int(float(c)) for c in counts), sep='\t')


if __name__ == '__main__':
    main()
