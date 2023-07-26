hot_spots() = 8,9,65,67,70,73,207,243,244,247,256,257,258,259,281,282,283,290,293,309,310

substitutions() = 'ALA' , 'ARG', 'ASN', 'ASP' , 'CYS' , 'GLN' , 'GLU' , 'GLY' , 'HIS' , 'ILE' , 'LEU' , 'LYS' , 'MET' , 'PHE' , 'PRO' , 'SER' , 'THR' , 'TRP' , 'TYR' , 'VAL' 

For i in substitutions
  cd (i)
  For j in hot_spots
    LoadSce Gln_(j)_(i)_water.sce
    SplitObj 1,Center=Yes,Keep=ObjNum
    SaveMOL2 Obj 5, CBZ_Gln_(j)_(i).mol2
    Clear
  Clear
  cd ..
Exit