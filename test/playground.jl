using ProceduralNoise
using Plots
using StaticArrays, BenchmarkTools
scale = (2, 2) .* 1
resolution = (256, 256) .* 2
resolution = (3, 3)
grid = ProceduralNoise.create_gradients(scale)
A = zeros(resolution)
# @time perlin2d!(A, grid)
@time perlin!(A, grid)
@benchmark perlin!($A, $grid)
@profiler perlin!(A, grid)
heatmap(A)
ProceduralNoise.adjacent((1.5, 2.5))


function mydot(a, b)
    arr = @. (a - b) * a
    sum(arr)
end


function mydot!(arr, a, b)
    @. arr = (a - b) * a
    sum(arr)
end

# @generated function genadjacent!(neighbors, vec::NTuple{N, Float64}) where N
#
#     quote
#         for value in vec
#
#         vec
#     end
# end
myadjacent!(tmp_alloc, i) = tmp_alloc .= floor(i), ceil(i)
function myadjacent!(arr, p)
    # arr[1, :] .= repeat(myadjacent!(tmp_alloc, p[1]), inner=2)
    # @views arr[1, :] .= repeat(p, outer=2)
    # cp = myadjacent(p[2])
    # arr .= [...; repeat(cp, inner=2)...]
    fp1, fp2 = floor.(p)
    cp1, cp2 = ceil.(p)
    # arr .= [fp1 fp2 fp1 fp2 ; cp1 cp1 cp2 cp2]
    arr[1, 1] = fp1
    arr[1, 2] = fp2
    arr[1, 3] = fp1
    arr[1, 4] = fp2
    arr[2, 1] = cp1
    arr[2, 2] = cp1
    arr[2, 3] = cp2
    arr[2, 4] = cp2
end

function test_myadjacent()
    arr = zeros(2, 4)
    pos = [1.7, 6.8]
    tmp_alloc = zeros(2)
    @benchmark myadjacent!($arr, $pos, $tmp_alloc)
    # @benchmark myadjacent!($tmp_alloc, 2.7)
end


function f2!(arr, p)
    fp1, fp2 = floor.((p[1], p[2]))
    cp1, cp2 = ceil.((p[1], p[2]))
    arr[1, 1] = fp1
    arr[1, 2] = cp1
    arr[1, 3] = fp1
    arr[1, 4] = cp1
    arr[2, 1] = fp2
    arr[2, 2] = fp2
    arr[2, 3] = cp2
    arr[2, 4] = cp2
end

function f1(p)
    fp1, fp2 = floor.(p)
    cp1, cp2 = ceil.(p)
    arr = @SArray Int[fp1 cp1 fp1 cp1; fp2 fp2 cp2 cp2]
end

function f1!(arr, p)
    fp1, fp2 = floor.(p)
    cp1, cp2 = ceil.(p)
    arr .= @SArray [fp1 cp1 fp1 cp1; fp2 fp2 cp2 cp2]
end

p_s = @SVector [1.3, 6.8]
arr = zeros(Int, 2, 4)
@benchmark f1!($arr, Ref($p_s)[])
@benchmark f2!($arr, Ref($p_s)[])

f1!(Ref(p_s)[])
f2!(arr, Ref(p_s)[]); arr
