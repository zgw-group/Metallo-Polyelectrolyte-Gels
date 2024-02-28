import matplotlib.pyplot as plt
import time
import numpy as np

while True:
    plt.clf()
    try:
        # Read the file
        Energy = []
        kword = "FINAL SINGLE POINT ENERGY"
        with open('optimization.out', 'r') as f:
            lines = f.readlines()
            for line in lines:
                if kword in line:
                    Energy.append(float(line.replace(kword,"")))   
        E = np.array(Energy)
        E -= E[0]
        # dE = np.diff(E)     
        # Plot the iterations
        plt.plot(E)
        # add text to indicate the time
        # plt.text(45, 2, time.strftime("%H:%M:%S"), fontsize=12)
        plt.xlabel('Iteration')
        plt.ylabel('$\Delta E$ (Hartree)')
        plt.xlim(0, len(Energy)+1)
        
        plt.savefig('convergence.png')
        time.sleep(30)

    except Exception as error:
        print(error)
        time.sleep(30)
        continue
    # wait 120s
