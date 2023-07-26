#!/bin/bash
#Script for generation of GROMACS competent Topology for your Protein and Ligand of interest (Author: Paul Schrank)
#Version 1.2 (Fixed column issues for PDB files / Fixed missing chain ID for PDB files / Fixed inconsistencies in topology files)
#Software Prerequsites:
#   - GROMACS
#   - AMBERTOOLS21/22
#   - ACPYPE
#   - GETOPTS


#---------  FILE SETUP  ----------- (Decraped, but left in, to give more context on the plugin + help commands to install new force fields)
#PDB FILE of your Protein system (Can be with water and ligand, as long as they are defined as HETATM in you PDB) -- Be sure to set protonation state for all residues for the pH you want to simulate in
#RECNAME="smTG_Gln" #<<<<<<<<<<<<<<<<<<<<<<<<< PUT THE PDB NAME HERE (without the extension)
# LIGAND NAME, if you have a ligand, it will be parametrize with acpype and the ligand name will be replace by "LIG".
#LIGNAME="CBZ_Gln_Gly"  #PUT LIGAND NAME HERE, leave it blank if no ligand. Please make sure that your molecule identifier for the ligand atoms is "LIG", otherwise the macro will not work, or you have to provide a new residue name when building the ligand index file without hydrogens
#WATER=tip3p #Water type
#Force field for generation of receptor topology. U can use standart gromacs forcefields (refer to documentation: https://manual.gromacs.org/documentation/current/reference-manual/functions/force-field.html) 
#or custom ones from the user contributions (http://www.gromacs.org/Downloads/User_contributions --- link might change when GROMACS updates), which you need to download and install in the GROMACS topology directory first (should be under ../gromacs/share/gromacs/top/)
#FF=amber14sb_parmbsc1

#This script wants to use the Amber14SB forcefield, as it also describes the one we will use in YASARA for the restricted MD run. For this it will get the forcefield repository from the webadress and install it in the GROMACS topology directory (see the next 5 lines - I left them commented by default, so uncomment if you want to install)
#FF_PATH="/usr/local/gromacs/share/gromacs/top/" #<<<<<<<<<<<<<<<<<<<<<<<<<PUT THE PATH TO TOPOLOGY DIRECTORY HERE (Also put "/"" of the final directory)  
#Be sure to run in as root or add sudo!

#wget https://ftp.gromacs.org/contrib/forcefields/amber14sb.ff.tar.gz
#mv amber14sb.ff.tar.gz $FF_PATH
#tar xfv $FF_PATH'amber14sb.ff.tar' -C $FF_PATH

unset -v RECNAME
unset -v LIGNAME
unset -v WATER
unset -v FF
unset -v LIGTOP

while getopts r:l:w:f:t:hg opt; do
  case $opt in
    r)
      RECNAME=$OPTARG
      echo "Will use PDB file of '$OPTARG' as input for topology generation"
      ;;
    l)
      LIGNAME=$OPTARG
      echo "Will use PDB file of '$OPTARG'as input for topology generation"
      ;;
    w)
      WATER=$OPTARG
      echo "Will use '$OPTARG' water model for topology generation"
      ;;
    f)
      FF=$OPTARG
      echo "Will '$OPTARG' force field for protein topology generation"
      ;;
    t)
      LIGTOP=$OPTARG
      echo "Will generate '$OPTARG' topology for ligand"
      ;;
    h)
      echo "script usage: GROMACS_AMBER_GENERATOR.sh
      
      Mandatory flags:

      [-r] {PDB FILE of your Protein system (Can be with water and ligand, as long as they are defined as HETATM in you PDB)
            - Please add without .pdb extension}
      
      Optional flags:

      [-l] {LIGAND NAME, if you have a ligand, it will be parametrize with acpype and the ligand name will be replace by "LIG" 
            - Please add without .pdb extension}

      [-w] {Specify water model to use for topology generation, can use all default Gromacs water models 
           (none, spc, scpe, tip3p, tip4p, tip5p, tips3p) 
           - DEFAULT 'spc' (To use novel models, please download and install them first)}

      [-f] {Specify force field to use for topology generation, can use all default Gromacs force fields 
           (AMBER03, AMBER94, AMBER96, AMBER99, AMBER99SB, AMBER99SB-ILDN, AMBERGS, CHARMM27, GROMOS96, OPLS-AA)
           - DEFAULT 'amber03' (To use novel force fields, please download and install them first)}

      [-t] {Specify force field to generate ligand topology for, can use al default acpype options 
           (gaff, amber, gaff2, amber2)}

      [-g] {Renames Histidine residues from HIS (assuming they describe the ND1 and NE2 protonated species) to general Amber naming HIP}
      
      Help page:

      [-h] {help page}
      
      " 
      >&2
      exit 0
      ;;
    g)
     HISGEN=true
     ;;
  esac
done

shift "$(( OPTIND -1 ))"

if [ -z "$RECNAME" ]; then
        echo 'Missing Protein structure file, please add -r flag to your command' >&2
        exit 0
fi

if [ -z "$WATER" ]; then
        echo 'No water model defined, will use SPC water model' >&2
        WATER="spc"
fi

if [ -z "$FF" ]; then
        echo 'No force field defined, will use AMBER03 force field' >&2
        FF="amber03"
fi

#---------  HPC SETUP  -----------
#Path to gromacs executable, if you don't have it set up as envoirment variable (e.g. in your .bashrc/.profile), please uncomment the next to lines to source your GROMACS binary first
#GMXRCPATH= #<<<<<<<<<<<<<<<<<<<<<<<<< PUT THE GROMACS EXECUTABLE PATH HERE (usally '/usr/local/gromacs/bin/GMXRC')
#. $GMXRCPATH

#GMX command (Usally you don't need to change, this is a placeholder if the gmx command will change in the next GROMACS versions)
GMX=gmx 

#---------  TOPOLOGY BUILDING  -----------
#Building parametersation directory for calculation and filling it with your Protein and Ligand 
mkdir param
cp $RECNAME.pdb param/
cp $LIGNAME.pdb param/
cd param

#Generating prerequisites for building receptor topology. Splitting water molecules and ligand from protein (using grep tool) and converting it to AMBER naming (using pdb4amber tool)  
grep 'ATOM' $RECNAME.pdb --color=none > receptor_stat.pdb
if [ "$HISGEN" = true ]; then
  awk '{if ($0 ~ /^ATOM/ && substr($0,18,3)=="HIS") {sub("HIS","HIP",$0)}}1' receptor_stat.pdb > receptor_his.pdb
  pdb4amber -i receptor_his.pdb --nohyd -o receptor.pdb
else
  pdb4amber -i receptor_stat.pdb --nohyd -o receptor.pdb
fi
rm receptor_*

#Use ACPYPE to prepare topology for the ligand
mv $LIGNAME.pdb ligand.pdb
acpype -i ligand.pdb -a $LIGTOP

#DISCLAMER! This is a "quick and dirty method", it has to be optimised with ACPYPE parameters of course and adapted to ligands
#If you see strange MD behaviours you may also consider Automated Topology Builder (ATB) (webserver) Or LibParGen (webserver & standalone tools)
#^^^^THIS DISCLAIMER IS ONLY RELEVANT IF YOU USE GROMACS FOR MD SIMULATION^^^^

#Reorganize the generated data of the ligand for better overview, get ready to prepare recptor topology
mkdir ligand
mv ligand.* ligand/
mkdir receptor
mv receptor.pdb receptor/
cd receptor

#Preparing topology for receptor
$GMX pdb2gmx -f receptor.pdb -o receptor_GMX.pdb -water $WATER -ff $FF

#Copy files from receptors/ligand folders, to merge receptor and ligand topologies.
cd ../../
cp param/receptor/*.itp param/receptor/topol.top .
cp param/ligand/ligand.acpype/ligand_GMX.itp ligand.itp
cp param/ligand/ligand.acpype/posre_ligand.itp posre_ligand.itp

#Add the ligand topology inside "topol.top"
cp topol.top topol.bak
awk '/; Include forcefield parameters/ {found=1} /#include/ && found \
{print; print ""; print "; Include topology for ligand"; print "#include \"ligand.itp\""; found=0; next} 1' \
topol.top > tmpfile && mv tmpfile topol.top
echo "ligand   1" >> topol.top

#Build the final topology structure to use in your MD Simulation and store everything in an results directory (besides YASARA you could of course use the the files)
ndx=$($GMX make_ndx -f param/receptor/receptor_GMX.pdb -o param/receptor/receptor_GMX_conv.ndx <<EOF
q
EOF
)
edit=$($GMX editconf -f param/receptor/receptor_GMX.pdb -o param/receptor/receptor_GMX_conv.pdb -n param/receptor/receptor_GMX_conv.ndx <<EOF
0
EOF
)
grep -h 'ATOM\|TER\|TITLE\|MODEL' param/receptor/receptor_GMX_conv.pdb param/ligand/ligand.acpype/ligand_NEW.pdb > $RECNAME"_MDprocessed.pdb"
echo 'TER
ENDMDL
' >> $RECNAME"_MDprocessed.pdb"
cut --complement -b67-79 $RECNAME"_MDprocessed.pdb" > $RECNAME"_MDtemp.pdb"
mv $RECNAME"_MDtemp.pdb" $RECNAME"_MDprocessed.pdb"
ndx=$($GMX make_ndx -f $RECNAME"_MDprocessed.pdb" -o $RECNAME"_MDprocessed.ndx" <<EOF
"Protein" | "LIG"
name 14 Complex
q
EOF
)
edit=$($GMX editconf -f $RECNAME"_MDprocessed.pdb" -n $RECNAME"_MDprocessed.ndx"  -o $RECNAME"_MDprocessed.gro" <<EOF
0
EOF
)
mkdir results
mkdir results/final_strc
mkdir results/final_top
mkdir results/inputs
mv *_MDprocessed* results/final_strc/
mv topol.* results/final_top/
mv ligand.itp results/final_top/
mv posre* results/final_top/
mv $RECNAME".pdb" results/inputs/
mv $LIGNAME".pdb" results/inputs/
mv GROMACS_AMBER_GENERATOR.sh results/
rm *
