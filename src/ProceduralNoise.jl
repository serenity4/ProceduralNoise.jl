"""
Gradient noise generation (e.g. Perlin noises)
"""
module ProceduralNoise

using GridHelpers
using StaticArrays: @SMatrix

include("utils.jl")
include("noise.jl")
include("perlin.jl")
include("fractal.jl")

export NoiseGenerator, Perlin, Fractal, create_gradients

end # module
