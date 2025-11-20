# Parse log files to obtain fourier coefficients

function get_uc_coefs(filename::AbstractString; dir::AbstractString="./logs/")
    io = open(dir * filename, "r") 
    logstr = read(io, String)
    close(io)
    logstr_split = split(logstr, "\n")
    uc_coefs_str = filter(x->startswith(x, "command-line param: uc-coefs="), logstr_split)[end]
    uc_coefs_str = split(uc_coefs_str, "command-line param: uc-coefs=")[end]
    uc_coefs_str = String(split(uc_coefs_str, "(list")[end])
    uc_coefs_str = replace(uc_coefs_str, ")" => "")
    uc_coefs = parse.(Float64, String.(split(uc_coefs_str, " ")[2:end]))
    return uc_coefs
end

function get_uc_coefs_from_logstr(logstr::AbstractString)
    logstr_split = split(logstr, "\n")
    uc_coefs_str = filter(x->startswith(x, "command-line param: uc-coefs="), logstr_split)[end]
    uc_coefs_str = split(uc_coefs_str, "command-line param: uc-coefs=")[end]
    uc_coefs_str = String(split(uc_coefs_str, "(list")[end])
    uc_coefs_str = replace(uc_coefs_str, ")" => "")
    uc_coefs = parse.(Float64, String.(split(uc_coefs_str, " ")[2:end]))
    return uc_coefs
end

function get_rvecs(filename::AbstractString; dir::AbstractString="./logs/")
    io = open(dir * filename, "r") 
    logstr = read(io, String)
    close(io)
    logstr_split = split(logstr, "\n")
    rvecs_str = first(filter(x->startswith(x, "command-line param: rvecs="), logstr_split))
    rvecs_str_split = split(rvecs_str, "command-line param: rvecs=")[end]
    rvecs_str_split = split(rvecs_str_split, "(vector3 ")[2:end]
    rvecs_str_split = replace.(rvecs_str_split, ") " => "", ")"=>"")
    R1 = parse.(Float64, String.(split(rvecs_str_split[1], " ")))
    R2 = parse.(Float64, String.(split(rvecs_str_split[2], " ")))
    return [R1, R2]
end

function get_rvecs_from_logstr(logstr::AbstractString)
    logstr_split = split(logstr, "\n")
    rvecs_str = first(filter(x->startswith(x, "command-line param: rvecs="), logstr_split))
    rvecs_str_split = split(rvecs_str, "command-line param: rvecs=")[end]
    rvecs_str_split = split(rvecs_str_split, "(vector3 ")[2:end]
    rvecs_str_split = replace.(rvecs_str_split, ") " => "", ")"=>"")
    R1 = parse.(Float64, String.(split(rvecs_str_split[1], " ")))
    R2 = parse.(Float64, String.(split(rvecs_str_split[2], " ")))
    return [R1, R2]
end