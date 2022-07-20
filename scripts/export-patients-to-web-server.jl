include("using.jl")
cd(joinpath(dirname(pathof(ICUDYN)),".."))
# @info pwd()
ETL.exportPatientsToWebServer()
