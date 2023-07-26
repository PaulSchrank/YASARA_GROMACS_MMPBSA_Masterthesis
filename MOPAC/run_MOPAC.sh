#!/bin/bash
#
#$ -cwd
#$ -q CC
#
JOB=benchmark_system_7thr
# Notes:
# Execute job on the compute cluster. The cluster queue is specified
# by the "#$ -q QUEUE" line. Valid queue names for computational
# chemistry are 'CC' and 'GPU'. The "#$ -cwd" argument requires your
# job to be started in the submit directory.
#
# Usage: qsub runJOB.sh
#
MOPAC2019 $JOB.dat > $JOB.log
