# Metallo-Polyelectrolyte-Gels - Scripts
This section of the repository contains all the scripts used to perform the molecular dynamics simulations. It assumes that all software has been installed within the `software` folder. The primary file is `run.sh` where users can find out more by running:
```bash
source run.sh -h
```
The folders are organised as follows:
* `method`: Contains all the different methods potentially used by `run.sh`
* `parameters`: Contains all the parameters used by the methods (such as generic input files and analysis scripts).
* `variable`: Contain scripts for generating variables related to the system and software used when performing the simulations. 