# Metallo-Polyelectrolyte-Gels - Mean-Field Theory
This section of the repository contains all the codes needed to obtain the results obtained from mean-field theory (fraction of associated sites and phase diagrams). Unlike the other folders, the only software required to use the mean-field theory is Julia, which can be downloaded [here](https://julialang.org/downloads/). From here, to install the code needed to perform the MFT calculations, simply:
```julia
using Pkg
Pkg.activate(".")
Pkg.instantiate()
```
Once all dependencies are installed, the calculations can be performed as follows:
```julia
using MPEC

model = LS(["PAA","Ca2+"],1e3;userlocations=(;
           Z = [-1,2],
           N = [1000,1],
           l = [10,1]))

lBc, ρc = crit_pure(model)

ρsup, ρco = phaseq_pure(model, 5.0)
```