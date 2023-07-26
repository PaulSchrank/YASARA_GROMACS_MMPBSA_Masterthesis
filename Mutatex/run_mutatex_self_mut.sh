#!bin/bash
#
#$ -cwd
#$ -q GPU
#
PDB_FILE="TG16.pdb"

. /home/pschrank/Programms/mutatex/mutatex-env/bin/activate

mutatex $PDB_FILE \
--np 16 \
--nruns 10 \
--foldx-version suite5 \
--verbose \
--foldx-log \
--clean partial \
--self-mutate
