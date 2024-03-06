import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import MDAnalysis as mda

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
        'font.sans-serif': "Arial",
        'font.family': "sans-serif"
    }
)

# Files
files = [['0.1.0-Na-I-1-C(C(=O)[O-])-3,4-1-1-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.1.1-Li-I-1-C(C(=O)[O-])-3,4-1-1-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.1.2-K-I-1-C(C(=O)[O-])-3,4-1-1-B3LYP-def2-TZVPP D3BJ CPCM(water)'],
         ['0.2.0-Ca-II-1-C(C(=O)[O-])-3,4-2-1-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.2.1-Zn-II-1-C(C(=O)[O-])-3,4-2-1-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.2.2-Ni-II-3-C(C(=O)[O-])-3,4-2-1-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.2.3-Fe-II-7-C(C(=O)[O-])-3,4-2-5-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.2.4-Be-II-1-C(C(=O)[O-])-3,4-2-1-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.2.5-Cd-II-1-C(C(=O)[O-])-3,4-2-1-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.2.6-Pb-II-1-C(C(=O)[O-])-3,4-2-1-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.2.7-Co-II-4-C(C(=O)[O-])-3,4-2-2-B3LYP-def2-TZVPP D3BJ CPCM(water)'],
         ['0.3.0-Al-III-1-C(C(=O)[O-])-3,4-3-1-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.3.1-Cr-III-4-C(C(=O)[O-])-3,4-3-2-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.3.2-Fe-III-6-C(C(=O)[O-])-3,4-3-4-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.3.3-Ga-III-1-C(C(=O)[O-])-3,4-3-1-B3LYP-def2-TZVPP D3BJ CPCM(water)'],
         ['0.4.0-Zr-IV-1-C(C(=O)[O-])-4-4-1-B3LYP-def2-TZVPP D3BJ CPCM(water)',
          '0.4.1-Ti-IV-1-C(C(=O)[O-])-4-4-1-B3LYP-def2-TZVPP D3BJ CPCM(water)']]

color = ['steelblue', 'yellowgreen', 'gold', 'darkorchid']
marker = ['s', 'o', '^', '>']

plt.figure(figsize=(4.3,4))

r = np.linspace(190,350,100)
phi = -2.9979245798641774*4.74837/(1e-4*(r)**2)/1.3
# E = []
# r = []
for i, valence in enumerate(files):
    E_v = []
    r_v = []
    for j, metal in enumerate(valence):
        numligand = int(metal.split('-')[7])
        metal_name = metal.split('-')[1]
        kwd = 'Binding energy              (eV) =  '
        with open(f'../../data/{metal}/3-binding/binding.out') as file:
            for line in file:
                if kwd in line:
                    binding = float(line.split()[-1])/numligand
                    E_v.append(binding)
                    break
        u = mda.Universe(f'../../data/{metal}/2-optimization/optimization.xyz')
        
        r_metal = u.atoms[0].position
        ag = u.atoms[1:]
        r_O = []
        for k in range(numligand):
            ag2 = ag.atoms[7*k:7*(k+1)]
            r_O.append(np.sum((ag2.center_of_mass() - r_metal)**2)**0.5)
        r_v.append(np.mean(r_O)*100 )
    # E.append(E_v)
    # r.append(r_v)
        plt.plot(r_v[j],E_v[j], linestyle='', marker=marker[i], color=color[i], markeredgecolor="dimgrey", markeredgewidth=0.5)
        if i==0:
            plt.text(r_v[j]+2,E_v[j]+0.2,metal_name+r"$^{+}$",fontsize=10, color=color[i])
        elif metal_name=="Be" or metal_name=="Ca":
            plt.text(r_v[j]+2,E_v[j]-0.4,metal_name+r"$^{"+str(i+1)+"+}$",fontsize=10, color=color[i])
        elif metal_name=="Al":
            plt.text(r_v[j]-8,E_v[j]-0.6,metal_name+r"$^{"+str(i+1)+"+}$",fontsize=10, color=color[i])
        elif metal_name=="Ga":
            plt.text(r_v[j]+2,E_v[j]-0.6,metal_name+r"$^{"+str(i+1)+"+}$",fontsize=10, color=color[i])
        elif metal_name=="Cr":
            plt.text(r_v[j]-8,E_v[j]+0.2,metal_name+r"$^{"+str(i+1)+"+}$",fontsize=10, color=color[i])
        elif metal_name=="Fe" and i==2:
            plt.text(r_v[j]+2,E_v[j]-0.1,metal_name+r"$^{"+str(i+1)+"+}$",fontsize=10, color=color[i])
        else:
            plt.text(r_v[j]+2,E_v[j]+0.2,metal_name+r"$^{"+str(i+1)+"+}$",fontsize=10, color=color[i])
    
plt.plot(r,phi,linestyle="--",color="SteelBlue")
plt.plot(r,phi*2,linestyle="--",color="YellowGreen")
plt.plot(r,phi*3,linestyle="--",color="gold")

plt.text(250.,-5.9,"Ion-dipole potential",rotation=20,color="dimgrey")

plt.ylim(-11,0)
plt.xlim(190,350)
plt.tick_params(axis="x", direction="in")
plt.tick_params(axis="y", direction="in")

plt.xlabel(r"Metal-Carboxylate Distance [pm]")
plt.ylabel(r"Binding Energy [eV]")
plt.savefig("figures/binding_energy_vs_distance_tetravalent.png")

# print(E)
# print(r)