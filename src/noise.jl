abstract type NoiseGenerator{N,T} end

Base.eltype(::Type{<:NoiseGenerator{N,T}}) where {N,T} = T
dimension(::Type{<:NoiseGenerator{N,T}}) where {N,T} = N

Base.eltype(noise::NoiseGenerator) = eltype(typeof(noise))
dimension(noise::NoiseGenerator) = dimension(typeof(noise))

Base.broadcastable(noise::NoiseGenerator) = Ref(noise)

default_range(noise::NoiseGenerator) = (zero(eltype(noise)), one(eltype(noise)))

function (noise!::NoiseGenerator{1,T})(A::Vector{T}, range = default_range(noise!)) where {T}
    n = length(A)
    for i in eachindex(A)
        @inbounds A[i] = evaluate(noise!, remap(i, 1, n, 1, noise!.scale[1]))
    end
    remap!(A, range)
end

function (noise!::NoiseGenerator{2,T})(A::Matrix{T}, range = default_range(noise!)) where {T}
    dims = size(A)
    for j in 1:dims[2]
        for i in 1:dims[1]
            @inbounds A[i, j] = evaluate(noise!, remap.((i, j), 1, dims, 1, noise!.scale))
        end
    end
    remap!(A, range)
end

remap!(A::AbstractArray, range::NTuple{2}) = (A .= remap.(A, minimum(A), maximum(A), range...))
remap!(A::AbstractArray, range::Nothing) = A

(noise::NoiseGenerator{1})(size::Integer, range = default_range(noise)) = noise(zeros(eltype(noise), size), range)
(noise::NoiseGenerator{N})(size::NTuple{N}, range = default_range(noise)) where {N} = noise(zeros(eltype(noise), size...), range)
