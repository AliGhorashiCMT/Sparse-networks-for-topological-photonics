## Description of dataset and analysis herein

## Description of scripts and notebooks

  **runarray.sh**: Main script that runs a series of job arrays, each of which computes photonic crystal band properties by calling **runlattices-array.jl**, detailed below. 
  
  **runlattices-array.jl**: julia script that calls **runlattice.sh** and provides it with the appropriate photonic crystal parameters. 
  
  **runlattice.sh**: script that runs a 2D mpb calculation for fixed oblique lattice vectors, given by $(1, 0)$ and $(0.5, 0.8)$ 

  **Inverse_Design_From_Symbols_Random.py**: 

  **Two_Tone_Inverse_Design_From_Symbols_Random.py**:

  **run_inverse_design_from_symbols.sh**: Bash script that runs inverse design through gradient descent of the formulas we obtain from symbolic regression (by calling relevant python file(s)). 

## Symbolic formulas 
  
