abstract type NoiseGenerator end

Base.broadcastable(noise::NoiseGenerator) = Ref(noise)

function (noise!::NoiseGenerator)(A::Vector)
    n = length(A)
    for i in eachindex(A)
        @inbounds A[i] = evaluate(noise!, remap(i, 1, n, 1, noise!.scale[1]))
    end
    A
end

function (noise!::NoiseGenerator)(A::Matrix)
    dims = size(A)
    for j in 1:dims[2]
        for i in 1:dims[1]
            @inbounds A[i, j] = evaluate(noise!, remap.((i, j), 1, dims, 1, noise!.scale))
        end
    end
    A
end

(noise::NoiseGenerator)(size::Integer, T = Float64) = noise(zeros(T, size))
(noise::NoiseGenerator)(size::NTuple{2}, T = Float64) = noise(zeros(T, size...))

"""
    Perlin(scale_x) # 1D Perlin noise
    Perlin(scale_x, scale_y) # 2D Perlin noise
    Perlin(scale::NTuple{N}) where {N ≤ 2}

Perlin noise, using preinitialized gradients set at construction time.

Evaluation is fully deterministic given a set of gradients.
"""
struct Perlin{N,T} <: NoiseGenerator
    scale::NTuple{N,Int}
    gradients::Array{NTuple{N,T},N}
end

Base.ndims(::Perlin{N}) where {N} = N

Perlin{T}(scale::Integer...) where {T} = Perlin{T}(scale)
Perlin{T}(scale::NTuple{N}) where {N,T} = Perlin{N,T}(scale, create_gradients(scale))
Perlin(args...) = Perlin{Float64}(args...)

rescale(noise::Perlin{2}, location) = 1 .+ location ./ noise.scale
rescale(noise::Perlin{1}, location) = 1 + location / noise.scale[1]

function create_gradients(scale)
    gradients = Array{NTuple{length(scale),Float64}}(undef, scale...)
    for i in eachindex(gradients)
        @inbounds gradients[i] = normalize(1 .- 2 .* ntuple(_ -> rand(), length(scale)))
    end
    gradients
end

normalize(x::NTuple{1}) = sign.(x)
normalize(x::NTuple{2}) = x ./ hypot(x...)

function evaluate(perlin::Perlin{1}, x::Number)
    gradient_indices = adjacent(x)
    noise_contribs = (perlin.gradients[i][1] * (x - gradient_indices[i]) for i in 1:2)
    lerp(noise_contribs..., fade(x - floor(x)))
end

function adjacent(p::Number)
    fp1 = floor(Int, p)
    (fp1, fp1 + 1)
end

lerp(x, y, w) = x * (1 - w) + y * w

corner_value(perlin::Perlin, corner, location) = perlin.gradients[corner] ⋅ (location .- corner[])

function evaluate(perlin::Perlin{2}, location::NTuple{2,T}) where {T}
    cell = Cell(location, perlin.scale)
    corner_values = @SMatrix [
        corner_value(perlin, cell.bottom_left, location) corner_value(perlin, cell.top_left, location)
        corner_value(perlin, cell.bottom_right, location) corner_value(perlin, cell.top_right, location)
    ]
    weights = location .- cell.bottom_left[]
    smoothed_weights = fade.(weights)
    interpolate_bilinear(corner_values, smoothed_weights .+ 1, Cell(1, 1))
end

⋅(px, py) = px[1] * py[1] + px[2] * py[2]
fade(x) = 6x^5 - 15x^4 + 10x^3
