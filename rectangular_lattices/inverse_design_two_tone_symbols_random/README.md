## Inverse design (from symbolic formulas) of smooth photonic crystals from random initialization

## Description of scripts and notebooks

  **runlattices-array.jl**: julia script that calls **runlattice.sh** and provides it with the appropriate photonic crystal parameters. This version of **runlattices-array.jl** differs slightly from the other julia scripts that share the same name (that you will find in other directories). In particular, in this version the first three Fourier coefficients are loaded from hdf5 files that store the inverse design parameters. The rest of the Fourier coefficients are sampled randomly (and loaded from a different hdf5 file). 

