#!/usr/bin/python3
import numpy as np
import pandas as pd
import re
import argparse

def filename2code(filename):
    code_wrapper = re.search("type_(subzero|default)", filename).group(0)
    code = re.search("(subzero|default)", code_wrapper).group(0)
    return code

def filename2bs(filename):
    bs_wrapper = re.search("bs_\d+", filename).group(0)
    bs = re.search("\d+", bs_wrapper).group(0)
    return bs

def main(args):
    ### Create list of file names
    filename_list = args.filename_list
    abort_on_zero = args.abort_on_zero
    simple = args.simple
    no_header = args.no_header
    
    ### Compute mean for each file
    mean_list = []
    for filename in filename_list:
        # read the file
        with open(filename, "r") as f:
            raw = f.read()
        f.close()

        # find the matching pattern within the file
        time_reg = re.findall("\d+\.\d+ s", raw)

        # convert time_reg to nparray
        values = []
        for r in time_reg:
            values.append(float(r.split(" ")[0]))
        nparray = np.asarray(values)

        # sanity check
        if(len(nparray) == 0 and abort_on_zero):
            print('[ERROR] File "%s" did not contain any parsable result. Aborting.' % (filename))
            return -1

        # append the result
        mean_list.append(nparray.mean())

        # print the statistics
        if args.verbose > 1:
            print("--------------------------------------------------")
            print("Filename: ", filename)
            print("Count: ", len(nparray))
            print("Mean : ", nparray.mean())
            print("Std  : ", nparray.std())
            print("Min  : ", nparray.min())
            print("Max  : ", nparray.max())
            print("--------------------------------------------------")

    ### Noramlize with the first value
    norm_mean_list=[]
    divider = mean_list[0]
    for m_val in mean_list:
        norm_mean_list.append(m_val / divider)
    assert(len(norm_mean_list) == len(filename_list))

    ### Finally print out the result
    if(not simple):
        print("--------------------------------------------------")

    header_line=[]
    if(not no_header):
        if (simple):
            header_line.append("io_size")
            for filename in filename_list:
                header_line.append(filename2code(filename))

            for filename in filename_list[1:]:
                header_line.append(filename2code(filename) + "_speedup")

            print( "%s\b" % (','.join(header_line)) )
        else:
            print('filename,time,norm_time,speedup')


    final_line=[]
    if(simple):
        target_bs = filename2bs(filename_list[0])
        final_line.append(target_bs)
            
        for i in range(len(norm_mean_list)):
            final_line.append('%.4f' % mean_list[i])
        
        for i in range(1, len(norm_mean_list)):
            final_line.append('%.4f' % (norm_mean_list[0] / norm_mean_list[i]))

        print( "%s\b" % (','.join(final_line)) )
    else:
        for i in range(len(norm_mean_list)):
            print("%s,%.4f,%.4f,%.4f" % (filename_list[i], mean_list[i], norm_mean_list[i], norm_mean_list[0]/norm_mean_list[i]) )

    return 0

if __name__ == '__main__':
    parser = argparse.ArgumentParser( \
        description="Process dd result files.")
    
    parser.add_argument('filename_list', nargs='+', \
        help="list of filenames. Normalized to the first file result")
    parser.add_argument('--abort-on-zero', '-a', action='store_false', default=True,\
        help="if set, print out warnings")
    parser.add_argument('--simple', '-s', action='store_true', default=False,\
        help="if set, print out simple version")
    parser.add_argument('--no-header', '-n', action='store_true', default=False,\
        help="if set, print out simple version")
    parser.add_argument('--verbose', '-v', action='count', default=0, \
        help="verbose printing. 0: Just the output, 1: +INFO, 2: +DBG")

    args = parser.parse_args()

    if args.verbose > 0:
        print("[INFO]", args)

    main(args)