using ProceduralNoise
using Plots: Plots, heatmap

plot(A::AbstractVector) = Plots.plot(A)
plot(A::AbstractMatrix) = heatmap(A, colormap=:inferno)

plot_perlin(scale, resolution) = plot(Perlin(scale)(resolution))
plot_perlin(scale::Integer, resolution::Integer) = plot_perlin((2, 2) .^ scale, (2, 2) .^ resolution)

plot_fractal(::Type{T}, scale, resolution; fractal_kwargs...) where {T<:NoiseGenerator} = plot(Fractal{T}(scale; fractal_kwargs...)(resolution))
plot_fractal(::Type{T}, scale::Integer, resolution::Integer; kwargs...) where {T<:NoiseGenerator} = plot_fractal(T, (2, 2) .^ scale, (2, 2) .^ resolution; kwargs...)

plot_perlin(1, 9)
plot_perlin(4, 9)

noise = Perlin((2, 2) .^ 4)
plot_fractal(Perlin, 4, 9; octaves = 4)
plot_fractal(Perlin, 1, 9; octaves = 16, persistence = 0.6, lacunarity = 1.5)
plot_fractal(Perlin, 1, 9; octaves = 16, persistence = 0.75, lacunarity = 1.5)
plot_fractal(Perlin, 1, 9; octaves = 16, persistence = 0.9, lacunarity = 1.5)

resolution = 2 ^ 12
scale = (2,)
plot_fractal(Perlin, scale, resolution; octaves = 14, persistence = 0.9)
plot_fractal(Perlin, scale, resolution; octaves = 14, persistence = 1.3)
plot_fractal(Perlin, scale, resolution; octaves = 24, persistence = 0.8)
plot_fractal(Perlin, scale, resolution; octaves = 24, persistence = 0.8, lacunarity = 1.5)
plot_fractal(Perlin, scale, resolution; octaves = 24, persistence = 0.9, lacunarity = 1.5)
plot_fractal(Perlin, (55,), resolution; octaves = 48, persistence = 0.8, lacunarity = 1.3)
