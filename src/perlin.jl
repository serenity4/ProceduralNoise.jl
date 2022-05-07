abstract type NoiseGenerator end

(noise::NoiseGenerator)(coordinates::Real...) = noise(SVector{length(coordinates), eltype(coordinates)}(coordinates))

struct Perlin{N,A<:AbstractArray{SVector{N,Float64},N}} <: NoiseGenerator
    gradients::A
end

Base.ndims(::Perlin{N}) where {N} = N

Perlin(scale::Integer...) = Perlin(create_gradients(scale))
Perlin(scale::NTuple) = Perlin(create_gradients(scale))

function create_gradients(scale)
    gradients = Array{SVector{length(scale),Float64}}(undef, scale...)
    for i in eachindex(gradients)
        gradients[i] = SVector{length(scale),Float64}(normalize(1 .- 2 .* rand(length(scale))))
    end
    CircularArray(gradients)
end

function (perlin::Perlin)(position)
    (; gradients) = perlin

    neighbor_inds = adjacent(position)
    noise_contribs = map(neighbor_inds) do inds
        rel_neigh = position .- inds
        grad = gradients[inds...]
        grad ⋅ rel_neigh
    end

    rel_grid = position .- first(neighbor_inds)
    weights = fade.(rel_grid)

    interpolate_bilinear(noise_contribs, weights)
end

fade(x) = 6x^5 - 15x^4 + 10x^3

function adjacent(p)
    fp1, fp2 = floor.(Int, p)
    cp1, cp2 = (fp1, fp2) .+ 1
    @SArray NTuple{2,Int}[(fp1, fp2) (fp1, cp2)
                          (cp1, fp2) (cp1, cp2)]
end

# Dead code; the corner points are always checked by Interpolations.jl which makes it slow for repeated use.
function interpolate_multilinear(corners, A, position)
    itp = interpolate(corners, A, Gridded(Linear()))
    itp(position...)
end

function interpolate_bilinear(A::AbstractArray{<:Any,2}, position)
    nx0 = lerp(A[1, 1], A[2, 1], position[1])
    nx1 = lerp(A[1, 2], A[2, 2], position[1])
    lerp(nx0, nx1, position[2])
end

lerp(x, y, w) = x * (1 - w) + y * w
