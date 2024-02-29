#!/usr/bin/python
 
# Script:  mkinput.py
# Purpose: Make input file
# Syntax:  mkinput_pendant.py
# Example: mkinput_pendant.py
# Author:  Mark Stevens
# Modified: Lisa Hall 1/10
#Change to box center of 0 (-L/2 to L/2)

 
# Took out angle placeholders, binning, salt, overlap check, grafting site LMH 
# Counterion valence works for integer polymercharges/counterionvalence LMH 
# chains are random walk.
# No impropers in pdb, psf files

#  lammps types    
#  1         charged polymer beads
#  2         neutral polymer beads
#  3         counterions

import sys, string, math
from numpy import *
from random import *

#-------------------------------------------------------------------------
 ## 3 beads, 10 monomers, 100 poly = 4000 atoms, 30 bead/monomer
 ## 5 beads, 6 monomers, 111 poly = 3996 atoms, 30 bead/monomer
 ## 7 beads, 4 monomers, 125 poly = 4000 atoms, 28 bead/monomer
# INPUT PARAMETERs

##ADJUSTED DENSITY

iseed = 9328              # random number seed
nbeads = Nbb+1               # number of beads in monomer (3, 5, 7, or 9 for ionomer project, plus one for pendant group)
nxbeads = 1       #number of beads in the x segment of only backbone, to be randomly added in
x_y = 0     #ratio of uncharged x segments per regular 'y' segments with charged monomers
nmonomersperpoly = Nmono      # total (including x) number of monomers in polymer (for now use 12,7,5,4)(could use 35, 21, or 15 to make 105 bead/chain)
npoly = Npoly                 # number of polymers
minsep = 1.0                # allowed separation in overlap check
cisize = r_i               #counterion diameter/bead diameter; to adjust density
pendantsize = 1.0           #pendant group diameter/bead diameter; to adjust density and length from bead
N_i = Nion
z_c = Z_c                   # counterion valence                 
dens = rho               # bead density
neutralizedfraction = 1.0      #fraction of pendant groups that are fully (-1) charged
chargeonunneutralized = 0.0     #charge (- on pendant, + on alpha bead) for unneutralized pendants
bond = 0.97  # bond length. depends on bond potential, but close to 1 is good enough

minsep2 = minsep*minsep

# Label schemes

# type names: alpha bead (alpha to the pendant group), neutral bead, pendant group, counterion, unneutralized alpha, unneutralized pendant, extra (random) beads
#            0   1     2     3    4     5     6      7 
atype = ( '00', 'AB', 'NB', 'PG', 'IO', 'FA', 'UP', 'EB')

# define monomer
#  [note first entry is 0 index & not used]
sequence = []
for i in range(nbeads+1):
    if i<int((nbeads-2)/2) or i>int(nbeads/2+1):
        sequence.append(2)
    elif i==int(nbeads/2):
        sequence.append(1)
    elif i==int(nbeads/2+1):
        sequence.append(3)
if (nxbeads == 3):
    xsequence =  [ 7, 7, 7]  # entries are types
elif (nxbeads==1):
    xsequence = [7]
else:
    sys.exit ("define x sequence of monomers.")
# dictionary between type and charge (if neutralizedfraction<1, some - charges will be overwritten as 0)
charge  = {
        1:0,
        2:0,
        3:-1,
        4:+1,
        }

# END INPUT Parameters ------------------------------------------------------
#If you don't want to use stdin, try something like:
#import os
#os.chdir('/Users/lhall/imers3')
#file1=open('sim.dump','r')
#file1.readline()

# files
INPUT_LAMMPS = open('input.data', 'w')
##INPUT_PDB = open('input.pdb', 'w')
##INPUT_PSF = open('input.psf', 'w')

print(str(sequence)+"\n")

if nbeads == 3:
    nmonomers=(nmonomersperpoly)*npoly
else:
    nmonomers=(nmonomersperpoly)*npoly

nxmonomers=int(round(float(x_y)/(float(x_y)+1)*nmonomers))
print(str(nmonomers)+"\n")
print(str(nxmonomers)+"\n")
#length = nbeads*nmonomersperpoly
#length1 = length+1 # used for loops

# constants
ntypes = 5 # neutral site + alpha site + pendant + counterion + unneutralized alpha+ unneutralized pendant/cb + extra uncharged bead

nchargedmonomers = int((nmonomers-nxmonomers)*neutralizedfraction)
print(nchargedmonomers)
ncounterions = N_i
ncoion = int(nchargedmonomers-z_c*N_i)
if ncoion<0:
    charge_coion = -1
    ncoion = -ncoion
else:
    charge_coion = 1

npendant=int(nmonomers-nxmonomers)

if nbeads==3:
    ntot = int((nmonomers-nxmonomers)*nbeads + nxmonomers*nxbeads + npoly + ncounterions + ncoion)
else:
    ntot = int((nmonomers-nxmonomers)*nbeads + nxmonomers*nxbeads + ncounterions + ncoion)

#adjust volume to account for same eta_t with different size counterions
#eta_t=pi/6*dens=(N1sigma1^3pi/6+N2sigma2^3pi/6+N3sigma2^3pi/6)/vol
#number of regular beads = total beads- pendants (pendans = npoly*nmonomers)
vol = (ntot-ncounterions-ncoion-npendant+npendant*pendantsize**3+ncounterions*cisize**3)/dens
side = vol**(1./3.)
dim = int(ntot+1)

# simulation cell parameters
hx = side
hy = side
hz = side

hx2 = hx/2.
hy2 = hy/2.
hz2 = hz/2.

vol = hx*hy*hz
#bonds along chain plus pendant bonds
nbonds = ntot-ncounterions-npoly-ncoion

print("\n")
print("Total number of particles: "+str(ntot)+"\n")
print("Number of chains = "+ str(npoly)+"\n")
print("actual density "+str(ntot/vol)+"\n")
print("beads in y monomer = "+ str(nbeads)+"\n")
print("beads in x monomer = "+ str(nxbeads)+"\n")
print("ratio x/y monomers = "+ str(x_y)+"\n")
print("monomers total = "+ str(nmonomers)+"\n")
print("N counterions = "+ str(ncounterions)+"\n")
print("N co-ions = "+ str(ncoion)+"\n")


print("Number of atoms types = "+str(ntypes)+"\n")
print("seed = "+str( iseed)+"\n")

print("\n")
print("Geometry:"+"\n")
print("dens = "+str(dens)+"\n")

print("vol = "+str(vol)+"\n")

print("\n")



print("metric: %10.4f %10.4f %10.4f\n\n" % (hx, hy, hz)+"\n")


# init position variables
xc=zeros(dim,float32)
yc=zeros(dim,float32)
zc=zeros(dim,float32)
cx=zeros(dim)
cy=zeros(dim)
cz=zeros(dim)

# Build polymers

rg2ave=0.0
rgave=0.0
rend2ave = 0.0
typeb=[0]*dim
molnum=[0]*dim
q=[0.0]*dim
k=0
                              
xmonomers=sample(range(nmonomers),nxmonomers)

if nbeads==3:
    for ix in range(npoly):
        lengthcurrentpoly = 0
        k = k+1
        k1 = k
        xc[k] = random()*hx
        yc[k] = random()*hy
        zc[k] = random()*hz
        typeb[k] = 2
        q[k] = 0
        molnum[k] = ix + 1
        lengthcurrentpoly = lengthcurrentpoly + 1
        for iy in range(nmonomersperpoly):
            currentmonomer = ix*nmonomersperpoly + iy
            seq=sequence
            seqnum = 0
            for iz in seq:
                seqnum = seqnum + 1
                k = k + 1
                lengthcurrentpoly = lengthcurrentpoly + 1
                typeb[k] = iz
                q[k] = charge[iz]
                molnum[k] = ix + 1
                if iy == 0 and seqnum == 1:
                    dx = random()-0.5
                    dy = random()-0.5
                    dz = random()-0.5
                    r = sqrt(dx*dx+dy*dy+dz*dz)
                    scale = bond/r
                    dx = scale*dx
                    dy = scale*dy
                    dz = scale*dz
                    if (typeb[k-1] == 2 or typeb[k-1] == 7):
                        xc[k] = xc[k-1] + dx
                        yc[k] = yc[k-1] + dy
                        zc[k] = zc[k-1] + dz
                    elif (typeb[k-1] == 3): #if you just did a pendant group, attach back to the alpha bead
                        xc[k] = xc[k-2] + dx
                        yc[k] = yc[k-2] + dy
                        zc[k] = zc[k-2] + dz
                    elif (typeb[k-1] == 1): #if you just did an alpha group, attach pendant at potentially different distance
                        xc[k] = xc[k-1] + dx*pendantsize
                        yc[k] = yc[k-1] + dy*pendantsize
                        zc[k] = zc[k-1] + dz*pendantsize
                else:
                    if (typeb[k-1] == 2 or typeb[k-1] == 7):
                        xc[k] = xc[k-1] + dx
                        yc[k] = yc[k-1] + dy
                        zc[k] = zc[k-1] + dz
                    elif (typeb[k-1] == 3): #if you just did a pendant group, attach back to the alpha bead
                        xc[k] = xc[k-2] + dx
                        yc[k] = yc[k-2] + dy
                        zc[k] = zc[k-2] + dz
                    elif (typeb[k-1] == 1): #if you just did an alpha group, attach pendant at potentially different distance
                        dxp = random()-0.5
                        dyp = random()-0.5
                        dzp = -(dx*dxp+dy*dyp)/dz
                        r = sqrt(dxp*dxp+dyp*dyp+dzp*dzp)
                        scale = bond/r
                        dxp = scale*dxp
                        dyp = scale*dyp
                        dzp = scale*dzp
                        xc[k] = xc[k-1] + dxp
                        yc[k] = yc[k-1] + dyp
                        zc[k] = zc[k-1] + dzp

        # calculate R and R_G
        k2= k1 + lengthcurrentpoly
        xcm = sum(xc[k1:k2+1])/lengthcurrentpoly
        ycm = sum(yc[k1:k2+1])/lengthcurrentpoly
        zcm = sum(zc[k1:k2+1])/lengthcurrentpoly
        xg = xc[k1:k2+1]-xcm
        yg = yc[k1:k2+1]-ycm
        zg = zc[k1:k2+1]-zcm
        rg2 = (dot(xg,xg) + dot(yg,yg) + dot(zg,zg))/lengthcurrentpoly
        # end to end
        rend2 = (xc[k1]-xc[k2])**2 + (yc[k1]-yc[k2])**2 + (zc[k1]-zc[k2])**2
        rend2ave = rend2ave + rend2
        rg2ave = rg2ave + rg2
        rgave = rgave + sqrt(rg2)
else:        
    for ix in range(npoly):
        lengthcurrentpoly = 0
        for iy in range(nmonomersperpoly):
            currentmonomer = ix*nmonomersperpoly + iy
            seq=sequence
            seqnum = 0
            for iz in seq:
                seqnum = seqnum + 1
                k = k + 1
                lengthcurrentpoly = lengthcurrentpoly + 1
                typeb[k] = iz
                q[k] = charge[iz]
                molnum[k] = ix + 1
                if iy == 0 and seqnum == 1:
                    k1 = k
                    xc[k] = random()*hx
                    yc[k] = random()*hy
                    zc[k] = random()*hz
                elif iy == 0 and seqnum == 2:
                    dx = random()-0.5
                    dy = random()-0.5
                    dz = random()-0.5
                    r = sqrt(dx*dx+dy*dy+dz*dz)
                    scale = bond/r
                    dx = scale*dx
                    dy = scale*dy
                    dz = scale*dz
                    if (typeb[k-1] == 2 or typeb[k-1] == 7):
                        xc[k] = xc[k-1] + dx
                        yc[k] = yc[k-1] + dy
                        zc[k] = zc[k-1] + dz
                    elif (typeb[k-1] == 3): #if you just did a pendant group, attach back to the alpha bead
                        xc[k] = xc[k-2] + dx
                        yc[k] = yc[k-2] + dy
                        zc[k] = zc[k-2] + dz
                    elif (typeb[k-1] == 1): #if you just did an alpha group, attach pendant at potentially different distance
                        xc[k] = xc[k-1] + dx*pendantsize
                        yc[k] = yc[k-1] + dy*pendantsize
                        zc[k] = zc[k-1] + dz*pendantsize
                else:
                    if (typeb[k-1] == 2 or typeb[k-1] == 7):
                        xc[k] = xc[k-1] + dx
                        yc[k] = yc[k-1] + dy
                        zc[k] = zc[k-1] + dz
                    elif (typeb[k-1] == 3): #if you just did a pendant group, attach back to the alpha bead
                        xc[k] = xc[k-2] + dx
                        yc[k] = yc[k-2] + dy
                        zc[k] = zc[k-2] + dz
                    elif (typeb[k-1] == 1): #if you just did an alpha group, attach pendant at potentially different distance
                        dxp = random()-0.5
                        dyp = random()-0.5
                        dzp = -(dx*dxp+dy*dyp)/dz
                        r = sqrt(dxp*dxp+dyp*dyp+dzp*dzp)
                        scale = bond/r
                        dxp = scale*dxp
                        dyp = scale*dyp
                        dzp = scale*dzp
                        xc[k] = xc[k-1] + dxp
                        yc[k] = yc[k-1] + dyp
                        zc[k] = zc[k-1] + dzp

        # calculate R and R_G
        k2= k1 + lengthcurrentpoly
        xcm = sum(xc[k1:k2+1])/lengthcurrentpoly
        ycm = sum(yc[k1:k2+1])/lengthcurrentpoly
        zcm = sum(zc[k1:k2+1])/lengthcurrentpoly
        xg = xc[k1:k2+1]-xcm
        yg = yc[k1:k2+1]-ycm
        zg = zc[k1:k2+1]-zcm
        rg2 = (dot(xg,xg) + dot(yg,yg) + dot(zg,zg))/lengthcurrentpoly
        # end to end
        rend2 = (xc[k1]-xc[k2])**2 + (yc[k1]-yc[k2])**2 + (zc[k1]-zc[k2])**2
        rend2ave = rend2ave + rend2
        rg2ave = rg2ave + rg2
        rgave = rgave + sqrt(rg2)
#    print "current rg", rg2


# PBC #added -hx2 to everything to center box LMH; correct previous version error where it's different (not just the negative) depending on if/elif loop below for y and z
for k in range(1,ntot-ncounterions-ncoion+1):
    if (xc[k] > hx):
        cx[k] = int(xc[k]/hx)
        xc[k] = xc[k] - cx[k]*hx - hx2
    elif (xc[k] < 0.0):
        cx[k] = -int((-xc[k]+hx)/hx)
        xc[k] = xc[k] - cx[k]*hx - hx2
    else:
        cx[k] = 0
        xc[k] = xc[k] - hx2
    if (yc[k] > hy):
        cy[k] = int(yc[k]/hy)
        yc[k] = yc[k] - cy[k]*hy - hy2
    elif (yc[k] < 0.0):
        cy[k] = -int((-yc[k]+hy)/hy)
        yc[k] = yc[k] - cy[k]*hy - hy2
    else:
        cy[k] = 0
        yc[k] = yc[k] - hy2
    if (zc[k] > hz):
        cz[k] = int(zc[k]/hz)
        zc[k] = zc[k] - cz[k]*hz - hz2
    elif (zc[k] < 0.0):
        cz[k] = -int((-zc[k]+hz)/hz)
        zc[k] = zc[k] - cz[k]*hz - hz2
    else:
        cz[k] = 0
        zc[k] = zc[k] - hz2


print("Polymers built."+"\n")
rg2ave = rg2ave/npoly
rgave = rgave/npoly
rend2ave = rend2ave/npoly
rave = rend2ave/rg2ave
print("<R_G^2> <R_G> = "+str(rg2ave)+" "+str(rgave)+"\n")
print("<R_end^2>= "+str(rend2ave)+"\n")

# Counterions
# Randomly place counterions in volume 
for ii in range(1,ncounterions+1):
    k = ii + ntot - ncounterions - ncoion
    xc[k] = random()*hx
    yc[k] = random()*hy
    zc[k] = random()*hz
    typeb[k] = 4
    q[k] = z_c*1.0
    #The following image flag stuff shouldn't be necessary since we put them in the box: just leave it, they will all go to the else:
    if (xc[k] > hx):
        cx[k] = int(xc[k]/hx)
        xc[k] = xc[k] - cx[k]*hx - hx2
    elif (xc[k] < 0.0):
        cx[k] = -int((-xc[k]+hx)/hx)
        xc[k] = xc[k] - cx[k]*hx - hx2
    else:
        cx[k] = 0
        xc[k] = xc[k] - hx2
    if (yc[k] > hy):
        cy[k] = int(yc[k]/hy)
        yc[k] = yc[k] - cy[k]*hy - hy2
    elif (yc[k] < 0.0):
        cy[k] = -int((-yc[k]+hy)/hy)
        yc[k] = yc[k] - cy[k]*hy - hy2
    else:
        cy[k] = 0
        yc[k] = yc[k] - hy2
    if (zc[k] > hz):
        cz[k] = int(zc[k]/hz)
        zc[k] = zc[k] - cz[k]*hz - hz2
    elif (zc[k] < 0.0):
        cz[k] = -int((-zc[k]+hz)/hz)
        zc[k] = zc[k] - cz[k]*hz - hz2
    else:
        cz[k] = 0
        zc[k] = zc[k] - hz2

print("Counterions complete."+"\n")


# Co-ions
# Randomly place co-ions in volume 
for ii in range(1,ncoion+1):
    k = ii + ntot - ncoion
    xc[k] = random()*hx
    yc[k] = random()*hy
    zc[k] = random()*hz
    typeb[k] = 5
    q[k] = charge_coion
    #The following image flag stuff shouldn't be necessary since we put them in the box: just leave it, they will all go to the else:
    if (xc[k] > hx):
        cx[k] = int(xc[k]/hx)
        xc[k] = xc[k] - cx[k]*hx - hx2
    elif (xc[k] < 0.0):
        cx[k] = -int((-xc[k]+hx)/hx)
        xc[k] = xc[k] - cx[k]*hx - hx2
    else:
        cx[k] = 0
        xc[k] = xc[k] - hx2
    if (yc[k] > hy):
        cy[k] = int(yc[k]/hy)
        yc[k] = yc[k] - cy[k]*hy - hy2
    elif (yc[k] < 0.0):
        cy[k] = -int((-yc[k]+hy)/hy)
        yc[k] = yc[k] - cy[k]*hy - hy2
    else:
        cy[k] = 0
        yc[k] = yc[k] - hy2
    if (zc[k] > hz):
        cz[k] = int(zc[k]/hz)
        zc[k] = zc[k] - cz[k]*hz - hz2
    elif (zc[k] < 0.0):
        cz[k] = -int((-zc[k]+hz)/hz)
        zc[k] = zc[k] - cz[k]*hz - hz2
    else:
        cz[k] = 0
        zc[k] = zc[k] - hz2

print("Co-ions complete."+"\n")


# OUTPUT headers ---------------------------------------------------------------


# input.psf header line
##INPUT_PSF.write("PSF\n\n%8i !NATOM\n" % (ntot))
##INPUT_PDB.write("CRYST1  %7.3f  %7.3f  %7.3f %6.2f %6.2f %6.2f P 1           1\n" % (hx,hy,hz,90.0,90.0,90.0)) #Mark says this will allow use of pbctools in VMD

# input.lammps header 
INPUT_LAMMPS.write("#Ionomers PJW 8/2022\n")
INPUT_LAMMPS.write("\n")
INPUT_LAMMPS.write("%10i    atoms\n" %     ntot)
INPUT_LAMMPS.write("%10i    bonds\n" %     nbonds)
INPUT_LAMMPS.write("%10i    angles\n" %     0)
INPUT_LAMMPS.write("%10i    dihedrals\n" % 0)
##INPUT_LAMMPS.write("%10i    impropers\n" % npendant)
INPUT_LAMMPS.write("%10i    impropers\n" % 0)
INPUT_LAMMPS.write("\n")
INPUT_LAMMPS.write("%10i    atom types\n" % ntypes)
INPUT_LAMMPS.write("%10i    bond types\n" % 2)
##INPUT_LAMMPS.write("%10i    improper types\n" % 1)
INPUT_LAMMPS.write("\n")
INPUT_LAMMPS.write(" %16.8f %16.8f   xlo xhi\n" % (-hx2,hx2))
INPUT_LAMMPS.write(" %16.8f %16.8f   ylo yhi\n" % (-hy2,hy2))
INPUT_LAMMPS.write(" %16.8f %16.8f   zlo zhi\n" % (-hz2,hz2))
INPUT_LAMMPS.write("\n")
INPUT_LAMMPS.write("Masses\n")
INPUT_LAMMPS.write("\n")
INPUT_LAMMPS.write("1 1\n")
INPUT_LAMMPS.write("2 1\n")
INPUT_LAMMPS.write("3 1\n")
INPUT_LAMMPS.write("4 1\n")
INPUT_LAMMPS.write("5 1\n")
INPUT_LAMMPS.write("\n")
INPUT_LAMMPS.write("Pair Coeffs # lj/cut/coul/long\n")
INPUT_LAMMPS.write("\n")
INPUT_LAMMPS.write("1 1 1\n")
INPUT_LAMMPS.write("2 1 1\n")
INPUT_LAMMPS.write("3 1 1\n")
INPUT_LAMMPS.write("4 1 %0.2f\n" % cisize)
INPUT_LAMMPS.write("5 1 0.5\n")
INPUT_LAMMPS.write("\n")
INPUT_LAMMPS.write("Bond Coeffs # fene\n")
INPUT_LAMMPS.write("\n")
INPUT_LAMMPS.write("1 30 1.5 1 1\n")
INPUT_LAMMPS.write("2 30 1.5 1 1\n")
INPUT_LAMMPS.write("\n")
INPUT_LAMMPS.write("Atoms\n")
INPUT_LAMMPS.write("\n")

# END OUTPUT headers -----------------------------------------------------------

# Atoms output
mass = 1.0

# Polymers
i = 0
imol = 0

# positions 
for i in range(1,dim):
    itype = typeb[i]
    aname = atype[itype]

    # could use a dictionary here between type and segname
    if itype != 4 and itype != 5 and itype != 6:
        imol = molnum[i] #this implies the polymers must be placed in before the counterions
        segname = "POLY"
    else:
        #imol = npoly+1 #the molecule number for all counterions is the same; it's more like a group number
        imol = i-ntot+ncounterions+npoly+ncoion #LMH now each ion has its own molecule number
        segname = "CION"

        
    INPUT_LAMMPS.write("%6i %6i %2i %6.2f %9.4f %9.4f %9.4f %6i %6i %6i\n" % (i, imol, typeb[i], q[i], xc[i], yc[i], zc[i], cx[i], cy[i], cz[i]))
##    INPUT_PDB.write("ATOM  %5i  %2s  NONE    1     %7.3f %7.3f %7.3f  1.00  0.00\n" %  (i,aname, xc[i], yc[i], zc[i] ))
##    INPUT_PSF.write("%8i %4s %3i  %2s   %2s   %2s   %8.6f       %7.4f %10i\n" %  (i,segname,imol,aname,aname,aname,q[i],typeb[i],0))
    
# Bonds
INPUT_LAMMPS.write("\n")
INPUT_LAMMPS.write("Bonds\n")
INPUT_LAMMPS.write("\n")
#jbond1 = zeros(nbonds+1)
#jbond2 = zeros(nbonds+1)
pbond1 = zeros(nbonds+1)
pbond2 = zeros(nbonds+1)
ibond=0
pbond=0
i0 = 0
for i in range(1,ntot-ncounterions-ncoion+1):
        #if not at the end of the polymer
        if molnum[i+1] == molnum[i]:
            ibond = ibond+1 #the bond number
            if typeb[i] == 1: #if you are on an alpha group, bond type is 2
                j=i+1
                INPUT_LAMMPS.write("%8i  2 %8i %8i\n" % (ibond,i,j))
            elif typeb[i] == 3: #if you are on a pendant group, go back to the alpha bead and make bond with beta
                i=i-1
                j=i+2
                INPUT_LAMMPS.write("%8i  1 %8i %8i\n" % (ibond,i,j))
            elif typeb[i] == 2:
                j=i+1
                INPUT_LAMMPS.write("%8i  1 %8i %8i\n" % (ibond,i,j))

    
# Masses
INPUT_LAMMPS.write("\n")
INPUT_LAMMPS.write("Masses\n")
INPUT_LAMMPS.write("\n")

for ii in range(1,ntypes+1):
    INPUT_LAMMPS.write("%3i  1.0\n" % ii)

#Close files
INPUT_LAMMPS.close()
##INPUT_PDB.close()
##INPUT_PSF.close()
##
print("LAMMPS output complete."+"\n")
