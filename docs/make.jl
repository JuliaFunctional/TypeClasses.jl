using TypeClasses
using Documenter

DocMeta.setdocmeta!(TypeClasses, :DocTestSetup, :(using TypeClasses); recursive=true)

makedocs(;
    modules=[TypeClasses],
    authors="Stephan Sahm <stephan.sahm@gmx.de> and contributors",
    repo="https://github.com/JuliaFunctional/TypeClasses.jl/blob/{commit}{path}#{line}",
    sitename="TypeClasses.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://JuliaFunctional.github.io/TypeClasses.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Manual" => [
            "Introduction" => "manual.md",
            "TypeClasses" => "manual-TypeClasses.md",
            "DataTypes" => "manual-DataTypes.md",
        ],
        "Library" => "library.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaFunctional/TypeClasses.jl",
)
