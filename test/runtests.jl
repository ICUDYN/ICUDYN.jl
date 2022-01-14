include("runtests-prerequisite.jl")

@testset "Test all" begin
    include("Controller/ETL/Misc/runtests-Misc.jl")
    include("Controller/ETL/Physiological/runtests-Physiological.jl")
    include("Controller/ETL/Transfusion/runtests-Transfusion.jl")
    include("Controller/ETL/FluidBalance/runtests-FluidBalance.jl")
    
end
