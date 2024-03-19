import numpy as np
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.ticker import AutoMinorLocator


WIDTH = 1.5 * 8.3 / 2.54
DOUBLE_WIDTH = 1.5 * 17.1 / 2.54
DPI = 150
matplotlib.rcParams.update(
    {
        'axes.labelsize': 14,
        'axes.xmargin': 0,
        'axes.ymargin': .1,
        'lines.markersize': 5,
        'figure.dpi': DPI,
        'figure.autolayout': True,
        'figure.figsize': (WIDTH, 3 * WIDTH / 4),
        'figure.facecolor': 'white',
        'font.size': 12,
        'grid.color': '0',
        'grid.linestyle': '-',
        'legend.edgecolor': '1',
        'legend.fontsize': 10,
        'xtick.labelsize': 12,
        'ytick.labelsize': 12,
        'font.family': "DeJavu Serif",
        'font.serif': ["Computer Modern Roman"],
        'mathtext.fontset': 'cm',
        'mathtext.rm': 'serif',
        'text.usetex': False
    }
)


files = ['0.1.0-ION-600-1-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1',
         '1.1.0-ION-600-1-0.5-POL-50-27-12-DIEL-0.15-PRE-0.005-TEMP-1',
         '0.2.0-ION-300-2-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1',
         '1.2.0-ION-300-2-0.5-POL-50-27-12-DIEL-0.15-PRE-0.005-TEMP-1',
         '0.3.0-ION-200-3-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1',
         '1.3.0-ION-200-3-0.5-POL-50-27-12-DIEL-0.15-PRE-0.005-TEMP-1']

colors = ['steelblue','steelblue','yellowgreen', 'yellowgreen', 'gold', 'gold']
linestyle = ['-', '--','-', '--', '-', '--']

fig, ax = plt.subplots()
xminorLocator   = AutoMinorLocator()
yminorLocator   = AutoMinorLocator()

for i, file in enumerate(files):
    data = np.loadtxt(f'../../data/{file}/4-deformation/stress.txt')
    ax.plot(data[:, 0]/data[-1, 0]*900, data[0,1]-data[:, 1], label=file, color=colors[i], linestyle=linestyle[i])
ax.xaxis.set_minor_locator(xminorLocator)
ax.yaxis.set_minor_locator(yminorLocator)
ax.set_xlabel("Strain [%]",fontsize=16)
ax.set_ylabel("Stress [-]",fontsize=16)
plt.ylim(0,0.12)
plt.xticks(fontsize=14)
plt.yticks(fontsize=14)
plt.tick_params(direction="in",top=True,right=True)
plt.tick_params(which="minor",direction="in",top=True,right=True)
plt.savefig("figures/stress_strain_di_tri_solv.png")