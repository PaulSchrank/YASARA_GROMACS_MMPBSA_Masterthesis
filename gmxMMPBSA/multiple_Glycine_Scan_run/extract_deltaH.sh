#!/bin/bash

Variant=114
DeltaH=414

for directory in /raid/data/pschrank/MMPBSA/Mut_Ala_studies/Gln/*; do
    EnergyDiff=$(sed -n "${DeltaH}p" "${directory}/FINAL_RESULTS_MMPBSA.dat")
    Mutant=$(sed -n "${Variant}p" "${directory}/FINAL_RESULTS_MMPBSA.dat")
    echo "${Mutant}: ${EnergyDiff}" >> results_PB_2.dat
done
