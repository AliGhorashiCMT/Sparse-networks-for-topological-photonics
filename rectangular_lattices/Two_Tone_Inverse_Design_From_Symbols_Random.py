import sys
from kan.hypothesis import *
from torchvision import transforms
import torch
import torch.nn.functional as F
from kan import *
import h5py
import copy
import sympy as sp
import pickle
dtype = torch.get_default_dtype()
topological_class = int(sys.argv[1])
inverse_design_dir = "./inverse_design_smooth_symbols_random/"
inverse_design_dir_1 = "./inverse_design_smooth_symbols/"

print(f"Inverse design for topological class idx: {topological_class}", flush = true)
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

print(f"Running on device: {device}", flush=true)

N = 250
two_tone_classifications = np.zeros((N, 8));

all_data = np.zeros((N, 9))

filename = f"inverse_design_params-class{topological_class}.h5"
file = h5py.File(inverse_design_dir + filename, 'r')
all_data[0:250, 0:3] = file["inverse_design_params"][()]
file.close()

filename = f"inverse_design_params-random-class{topological_class}.h5"
file = h5py.File(inverse_design_dir_1 + filename, 'r')
all_data[0:250, 3:9] = file["inverse_design_params_random"][()]
file.close()

all_formulas = []
for topological_class_idx in range(0, 8):
    with open(f"formula-class{topological_class_idx}.pkl", "rb") as f:
        loaded_formula = pickle.load(f)
        all_formulas.append(loaded_formula)

x1, x2, x3 = sp.symbols('x_1 x_2 x_3')

f0 = sp.lambdify((x1, x2, x3), all_formulas[0])
f1 = sp.lambdify((x1, x2, x3), all_formulas[1])
f2 = sp.lambdify((x1, x2, x3), all_formulas[2])
f3 = sp.lambdify((x1, x2, x3), all_formulas[3])
f4 = sp.lambdify((x1, x2, x3), all_formulas[4])
f5 = sp.lambdify((x1, x2, x3), all_formulas[5])
f6 = sp.lambdify((x1, x2, x3), all_formulas[6])
f7 = sp.lambdify((x1, x2, x3), all_formulas[7])

M = 64
xs = ys = np.linspace(-0.5, 0.5, M, endpoint=false)
xs = np.repeat(np.reshape(xs, (1, M)), M, axis=0);
ys = np.repeat(np.reshape(ys, (M, 1)), M, axis=1);
Gs = [[-1, 0], [0, -1], [-1, -1], [-1, 1], [-2, 0], [0, -2], [-2, -1], [-2, 1], [-1, -2]]

def smooth(X, M=64):
    epsilon_grid = np.zeros((M, M))
    for (CG, (Gx, Gy)) in zip(X, Gs):
        epsilon_grid += CG*np.cos(2*np.pi*xs* Gy + 2*np.pi*ys * Gx)
    return epsilon_grid

for n in range(0, N):
    print(f"n: {n}", flush=true)
    epsilon_grid = smooth(all_data[n,  :])
    perc25, perc50, perc75 = np.percentile(epsilon_grid, [25, 50, 75])
    epsilon_grid_two_tone = np.where(epsilon_grid < perc50, perc25, perc75)
    Cgs_two_tone = np.zeros(9)
    for (m, G) in enumerate(Gs): 
        Gx, Gy = G
        G_grid = np.cos(2*np.pi*xs* Gy + 2*np.pi*ys * Gx)
        Cgs_two_tone[m] = ((G_grid * epsilon_grid_two_tone)*2/M/M).sum()
    x = Cgs_two_tone[0:3]
    f0_r = f0(x[0], x[1], x[2])
    f1_r = f1(x[0], x[1], x[2])
    f2_r = f2(x[0], x[1], x[2])
    f3_r = f3(x[0], x[1], x[2])
    f4_r = f4(x[0], x[1], x[2])
    f5_r = f5(x[0], x[1], x[2])
    f6_r = f6(x[0], x[1], x[2])
    f7_r = f7(x[0], x[1], x[2])

    two_tone_classifications[n, :] = np.array([f0_r, f1_r, f2_r, f3_r, f4_r, f5_r, f6_r, f7_r])

with h5py.File(f"./inverse_design_two_tone_symbols_random/two_tone_scores-class{topological_class}.h5", 'w') as f:
    # Save the array to the file with the key 'dataset'
    f.create_dataset('two_tone_classifications', data=two_tone_classifications)

print(f"Data saved to two_tone_scores-class{topological_class}.h5", flush=true)

