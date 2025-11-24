## Scripts and notebooks that make the figures in the main text and supplement

  **Band structures.ipynb**: Band structure of photonic crystal used in **Figure 1** of the main text. This notebook finds the Photonic crystal with the best k-wise gap. The associated dispersion of this photonic crystal is saved by this notebook in `./figures/figure1-dispersion.pdf`    
  
  **data_augmentation.ipynb**: Data augmentation subfigures used in **Figure 1** of the main text as well as Fourier components for **Figure 2** of the main text. Shifted unit cells (corresponding to augmented data) are saved in `./figures/data_augmentation-$wp.pdf`, where `wp` can take values `1a, 1b, 1c, 1d`. Fourier components used in **Figure 2** are saved in `./figures/data_augmentation-fourier$idx.pdf`, where `idx` can take values from one to three. 

  **kans_for_smooth.ipynb**: KAN for classification of the lowest TM band symmetry. A KAN with width `[9, 24, 8]` is shown to have $>99\%$ train and test accuracies. This model is then pruned to create a KAN with width `[3, 4, 8]` with similar high accuracy. This notebook saves the activation functions shown in **Figure 2** of the main text as: `./figures/TM-Band1-prunedinput-prunednode-f$(idx).pdf`, where `idx=000, 001, 011, 130` and also saves the network itself as `TM-Band1-9948-9932-prunedinput-prunednode.pdf`, where the numbers indicate $99.48$ and $99.32$ train and test accuracies, respectively. 
  
  **Inverse Design Band Structures.ipynb**: Band structure and dielectric profile for **Figure 3**. Produces figures saved as `inverse_design_dielectric_from_KAN.pdf` and `inverse_design_bands_from_KAN.pdf`. 

  **Inverse design success rate.ipynb**: Inverse design statistics shown in **Figure 3**, saved as `inverse_design_accuracy_symbols_random.pdf`.

  **inverse_design_edge_states.ipynb**: Band structures for edge state dispersion in **Figure 4** of the main text. This notebook finds the symmetry eigenvalues for the PhC chosen in the main text and also saves the relevant figures in `./figures/edge_states.pdf` and `./figures/edge_state_unit_cell.pdf`. 

  **Inverse_Design_Dirac_Points.ipynb**: More in depth analysis of the Dirac point PhC of **Figure 4**. Verifies the non-trivial symmetry eigenvalues and saves the relevant figures in `./figures/dirac_point_bands.pdf`, `./figures/dirac_point_bz.pdf` and `./figures/dirac_point_ucell.pdf` 

  **kans_for_smooth_tm_band2.ipynb** and **kans_for_smooth_te.ipynb**: TM band 2 and TE band 1 models, corresponding to KANs saved as `./figures/TM-Band2-9774-9602.pdf` and `./figures/TE-Band1-98-98.pdf`.

  **small_datasets.ipynb**: Accuracy of KANs trained on small datasets with and without augmentation. Data is saved in `./figures/Augmentation_accuracy_increase.pdf`. 
  
  **Inverse design examples and success rates.ipynb**: Examples of inverse designed photonic crystals shown in the supplement and more fine grained inverse design statistics. This notebook saves inverse design statistics per topological class in seven pdfs: `./figures/Inverse_design_delineated_success_rates-class$(class).pdf` and it saves examples of inverse designed PhCs in `./figures/inverse_design_samples-class$(class).pdf`, where $\text{class} \in [0, 7]$.

## Scripts that make the original and inverse design datasets

  **runarray.sh**: Main script that runs a series of job arrays, each of which computes photonic crystal band properties by calling **runlattices-array.jl**, detailed below. 
  
  **runlattices-array.jl**: julia script that calls **runlattice.sh** and provides it with the appropriate photonic crystal parameters. Specifically, we loop over 4 levels of perturbation (labeled by `gidx`). For each `gidx`, we create 10,000 photonic crystals for which the dielectric function varies from a perfectly homogeneous dielectric by a scale set by `gidx`. **runlattices-array.jl** sets the DC component of the dielectric function to a value so 20, so that the dielectric function never goes below vacuum. The other 18 components (9 independent components) are sampled randomly in a range set by `gidx`. 
  
  **runlattice.sh**: Script that runs a 2D mpb calculation for fixed oblique lattice vectors, given by $(1, 0)$ and $(0.5, 0.8)$ 

  **makehdf5.jl**, **makejlds.jl**, and **makelogjlds.jl**: Scripts that save the MPB log files in `.hdf5` and `.jld2 `files.
  
  **Inverse_Design_From_Symbols_Random.py**: Inverse design of PhCs from random initialization. Our procedure for inverse of a given PhC is as follows: We start with a randomly initialized 3-component vector (with components betwen -0.25 and 0.25). This vector corresponds to the three smallest-in-magnitude Fourier components. We then minimize a target-category-dependent function g(x), which is derived from our symbolic formulas. After every ten gradient descent steps, we check to see if our formulas predict the PhC to be in the target category. If so, we stop the gradient descent. 

  **Two_Tone_Inverse_Design_From_Symbols_Random.py**: This evaluates the formulas on the fourier components of the two-tone lattices (which are mapped from the smooth lattices) in order to determine which two-tone PhCs we can expect to be in the target category. 

  **run_inverse_design_from_symbols.sh**: Bash script that runs inverse design through gradient descent of the formulas we obtain from symbolic regression (by calling relevant python file(s)). 

  **run_inverse_design_from_KAN.sh**: Bash script that runs inverse design through gradient descent directly on KAN network. 

  **level-set-fourier-lattice.scm**: Defines the dielectric function in real space. Note the counterintuitive ($x \leftrightarrow y$) switch in the material function, which was implemented for consistency with previous code.  

## Symbolic formulas derived through KANs

The formulas derived from the KANs (to predict the symmetry class of the lowest TM mode) may be found in seven `.pkl` files: `formula-class(class).pkl`, where `class` is a zero based index, ranging from $0$ to $7$. 

  **Symbolic_Formulas.ipynb**: For convenience, this notebook loads the formulas corresponding to each category and displays them in latex. It also calculates the accuracy of the formulas after they've been rounded. If you would like to see the accuracy of the formulas on the entire dataset, please refer to the instructions in `./verify_accuracies/`

  **Plot Symbolic Formulas.ipynb**: Plots how the formulas categorize over two slices in $(\varepsilon_{01}, \varepsilon_{10}, \varepsilon_{11})$ space. Produces the figures: `./figures/Formula_Plot_Slice_z=-0.25.pdf` and `Formula_Plot_Slice_z=0.25.pdf`. 
  

