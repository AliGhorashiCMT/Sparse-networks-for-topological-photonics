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
from sympy import latex

dtype = torch.get_default_dtype()
topological_class = int(sys.argv[1])
print(f"Inverse design for topological class idx: {topological_class}", flush = true)
data_dir = "./"
filename = "sg2-data.h5"
checkpoint_dir = "./saved_models/"
log_dir = './logs/'
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
print(f"Running on device: {device}", flush=true)
nGs = 10
gidxs = [1, 2, 3, 4]
wps = ['1a', '1b', '1c', '1d']
wps2 = ['1a', '1c', '1b', '1d'] # switch 1b and 1c due to convention of how Gvectors are stored

topological_dot_vector = [1, 1, 1, 1, 1, 1, 1, 1]
topological_dot_vector[topological_class] = -7

N = 250
inverse_design_params = np.zeros((N, 3));

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

def g(x):
    f0_r = f0(x[0], x[1], x[2])
    f1_r = f1(x[0], x[1], x[2])
    f2_r = f2(x[0], x[1], x[2])
    f3_r = f3(x[0], x[1], x[2])
    f4_r = f4(x[0], x[1], x[2])
    f5_r = f5(x[0], x[1], x[2])
    f6_r = f6(x[0], x[1], x[2])
    f7_r = f7(x[0], x[1], x[2])
    return (np.array([f0_r, f1_r, f2_r, f3_r, f4_r, f5_r, f6_r, f7_r]) * topological_dot_vector).sum()

def numerical_gradient(f, x, eps=1e-6):
    grad = np.zeros_like(x)
    for i in range(len(x)):
        x_pos = x.copy()
        x_neg = x.copy()
        x_pos[i] += eps
        x_neg[i] -= eps
        grad[i] = (f(x_pos) - f(x_neg)) / (2 * eps)
    return grad
# Gradient descent loop
def gradient_descent(f, x0, n, lr=0.1, max_iter=100, tol=1000):
    x = x0.copy()  # Initial guess
    n_count = 0 
    for step in range(max_iter):
        grad = numerical_gradient(f, x)  # Compute the gradient
        x = x - lr * grad  # Update step
        # Optionally: Print progress
        if step % 10 == 0:
            print(f"Step {step}: x = {x}, f(x) = {f(x):.4f}")
            print(f"grad: {grad}")
            f0_r = f0(x[0], x[1], x[2])
            f1_r = f1(x[0], x[1], x[2])
            f2_r = f2(x[0], x[1], x[2])
            f3_r = f3(x[0], x[1], x[2])
            f4_r = f4(x[0], x[1], x[2])
            f5_r = f5(x[0], x[1], x[2])
            f6_r = f6(x[0], x[1], x[2])
            f7_r = f7(x[0], x[1], x[2])
            m = np.argmax(np.array([f0_r, f1_r, f2_r, f3_r, f4_r, f5_r, f6_r, f7_r]))
            print(f"Current topological class: {m}")
            if m == n: 
                n_count += 1
        if n_count > 1: 
            print("Convergence reached!")
            break
    return x

for j in range(0, N):
    print(f"Current sample number: {j}")
    x = np.random.rand(3)*0.5 - 0.25
    new_vec = gradient_descent(g, x, topological_class, lr = 1e-5, max_iter=1000)
    inverse_design_params[j, :] = new_vec


with h5py.File(f"./inverse_design_smooth_symbols_random/inverse_design_params-class{topological_class}.h5", 'w') as f:
    # Save the array to the file with the key 'dataset'
    f.create_dataset('inverse_design_params', data=inverse_design_params)
