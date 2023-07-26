PID='Gln'

ForceField Amber14

Processors CPUThreads=20

density='0.99333'

pH='6'
pressurectrl='SolventProbe,Name=HOH,Density=(density)'

hot_spots() = 8,9,65,67,70,73,207,243,244,247,256,257,258,259,281,282,283,290,293,309,310

for i in hot_spots
  PressureCtrl Off
  LoadPDB (PID).pdb
  SwapRes (i), PRO
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
  SaveSce (PID)_(i)_PRO_water.sce
  Mutant='(PID)_(i)_PRO'
  MacroTarget (Mutant)
  Processors CPUthreads=20
  include md_run
  include md_convert
  SavePDB 1,(Mutant).pdb,Format=PDB3,Transform=Yes,UseCIF=No
  Clear

Exit