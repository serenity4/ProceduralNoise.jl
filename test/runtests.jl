using ProceduralNoise
const PN = ProceduralNoise
using Test

@testset "ProceduralNoise.jl" begin
    point = (512.2, 514.4)
    @test PN.adjacent(point) == [(512, 514) (513, 514)
                                 (512, 515) (513, 515)]

    A = perlin((512, 512), (32, 32))
    @test A isa Matrix
    @test size(A) == (512, 512)
end
