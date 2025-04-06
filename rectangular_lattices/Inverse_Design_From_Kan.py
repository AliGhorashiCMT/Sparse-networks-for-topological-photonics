import sys
from kan.hypothesis import *
from torchvision import transforms
import torch
import torch.nn.functional as F
from kan import *
import h5py
import copy
import sympy as sp
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

symmetry_data = torch.zeros(10000 * len(gidxs) * len(wps))
input_data = torch.zeros(10000 * len(gidxs) * len(wps), nGs)

for (widx, (wp1, wp2)) in enumerate(zip(wps, wps2)):
    print(f"Wyckoff index: {widx}", flush=true)
    sym_vec_phases = file[f'sg2/symmetry_vector_phases/{wp1}'][()]
    epsilon_G_phases = file[f'sg2/epsilon_G_phases/{wp2}'][()].real
    for gidx in gidxs:
        print(f"gidx: {gidx}", flush=true)
        for id in range(1, 10001):
            real_id = (id-1) + (gidx-1)*10000 + len(gidxs)*10000*widx
            if (id % 1000 == 0): 
                print(id, flush=true)
            symmetry_before_aug = file[f'sg2/{id}/symmetry-gidx={gidx}-mode=tm'][()][band_idx]
            if band_idx == 0:
                symmetry_data[real_id] =  sym_vec_phases[symmetry_before_aug] - 8
            else: 
                symmetry_data[real_id] =  sym_vec_phases[symmetry_before_aug] 

            fourier_data_before_aug = file[f'sg2/{id}/epsilon_Gs-gidx={gidx}'][()][0:nGs].real
            fourier_data = fourier_data_before_aug * epsilon_G_phases
            input_data[real_id, :] = torch.tensor([*fourier_data])

shuffled_indices = torch.randperm(10000 * len(gidxs) * len(wps))
input_data_shuffled = input_data[shuffled_indices, :]
symmetry_data_shuffled = symmetry_data[shuffled_indices]

dataset_kan = {}
n_train = 80000#int(input_data_shuffled.shape[0]*2/3)
nGs = 10
nGstart = 1
dataset_kan['train_input'] = input_data_shuffled[0:n_train, [*range(nGstart, nGs)]].to(device)
dataset_kan['test_input'] = input_data_shuffled[n_train:, [*range(nGstart, nGs)]].to(device)
dataset_kan['train_label'] = symmetry_data_shuffled[0:n_train].long().to(device)
dataset_kan['test_label'] = symmetry_data_shuffled[n_train:].long().to(device)

model = KAN.loadckpt('./band1');

print((model(dataset_kan['train_input']).argmax(1) == dataset_kan['train_label']).sum()/80000)
print((model(dataset_kan['test_input']).argmax(1) == dataset_kan['test_label']).sum()/80000)

N = 250
indices_per_class = [(dataset_kan['train_label'] == n).nonzero(as_tuple=True)[0] for n in range(0, 8)]
inverse_design_params = torch.zeros((N, 9));

model.eval()

topological_dot_vector = [-1, -1, -1, -1, -1, -1, -1, -1]
topological_dot_vector[topological_class] = 7

indices = indices_per_class[topological_class]

for (j, i) in enumerate(indices[0:N]):
    print(f"Doing gradient descent on index: {i}, {j}", flush=true);
    x = dataset_kan['train_input'][i:i+1, :].cpu().numpy()
    input_tensor = torch.tensor(x, requires_grad=True, device=device).to(device)  # Adjust size to match model input
    optimizer = torch.optim.AdamW([input_tensor], lr=1e-3)
    num_iterations = 100
    for i in range(num_iterations):
        optimizer.zero_grad()
        output = model(input_tensor)
        target_score = (output[0, :]*torch.tensor(topological_dot_vector).cuda()).sum()
        loss = -target_score 
        loss.backward()
        input_tensor.grad[torch.isnan(input_tensor.grad)] = 0
        optimizer.step()
        if (i + 1) % 20 == 0 or i == 0:
            print(f"Iteration {i + 1}/{num_iterations}, Loss: {loss.item()}", flush=true)
    inverse_design_params[j, :] = input_tensor

with h5py.File(f"./inverse_design_smooth/inverse_design_params-class{topological_class}.h5", 'w') as f:
    # Save the array to the file with the key 'dataset'
    f.create_dataset('inverse_design_params', data=inverse_design_params.detach().numpy())

print(f"Data saved to inverse_design_params-class{topological_class}.h5", flush=true)

with h5py.File(f"./inverse_design_smooth/original_design_params-class{topological_class}.h5", 'w') as f:
    # Save the array to the file with the key 'dataset'
    original_data = dataset_kan['train_input'][indices[0:N]]
    f.create_dataset('original_design_params', data = original_data.cpu().detach().numpy())
