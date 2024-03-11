import numpy as np
import MDAnalysis as mda
import sys
from mdhelper.analysis import polymer

NCHAINS = int(sys.argv[1])
NMONOMERS = int(sys.argv[2])
SPARSITY = int(sys.argv[3])

NBEADS = (SPARSITY+1)*NMONOMERS

u = mda.Universe('production_nve.data', 
                 'production_nve.dcd')

ag =  u.select_atoms("type 3 or type 1 or type 2")

relax = polymer.EndToEndVector(ag, n_chains=NCHAINS, n_monomers=NBEADS, dt=1, unwrap=True, fft=True, verbose=True)

relax.run()

relax.save('analysis_e2e')