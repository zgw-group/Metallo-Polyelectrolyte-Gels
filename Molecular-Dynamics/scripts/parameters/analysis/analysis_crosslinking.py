import logging
from pathlib import Path
from typing import Callable

# Third-party packages
import numpy as np
import pandas as pd
import sys

# MDAnalysis package
import MDAnalysis as mda
from MDAnalysis.analysis.base import AnalysisBase
from MDAnalysis.analysis import distances
from MDAnalysis.core.groups import AtomGroup
from MDAnalysis.lib.log import ProgressBar

class CrossLinking(AnalysisBase):  # subclass AnalysisBase

    def __init__(self, ag1: AtomGroup, ag2: AtomGroup, charge: int,
                 verbose: bool = True, **kwargs):
        # must first run AnalysisBase.__init__ and pass the trajectory
        super(CrossLinking, self).__init__(
            ag1.universe.trajectory, verbose=verbose, **kwargs)

        # Verify that the atomgroups are of type AtomGroup
        if (not isinstance(ag1, AtomGroup)) or (not isinstance(ag2, AtomGroup)):
            raise TypeError("atomgroups must be of type AtomGroup")

        self.logger = logging.getLogger(
            "MDAnalysis.analysis.CrossLinking")

        self.ag1: AtomGroup = ag1
        self.ag2: AtomGroup = ag2
        self.charge = charge


    def _prepare(self) -> None:
        if self._verbose:
            self.logger.info("Preparing analysis of CrossLinking")

        self.df = None
        self.results.Rg = np.zeros((self.n_frames, len(self.ag2.fragments)), dtype=float)
        self.results.Ncross = np.zeros((self.n_frames, len(self.ag2.fragments)), dtype=float)
        self.results.n_100 = np.zeros((self.n_frames, len(self.ag1.fragments)), dtype=float)
        self.results.n_110 = np.zeros((self.n_frames, len(self.ag1.fragments)), dtype=float)
        self.results.n_200 = np.zeros((self.n_frames, len(self.ag1.fragments)), dtype=float)
        self.results.n_111 = np.zeros((self.n_frames, len(self.ag1.fragments)), dtype=float)
        self.results.n_210 = np.zeros((self.n_frames, len(self.ag1.fragments)), dtype=float)
        self.results.n_300 = np.zeros((self.n_frames, len(self.ag1.fragments)), dtype=float)


    def _single_frame(self) -> None:
        ag1 = self.ag1
        ag2 = self.ag2
        u = self.ag1.universe
        if self._verbose:
            self.logger.info(f"Analyzing frame index {self._frame_index}")

        dist_arr = distances.distance_array(ag1.positions, # reference
                                        ag2.positions, # configuration
                                        box=u.dimensions)
        coord  = dist_arr<2
        ncross = np.zeros(len(ag2.fragments))
        N_100 = 0
        N_200 = 0
        N_110 = 0
        N_300 = 0
        N_210 = 0
        N_111 = 0
        for i in range(len(ag1)):
            Coord = np.add.reduceat(coord[i], np.arange(0, len(coord[i]), self.charge))
            cross = Coord>0
            b = np.array([cross])
            B = np.dot(b.transpose(),b)
            cross = cross*(sum(cross)-1)
            ncross += cross
            Coord = Coord[Coord != 0]
            Coord = list(Coord)
            if Coord == [1]:
                N_100+=1
            elif Coord == [2]:
                N_200+=1
            elif Coord == [1,1]:
                N_110+=1
            elif Coord == [3]:
                N_300+=1
            elif Coord == [2,1] or Coord == [1,2]:
                N_210+=1
            elif Coord == [1,1,1]:
                N_111+=1
        self.results.n_100[self._frame_index,:] = N_100
        self.results.n_200[self._frame_index,:] = N_200
        self.results.n_300[self._frame_index,:] = N_300
        self.results.n_110[self._frame_index,:] = N_110
        self.results.n_210[self._frame_index,:] = N_210
        self.results.n_111[self._frame_index,:] = N_111
        self.results.Ncross[self._frame_index,:] = ncross

    def _conclude(self) -> None:
        if self._verbose:
            self.logger.info("Finishing analysis of CrossLinking")

    
        # Output results
        columns = ["Frame_Index" "Ncross",
                   "n_100", "n_110", "n_200","n_111", "n_210", "n_300"]
        self.df = pd.DataFrame()
        self.df["Frame_Index"] = np.arange(self.n_frames)
        self.df["Ncross"] = [np.mean(self.results.Ncross[i,:]) for i in range(self.n_frames)]
        self.df["n_100"] = [np.mean(self.results.n_100[i,:]) for i in range(self.n_frames)]
        self.df["n_110"] = [np.mean(self.results.n_110[i,:]) for i in range(self.n_frames)]
        self.df["n_200"] = [np.mean(self.results.n_200[i,:]) for i in range(self.n_frames)]
        self.df["n_111"] = [np.mean(self.results.n_111[i,:]) for i in range(self.n_frames)]
        self.df["n_210"] = [np.mean(self.results.n_210[i,:]) for i in range(self.n_frames)]
        self.df["n_300"] = [np.mean(self.results.n_300[i,:]) for i in range(self.n_frames)]

u = mda.Universe(f'production_nve.data', 
                 f'production_nve.dcd')

ag1 = u.select_atoms("type 4")
ag2 = u.select_atoms("type 3")

CL = CrossLinking(ag1, ag2, int(sys.argv[1]))

CL.run()

CL.df.to_csv("crosslinking.csv")