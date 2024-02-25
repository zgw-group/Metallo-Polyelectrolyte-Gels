mkdir ${metal}_complex_IR
cd ${metal}_complex_IR

if [ ! -f ${metal}_complex.xyz ]
then
    cp ../../../../scripts/inputs/Metal_complex_IR.inp ${metal}_complex_IR.inp
    sed -i "s/ncpu/$ncpu/g" ${metal}_complex_IR.inp
    sed -i "s/Metal/$metal/g" ${metal}_complex_IR.inp
    sed -i "s/spin/$complexspin/g" ${metal}_complex_IR.inp
    sed -i "s/netcharge/$netcharge/g" ${metal}_complex_IR.inp

    cp ../${metal}_complex/${metal}_complex.xyz ${metal}_complex.xyz

    $orca_path "${metal}_complex_IR.inp" > output.out "-np $ncpu --use-hwthread-cpus --bind-to core --cpu-set $cpulist"
fi

cd ..