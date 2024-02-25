# Description: optimisation of the metal complex structure
# Make and enter the optimisation directory
mkdir optimisation
cd optimisation

# if [ ! -f output.out ] # Check if the optimisation.xyz file exists. If it does, then the run probably has already been performed.
# then
    if grep -Fq "ORCA TERMINATED NORMALLY" output.out
    then
        echo "Optimisation already performed"
    else
        # Copy the input files for the optimisation to this repository
        cp ${script_path}/optimisation.inp optimisation.inp

        # Replace the placeholders in the input file with the correct values
        sed -i'' -e "s/spin/$complex_spin/g" optimisation.inp
        sed -i'' -e "s/netcharge/$complex_charge/g" optimisation.inp
        sed -i'' -e "s/ncpu/$ncpu/g" optimisation.inp
        sed -i'' -e "s/METHOD/$method/g" optimisation.inp
        sed -i'' -e "s/BASIS/$basis/g" optimisation.inp

        # Run the optimisation using ORCA
        # if ncpu greater than 1, then use pinseting

        if [ $ncpu -gt 1 ]
        then
            $orca_path optimisation.inp > output.out "-np $ncpu --use-hwthread-cpus --bind-to core --cpu-set $cpulist"
        else
            $orca_path optimisation.inp > output.out
        fi
    fi
# fi

# Exit the directory and return to the main folder
cd ..