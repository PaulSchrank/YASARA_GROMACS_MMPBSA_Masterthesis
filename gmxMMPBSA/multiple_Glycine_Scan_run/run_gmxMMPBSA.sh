#!bin/bash
#
#$ -cwd
#$ -q CC

export PATH=/raid/data/pschrank/Anaconda3/anaconda/condabin:$PATH

COMPLEX_TOP="smTG_Gln.pdb"
MMPBSA_IN="mmpbsa.in"
TRAJ_FILE="smTG_Gln_trunc.xtc"
NDX_FILE="smTG_Gln.ndx"
PROTEIN_ID="1"
LIGAND_ID="13"

. /raid/data/pschrank/Anaconda3/anaconda/etc/profile.d/conda.sh
conda activate gmxMMPBSA

mpirun -np 9 gmx_MMPBSA -O -i $MMPBSA_IN -cs $COMPLEX_TOP -cp topol.top -ct $TRAJ_FILE -ci $NDX_FILE -cg $PROTEIN_ID $LIGAND_ID  -nogui  
