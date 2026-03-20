sg = first(parse.(Int, ARGS))
using JLD2
println("Running Spacegroup: $sg")
contrast_idx_max = 2000
for mode in ["tm"]
    println("mode: ", mode)
    flush(stdout)
    dir = "./logs/"
    logsv = String[]
    true_id  = 1622
    for contrast_idx in 1:contrast_idx_max
        println("contrast_idx: ", contrast_idx)
	flush(stdout)
        dir = "./logs/"
	io = open(dir*"dim2-sg$sg-$(true_id)-$(contrast_idx)-res64-$(mode).log")
	push!(logsv, read(io, String))
	close(io)
    end
    filename = dir*"sg$(sg)-id$(true_id)-$(mode)-log.jld2"                
    jldopen(filename, "w") do fid
        fid["logsv"] = logsv
    end
end

