PID='Gln'

ForceField Amber14

Processors CPUThreads=20

density='0.99333'

pH='6'
pressurectrl='SolventProbe,Name=HOH,Density=(density)'

PressureCtrl Off
LoadPDB (PID).pdb
Cell Auto, Extension=5.0, Shape=Cube
FillCellWater Density=(density),Probe=1.4,BumpSum=1.0,DisMax=0
Temp 310K
pH (pH), Update=no
Boundary Type=Periodic
Experiment Neutralization
  WaterDensity (density) 
  pH (pH)
  Ions Na, Cl, Massfraction=0.9
  pKaFile (PID)_pH.pka
  Speed Fast
Experiment On
Wait ExpEnd
Experiment Minimization
  Convergence 0.01
Experiment On
Wait ExpEnd  
SaveSce (PID)_WT_water.sce
Wildtype='(PID)_WT'
MacroTarget (Wildtype)
Processors CPUthreads=20
include md_run
include md_convert
SavePDB 1,(Wildtype).pdb,Format=PDB3,Transform=Yes,UseCIF=No
Clear
  
Exit
