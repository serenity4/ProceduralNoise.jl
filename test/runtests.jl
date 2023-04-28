using ProceduralNoise
using GridHelpers
using ProceduralNoise: evaluate, ⋅
using Test

@testset "ProceduralNoise.jl" begin
    @testset "Remapping" begin
        x = (0.0, 1.0)
        @test remap.(x, x..., x...) == x
        @test remap.(x, -1.0, 1.0, 5.0, 7.0) == (6.0, 7.0)
    end

    @testset "Gradient creation" begin
        scale = (2,) .^ 10
        grads = create_gradients(scale)
        @test size(grads) == scale
        @test all(all(-1 ≤ x ≤ 1 for x in grad) for grad in grads)
        @test !allequal(grads)

        scale = (2, 2) .^ 4
        grads = create_gradients(scale)
        @test size(grads) == scale
        @test all(all(-1 ≤ x ≤ 1 for x in grad) for grad in grads)
        @test all(hypot(grad...) ≈ 1 for grad in grads)
        @test !allequal(grads)
    end

    @testset "Perlin noise" begin
        @testset "1D Perlin noise" begin
            scale = 2 .^ 4
            perlin = Perlin(scale)
            # Perlin noise at gradient coordinates should always be zero.
            @test perlin(scale) == zeros(scale)
            A = perlin(512)
            @test !allequal(A)
            @test all(-1 ≤ x ≤ 1 for x in A)
            @test A == perlin(A)
        end

        @testset "2D Perlin noise" begin
            scale = (2, 2) .^ 4
            perlin = Perlin(scale)
            v = evaluate(perlin, (2.5, 3.5))
            @test v isa Float64
            # Perlin noise at gradient coordinates should always be zero.
            @test perlin(scale) == zeros(scale)
            # The value at the middle point is the average of all gradient contributions.
            @test evaluate(perlin, (1.5, 1.5)) ≈ sum(perlin.gradients[1:2, 1:2] .⋅ [[j * 0.5, i * 0.5] for j in (1, -1), i in (1, -1)]) / 4

            A = perlin(scale .* 2^2)
            @test !allequal(A)
            @test all(-1 ≤ x ≤ 1 for x in A)
        end
    end

    @testset "Fractal noise" begin
        scale = (2, 2) .^ 2
        resolution = scale .* 2^2
        fractal = Fractal{Perlin}(scale, octaves = 8, persistence = 0.75)
        A = fractal(resolution .* 2^2)
        @test !allequal(A)
        @test all(-1 ≤ x ≤ 1 for x in A)
    end
end;
