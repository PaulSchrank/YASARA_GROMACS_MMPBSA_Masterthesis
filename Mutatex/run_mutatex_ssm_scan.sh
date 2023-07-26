#!bin/bash
#
#$ -cwd
#$ -q GPU
#
PDB_FILE="TG16.pdb"
MUT_LIST_FILE=""
. /home/pschrank/Programms/mutatex/mutatex-env/bin/activate

mutatex $PDB_FILE \
--np 16 \
--nruns 10 \
--foldx-version suite5 \
--verbose \
--foldx-log \
--clean partial \
--mutlist $MUT_LIST_FILE
