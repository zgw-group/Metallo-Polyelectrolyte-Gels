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
         '0.1.2-ION-600-1-0.5-POL-50-7-42-DIEL-0.15-PRE-0.001-TEMP-1',
         '0.1.1-ION-600-1-0.5-POL-50-41-8-DIEL-0.15-PRE-0.001-TEMP-1'],
         ['0.2.0-ION-300-2-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1',
         '0.2.2-ION-300-2-0.5-POL-50-7-42-DIEL-0.15-PRE-0.001-TEMP-1',
         '0.2.1-ION-300-2-0.5-POL-50-41-8-DIEL-0.15-PRE-0.001-TEMP-1'],
         ['0.3.0-ION-200-3-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1',
         '0.3.2-ION-200-3-0.5-POL-50-7-42-DIEL-0.15-PRE-0.001-TEMP-1',
         '0.3.1-ION-200-3-0.5-POL-50-41-8-DIEL-0.15-PRE-0.001-TEMP-1']]

size = [[17400, 18900, 17600],
        [17100, 18600, 17300],
        [17000, 18500, 17200]]

l = [27, 7, 41]

colors = ['steelblue', 'yellowgreen', 'gold']


medianprops = dict(linewidth=0)
p = [[0.12186809,-0.51679297,0.56899599],
[-0.14313027 ,0.3437443 , 0.71975841],
[-0.11313027 ,0.3437443 , 0.73975841]]

for i, file in enumerate(files):
    cluster = [np.loadtxt(f'../../data/{f}/3-production_nve/cluster_size.txt')[:,1] for f in file]
    cluster_frac = [c/size[i][j] for j, c in enumerate(cluster)]
    mean_cluster_frac = [np.median(c) for c in cluster_frac]
    width = [i*2/7 for i in l[:len(file)]]

    parts = plt.violinplot(cluster_frac,widths=width, points=50, positions=l[:len(file)], showmeans=False, showmedians=False, showextrema=False)
    plt.plot(l[:len(file)],mean_cluster_frac,'+',color=colors[i],markeredgewidth=2,markersize=7)
    x = np.linspace(0,2.6,100)
    plt.plot(10**x,np.polyval(p[i],x),'--',color=colors[i])
    for pc in parts['bodies']:
        pc.set_facecolor(colors[i])
        pc.set_edgecolor(colors[i])
        pc.set_alpha(0.5) 
plt.ylim(0,1.1)
plt.xscale('log')
plt.xlim(4,300)
plt.ylabel(r"Cluster $M_w$ / Total $M_w$",fontsize=16)
plt.xlabel(r"$\ell=$[COOH]/[COO$^-$]",fontsize=16)
plt.tick_params(which="both", direction="in",top=True,right=True,labelsize=13)

plt.savefig('figures/cluster_size_pH.png')