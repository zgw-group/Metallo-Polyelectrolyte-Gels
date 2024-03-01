# Metallo-Polyelectrolyte-Gels - Quantum Chemistry Software
In this folder, we provide all the scripts needed to install the packages used to perform the molecular dynamics simulations:
* LAMMPS (August 2023): Performs the molecular dynamics simulations. The installation script will automatically add the optional packages. However, users will need to specify the CUDA architecture used.
* mdhelper: Used to perform the analysis of the molecular dynamics trajectories.
* mpirun (v4.1.5): Used to parallelize the simulations across multiple CPUs.

Note that, to install ORCA, one needs to download the tarball from the [ORCA forum](https://orcaforum.kofo.mpg.de/app.php/portal).