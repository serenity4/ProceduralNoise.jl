using ProceduralNoise
const PN = ProceduralNoise
using Test
using LinearAlgebra

@testset "ProceduralNoise.jl" begin
    point = (512.2, 514.4)
    @test PN.adjacent(point) == [(512, 514) (512, 515)
                                 (513, 514) (513, 515)]

    scale = (2, 2) .^ 4
    p = Perlin(scale)
    v = p(2.5, 3.5)
    @test v isa Float64
    gradient_coordinates = [[i, j] for i in 1:scale[1], j in 1:scale[2]]
    @test all(p.(gradient_coordinates) .≈ 0)
    @test !all(p.(gradient_coordinates .+ Ref([0.5, 0.5])) .≈ 0)

    # The value at the middle point is the average of all gradient contributions.
    @test p(1.5, 1.5) ≈ sum(p.gradients[1:2, 1:2] .⋅ [[j * 0.5, i * 0.5] for j in (1, -1), i in (1, -1)]) / 4
end;
