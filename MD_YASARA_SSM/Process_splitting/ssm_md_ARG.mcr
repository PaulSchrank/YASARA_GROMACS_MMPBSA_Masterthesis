PID='Gln'

ForceField Amber14

Processors CPUThreads=20

density='0.99333'

pH='6'
pressurectrl='SolventProbe,Name=HOH,Density=(density)'

hot_spots() = 281,282,283,290,293,309,310

for i in hot_spots
  PressureCtrl Off
  LoadPDB (PID).pdb
  SwapRes (i), ARG
  Cell Auto, Extension=5.0, Shape=Cube
  FillCellWater Density=(density),Probe=1.4,BumpSum=1.0,DisMax=0
  Temp 310K
  pH (pH), Update=no
  AddHydRes (i), Number=all
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
  SaveSce (PID)_(i)_ARG_water.sce
  Mutant='(PID)_(i)_ARG'
  MacroTarget (Mutant)
  Processors CPUthreads=20
  include md_run
  include md_convert
  SavePDB 1,(Mutant).pdb,Format=PDB3,Transform=Yes,UseCIF=No
  Clear

Exit