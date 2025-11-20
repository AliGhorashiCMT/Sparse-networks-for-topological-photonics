## Description of dataset and analysis herein

## Description of scripts and notebooks

  **Band structures.ipynb**: Band structure of photonic crystal used in **Figure 1** of the main text. This notebook finds the Photonic crystal with the best k-wise gap. The associated dispersion of this photonic crystal is saved by this notebook in `./figures/figure1-dispersion.pdf`    
  
  **data_augmentation.ipynb**: Data augmentation subfigures used in **Figure 1** of the main text as well as Fourier components for **Figure 2** of the main text. Shifted unit cells (corresponding to augmented data) are saved in `data_augmentation-$wp.pdf`, where `wp` can take values `1a, 1b, 1c, 1d`. 

  **Inverse Design Band Structures.ipynb**: Band structures for **Figure 3** and **Figure 4** of the main text. 

  **Inverse_Design_Dirac_Points.ipynb**: More in depth analysis of the Dirac point PhC of **Figure 4** (mostly sanity checks).
  
  **Inverse design examples and success rates.ipynb**: Examples of inverse designed photonic crystals shown in the supplement. 
  
  **runarray.sh**: Main script that runs a series of job arrays, each of which computes photonic crystal band properties by calling **runlattices-array.jl**, detailed below. 
  
  **runlattices-array.jl**: julia script that calls **runlattice.sh** and provides it with the appropriate photonic crystal parameters. Specifically, we loop over 4 levels of perturbation (labeled by *gidx*). For each *gidx*, we create 10,000 photonic crystals for which the dielectric function varies from a perfectly homogeneous dielectric by a scale set by *gidx*. **runlattices-array.jl** sets the DC component of the dielectric function to a value so 20, so that the dielectric function never goes below vacuum. The other 18 components (9 independent components) are sampled randomly in a range set by *gidx*. 
  
  **runlattice.sh**: script that runs a 2D mpb calculation for fixed oblique lattice vectors, given by $(1, 0)$ and $(0.5, 0.8)$ 

  **Inverse_Design_From_Symbols_Random.py**: Inverse design of PhCs from random initialization. Our procedure for inverse of a given PhC is as follows: We start with a randomly initialized 3-component vector (with components betwen -0.25 and 0.25). This vector corresponds to the three smallest-in-magnitude Fourier components. We then minimize a target-category-dependent function g(x), which is derived from our symbolic formulas. After every ten gradient descent steps, we check to see if our formulas predict the PhC to be in the target category. If so, we stop the gradient descent. 

  **Two_Tone_Inverse_Design_From_Symbols_Random.py**: This evaluates the formulas on the fourier components of the two-tone lattices (which are mapped from the smooth lattices) in order to determine which two-tone PhCs we can expect to be in the target category. 

  **run_inverse_design_from_symbols.sh**: Bash script that runs inverse design through gradient descent of the formulas we obtain from symbolic regression (by calling relevant python file(s)). 

  **run_inverse_design_from_KAN.sh**: Bash script that runs inverse design through gradient descent directly on KAN network. 

  **Symbolic_Formulas.ipynb**: This notebook loads the formulas corresponding to each category and displays them in latex. 

  **level-set-fourier-lattice.scm**: Defines the dielectric function in real space. Note the counterintuitive (x<->y) switch in the material function, which was implemented for consistency with previous code.  

## Symbolic formulas 

The formulas derived from the KANs (to predict the symmetry class of the lowest TM mode) may be found in seven *.pkl* files: *formula-class(class).pkl*, where *class* is a zero based index, ranging from $0$ to $7$. 
  
