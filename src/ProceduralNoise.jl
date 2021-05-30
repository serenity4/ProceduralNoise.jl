module ProceduralNoise

using LinearAlgebra
using StaticArrays
using Base.Threads:@threads

include("utils.jl")
include("gradient.jl")

export perlin, perlin!, perlin2d!

end # module
