# Created by Alec Glisman (GitHub: @alec-glisman)
# Standard library
import logging
from pathlib import Path
import sys

# Third-party packages
import numba as nb
import numpy as np
import pandas as pd

# MDAnalysis package
import MDAnalysis as mda
from MDAnalysis.analysis.base import AnalysisBase
from MDAnalysis.analysis import distances
from MDAnalysis.core.groups import AtomGroup
from MDAnalysis.lib.log import ProgressBar

class AutocorrelationAtomPair(AnalysisBase):  # subclass AnalysisBase
    """
    This class implements the calculation of the atom pair relaxation
    correlation function (APC)

    :param AnalysisBase: MDAnalysis analysis class
    :type AnalysisBase: AnalysisBase
    """

    def __init__(self, ag1: AtomGroup, ag2: AtomGroup,
                 r_cut_ang: float,
                 tau_max: int, window_step: int = 0,
                 verbose: bool = True, **kwargs):
        """
        Initialize AutocorrelationAtomPair analysis class. Method calls parent
        class initializer.

        :param ag1: AtomGroup 1 for pair relaxation
        :type ag1: AtomGroup
        :param ag2: AtomGroup 2 for pair relaxation
        :type ag2: AtomGroup
        :param r_cut_ang: Cutoff distance for pair relaxation. Reference
        unit: Angstrom.
        :param tau_max: Maximum lag time in number of frames to calculate
        correlation function.
        :type tau_max: int
        :param window_step: Maximum number of frames atoms can be
        continuously separated to account for recrossing events, defaults to 0
        :type window_step: int, optional
        :param verbose: Output verbose information for debugging and logging,
        defaults to True
        :type verbose: bool, optional
        """
        # must first run AnalysisBase.__init__ and pass the trajectory
        super(AutocorrelationAtomPair, self).__init__(
            ag1.universe.trajectory, verbose=verbose, **kwargs)

        # Verify that the atomgroups are of type AtomGroup
        if (not isinstance(ag1, AtomGroup)) or (not isinstance(ag2, AtomGroup)):
            raise TypeError("atomgroups must be of type AtomGroup")

        self.logger = logging.getLogger(
            "MDAnalysis.analysis.AutocorrelationAtomPair")

        self.ag1: AtomGroup = ag1
        self.ag2: AtomGroup = ag2

        self.df = None
        self.results = None
        self.coeffs = None

        self.r_cut_ang: float = r_cut_ang
        self.window_step: int = window_step
        self.tau_max: int = tau_max

    def _prepare(self) -> None:
        """
        Initialize data structures dependent on `self.n_frames` and prepare
        class for frame-by-frame trajectory analysis.
        """
        if self._verbose:
            self.logger.info("Preparing analysis of AutocorrelationAtomPair")

        # output array of parameters (col 0: frame_index,
        # 1: Time[ps], 2: Time[ns],
        # 3: ACF_Survival_Probability
        self.results: np.ndarray = np.zeros((self.n_frames, 4), dtype=float)

        # initialize arrays for computations
        self.atom_pairs: np.ndarray = np.zeros(
            (self.n_frames, len(self.ag1.atoms), len(self.ag2.atoms)),
            dtype=int)
        self.atom_pairs_filled: np.ndarray = np.zeros_like(
            self.atom_pairs, dtype=int)

    def _single_frame(self) -> None:
        """
        Capture the simulation time and atom pairing topology for each frame.
        """
        if self._verbose:
            self.logger.info(f"Analyzing frame index {self._frame_index}")

        # get time of current frame
        self.results[self._frame_index, 0] = self._trajectory.time
        self.results[self._frame_index, 1] = self._ts.frame
        self.results[self._frame_index, 2] = self._trajectory.time / 1000.0

        # calculate distances between groups in selections
        self._pairwise_distances()

    def _conclude(self) -> None:
        """
        Calculate the survival probability correlation function
        for  current trajectory.
        """
        if self._verbose:
            self.logger.info("Finishing analysis of AutocorrelationAtomPair")

        # Remove recrossing events from trajectory
        self.atom_pairs_filled = _persistence(
            self.atom_pairs.copy(), self.window_step)

        # calculate correlation function
        self._correlation()

        # Output results
        columns = ["Frame_Index",
                   "Time[ps]", "Time[ns]",
                   "ACF_Survival_Probability"]
        self.df = pd.DataFrame(self.results, columns=columns)

        self.df["Time[ns]"] = self.df["Time[ns]"]-self.df["Time[ns]"][0]

    def _pairwise_distances(self) -> None:
        """
        Calculate the pairwise distances between atoms in each group of the
        selection.

        Function modifies self.atom_pairs and uses built-in MDAnalysis
        function: distances.distance_array() for efficiency.
        """
        # get pairwise distances between atoms in selection_1 and selection_2
        dist_arr: np.ndarray = distances.distance_array(
            self.ag1.positions, self.ag2.positions,
            box=self.ag1.universe.dimensions)

        # convert 0.0 to np.inf (do not count self-interactions)
        dist_arr: np.ndarray = np.where(dist_arr <= 1e-6, np.inf, dist_arr)

        # convert float distances to int (booleans) based on distance cutoff
        self.atom_pairs[self._frame_index] = dist_arr < self.r_cut_ang

    def _correlation(self) -> None:
        """
        Iterate over all frame lag-times up to self.n_frames // 2 and
        calculate the un-normalized survival probability of all possible
        atom pairs.
        Function does not iterate over larger lag-times, as this would yield
        fewer lag-times to average over and generate good statistics.
        """
        if self._verbose:
            self.logger.info(
                "Calculating correlation of AutocorrelationAtomPair")

        for lag in ProgressBar(range(self.tau_max), verbose=self._verbose):
            self.results[lag, 3] += _survival_imm(
                lag, self.atom_pairs, self.atom_pairs_filled)

        # normalize probability
        self.results[:, 3] /= self.results[0, 3]

    def save(self, filename: str, tag: str = None,
             dir_out: str = "./output/mdanalysis") -> None:
        """
        Save key data structures for later analysis.

        :param filename: filename (without extension) for output files
        :type filename: str
        :param tag: Unique tag to add as a key to dataframe, defaults to None
        :type tag: str
        :param dir_out: directory path to output files, defaults to
        "./output/mdanalysis"
        :type dir_out: str, optional
        """
        if self._verbose:
            self.logger.info("Saving results of AutocorrelationAtomPair")

        if tag is not None:
            self.df["Tags"] = tag

        # create output directory and save files
        Path(dir_out).mkdir(parents=True, exist_ok=True)
        self.df.to_pickle(f"{dir_out}/df_ACFAtomPair_{filename}.pkl")

nb.set_num_threads(int(sys.argv[1]))
@ nb.jit(nopython=True, parallel=True, nogil=True)
def _survival_imm(lag: int, atom_pairs: np.ndarray,
                  atom_pairs_filled: np.ndarray) -> int:
    """
    Calculate the un-normalized survival probability of all possible atom pairs
    at all frames with range of the trajectory for a specific frame lag time.
    The atom pair must exist in the frame for the lag time at both end points
    and can be unpaired continuously for at most n_frame_unpair frames.

    The survival probability is calculated using the algorithm in [Impey1983]_.

    :param lag: Number of frames between the start and end frames of the
    atom pair
    :type lag: int
    :param atom_pairs: 3D array (n_frame, atom_1, atom_2) of booleans indicating
    whether the atom pair (atom_1, atom_2) exists at the frame
    :type atom_pairs: np.ndarray
    :param atom_pairs_filled: 3D array (n_frame, atom_1, atom_2) of booleans
    indicating whether the atom_pair (atom_1, atom_2) persisted
    (with recrossings) during the trajectory
    :type atom_pairs_filled: np.ndarray
    :return: Total number of atom pairs that existed in the trajectory for the
    specified lag time
    :rtype: int
    """
    # initialize number of surviving atom pairs to zero
    survive: int = 0
    n_frames, n_ag1, n_ag2 = np.shape(atom_pairs)

    # loop over all possible subsets of trajectory with given lag time
    for start in nb.prange(n_frames - lag):  # pylint: disable=not-an-iterable
        end: int = start + lag
        # find if pair exists at both ends of trajectory
        pairs_exist: np.ndarray = \
            (atom_pairs[start, :, :] + atom_pairs[end, :, :]) == 2

        # check if each atom pair survived
        for ag1 in nb.prange(n_ag1):      # pylint: disable=not-an-iterable
            for ag2 in nb.prange(n_ag2):  # pylint: disable=not-an-iterable

                # only evaluate persistence if the pair exists at both ends
                # of the trajectory
                pair_survived: int = 1
                if pairs_exist[ag1, ag2]:

                    for p in atom_pairs_filled[start:(end+1), ag1, ag2]:
                        if p == 0:
                            pair_survived = 0
                            break

                    survive += pair_survived

    return survive


def _replace_recrossing_events(arr: np.ndarray, window_step: int) -> np.ndarray:
    """
    Replaces temporary recrossing events with paired state to make calculation
    of atom pair persistence easier. Original code is modified from
    https://stackoverflow.com/a/3274416/13215572

    :param arr: 1D array of 1, 0 pairing states.
    :type arr: np.ndarray
    :param window_step: Maximum number of frames an atom pair can be
    continuously unpaired and be considered a recrossing event
    :type window_step: int
    :return: 1D array with recrossing events all replaced with ones
    :rtype: np.ndarray
    """
    # Input checking
    if arr.ndim != 1:
        raise ValueError(f"Input array must be 1D: {arr.shape}")
    if window_step >= len(arr):
        raise ValueError(f"Window step must be smaller than array length: "
                         f"{window_step} > {len(arr)}")

    # Pad array with ones so that diff can work properly
    pad_arr = np.concatenate(([1], arr, [1]))

    # Find all indices where pairing state changes
    diff_arr = np.diff(pad_arr)

    # Find indices of continuous unpaired events
    idx_start = np.argwhere(diff_arr < 0)  # 1 --> 0
    idx_end = np.argwhere(diff_arr > 0)    # 0 --> 1
    duration = idx_end - idx_start

    # Find continuous unpairing events that are recrossing events
    pairs_recrossed = duration <= window_step
    idx_start = idx_start[pairs_recrossed]
    idx_end = idx_end[pairs_recrossed]
    idx_end = idx_end[idx_end < len(arr)]

    # Find all states that correspond to recrossing events
    idx_recross = np.zeros(len(arr), dtype=int)
    idx_recross[idx_start] = 1  # 1 at tart of the intervals
    idx_recross[idx_end] -= 1   # -1 at one frame after end of the intervals
    idx_recross = np.argwhere(np.cumsum(idx_recross))

    # replace data in original array with paired state
    arr[idx_recross] = 1
    return arr


def _persistence(pair_states: np.ndarray, window_step: int) -> np.ndarray:
    """
    Loops over all atom pairs and replaces recrossing events with ones to make
    pair persistence easier to calculate.

    :param pair_states: 3D array (frame, atom_1, atom_2) of ints indicating
    whether the atom pair (atom_1, atom_2) exists at the frame.
    :type pair_states: np.ndarray
    :param window_step: Maximum number of frames an atom pair can be
    continuously unpaired and be considered a recrossing event
    :type window_step: int
    :return: 3D array (frame, atom_1, atom_2) of ints indicating whether
    the atom pair (atom_1, atom_2) persists at the frame
    """
    _, n_ag1, n_ag2 = np.shape(pair_states)
    results = np.zeros_like(pair_states)

    for ag1 in range(n_ag1):
        for ag2 in range(n_ag2):
            results[:, ag1, ag2] = \
                _replace_recrossing_events(
                    pair_states[:, ag1, ag2], window_step)

    return results

u = mda.Universe(f'production_nve.data', 
                 f'production_nve.dcd')

ag1 = u.select_atoms("type 3")
ag2 = u.select_atoms("type 4")

IP = AutocorrelationAtomPair(ag1,ag2,1.5,int(sys.argv[2]))

IP.run(step=2)

IP.df.to_csv("ion_pair.csv")