# Description: Generate initial structure for the metal complex
# Make and enter the initial directory
mkdir initial
cd initial

if [ ! -f initial.xyz ] # Check if the initial.xyz file exists. If it does, then the run probably has already been performed.
then
    # Copy the input files for the initial guess to this repository
    cp ${script_path}/initial.inp initial.inp

    # Replace the placeholders in the input file with the correct values
    sed -i'' -e "s/metal/$metal/g" initial.inp
    sed -i'' -e "s/spinmultiplicity/$spin/g" initial.inp
    sed -i'' -e "s/netcharge/$netcharge/g" initial.inp
    sed -i'' -e "s/oxidationstate/$oxidationstate/g" initial.inp
    sed -i'' -e "s/ligandsmile/$ligandsmile/g" initial.inp
    sed -i'' -e "s/bindingsites/$bindingsites/g" initial.inp
    sed -i'' -e "s/numligand/$numligand/g" initial.inp

    # Obtain the initial guess for the structure from MolSimplify
    molsimplify -i initial.inp

    # Rename the output file to initial.xyz and remove all other files
    find . -name '*xyz' -exec mv {} initial.xyz \;
    rm -r Runs
fi

# Exit the directory and return to the main folder
cd ..