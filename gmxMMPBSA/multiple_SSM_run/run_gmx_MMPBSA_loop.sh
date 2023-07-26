#!/bin/bash
#$ -cwd
#$ -q GPU



DIR="/raid/data/pschrank/MMPBSA/Mut_SSM/Gln"

Targets=$(find $DIR -type f -name "*.xtc")
Molecules=$(find $DIR -type f -name "*.mol2")

export PATH=/raid/data/pschrank/Anaconda3/anaconda/condabin:$PATH
. /raid/data/pschrank/Anaconda3/anaconda/etc/profile.d/conda.sh
conda activate gmxMMPBSA

REC_ID="1"

LIG_ID="13"

mkdir MMPBSA_results

for LIG_FILE in $Molecules; do
    Placeholderb="${LIG_FILE%.*}" 
    acpype -i $LIG_FILE -a amber2
    cp $Placeholderb".acpype"/$Placeholderb"_bcc_amber.mol2" ../  &&
    rm $LIG_FILE
    mv $Placeholderb"_bcc_amber.mol2" $LIG_FILE
done

for TRJ_FILE in $Targets; do
    Placeholder="${TRJ_FILE%.*}"
    gmx make_ndx -f $Placeholder".pdb" -o $Placeholder".ndx" <<EOF &&
1 | 13
q
EOF
    mpirun -np 9 gmx_MMPBSA -O -i mmpbsa.in -cs $Placeholder".pdb" -ct $TRJ_FILE -lm "CBZ_"$Placeholder".mol2" -ci $Placeholder".ndx" -cg $REC_ID $LIG_ID -o $Placeholder"_Results.dat" -do $Placeholder"_Decomp.dat" -nogui
    mv $Placeholder"_Decomp.dat" MMPBSA_results/
    mv $Placeholder"_Results.dat" MMPBSA_results/
done
