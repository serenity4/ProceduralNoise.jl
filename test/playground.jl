using ProceduralNoise
using CairoMakie
using StaticArrays

plot_perlin(A::AbstractMatrix, cs) = heatmap(first.(cs), last.(cs), A, colormap=:inferno)
plot_perlin!(A::AbstractMatrix, cs) = heatmap!(first.(cs), last.(cs), A, colormap=:inferno)

function coordinates(resolution, scale)
  [@SVector([i, j]) .* scale ./ resolution for (i, j) in Iterators.product([0:(r - 1) for r in resolution]...)]
end

scale = (2, 2) .^ 4
p = Perlin(scale)
resolution = (2, 2) .^ 9
cs = coordinates(resolution, scale)
f = Figure(resolution = (800, 800))
Axis(f[1, 1], backgroundcolor = "black")
A = p.(cs)
plot_perlin!(A, cs)
f
arrows!(range.(1, scale)..., first.(p.gradients), last.(p.gradients), linecolor=:green, arrowcolor=:green, arrowsize=10, lengthscale=0.5, linewidth=1)
f

function perlin_image(scale, resolution)
  p = Perlin(scale...)
  cs = coordinates(resolution, scale)
  A = p.(cs)
  plot_perlin(A, cs)
end
perlin_image(scale::Integer, resolution::Integer) = perlin_image(fill(1, 2) .* scale, fill(1, 2) .* resolution)

perlin_image((2, 2) .^ 1, (2, 2) .^ 9)
perlin_image(2, 2^9)

function fractal_image(p, scale, resolution; fractal_kwargs...)
  cs = coordinates(resolution, scale)
  f = Fractal(p; fractal_kwargs...)
  A = f.(cs)
  plot_perlin(A, cs)
end
fractal_image(p, scale::Integer, resolution::Integer; kwargs...) = fractal_image(p, fill(1, 2) .* scale, fill(1, 2) .* resolution; kwargs...)

p = Perlin((2^4, 2^4))
fractal_image(p, 2^1, 2^9; octaves = 4)
fractal_image(p, 2^1, 2^9; octaves = 16, persistence = 0.75, lacunarity = 1.5)

plot_perlin(A::AbstractVector, cs; kwargs...) = lines(cs, A; kwargs...)
plot_perlin!(A::AbstractVector, cs; kwargs...) = lines!(cs, A; kwargs...)

coordinates(resolution::Integer, scale::Integer) = (0:(resolution-1)) .* scale ./ resolution 

function perlin_curve(scale, resolution)
  p = Perlin(scale...)
  cs = coordinates(resolution, scale)
  A = p.(cs)
  plot_perlin(A, cs)
end

perlin_curve(2 ^ 7, 2 .^ 13)

function fractal_curve(p, scale, resolution; base_frequency = 1., fractal_kwargs...)
  cs = coordinates(resolution, scale)
  f = Fractal(p; base_frequency, fractal_kwargs...)
  A = f.(cs)
  plot_perlin(A, cs)
end

resolution = 2^13
scale = 2^1
p = Perlin(2^4)
fractal_curve(p, scale, resolution; octaves = 14, persistence = 0.9)
fractal_curve(p, scale, resolution; octaves = 14, persistence = 1.3)
fractal_curve(p, scale, resolution; octaves = 24, persistence = 0.8)
fractal_curve(p, scale, resolution; octaves = 24, persistence = 0.8, lacunarity = 1.5)
fractal_curve(p, scale, resolution; octaves = 24, persistence = 0.9, lacunarity = 1.5)
fractal_curve(Perlin(2^10), 1, resolution; base_frequency = 55., octaves = 48, persistence = 0.8, lacunarity = 1.3)

f = Fractal(p; base_frequency = 1., octaves = 24, persistence = 0.8, lacunarity = 1.5)
cs = coordinates(resolution, scale)

function ema(ys, n)
  res = similar(ys)
  for i in eachindex(ys)
    v = 0.
    range = i:-1:max(1, i-n)
    for j in range
      v += ys[j] * exp(j/i)
    end
    res[i] = v / sum(exp.(range ./ i))
  end
  res
end

fig = Figure(resolution = (800, 800))
Axis(fig[1, 1], backgroundcolor = "black")
plot_perlin!(f.(cs), cs)
plot_perlin!(ema(f.(cs), 200), cs, color=:red)
fig
