using ProceduralNoise
using Plots

scale = (2, 2) .^ 2
resolution = (2, 2) .^ 9
A = perlin(resolution, scale)
heatmap(A)
