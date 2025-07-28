using Crystalline, MPBUtils, JLD2, LinearAlgebra, StaticArrays, SymmetryBases, DelimitedFiles, HDF5, Statistics, PyCall
D = 2
sgnum = 2
mode = "tm"
numgs = 10
N = 101
xyz = range(-0.5, 0.5, length=N)[1:N-1]

include("../../../../Topology_ML/Phc_ML/fft.jl")
include("../../get_uc_coefs.jl")

M = 250
loaded_coefs = zeros(9, M*8)
dir = "./"
for topological_class in range(0, 7)
    filename = "../../inverse_design_smooth_symbols_random/inverse_design_params-class$(topological_class).h5"
    f = h5open(dir * filename, "r");
    data = f["inverse_design_params"][]
    close(f)
    loaded_coefs[1:3, (1+topological_class*M):(topological_class+1)*M] = data

    filename = "../../inverse_design_smooth_symbols/inverse_design_params-random-class$(topological_class).h5"
    f = h5open(dir * filename, "r");
    data = f["inverse_design_params_random"][]
    close(f)
    loaded_coefs[4:9, (1+topological_class*M):(topological_class+1)*M] = data
end

task_id, num_tasks = parse.(Int, ARGS)
println("task_id is $task_id")
println("num_tasks $num_tasks")

ids = 1:2000
orbits, _ = get_orbits(2, (10, 10));
orbits = orbits[1:numgs]

topology_paper_dir = "../../../../TopologyPaper/"
log_dir = "../../logs/"

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

function evaluate_fourier(x, y, orbits::Vector{<:Vector{<:SVector{2, <:Int64}}}, orbit_coeffs::Vector{<:Real})
    epsilon = 0 
    for (orbit_coeff, orbit) in zip(orbit_coeffs, orbits)
        for G in orbit
            epsilon += orbit_coeff*cis(2π*dot([x, y], G))
        end
    end
    return real(epsilon)
end;


loaded_inputjld2 = load(topology_paper_dir * "./symeigs/input/sg$(sgnum)-epsid1-res64-$(mode)-input.jld2")
inputsv = loaded_inputjld2["inputsv"]
# Note that we only load the data for the lowest epsilon above, but this doesn't matter 
# since we give the fourier components later anyway and epsin is not used in any way in our code
for id in task_id:num_tasks:ids[end]
    uc_coefs_unique = [20, loaded_coefs[1:9, id]...]
    uc_coefs = Float64[]
    for (orb_idx, orbit) in enumerate(orbits)
                    for gvector in orbit
                        push!(uc_coefs, uc_coefs_unique[orb_idx])
                    end
    end
    dielectric_function = broadcast(evaluate_fourier, reshape(xyz, (N-1, 1)), reshape(xyz, (1, N-1)), Ref(orbits), Ref(uc_coefs_unique))

    medianeps = quantile(vec(dielectric_function), 0.5) 
    inputs = inputsv[id]
    uc_coefs_str = "uc-coefs=(list"
    for uc_coef in uc_coefs
        uc_coefs_str *= " $(uc_coef)"
    end
    uc_coefs_str *= ")"
    println("\n\n")
    epsin = 1
    for (contrast_idx, epsout) in enumerate([2, 4, 6, 8, 10, 12])
    real_id = id + (contrast_idx-1)*20000
    run(`./runlattice-contrasts.sh $(inputs) $(uc_coefs_str) $(uc_gvecs_str) dim2-sg$sgnum-$(real_id)-res64-$(mode) $(mode) $(sgnum) $(epsin) $(epsout) $(medianeps) $(contrast_idx)`) 
    end	
end

