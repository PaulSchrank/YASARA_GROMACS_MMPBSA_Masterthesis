#!/bin/bash
#
#$ -cwd
#$ -q GPU
#
#This file contains all commands used to generate an MD run of your protein of interest in explicit water envoirment
#Run this file in a directory located in the /raid/data/<username>/... directory to run it from the ocean2 server (high performance!) and be sure that you are also logged in to the ocean-cluster (using "ssh ocean" command)
#
#Usage of script: $qsub ./run_md_protein_in_water.sh
#
#Data preperation for your MD:
#       - Generate a reliable model of your protein in .pdb formatting (Or use crystal structure, if avaliable)
#       - Be careful to use the atom and residue naming, which are recognizialbe by MOPACs .rtp files for the specific force you want to use (default for this script is usage of AMBER03 forcefield, so load your structure in Yasara and afterwards save it as pdb using the XPLOR format variant, it should have right formatting :D --> further information on how to format your pdb files according to the rtp files, read: https://manual.gromacs.org/documentation/current/reference-manual/file-formats.html#rtp)  
#       - Prepare the protonation of your system at desired pH and temperature, if needed (You can use MOEs Protonate3D tool for this and manually check the protonation states of your structure --> but again, please be careful with the naming of your residues and atoms, as different forcefield have different identifiers for residues with certain protonation states)
#       - Strip your protein structure from crystal water and cocrystallized ligands, if present (You can edit them out using PyMOL, Yasara, MOE, ... or use linux grep module (very easy to use))
#       - Put the .pdb file of your prepared structure in your working directory
#       - Pull also this list .mdp files in your working directory (should be annotated in the directory your find this file), as these are the parameter file for running the different jobs for your MD --> ions.mdp, em.mdp, npt.mdp, nvt.mdp, md_run.mdp
#       - Edit the definition variable "JOB" in line 11 (according to you .pdb file naming without the ".pdb" extension!) and also pull the .sh file into your working directory
WORKDIR=`pwd`
JOB=smTG_wt
#
#This MD run will simulate with follwoing properties:
#       - Using AMBER03 forcefield
#       - Using a cuboid simulation box with distance between structure and box edges of 1 nm
#       - Using TIP3P water molecules
#       - Neutral charge of whole system (see ions.mdp file)
#       - Stopping energy minimization if Fmax is <1000 kJ/mol*nm (see em.mdp file)
#       - Temperature equillibration at 298 K for 10 ns (see nvt.mdp file)
#       - Density equillibration at 1 bar for 10 ns (see npt.mdp file)
#       - MD simulation at 1 bar and 298 K for 100 ns (see md_run.mdp --> to produce replicates of your process please turn on Velocity generation in the file!)
#
#Of course you are free to edit the parameters in the .mdp files and the commands in this .sh file to adapt them to your system
#
#Generate topology files for your .pdb structure file with all necessary information for the MD run (atom types, charges, bonds, positions, restrains, ...)
#Value 1 ofter "&&" command specifices which forcefield to use for the MD simulation (AMBER03 for proteins//AMBBER98 for nucleic acids--> can be customized to desired forcefield)
#Output files have extension "_processed" after jobname
gmx pdb2gmx -f $JOB.pdb \
    -o $JOB'_processed'.gro \
    -water tip3p \
    -ff amber03 &&
#
#Build simulation box around your system --> size can be decreased (to save computational costs) or increased (to prevent issues between box edges and size of your system)
#Output files have extension "_simbox" after jobname
gmx editconf -f $JOB'_processed'.gro \
    -o $JOB'_simbox'.gro \
    -c \
    -d 1.1 \
    -bt cubic &&
#
#Fill your simulation cell with solvent molecules based on the spc216.gro structure file (filles your cell with explicit water molecules you defined in the 'pdb2gmx' command)
#Output files have extension "_solv" after jobname  
gmx solvate -cp $JOB'_simbox'.gro \
    -cs spc216.gro \
    -o $JOB'_solv'.gro \
    -p topol.top &&
#
#Add ions to neutralize the charge of your system using the input information of the ions.mdp file (can be customized if needed)
#Will produce a binary file called 'ions.tpr' for executing the neutralization in the following command    
gmx grompp -f ions.mdp \
    -c $JOB'_solv'.gro \
    -p topol.top \
    -o ions.tpr &&
#
#Fill your system with ions for neutralization
#PLEASE input '13' when facing prompt to select group of your system (adding ions to solvent)
#Output files have extension "_solv_ions" after jobname
gmx genion -s ions.tpr \
    -o $JOB'_solv_ions'.gro \
    -p topol.top \
    -pname NA \
    -nname CL \
    -neutral &&
#
#Minimize the potential energy of your system using steepest decent as described in the em.mdp file (can be customized if needed)
#Will produce a binary file called with '_em.tpr' extension for executing the energy minimization in the following command   
gmx grompp -f em.mdp \
    -c $JOB'_solv_ions'.gro \
    -p topol.top \
    -o $JOB'_em'.tpr &&
#
#Minimize the potential energy of your system using GPU acceleration
#Output files have extension "_em" after jobname   
gmx mdrun -v \
    -s $JOB'_em'.tpr \
    -gpu_id 1 \
    -nb gpu \
    -ntmpi 1 \
    -ntomp 0 \
    -pin on \
    -pinstride 1 \
    -deffnm $JOB'_em' &&
#
#Extract data for potential energy of your system during the minimization
#PLEASE input '10 0' when facing prompt to select group of your system (adding ions to solvent)    
#Will produce XVG file with '_potential' extension storing all relevant data (can be converted to CVS file for viewing in excel if needed)
gmx energy -f $JOB'_em'.edr \
    -o $JOB'_potential'.xvg &&
#
#Equillibrate the temperature of your system using for the desired temperature provided in the the nvt.mdp file (can be customized if needed --> default: 37 °C equillibrated for 100 ps)
#Will produce a binary file called with '_temp_eq.tpr' extension for executing the temperature equillibration in the following command     
gmx grompp -f nvt.mdp \
    -c $JOB'_em'.gro \
    -r $JOB'_em'.gro \
    -p topol.top \
    -o $JOB'_temp_eq'.tpr &&
#
#Equillibrate the temperature of your system using GPU acceleration
#Output files have extension "_temp_eq" after jobname   
gmx mdrun -v \
    -s $JOB'_temp_eq'.tpr \
    -gpu_id 1 \
    -nb gpu \
    -pme gpu \
    -bonded gpu \
    -update gpu \
    -ntmpi 1 \
    -ntomp 0 \
    -pin on \
    -pinstride 1 \
    -deffnm $JOB'_temp_eq' &&
#
#Extract data for temperature of your system during the equillibration
#PLEASE input '16 0' when facing prompt to select group of your system (For output of temperature data)    
#Will produce XVG file with '_temperature' extension storing all relevant data (can be converted to CVS file for viewing in excel if needed)
gmx energy -f $JOB'_temp_eq'.edr \
    -o $JOB'_temperature'.xvg &&
#
#Equillibrate the density of your system using for the desired density provided in the the npt.mdp file (can be customized if needed --> default: 1000 kg/m^3 equillibrated for 100 ps)
#Will produce a binary file called with '_temp_press_eq.tpr' extension for executing the temperature equillibration in the following command        
gmx grompp -f npt.mdp \
    -c $JOB'_temp_eq'.gro \
    -r $JOB'_temp_eq'.gro \
    -p topol.top \
    -o $JOB'_temp_press_eq'.tpr &&
#
#Equillibrate the density of your system using GPU acceleration
#Output files have extension "_temp_press_eq" after jobname   
gmx mdrun -v \
    -s $JOB'_temp_press_eq'.tpr \
    -gpu_id 1 \
    -nb gpu \
    -pme gpu \
    -bonded gpu \
    -update gpu \
    -ntmpi 1 \
    -ntomp 0 \
    -pin on \
    -pinstride 1 \
    -deffnm $JOB'_temp_press_eq' &&
#
#Extract data for pressure of your system during the equillibration
#PLEASE input '18 0' when facing prompt to select group of your system (for output of pressure data)    
#Will produce XVG file with '_pressure' extension storing all relevant data (can be converted to CVS file for viewing in excel if needed)    
gmx energy -f $JOB'_temp_press_eq'.edr \
    -o $JOB'_pressure'.xvg &&
#
#Extract data for density of your system during the equillibration
#PLEASE input '24 0' when facing prompt to select group of your system (for output of density data)    
#Will produce XVG file with '_density' extension storing all relevant data (can be converted to CVS file for viewing in excel if needed) 
gmx energy -f $JOB'_temp_press_eq'.edr \
    -o $JOB'_density'.xvg &&
#
#Finally, run the molecular dynamics (MD) simulation for your system using for the desired parameters given in the md_run.mdp file (can be customized if needed --> default: 37°C, 1000 kg/m^3, leap-frog intergration for 1 ns, saving trjajectory each 10 ps)
#Will produce a binary file called with '_temp_press_eq.tpr' extension for executing the temperature equillibration in the following command      
gmx grompp -f md_run.mdp \
    -c $JOB'_temp_press_eq'.gro \
    -r $JOB'_temp_press_eq'.gro \
    -p topol.top \
    -o $JOB'_md_sim'.tpr &&
#
#Run MD simulation for your system using GPU acceleration
#Output files have extension "_md_sim" after jobname 
gmx mdrun -v \
    -s $JOB'_md_sim'.tpr \
    -gpu_id 1 \
    -nb gpu \
    -pme gpu \
    -bonded gpu \
    -update gpu \
    -ntmpi 1 \
    -ntomp 0 \
    -pin on \
    -pinstride 1 \
    -deffnm $JOB'_md_sim' &&
#
#Correct the trajectories produced by the MD simulation and center them all according to the first frame (post processing tool to correct f.e. periodicty of your trajectories to prevent artifacts during your analysis using f.e. VMD)
#PLEASE input '1' and then '0' when facing prompt to select group of your system (for aligning your protein to the center of your system)  
#Output files have extension "_md_sim_noPBC" after jobname    
gmx trjconv -s $JOB'_md_sim'.tpr \
    -f $JOB'_md_sim'.xtc \
    -o $JOB'_md_sim_noPBC'.xtc \
    -pbc mol \
    -center &&
#
#Extract data for RMS and RMSD of your protein backbone during the MD simulation
#PLEASE input '4' and then again '4' when facing prompt to select group of your system (for output of backbone RMS/RMSD data)    
#Will produce XVG file with '_rmsd' extension storing all relevant data (can be converted to CVS file for viewing in excel if needed)
gmx rms -s $JOB'_md_sim'.tpr \
    -f $JOB'_md_sim_noPBC'.xtc \
    -o $JOB'_rmsd'.xvg \
    -tu ns &&
#
#Extract data for radius of gyration of your overall protein (so "compactness" of your system) during the MD simulation
#PLEASE input '1' when facing prompt to select group of your system (for output of protein gyration data)    
#Will produce XVG file with '_gyrate' extension storing all relevant data (can be converted to CVS file for viewing in excel if needed)
gmx gyrate -s $JOB'_md_sim'.tpr \
    -f $JOB'_md_sim_noPBC'.xtc \
    -o $JOB'_gyrate'.xvg;
#
#Plugin written by Paul Schrank
#E-mail: paul.schrank@student.uni-halle.de // pschrank@ipb-halle.de
#Last edited 29.11.2022
