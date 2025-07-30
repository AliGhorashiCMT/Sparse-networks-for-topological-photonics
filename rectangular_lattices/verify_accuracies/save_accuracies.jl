using DelimitedFiles
using PyCall
np = pyimport("numpy")

accuracies = Float64[]

for i in range(0, 159)
	acc = readdlm("verify_accuracy-$i.o")[end, 1];
	push!(accuracies, acc)
end

np.savetxt("all_accuracies.txt", accuracies)
