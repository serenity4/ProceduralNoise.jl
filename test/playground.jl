using ProceduralNoise
using CairoMakie
using StaticArrays

plot_perlin(A, cs) = heatmap(first.(cs), last.(cs), A, colormap=:inferno)
plot_perlin!(A, cs) = heatmap!(first.(cs), last.(cs), A, colormap=:inferno)

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
