using Core: include
using Dates: include
using Revise: include
include("runtests-prerequisite.jl")

@testset "Test all" begin
    include("Controller/ETL/Misc/runtests-Misc.jl")
    include("Controller/ETL/Physiological/runtests-Physiological.jl")
end