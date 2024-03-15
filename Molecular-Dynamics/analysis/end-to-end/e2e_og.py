import numpy as np
import MDAnalysis as mda
from mdhelper.analysis import polymer
from matplotlib import pyplot as plt
import pandas as pd

def acf_end(df):
    Rend= np.array([[df["Rend"][i][j][0] for j in range(50)] for i in range(len(df["Rend"]))])
    acf = np.zeros(len(Rend))
    for i in range(len(Rend)):
        for j in range(50):
            acf[i]+=np.mean(np.sum(Rend[i:,j]*Rend[:len(Rend)-i,j],axis=1))
        acf[i] = acf[i]/50
    df["ACF_Rend"] = acf
    return df

def analysis(u):
    ag2 = u.select_atoms("type 3 or type 1 or type 2")

    df = pd.DataFrame()
    Rend = []
    j = 0
    for ts in u.trajectory:
        Rend2 = []
        for i in range(len(ag2.fragments)):
            frag_coord = ag2.fragments[i].unwrap()
            rstart = frag_coord[0]
            rend   = frag_coord[-1]
            Rend2.append([rstart-rend])
        if j % 1000 == 0:
            print(j)
        Rend.append(Rend2)
        j+=1

    df["Rend"] = Rend
    df = acf_end(df)

    return df



file = '0.3.0-ION-200-3-0.5-POL-50-27-12-DIEL-0.15-PRE-0.001-TEMP-1'

u = mda.Universe('../../data/'+file+'/3-production_nve/production_nve.data', 
                 '../../data/'+file+'/3-production_nve/production_nve.dcd')

ag2 = u.select_atoms("type 3 or type 1 or type 2")
# print(len(ag2.fragments[0]))
ag2 = u.select_atoms("type 3")
# print(len(ag2.fragments[0]))

df = analysis(u)

df.to_csv('test.csv', index=False)

df = pd.read_csv('test.csv')

plt.semilogx(df["ACF_Rend"]/df["ACF_Rend"].iloc[0])
plt.savefig('test_old.png')
# print(len(ag))