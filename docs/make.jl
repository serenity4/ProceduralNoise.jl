using Documenter, ProceduralNoise

makedocs(;
    modules=[ProceduralNoise],
    format=Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ],
    repo="https://github.com/serenity4/ProceduralNoise.jl/blob/{commit}{path}#L{line}",
    sitename="ProceduralNoise.jl",
    authors="Cédric Belmant",
    assets=String[],
)

deploydocs(;
    repo="github.com/serenity4/ProceduralNoise.jl",
)
