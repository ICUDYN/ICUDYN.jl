using Pkg
Pkg.activate(".")
using Documenter
using Distributed
include("../scripts/using.jl")
# using ICUDYN.Controller.ETL.Biology

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