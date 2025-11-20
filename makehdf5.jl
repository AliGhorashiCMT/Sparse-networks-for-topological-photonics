sg = first(parse.(Int, ARGS))
using Crystalline, MPBUtils, JLD2, SymmetryBases, DelimitedFiles, PyCall, HDF5, StaticArrays, LinearAlgebra

D = 2 # Dimension of calculations

include("../Topology_ML/Phc_ML/fft.jl"); #Utilities to calculate the fourier components of the dielectric function
include("../TopologyPaper/get-freqs-symeigs.jl")
include("get_uc_coefs.jl")

ngs = 10 
res = 64

orbits, _ = get_orbits(sg, (ngs, ngs)) # Corresponding to (ngs+1)^2 number of coefficients. 
orbits = orbits[1:ngs]
wps = wyckoffs(sg, D)
lgs = littlegroups(sg, D)
cn_rot_idx = 2 #index of the plane group element corresponding to the C_n rotation matrix
rot_mat = spacegroup(sg, D)[cn_rot_idx].rotation

h5open("sg$sg-data.h5", "w") do file
    sg_group = create_group(file, "sg$sg")
	symeigsdvd = Dict{Tuple{Integer, String}, Vector{Dict{String, Vector{Vector{ComplexF64}}}}}() # key is (epsilon, mode), value is a vector of 
    # symmetry eigenvalue dictionaries. Where the key in each dictionary is the klabel, and the value is a vector of vectors of symmetry eigenvalues
    # corresponding to each band and symmetry operation in the little group of the k point. 
    logsvd = Dict{Tuple{Integer, String}, Vector{String}}() 
	for mode in ["tm"]
        for gidx in 1:4
            loaded_data = load("output/sg$sg/g$(gidx)/$mode/sg$sg-g$(gidx)-$mode.jld2")
            loaded_data_log = load("logs/sg$sg-g$(gidx)-$mode-log.jld2")
            logsv = loaded_data_log["logsv"]
            symeigsdv = loaded_data["symeigsdv"]
            symeigsdvd[(gidx, mode)] = symeigsdv
            logsvd[(gidx, mode)] = logsv
        end
	end
    for gidx in 1:4
    	for (id, logs) in enumerate(logsvd[(gidx, "tm")])
    		id % 100 == 0 && (println("ID: $id"); flush(stdout))
            if gidx == 1
        		g = create_group(file, "sg$sg/$id") # create a group for this plane group and Fourier lattice index. 
                
                R2x, R2y = get_rvecs_from_logstr(logs)[2]
                    
            	g["R2x"] = R2x # Projection of second lattice vector on first lattice vector	
            	g["R2y"] = R2y # Projection of second lattice vector perpendicular to first lattice vector; 
            end
            g = file["sg$sg/$id"]
            uc_coefs = get_uc_coefs_from_logstr(logs)
            uc_coefs_unique = [uc_coefs[1], uc_coefs[2:2:end]...]
            # May want to make the above a little bit more general. 
            g["epsilon_Gs-gidx=$(gidx)"] = uc_coefs_unique
            for mode in ["tm"]
                symeigsdv = symeigsdvd[(gidx, mode)]
                Γ_irreps, Y_irreps, A_irreps, B_irreps = [[round(Int, real(x[2] + 1)/2) for x in symeigsdv[id][key]] for key in ["Γ", "Y", "A", "B"]]  
                Encoding =  8*Γ_irreps + 4*Y_irreps + 2*A_irreps + B_irreps
                frequencies_str = logs_to_dispersion(logs)
                frequencies_io = IOBuffer(frequencies_str)
                frequencies = sort((readdlm(frequencies_io, ',')::Matrix{Float64})[:, 6:end], dims = 2)
                g["symmetry-gidx=$(gidx)-mode=$(mode)"] = Encoding[1:10]
                g["frequencies-gidx=$(gidx)-mode=$(mode)"] = frequencies[:, 1:10]
            end
    		if ((id == 1) && (gidx == 1))
    			# Now we augment the dataset: 
    			for wp in wps
    				wp_v = wp.v.cnst # Discard the free part of the Wyckoff position (not relevant in our case anyway)
    				epsilon_G_orbit_phases = Vector{ComplexF64}()
    				for orbit in orbits
    					G = first(orbit)
    					phase = cis(2*pi*dot(wp_v, G))
    					push!(epsilon_G_orbit_phases, phase)
    				end
    				sg_group["epsilon_G_phases/"*string(wp.mult)*string(wp.letter)] = epsilon_G_orbit_phases
    				kv_phases = Dict{String, Bool}()
    				for (key, val) in lgs
    					kv = val.kv.cnst
    					phase = cis(2*pi*(dot(kv, wp_v-inv(rot_mat)*wp_v)))
    					kv_phases[val.klab] = (real(phase) + 1) /2
    				end 
    				symmetry_map_wp = collect(1:16)
    				for i in 0:15 
    					new_base = digits(i, base=2); new_base = [new_base..., zeros(4-length(new_base))...]; 
                        # Figure out decomposition in irreps and ensure consistent length. 
    					!kv_phases["Γ"] && (new_base[4] = 1 - new_base[4])
    					!kv_phases["Y"] && (new_base[3] = 1 - new_base[3])
    					!kv_phases["A"] && (new_base[2] = 1 - new_base[2])
    					!kv_phases["B"] && (new_base[1] = 1 - new_base[1]) # If phases change, change 0 to 1 and change 1 to 0 
    					symmetry_map_wp[i+1] = sum([new_base[n+1]*2^n for n in 0:3]) # Convert back from base 2
    				end
    				sg_group["symmetry_vector_phases/"*string(wp.mult)*string(wp.letter)] = symmetry_map_wp
                    #Symmetry vector map- the (0-based) ith indexing corresponding to the ith encoding indicates how the encoding will change. 
    			end
    		end
    	end
    end
end
