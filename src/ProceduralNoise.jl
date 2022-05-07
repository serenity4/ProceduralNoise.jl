"""
Gradient noise generation (e.g. Perlin noises)
"""
module ProceduralNoise

using LinearAlgebra
using StaticArrays
using Base.Threads:@threads
using Interpolations

include("utils.jl")
include("gradient.jl")

export perlin, perlin!, perlin2d!, remap, create_gradients

end # module
