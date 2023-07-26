#Script for Generation of electrostatic surface maps using Delphi/MSMS and extracting charge per residue information using md-davis
#Author: Paul Schrank
#Requirements:
#   - Getopt package (for parsing the flag options provided by the script - installable using get/get-apt/pip/conda/...)
#   - MD DaVis package (Downloadable using conda see: https://md-davis.readthedocs.io/en/latest/install.html)
#   - Delphi Software (Downloadable after registration see: http://honig.c2b2.columbia.edu/delphi)
#   - MSMS Software (Downloadable at: https://ccsb.scripps.edu/msms/)
#   - HDF5toExcel tool (Downloadable at: https://github.com/echlebek/h5xl)

MSMS_EXE_PATH="/mnt/c/Users/paul_/Desktop/GitHub_clones/msms/msms.x86_64Linux2.2.6.1"

DELPHI_EXE_PATH="/mnt/c/Delphicpp_v8.5.0_Linux/Release/delphicpp_release"

WORKING_DIRECTORY="$(pwd)"

unset -v PDB_FILE
unset -v CHRG_FILE
unset -v RAD_FILE
unset -v PROT_NAME
unset -v MODEL_ORG

while getopts s:c:hr:l:m: opt; do
  case $opt in
    s)
      PDB_FILE=$OPTARG
      echo "Will use PDB file '$OPTARG', generated files will have same naming without the .pdb extension"
      ;;
    c)
      CHRG_FILE="/mnt/c/Shell_Scripts/Delphi_charge_per_res/parameters/"$OPTARG
      echo "The charge of your atoms will be assigned using '$OPTARG' forcefield parameters"
      ;;
    h)
      echo "script usage: Delphi_charge_per_res.sh
      
      Mandatory flags:

      [-s] {PDB structure - PLEASE assign protonation state and add hydrogens beforhand! F.e. by using PDB2PQR}
      
      Optional flags:

      [-c] {Charge assignment based on this force field parameters. OPTIONS: "amber, charmm, opls, parse"
            - DEFAULT: AMBER charge file}

      [-r] {Atomic radii assignment based on this force field parameters. OPTIONS: "amber, charmm, opls, parse"
            - DEFAULT: AMBER radius file}

      [-l] {Protein label to use for the TMOL file, if not needed leave open}

      [-m] {Organism label to use for the TMOL file, if not needed leave open}

      Help page:

      [-h {help page}]

      " >&2
      exit 0
      ;;
    r)
      RAD_FILE="/mnt/c/Shell_Scripts/Delphi_charge_per_res/parameters/"$OPTARG
      echo "The radii of your atoms will be assigned using '$OPTARG' forcefield parameters"
      ;;
    l)
      PROT_NAME=$OPTARG
      echo "Will name Protein '$OPTARG', in the generated TMOL file"
      ;;
    m)
      MODEL_ORG=$OPTARG
      echo "Will name organism of origin '$OPTARG', in the generated TMOL file"
      ;;
  esac
done

shift "$(( OPTIND -1 ))"

if [ -z "$PDB_FILE" ]; then
        echo 'Missing PDB file, please add -s flag to your command' >&2
        exit 0
fi

if [ -z "$CHRG_FILE" ]; then
        echo 'No charge file specified, will use amber charges for calculation' >&2
        CHRG_FILE="/mnt/c/Shell_Scripts/Delphi_charge_per_res/parameters/amber"
fi

if [ -z "$RAD_FILE" ]; then
        echo 'No radius file specified, will use amber radii for calculation' >&2
        RAD_FILE="/mnt/c/Shell_Scripts/Delphi_charge_per_res/parameters/amber"
fi

mkdir Delphi_Data
md-davis electrostatics --surface -c $CHRG_FILE -m $MSMS_EXE_PATH -c $CHRG_FILE".crg" -r $RAD_FILE".siz" -d $DELPHI_EXE_PATH -o $WORKING_DIRECTORY"/Delphi_Data" $WORKING_DIRECTORY/$PDB_FILE".pdb"

cp $WORKING_DIRECTORY"/"$PDB_FILE".pdb" $WORKING_DIRECTORY"/Delphi_Data/"
cd Delphi_Data 
cat >> $PDB_FILE".tmol" <<EOF
name = '$PROT_NAME'
output = 'Charge_Per_Res_$PDB_FILE.h5'
label = '$PROT_NAME from <i>$MODEL_ORG<i/>'
text_label = '$PDB_FILE'

structure = '$PDB_FILE.pdb'

[residue_property]
    surface_potential = '$WORKING_DIRECTORY/Delphi_Data'
EOF

md-davis collate $PDB_FILE".tmol"
h5xl "Charge_Per_Res_"$PDB_FILE".h5" "Charge_Per_Res_"$PDB_FILE".xlsx"
