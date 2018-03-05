#!/usr/bin/env python3
import argparse
import pathlib
import re


TIME_RE = re.compile(r'\tElapsed.+?: (?:(?P<hours>\d+):)?(?P<minutes>\d+):(?P<seconds>.+)')
MEMORY_RE = re.compile(r'\tMaximum.+?: ([0-9]+)')


def get_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('--profile_log_fps', required=True, type=pathlib.Path,
            nargs='+', help='Filepaths to profile logs')

    parser.add_argument('--output_fp', required=True, type=pathlib.Path,
            help='Rrofile output filepath')

    # Check that input files exist
    args = parser.parse_args()
    for profile_log_fp in args.profile_log_fps:
        if not profile_log_fp.exists():
            parser.error('Input file %s does not exist' % profile_log_fp)

    return args


def main():
    # Get command line arguments
    args = get_arguments()

    # Write out header
    header = ['software', 'time', 'memory']
    with args.output_fp.open('w') as fh:
        print(*header, sep='\t', file=fh)

    # Iterate sorted suffices and printing collected timings
    for fp in args.profile_log_fps:
        # Collect and print out data
        with fp.open('r') as fh:
            lines = fh.read()
        memory_result = MEMORY_RE.search(lines)
        timing_result = TIME_RE.search(lines)
        memory = int(memory_result.group(1))
        elapsed = convert_elapsed(timing_result)

        # Write
        with args.output_fp.open('a') as fh:
            print(fp.name, elapsed, memory, sep='\t', file=fh)


def convert_elapsed(re_result):
    # Return variable
    time = 0

    # Multipler unit map
    conv_multi = {'hours': 3600,
                  'minutes': 60,
                  'seconds': 1}

    # Convert to seconds
    for unit, value in re_result.groupdict().items():
        if value:
            time += float(value) * conv_multi[unit]

    # Round to closest two decimal places
    return round(time, 2)


if __name__ == '__main__':
    main()
