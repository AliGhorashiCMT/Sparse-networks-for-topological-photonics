sg, gidx = parse.(Int, ARGS)
using JLD2
println("Running Spacegroup: $sg")
idx_max = 10000
for mode in ["te"] #["tm"]
    println("mode: ", mode)
    flush(stdout)
    for id_eps in [1]
        println("id_eps: ", id_eps)
	flush(stdout)
        dir = "./logs/"
	logsv = String[]

        for id in 1:idx_max
            true_id  = id + (gidx-1)*10000 # actual id
	    io = open(dir*"dim2-sg$sg-$(true_id)-res64-$(mode).log")
	    push!(logsv, read(io, String))
	    close(io)
	end
        filename = dir*"sg$(sg)-g$(gidx)-$(mode)-log.jld2"                
        jldopen(filename, "w") do fid
            fid["logsv"] = logsv
	end
    end
end

