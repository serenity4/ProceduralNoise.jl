struct Fractal{G<:NoiseGenerator,F} <: NoiseGenerator
  noise::G
  octaves::Int
  amplitude::Float64
  base_frequency::F
  persistence::Float64
  lacunarity::Float64
end

function Fractal(noise::NoiseGenerator; base_frequency = ntuple(Returns(1.), ndims(noise)), octaves = 8, amplitude = 1., persistence = 0.5, lacunarity = 2.)
  Fractal(noise, octaves, amplitude, base_frequency, persistence, lacunarity)
end

function (f::Fractal)(position)
  (; amplitude, persistence, lacunarity, noise) = f
  frequency = f.base_frequency
  value = 0.
  for _ in 1:f.octaves
      value += noise(position .* frequency) * amplitude
      frequency = frequency .* lacunarity
      amplitude *= persistence
  end
  value
end
