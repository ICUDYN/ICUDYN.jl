using Documenter
using Distributed
include("../scripts/using.jl")

makedocs(
    sitename="ICUDYN.jl",
    modules = [ETL.Biology],
    pages = [
        "Index" => "index.md",
        "Module ETL" => [
            "modules/ETL/ETL.Biology.md"
        ]
    ]
)

deploydocs(
    repo = "github.com/ICUDYN/ICUDYN.jl.git",
)