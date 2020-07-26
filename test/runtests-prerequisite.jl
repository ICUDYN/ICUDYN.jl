using Pkg
Pkg.activate(".")

using Revise

# We explicitely import Distributed package in case we haven't set '--procs' in
#   the julia call
using Distributed

# nprocs()

# Ajout du chemin vers PostgresqlDAO dans le path de julia
@everywhere push!(LOAD_PATH, ENV["POSTGRESQLDAO_PATH"])

using Test
@time using TickTock, Random, Dates, TimeZones, UUIDs, DataFrames, Query, CSV,
            XLSX
# using Tables, DataFrames, Query, LibPQ, Dates, UUIDs, TickTock
@time using PostgresqlDAO

# versioninfo()

Random.seed!() # Ensures that we get new random values every time we run the @testset

# Run all the required 'using'
include("../src/using.jl")

# @testset "Test OQS `greet`" begin
#     OQS.greet()
# end
#
# @testset "Test OQS `rand2`" begin
#     rand2(2,2)
# end
