struct Fractal{N,T,G<:NoiseGenerator{N,T}} <: NoiseGenerator{N,T}
  layers::Vector{G}
  persistence::T
end

function Fractal{G}(scale; octaves = 8, persistence = 0.5, lacunarity = 2.) where {G<:NoiseGenerator}
  layers = [G(round.(Int, scale .* lacunarity .^ (octave - 1))) for octave in 1:octaves]
  G′ = eltype(layers)
  Fractal{dimension(G′), eltype(G′), G′}(layers, persistence)
end

function (noise!::Fractal{1,T})(A::Vector{T}, range = default_range(noise!)) where {T}
  fill!(A, zero(eltype(A)))
  n = length(A)
  for (octave, layer) in enumerate(noise!.layers)
    for i in eachindex(A)
      @inbounds A[i] += evaluate(layer, remap(i, 1, n, 1, layer.scale[1])) * noise!.persistence ^ octave
    end
  end
  remap!(A, range)
end

function (noise!::Fractal{2,T})(A::Matrix{T}, range = default_range(noise!)) where {T}
  fill!(A, zero(eltype(A)))
  dims = size(A)
  for (octave, layer) in enumerate(noise!.layers)
    for j in 1:dims[2]
        for i in 1:dims[1]
            @inbounds A[i, j] += evaluate(layer, remap.((i, j), 1, dims, 1, layer.scale)) * noise!.persistence ^ octave
        end
    end
  end
  remap!(A, range)
end
