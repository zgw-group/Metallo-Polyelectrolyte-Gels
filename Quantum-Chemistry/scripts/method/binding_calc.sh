# Description: binding energy calculations for the metal complex structure
# Make and enter the binding energy directory
mkdir binding_calc
cd binding_calc

# if [ ! -f output_metal.out ] # Check if the optimisation.xyz file exists. If it does, then the run probably has already been performed.
# then
    if grep -Fq "ORCA TERMINATED NORMALLY" output_metal.out
    then
        echo "Metal calculation already performed"
    else
        # Copy the input files for the metal to this repository
        cp ${script_path}/binding_metal.inp binding_metal.inp

        # Replace the placeholders in the input file with the correct values
        sed -i'' -e "s/Metal/$metal/g" binding_metal.inp
        sed -i'' -e "s/spin/$spin/g" binding_metal.inp
        sed -i'' -e "s/charge/$charge/g" binding_metal.inp
        sed -i'' -e "s/ncpu/$ncpu/g" binding_metal.inp
        sed -i'' -e "s/METHOD/$method/g" binding_metal.inp
        sed -i'' -e "s/BASIS/$basis/g" binding_metal.inp

        # Run the metal calculations using ORCA
        $orca_path binding_metal.inp > output_metal.out
    fi
# fi

# if [ -f output_ligand.out ] # Check if the optimisation.xyz file exists. If it does, then the run probably has already been performed.
# then
    if grep -Fq "ORCA TERMINATED NORMALLY" output_ligand.out
    then
        echo "Ligand calculation already performed"
    else
        # Copy the input files for the ligand to this repository
        cp ${script_path}/binding_ligand.inp binding_ligand.inp

        # Replace the placeholders in the input file with the correct values
        cp ../optimisation/optimisation.xyz initial_ligand.xyz
        sed -i '3d' initial_ligand.xyz
        natoms=$(head -n 1 initial_ligand.xyz)
        natoms=$((natoms-1))
        sed -i "1s/.*/$natoms/" initial_ligand.xyz

        sed -i'' -e "s/spin/$total_ligand_spin/g" binding_ligand.inp
        sed -i'' -e "s/netcharge/$total_ligand_charge/g" binding_ligand.inp
        sed -i'' -e "s/ncpu/$ncpu/g" binding_ligand.inp
        sed -i'' -e "s/METHOD/$method/g" binding_ligand.inp
        sed -i'' -e "s/BASIS/$basis/g" binding_ligand.inp

        # Run the ligand calculations using ORCA
        if [ $ncpu -gt 1 ]
        then
            $orca_path binding_ligand.inp > output_ligand.out "-np $ncpu --use-hwthread-cpus --bind-to core --cpu-set $cpulist"
        else
            $orca_path binding_ligand.inp > output_ligand.out
        fi
    fi
# fi
python ${script_path}/binding_energy_calc.py > output_binding.out
# Exit the directory and return to the main folder
cd ..