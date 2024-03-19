import numpy as np
import matplotlib.pyplot as plt
import matplotlib

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


files = [['0.1.0-ION-600-1-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1',
         '1.1.0-ION-600-1-0.5-POL-50-27-12-DIEL-0.15-PRE-0.005-TEMP-1'],
        ['0.2.0-ION-300-2-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1',
         '1.2.0-ION-300-2-0.5-POL-50-27-12-DIEL-0.15-PRE-0.005-TEMP-1'],
         ['0.3.0-ION-200-3-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1',
         '1.3.0-ION-200-3-0.5-POL-50-27-12-DIEL-0.15-PRE-0.005-TEMP-1']]

size = [[17400, 17400],
        [17100, 17100],
        [17000, 17000]]

rho = [0.05, 0.1]

colors = ['steelblue','yellowgreen', 'gold']


medianprops = dict(linewidth=0)

for i, file in enumerate(files):
    cluster = [np.loadtxt(f'../../data/{f}/3-production_nve/cluster_size.txt')[:,1] for f in file]
    cluster_frac = [c/size[i][j] for j, c in enumerate(cluster)]
    mean_cluster_frac = [np.median(c) for c in cluster_frac]
    width = [0.01 for i in rho]

    parts = plt.violinplot(cluster_frac,widths=width, points=50, positions=rho, showmeans=False, showmedians=False, showextrema=False)
    plt.plot(rho,mean_cluster_frac,'+',color=colors[i],markeredgewidth=2,markersize=7)
    p = np.polyfit(np.log10(rho),mean_cluster_frac,1)
    x = np.linspace(0,0.1,100)
    plt.plot(10**x,np.polyval(p,x),'--',color=colors[i])
    for pc in parts['bodies']:
        pc.set_facecolor(colors[i])
        pc.set_edgecolor(colors[i])
        pc.set_alpha(0.5) 
plt.ylim(0.,1.05)
# plt.xscale('log')
plt.xlim(0.02,0.12)
plt.ylabel(r"Cluster $M_w$ / Total $M_w$",fontsize=16)
plt.xlabel(r"$\rho\sigma^3$",fontsize=16)
plt.tick_params(which="both", direction="in",top=True,right=True,labelsize=13)

plt.savefig('figures/cluster_size_solv.png')