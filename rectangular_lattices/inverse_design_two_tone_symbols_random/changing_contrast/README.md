## Increasing dielectric contrast of inversely designed two-tone PhCs

## Description of scripts and notebooks

  **runlattices-contrasts.jl**: Loops through six values of the dielectric contrast **(2, 4, 6, 8, 10, 12)** and evaluates the two-tone PhCs at these values. 
  **runlattice-contrasts.sh**: Runs MPB on the two-tone lattices. This script takes, as input, several parameters, which we describe below: 
  
      *inputs*: A variety of input parameters, some of which are overwritten below
      
      *coefs*: Fourier coefficients 
      
      *vecs*: Reciprocal lattice vectors corresponding to the Fourier coefficients 
      
      *calcname*: Prefix name of the output files
      
      *runtype*: Either TE (transverse electric) or TM (transverse magnetic)
      
      *sgnum*: Plane group number (2 in all cases)
      
      *epsin*: The lower value of the dielectric constant (fixed to 1)
      
      *epsout*: The higher value of the dielectric constant. Takes values in **(2, 4, 6, 8, 10, 12)**. 
      
      *medianeps*: The median value of the smooth dielectric function in the unit cell
      
      *contrastidx*: The index corresponding to the value of the dielectric contrast. Takes values from **1** to **6**. 
  
