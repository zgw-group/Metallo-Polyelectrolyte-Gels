import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import pandas as pd
from matplotlib.ticker import AutoMinorLocator

file = '0.3.0-ION-200-3-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1'

df = pd.read_csv(f'../../data/{file}/3-production_nve/ion_pair.csv')

plt.semilogx(df['Time[ps]']*5, df['ACF_Survival_Probability'], label='Ion Pair')

plt.savefig('ion_pair.png', dpi=300)