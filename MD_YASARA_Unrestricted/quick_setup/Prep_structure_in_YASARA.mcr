#YASARA MACRO
#TITLE:         md_run_protein_in_water.mcr
#REQUIRES:      Dynamics, Model
#AUTHOR:        Paul Schrank
#LICENSE:       GPL
#DESCRIPTION:   Pipeline for automatization of protein structure (with or without ligand) preperation concerning protonation and energy minimization
#
#Treat all system warnings during the run of this macro as errors and immediately kill process
WarnIsError Flag=On
#Please change macro target, so your protein of interest (PID) in PDB format, in the following command line!!!
#The macro won't work otherwise (please don't include the '.pdb' in the placeholder)!!!
PID='smTG_Gln'

#Change Temperature for the simulation to desired value (in Kelvin)
PID_Temp='310K'

#Change pH for the simulation to desired value
PID_pH='6.0'

#Change density (pressure) for the simulation to desired value
PID_density='0.99333'

#Change forcefield for the simulation to desired one
PID_FF='AMBER14'

#Define number of CPU threads and GPU-ID to use during your simulation
Processors CPUThreads=20

#Set the forcefield of your system
ForceField (PID_FF)

#Load your protein of interest as an PDB file
LoadGRO Filename=(PID).gro

#Prepare PID for the energy minimization
Cell Auto, Extension=5.0, Shape=Cube
FillCellWater Density=(PID_density),Probe=1.4,BumpSum=1.0,DisMax=0
#Set simulation pressure to deseried value and customize to required Solvent
PressureCtrl SolventProbe,Name=HOH,Density=(PID_density)

#Set simulation temperature of your system to the desired value (in Kelvin)
Temp degrees=(PID_Temp)

#Set custom pKa for catalytic residues --> uncomment if and customize to your system if you want to carry out the function 
#pKaRes Cys 69 Mol A, value=12.31
#pKaRes Asp 260 Mol A, value=1.69
#pKaRes His 279 Mol A, value=6.21

#Set pH of your system
pH Value=(PID_pH), update=Yes

#Swap protonation of catalytic residues (in case wrong protonation got assigned) --> uncomment if and customize to your system if you want to carry out the function
#SwapRes Cys 69, new=CYM
#SwapRes Asp 260, new=ASH

#Predict pKa of the PID residues, assignes protonation states, neutralize the charge of your system to +/- 0 with NaCl atoms and optimizes the hydrogen bonding network of your PID
#Check the output of the neutralization in the nt.log (with appending numbering, when running macro multiple times) if of your system has suitable potential energy for running the MD (stable systems should exhibit around 1*10^5-1*10^6 kJ/mol)
#Check pKa prediction in pH.pka file
RecordLog (PID)_nt.log, append=Yes
Boundary Type=Periodic
Experiment Neutralization
  WaterDensity (density)
  pH (pH)
  Ions Na, Cl, Massfraction=0.9
  pKaFile (PID)_pH.pka
  Speed Fast
Experiment On
Wait ExpEnd

#Running energy minimization on your protein
#Check the output of the energy minimization in the em.log (with appending numbering, when running macro multiple times) if of your system has suitable potential energy for running the MD (stable systems should exhibit around 1*10^5-1*10^6 kJ/mol)
RecordLog (PID)_em.log, append=Yes
Boundary Type=Wall
Experiment Minimization 
  Convergence 0.01
Experiment On
Wait ExpEnd

#Save your prepared structure as PDB to input in the AMBER_GROMACS_Generator.sh
SavePDB (PID), (PID)_prep.pdb
