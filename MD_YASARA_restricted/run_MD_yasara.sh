#!/bin/bash
#
#$ -cwd
#$ -q CC
#
# Notes:
# Execute job on the compute cluster. The cluster queue is specified
# by the "#$ -q QUEUE" line. Valid queue names for computational
# chemistry are 'CC' and 'GPU'. The "#$ -cwd" argument requires your
# job to be started in the submit directory.
#
# Usage: $qsub ./runJOB.sh
#
WORKDIR=`pwd`
export yasara_clean=/home/pschrank/Programms/yasara.202101/yasara
export LD_LIBRARY_PATH=/home/pschrank/Programms/yasara.202101/lib
export PATH=/raid/soft/linux/gromacs.2022/bin:/raid/soft/linux/yasara.202101:$PATH
#
#Run yasara from text mode with custom macro
$yasara_clean -txt md_run.mcr > out.log
