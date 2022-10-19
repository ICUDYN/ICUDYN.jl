include("../../runtests-prerequisite.jl")

@testset "Test ETL.exportPatientsToWebServer" begin

    ETL.exportPatientsToWebServer(;maxNumberOfPatients=1)

end
