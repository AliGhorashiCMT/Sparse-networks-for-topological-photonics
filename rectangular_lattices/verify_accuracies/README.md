# Verifying symbolic formula accuracies

## Description of scripts and notebooks
  **symbol_accuracy.py**: Determines the average accuracy of our symbolic formulas. For each PhC, all eight formulas are evaluated. The formula that gives the greatest value is the predicted classification. 
  
  **verify_accuracy.sh**: Runs **symbol_accuracy.py** in a job array. This script gives the job array index to the python script, which determines the range of tested photonic crystals. Since there are four levels of perturbation, four TQC data augmentation shifts and `10,000` PhCs per perturbation and TQC shift, there are `160,000` total PhCs on which our formulas must be tested. 

  **save_accuracies.jl**: Combines outputs from all `.o` files into one text file.

  **all_accuracies.txt**: The text file with all accuracies. If you would like to average all the accuracies (across the entire dataset), all you need to do is: 
```
import numpy as np
accuracies = np.loadtxt("all_accuracies.txt")
print(accuracies.sum()/accuracies.shape[0])
```
