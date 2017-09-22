#!/usr/bin/env python
###
import re;
import os;


def mapToNearestPeak(options):
    peak_to_gene_data=open(options.peaks2genesFile,'r').read().strip().split('\n') 
    peak_to_gene_dict=dict() 
    for line in peak_to_gene_data: 
        tokens=line.split('\t') 
        peak=tuple(tokens[0:3])
        gene=tokens[7] 
        peak_to_gene_dict[peak]=gene 
    for f in options.sigPeakInputFiles:
        sig_peaks=open(f,'r').read().strip().split('\n') 
        f_dir='/'.join(f.split('/')[0:-1])
        f_name=f.split('/')[-1]
        print(f_dir+'/'+"nearestGenes_"+f_name)
        outf=open(f_dir+'/'+"nearestGenes_"+f_name,'w')
        for line in sig_peaks: 
            tokens=line.split('\t') 
            entry=tuple(tokens)
            if len(entry)<3:
                continue 
            nearest_gene=peak_to_gene_dict[entry] 
            outf.write(nearest_gene+'\n')

if __name__ == "__main__":
    import argparse;
    parser = argparse.ArgumentParser();
    parser.add_argument("--sigPeakInputFiles", nargs="+");
    parser.add_argument("--peaks2genesFile", required=True);
    parser.add_argument("--peakColumnInPeaks2GenesFile", type=int, default=3);
    parser.add_argument("--geneColumnInPeaks2GenesFile", type=int, default=7);
    options = parser.parse_args();
    
    mapToNearestPeak(options); 
