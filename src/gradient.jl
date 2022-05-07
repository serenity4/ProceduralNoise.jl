function perlin(resolution, scale)
    grid = create_gradients(scale)
    perlin(resolution, grid)
end

function create_gradients(scale)
    grid = zeros(scale...)
    grid = map(x -> normalize(1 .- 2 .* rand(length(scale))), grid)
end

function perlin(resolution, grid::AbstractArray)
    noise = zeros(resolution...)
    perlin!(noise, grid)
end

function perlin!(A::AbstractArray, grid::AbstractArray)
    resolution, scale = size(A), size(grid)
    n = ndims(grid)
    texels = Base.Iterators.product([1:r for r in resolution]...)
    resolution_range = map(x -> (1, x), resolution)
    scale_range = map(x -> (1, x), scale)

    for texel in texels
        # scale coordinates
        scale_coord = remap.(texel, resolution_range, scale_range)

        # scale coordinates (integer, used as index)
        neighbor_inds = adjacent(scale_coord, scale)

        # scale coordinates
        rel_grid = scale_coord .- first(neighbor_inds)

        @assert all(abs.(rel_grid) .< 1)

        # conversion from scale coordinates to unit coordinates [0, 1]
        # rel_grid_01 = remap.(rel_grid, map(x -> (0, x), scale), ntuple(Returns((0, 1)), n))

        weights = fade.(rel_grid)
        # @show texel rel_grid weights

        @assert all(x -> 0 ≤ x ≤ 1, weights)
        # Main.@infiltrate

        noise_contribs = map(neighbor_inds) do inds
            rel_neigh = scale_coord .- inds
            # @assert all(x -> -1 ≤ x ≤ 1, rel_neigh)
            # rel_neigh = remap.(rel_neigh, map(x -> (0, x), 1 ./ scale), ntuple(Returns((0, 1)), n))
            dot(grid[inds...], rel_neigh)
        end
        value = interpolate_multilinear(ntuple(i -> [0, 1], n), noise_contribs, weights)
        setindex!(A, value, texel...)
    end

    A
end

fade(x) = x^3 * (x * (6x - 15) + 10)

function adjacent(p, pmax)
    fp1, fp2 = floor.(Int, p)
    # cp1, cp2 = ceil.(Int, p)
    cp1, cp2 = min.(pmax, (fp1, fp2) .+ 1)
    @SArray NTuple{2,Int}[(fp1, fp2) (cp1, fp2)
                          (fp1, cp2) (cp1, cp2)]
end

function interpolate_multilinear(corners, A, position)
    itp = interpolate(corners, A, Gridded(Linear()))
    itp(position...)
end
