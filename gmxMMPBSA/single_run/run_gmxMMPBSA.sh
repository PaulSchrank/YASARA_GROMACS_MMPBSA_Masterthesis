#!bin/bash
#
#$ -cwd
#$ -q GPU
COMPLEX_TOP=""
MMPBSA_IN=""
TRAJ_FILE=""
NDX_FILE=""
LIG_FILE=""
PROTEIN_ID="1"
LIGAND_ID="13"

mpirun -np 20 gmx_MMPBSA -O -i $MMPBSA_IN -cs $COMPLEX_TOP -ct $TRAJ_FILE -ci $ND_FILE -cg $PROTEIN_ID $LIGAND_ID -lm $LIG_FILE -nogui  
