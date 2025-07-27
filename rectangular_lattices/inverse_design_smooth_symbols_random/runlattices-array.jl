using Crystalline, MPBUtils, JLD2, LinearAlgebra, StaticArrays, SymmetryBases,
DelimitedFiles, HDF5, Statistics, PyCall
D = 2
numgs = 10
include("../../../Topology_ML/Phc_ML/fft.jl")
N = 250
loaded_coefs = zeros(9, N*8)
dir = "./" 
for topological_class in range(0, 7)
    filename = "inverse_design_params-class$(topological_class).h5"
    f = h5open(dir * filename, "r");
    data = f["inverse_design_params"][]
    close(f)
    loaded_coefs[1:3, (1+topological_class*N):(topological_class+1)*N] = data

    filename = "inverse_design_params-random-class$(topological_class).h5"
    dir_random = "../inverse_design_smooth_symbols/"	
    f = h5open(dir_random * filename, "r");
    data = f["inverse_design_params_random"][]
    close(f)
    loaded_coefs[4:end, (1+topological_class*N):(topological_class+1)*N] = data
end

task_id, num_tasks = parse.(Int, ARGS)
println("task_id is $task_id")
println("num_tasks $num_tasks")
ids = 1:2000

topology_paper_dir = "../../../TopologyPaper/"
orbits, _ = get_orbits(2, (10, 10));
orbits = orbits[1:numgs]

uc_gvecs = SVector{2, Int64}[]
for (orb_idx, orbit) in enumerate(orbits)
    for gvector in orbit
        push!(uc_gvecs, gvector)
    end
end

uc_gvecs_str = "uc-gvecs=(list"
for uc_gvec in uc_gvecs
    global uc_gvecs_str *= " (vector3 $(uc_gvec[1]) $(uc_gvec[2]))"
end
uc_gvecs_str *= " )"
    
for sgnum in [2]
    for mode in ["tm"]
        loaded_inputjld2 = load(topology_paper_dir * "./symeigs/input/sg$(sgnum)-epsid1-res64-$(mode)-input.jld2")
        inputsv = loaded_inputjld2["inputsv"]
        # Note that we only load the data for the lowest epsilon above, but this doesn't matter 
        # since we give the fourier components later anyway and epsin is not used in any way in our code
        for id in task_id:num_tasks:ids[end]
            inputs = inputsv[id]
            real_id = id 
            uc_coefs_unique = [20, loaded_coefs[1:9, id]...]
            uc_coefs = Float64[]
                for (orb_idx, orbit) in enumerate(orbits)
                    for gvector in orbit
                        push!(uc_coefs, uc_coefs_unique[orb_idx])
                    end
                end
        
            uc_coefs[1] = (length(uc_coefs) - 1) + 2
                uc_coefs_str = "uc-coefs=(list"
                for uc_coef in uc_coefs
                    uc_coefs_str *= " $(uc_coef)"
                end
                uc_coefs_str *= ")"
                
            println("\n\n")
            run(`./runlattice.sh $(inputs) $(uc_coefs_str) $(uc_gvecs_str) dim2-sg$sgnum-$(real_id)-res64-$(mode) $(mode) $(sgnum)`) 
        end
    end
end

