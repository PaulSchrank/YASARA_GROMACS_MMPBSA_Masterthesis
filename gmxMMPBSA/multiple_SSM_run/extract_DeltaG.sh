#!/bin/bash

DIR=/raid/data/pschrank/MMPBSA/Mut_SSM/Asn/MMPBSA_results
Results=$(find "$DIR" -type f -name "*_Results.dat")
GB=108
PB=194

for file in $Results; do
    File_base=$(basename "$file")
    Variant=${File_base%_Results.dat}
    Delta_PB=$(awk -v col=25 'NR=='"$PB"' {print substr($0, col, 7)}' "$file")
    Delta_GB=$(awk -v col=25 'NR=='"$GB"' {print substr($0, col, 7)}' "$file")
    echo "$Variant: $Delta_PB" >> results_PB.dat
    echo "$Variant: $Delta_GB" >> results_GB.dat
done