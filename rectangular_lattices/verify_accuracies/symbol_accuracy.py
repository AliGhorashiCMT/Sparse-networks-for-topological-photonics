from kan.hypothesis import *
from torchvision import transforms
import torch
import torch.nn.functional as F
from kan import *
import h5py
import copy
import sympy as sp
dtype = torch.get_default_dtype()
from sympy import latex
import pickle
import sys

shift = int(sys.argv[1])
print(f"shift: {shift}", flush= True)

data_dir = "../"
filename = "sg2-data.h5"
checkpoint_dir = "../saved_models/"
log_dir = '../logs/'
band_idx = 0
gidxs = [1, 2, 3, 4]
only_obstructed = False
only_topological = False
binary_classification = False#True
no_penalize_last = True
bias = False
numrs = 1
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

file = h5py.File(data_dir + filename, 'r')

nGs = 10
gidxs = [1, 2, 3, 4]
wps = ['1a', '1b', '1c', '1d']
wps2 = ['1a', '1c', '1b', '1d'] # switch 1b and 1c due to convention of how Gvectors are stored

symmetry_data = torch.zeros(10000 * len(gidxs) * len(wps))
input_data = torch.zeros(10000 * len(gidxs) * len(wps), nGs)

all_formulas = []
for topological_class in range(0, 8): 
    with open(f"../formula-class{topological_class}.pkl", "rb") as f:
        loaded_formula = pickle.load(f)
        all_formulas.append(loaded_formula)

def formula_eval(t, formula_idx):
    x, y, z = t
    return float(all_formulas[formula_idx].subs('x_1', x).subs('x_2', y).subs('x_3', z))


for (widx, (wp1, wp2)) in enumerate(zip(wps, wps2)):
    print(f"Wyckoff index: {widx}")
    sym_vec_phases = file[f'sg2/symmetry_vector_phases/{wp1}'][()]
    epsilon_G_phases = file[f'sg2/epsilon_G_phases/{wp2}'][()].real
    for gidx in gidxs:
        print(f"gidx: {gidx}")
        for id in range(1, 10001):
            real_id = (id-1) + (gidx-1)*10000 + len(gidxs)*10000*widx
            if (id % 1000 == 0): 
                print(id)
            symmetry_before_aug = file[f'sg2/{id}/symmetry-gidx={gidx}-mode=tm'][()][band_idx]
            if band_idx == 0:
                symmetry_data[real_id] =  sym_vec_phases[symmetry_before_aug] - 8
            else: 
                symmetry_data[real_id] =  sym_vec_phases[symmetry_before_aug] 

            fourier_data_before_aug = file[f'sg2/{id}/epsilon_Gs-gidx={gidx}'][()][0:nGs].real
            fourier_data = fourier_data_before_aug * epsilon_G_phases
            input_data[real_id, :] = torch.tensor([*fourier_data])

N = 1000
formula_predictions = torch.zeros((N, 8), dtype=float)
for i in range(N*shift, N*(shift+1)): 
    for j in range(0, 8):
        y = formula_eval(input_data[i:i+1, 1:4][0], j)
        formula_predictions[i-N*shift, j] = y

x = (formula_predictions.argmax(1) == (symmetry_data.long())[(N*shift):N*(shift+1)]).sum()/N

print(x.item())
