"""Gradient noise generation (e.g. Perlin noises)
"""

function adjacent(p)
    fp1, fp2 = floor.(p)
    cp1, cp2 = ceil.(p)
    @SArray Int[fp1 cp1 fp1 cp1; fp2 fp2 cp2 cp2]
end

function lerp_weights(w)
    w1, w2 = w
    @SVector [1 - w1 - w2 + w1 * w2, w1 - w1 * w2, w2 - w1 * w2, w1 * w2]
end

function perlin!(A::AbstractArray, grid::AbstractArray)
    resolution, scale = size(A), size(grid)
    ranges = map.(Ref(x -> (1, x)), [resolution, scale])
    n = ndims(grid)
    neighbors = zeros(Int, n, 2^n)
    weights = zeros(2^n)
    # dot_prod_tmp = @SArray zeros(n)
    dot_prod_tmp = zeros(n)
    scaled_indices = zeros(n)
    # w = @SArray zeros(n)
    w = zeros(n)
    it_indices = collect(Base.Iterators.product(range.(Ref(1), resolution, step=1)...))
    
    # for indices in Base.Iterators.product(range.(Ref(1), resolution, step=1)...)
    #     scaled_indices .= remap.(indices, ranges...)
    #     @. w = fade(scaled_indices - floor(scaled_indices))
    #     lerp_weights!(weights, w)
    #     adjacent!(neighbors, scaled_indices)
    #     value = 0
    #     for i in 1:2^n
    #         neigh = neighbors[:, i]
    #         grad = getindex(grid, neigh...)
    #         @. dot_prod_tmp = (scaled_indices - neigh) * grad
    #         value += sum(dot_prod_tmp) * weights[i]
    #     end
    #     # distances = map(x -> scaled_indices .- x, neighbors)
    #     # dot_products = dot.(map(x -> getindex(grid, x...), neighbors), distances)
    #     # print(dot_products)
    #     # value = dot(dot_products, weights)
    #     setindex!(A, value, indices...)
    # end
    
    perlin_!(A, grid, weights, neighbors, scaled_indices, dot_prod_tmp, w, n, ranges, it_indices)
    
    A
end

function perlin_!(A, grid, weights, neighbors, scaled_indices, dot_prod_tmp, w, n, ranges, it_indices)
    for indices in it_indices
        scaled_indices .= remap.(indices, ranges[1], ranges[2])
        @. w = fade(scaled_indices - floor(scaled_indices))
        weights = lerp_weights(w)
        neighbors .= adjacent(scaled_indices)
        value = 0
        for i in 1:2^n
            @views neigh = neighbors[:, i]
            grad = getindex(grid, neigh[1], neigh[2])
            @. dot_prod_tmp = (scaled_indices - neigh) * grad
            value += sum(dot_prod_tmp) * weights[i]
        end
        # distances = map(x -> scaled_indices .- x, neighbors)
        # dot_products = dot.(map(x -> getindex(grid, x...), neighbors), distances)
        # print(dot_products)
        # value = dot(dot_products, weights)
        setindex!(A, value, indices...)
    end
end

# function perlin!(A::AbstractArray, grid::AbstractArray)
#     resolution, scale = size(A), size(grid)
#     ranges = map.(Ref(x -> (1, x)), [resolution, scale])
#     for indices in collect(Base.Iterators.product(range.(Ref(1), resolution, step=1)...))
#         scaled_indices = remap.(indices, ranges...)
#         subgrid_position = (scaled_indices .- floor.(scaled_indices))
#         w1, w2 = fade.(subgrid_position)
#         weights = (1 - w1 - w2 + w1 * w2, w1 - w1 * w2, w2 - w1 * w2, w1 * w2)
#         neighbors = adjacent(scaled_indices)
#         value = 0
#         for (neigh, weight) in zip(neighbors, weights)
#             grad = getindex(grid, neigh...)
#             value += dot(scaled_indices .- neigh, grad) * weight
#         end
#         # distances = map(x -> scaled_indices .- x, neighbors)
#         # dot_products = dot.(map(x -> getindex(grid, x...), neighbors), distances)
#         # print(dot_products)
#         # value = dot(dot_products, weights)
#         setindex!(A, value, indices...)
#     end

#     A
# end

function perlin(resolution, grid::AbstractArray)
    noise = zeros(resolution...)
    scale = size(grid)
    perlin!(noise, grid)
end

function create_gradients(scale)
    grid = zeros(scale...)
    grid = map(x -> normalize(rand(length(scale))), grid)
end

function perlin(resolution, scale)
    grid = create_gradients(scale)
    perlin(resolution, grid)
end

function perlin2d!(A::AbstractArray, grid::AbstractArray)
    resolution, scale = size(A), size(grid)
    for i in 1:resolution[1]
        for j in 1:resolution[2]
            x, y = remap.((i, j), map.(Ref(x -> (1, x)), [resolution, scale])...)
            x0 = Int(floor(x))
            x1 = Int(ceil(x))
            y0 = Int(floor(y))
            y1 = Int(ceil(y))
            sx = fade(x - x0)
            sy = fade(y - y0)

            n0 = dot_grid_gradient(grid, x0, y0, x, y)
            n1 = dot_grid_gradient(grid, x1, y0, x, y)
            ix0 = lerp([n0, n1], sx)

            n2 = dot_grid_gradient(grid, x0, y1, x, y)
            n3 = dot_grid_gradient(grid, x1, y1, x, y)
            ix1 = lerp([n2, n3], sx)
            # println((n0, n1, n2, n3))

            A[i, j] = lerp([ix0, ix1], sy)
        end
    end
    A
end

function dot_grid_gradient(grid, i, j, x, y)
    dx = x - i
    dy = y - j
    dot(grid[i, j], [dx, dy])
end
lerp(vals, w) = vals[1] * (1 - w) + vals[2] * w
fade(x) = 6x^5 - 15x^4 + 10x^3
