kwd = "FINAL SINGLE POINT ENERGY"

complexfile = open("../optimisation/output.out")

lines = complexfile.readlines()
for line in reversed(lines):
    if kwd in line:
        E_C = 27.2114*float(line.replace(kwd,""))
        break  
    
metalfile = open("output_metal.out")

lines = metalfile.readlines()
for line in reversed(lines):
    if kwd in line:
        E_M = 27.2114*float(line.replace(kwd,""))
        break  
    
ligandfile = open("output_ligand.out")

lines = ligandfile.readlines()
for line in reversed(lines):
    if kwd in line:
        E_L = 27.2114*float(line.replace(kwd,""))
        break  
    
print("Complex Single Point Energy (eV) = ",E_C)
print("Metal Single Point Energy   (eV) = ",E_M)
print("Ligand Single Point Energy  (eV) = ",E_L)
print("Binding energy              (eV) = ",E_C-E_M-E_L)