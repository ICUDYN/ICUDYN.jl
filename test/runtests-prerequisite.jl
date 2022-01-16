using Pkg
Pkg.activate(".")
using Revise

using Test, Distributed
using Statistics

include("../scripts/using.jl")


function getPatientsDataDir_testUtil()
    joinpath(pwd(),"test/assets/patients")
end

function getPatientXLSXPath_testUtil()

end
