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


# files = ['0.1.0-ION-600-1-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1',
files = [ '0.2.0-ION-300-2-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1',
         '0.2.0a-ION-300-2-0.75-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1',
         '0.3.0-ION-200-3-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1',
         '0.3.0a-ION-200-3-0.75-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1']

colors = ['yellowgreen','yellowgreen','gold', 'gold']
linestyle = ['-', '--','-', '--']

fig, ax = plt.subplots()
xminorLocator   = AutoMinorLocator()
yminorLocator   = AutoMinorLocator()

for i, file in enumerate(files):
    data = np.load(f'../../data/{file}/3-production_nve/analysis_e2e.npz')
    ax.semilogx(data["acf"][0][0], color=colors[i], linestyle=linestyle[i])


ax.xaxis.set_minor_locator(xminorLocator)
ax.yaxis.set_minor_locator(yminorLocator)
ax.set_xlabel(r"$t/\tau$",fontsize=16)
ax.set_ylabel(r"$\rho_\mathrm{poly.}(0,T)$",fontsize=16)
plt.ylim(0,1)
plt.xticks(fontsize=14)
plt.yticks(fontsize=14)
plt.tick_params(direction="in",top=True,right=True)
plt.tick_params(which="minor",direction="in",top=True,right=True)
plt.savefig('figures/e2e_tri_di_diameter.png')


# print(len(ag))