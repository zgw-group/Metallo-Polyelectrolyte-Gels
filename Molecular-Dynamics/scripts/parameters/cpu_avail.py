from logging import warning
import sys
import os
import pandas as pd

os.system("top 1 -b -n 1 -w 100 | fold -w 84 > top.txt")

ncpuT = int(sys.argv[1])
ncpu = int(sys.argv[2])

df = pd.read_csv("top.txt",header=None,skiprows=2,sep=',|:',usecols=[1],nrows=ncpuT,engine="python")
os.system("rm top.txt")

avail = []
for i in range(len(df)):
    if float(df[1][i].replace(" us",""))<50:
        if i<=ncpuT/2-1:
            avail.append(int(2*i))
        else:
            avail.append(int(2*(i-ncpuT/2)+1))
avail.sort()

avail = str(avail[:ncpu])
avail = avail.replace("[","")
avail = avail.replace("]","")
avail = avail.replace(" ","")
print(avail)