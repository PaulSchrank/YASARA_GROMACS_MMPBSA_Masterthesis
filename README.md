# YASARA_GROMACS_MMPBSA_Masterthesis
 This is a collection of all scripts (for GROMACS, AMBER, gmx_MMPBSA) and macros (YASARA), that where written and/or used during my master thesis.
 The topic of the thesis was the  "investigation of substrate specificity for the microbial transglutaminase of streptomyces mobarensis".  
 Additionally some minor scripts, which were used in the thesis, are supplied using mainly Delphi, MOPAC and Mutatex as dependencies.

 For each script informations about the function and usability are added. Then a list of dependencies (with literature references) and flag-options (if any are given) are supplied. Additionally there are remarks concerning the programming language, the usability in several envoirments and performance (if benchmarked) is supplied. 

# Delphi_charge_per_res
 This automasation-script can be used to generate electrostatic surface potential for a protein of interest. The structure of the protein needs to be supplied in PDB-format.
 The surface potential is then extracted as an GAUSSIAN-CUBE map, that can used to visualize the the charge potential on the surface of the protein structure. Additionally the surface potentials are averaged per amino acid and the charge values are output as an XLSX file (can be read with excel).
 The script uses the MD-DaVis programm suite [[REF]] (https://academic.oup.com/bioinformatics/article/38/12/3299/6582559?login=true) to carry out the commands. In the suite it firstly uses the MSMS software [REF] to calculate the protein surface, then Delphi software [REF] to generate the potential map. Inside the suite the charge values calculated get averaged for each amino acid in the protein and stored in a HDF file. Finally these values get exported to XLSX formatting using the H5XL tool [REF].

 Dependencies (need to be installed):

    - Getopt
    - MD-DaVis
    - MSMS
    - Delphi
    - H5XL

      