# YASARA_GROMACS_MMPBSA_Masterthesis
 This is a collection of all scripts (for GROMACS, AMBER, gmx_MMPBSA) and macros (YASARA), that where written and/or used during my master thesis.
 The topic of the thesis was the  "investigation of substrate specificity for the microbial transglutaminase of streptomyces mobarensis".  
 Additionally some minor scripts, which were used in the thesis, are supplied using mainly Delphi, MOPAC and Mutatex as dependencies.

 For each script informations about the function and usability are added. Then a list of dependencies (with literature references) and flag-options (if any are given) are supplied. Additionally there are remarks concerning the programming language, the usability in several envoirments and performance (if benchmarked) is supplied. 
 
## Delphi_charge_per_res
 This automasation-script can be used to generate electrostatic surface potential for a protein of interest. The structure of the protein needs to be supplied in PDB-format.
 The surface potential is then extracted as an GAUSSIAN-CUBE map, that can used to visualize the the charge potential on the surface of the protein structure. Additionally the surface potentials are averaged per amino acid and the charge values are output as an XLSX file (can be read with excel).
 The script uses the MD DaVis programm suite [[REF]](https://academic.oup.com/bioinformatics/article/38/12/3299/6582559?login=true) to carry out the commands. In the suite it firstly uses the MSMS software [[REF]](https://pubmed.ncbi.nlm.nih.gov/8906967/) to calculate the protein surface, then Delphi software [[REF]](https://bmcbiophys.biomedcentral.com/articles/10.1186/2046-1682-5-9) to generate the potential map. Inside the suite the charge values calculated get averaged for each amino acid in the protein and stored in a HDF file. Finally these values get exported to XLSX formatting using the H5XL tool.

 Dependencies (need to be installed):

   - Getopt (install according your linux distribution - information can be found [here](https://www.thegeekdiary.com/getopt-command-not-found/))
   - [MD DaVis 0.4.1](https://github.com/djmaity/md-davis)
   - [MSMS 2.2.6.1](https://ccsb.scripps.edu/msms/)
   - [Delphi 8.5.0](http://honig.c2b2.columbia.edu/delphi)
   - [H5XL](https://github.com/echlebek/h5xl)
      
The script can be the executed in default linux CLI in bash or shell envoirnment. To run it, eihter source the script file or set an evoirnmental variable (in this example "surfcharge") It is provided with several madatory and optional flags:
      
    surfcharge -h

    script usage: Delphi_charge_per_res.sh

      Mandatory flags:

      [-s] {PDB structure - PLEASE assign protonation state and add hydrogens beforhand! F.e. by using PDB2PQR}

      Optional flags:

      [-c] {Charge assignment based on this force field parameters. OPTIONS: amber, charmm, opls, parse
            - DEFAULT: AMBER charge file}

      [-r] {Atomic radii assignment based on this force field parameters. OPTIONS: amber, charmm, opls, parse
            - DEFAULT: AMBER radius file}

      [-l] {Protein label to use for the TMOL file, if not needed leave open}

      [-m] {Organism label to use for the TMOL file, if not needed leave open}

      Help page:

      [-h {help page}]

As provided in the help page, for the calculation of the protein surface and charge potential, several force field parameters are avaliable. Information for atom specific charges and vdw-radii can be found in the [parameter subdirectory](Delphi_charge_per_res/parameters) for this script.   

## GROMACS
This automasation-script can be used convert to set up and run a protein of interest (with or without any ligand) in explicit water for 100 ns simulation time. Additionally it can extract basic data like pressure, temperature, potential energy and    

### ---Work in Progress---