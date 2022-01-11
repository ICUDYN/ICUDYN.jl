using Revise: include
include("runtests-prerequisite.jl")

@testset "Test all" begin
    include("Controller/ETL/Misc/runtests-Misc.jl")
end