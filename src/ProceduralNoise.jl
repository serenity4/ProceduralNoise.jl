"""
Gradient noise generation (e.g. Perlin noises)
"""
module ProceduralNoise

using LinearAlgebra
using StaticArrays
using Base.Threads:@threads
using Interpolations
using CircularArrays

include("utils.jl")
include("perlin.jl")
include("fractal.jl")

export Perlin, Fractal, remap, create_gradients

end # module
