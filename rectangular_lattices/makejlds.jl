sg, gidx = parse.(Int, ARGS)

using Crystalline, MPBUtils, HDF5, JLD2, StaticArrays;

println("Running Spacegroup: $sg")
brs = bandreps(sg, 2)
lgirsd = lgirreps(sg, Val(2))
for mode in ["te"]#["tm"]
    println("mode: ", mode)
    flush(stdout)
    dir = "./output/sg$(sg)/g$(gidx)/$(mode)/"

    symeigsdv = Vector{Dict{String, Vector{Vector{ComplexF64}}}}(undef, 10000)
    summariesv = Vector{Vector{BandSummary}}(undef, 10000)

    for id in eachindex(symeigsdv)
	real_id = id + (gidx-1) * 10000
        symeigsd, lgd = read_symdata("dim2-sg$sg-$(real_id)-res64-$mode", dir = dir)
        fixup_gamma_symmetry!(symeigsd, lgd, Symbol(uppercase(mode)))
        id == 1 && (global lgirsd = pick_lgirreps(lgd))
        symeigsdv[id] = symeigsd
        summaries = analyze_symmetry_data(symeigsd, lgirsd, brs)            
        summariesv[id] = summaries
    end
    filename = dir * "sg$(sg)-g$(gidx)-$(mode).jld2"                
    jldopen(filename, "w") do fid
        fid["lgirsd"] = lgirsd
        fid["brs"] = brs
        fid["symeigsdv"] = symeigsdv
        fid["summariesv"] = summariesv
    end
end


