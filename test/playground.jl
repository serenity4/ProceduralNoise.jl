using ProceduralNoise
using CairoMakie

scale = (2, 2) .^ 4
resolution = (2, 2) .^ 9
A = perlin(resolution, scale)
heatmap(A)

grid = create_gradients(scale)

f = Figure(resolution = (800, 800))
Axis(f[1, 1], backgroundcolor = "black")
A = perlin(resolution, grid)
heatmap!(A)
f
xs = [remap(x, (1, size(grid)[1]), (1, size(A)[1])) for x in 1:size(grid)[1]]
ys = [remap(y, (1, size(grid)[2]), (1, size(A)[2])) for y in 1:size(grid)[2]]
arrows!(xs, ys, first.(grid), last.(grid), linecolor=:red, arrowcolor=:red, arrowsize=10, lengthscale=20, linewidth=1)
f
