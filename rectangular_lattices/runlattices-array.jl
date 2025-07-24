using Crystalline, MPBUtils, JLD2, LinearAlgebra, StaticArrays, SymmetryBases,
DelimitedFiles, HDF5, Statistics, PyCall
D = 2
g_perturbv = [1, 0.01, 0.05, 0.1]
numgs = 10
include("../../Topology_ML/Phc_ML/fft.jl")

task_id, num_tasks = parse.(Int, ARGS)
println("task_id is $task_id")
println("num_tasks $num_tasks")
ids = 1:10000

topology_paper_dir = "../../TopologyPaper/"

for (g_perturb_idx, g_perturb) in enumerate(g_perturbv)
    (g_perturb_idx > 1) && continue
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
        uc_gvecs_str *= " (vector3 $(uc_gvec[1]) $(uc_gvec[2]))"
    end
    uc_gvecs_str *= " )"
        
    for sgnum in [2]
    	for mode in ["te"] #["tm"]
    		loaded_inputjld2 = load(topology_paper_dir * "./symeigs/input/sg$(sgnum)-epsid1-res64-$(mode)-input.jld2")
    		inputsv = loaded_inputjld2["inputsv"]
    		# Note that we only load the data for the lowest epsilon above, but this doesn't matter 
    		# since we give the fourier components later anyway and epsin is not used in any way in our code
    		for id in task_id:num_tasks:ids[end]
                inputs = inputsv[id]
                real_id = id + (g_perturb_idx-1) * 10000

	            uc_coefs_unique = (rand(Float64, numgs) * 2 - ones(numgs)) * g_perturb
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
        	    run(`./runlattice.sh $(inputs) $(uc_coefs_str) $(uc_gvecs_str) dim2-sg$sgnum-$(real_id)-res64-$(mode) $(mode) $(sgnum) $(g_perturb_idx)`) 
    		end
    	end
    end
end

