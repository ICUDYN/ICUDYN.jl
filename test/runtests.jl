using Revise: include
using DataFrames: Dict
include("runtests-prerequisite.jl")

@testset "Test all" begin
    include("util/runtests-util.jl")
    include("Controller/ETL/Misc/runtests-Misc.jl")
    include("Controller/ETL/Physiological/runtests-Physiological.jl")
    include("Controller/ETL/Transfusion/runtests-Transfusion.jl")
    include("Controller/ETL/FluidBalance/runtests-FluidBalance.jl")
    include("Controller/ETL/Dialysis/runtests-Dialysis.jl")
    include("Controller/ETL/Ventilation/runtests-Ventilation.jl")
    include("Controller/ETL/Biology/runtests-Biology.jl")
end
