include("../../runtests-prerequisite.jl")


@testset "Test ETL.combineRefinedWindows" begin

    refinedWindow1 = Dict{Symbol,Any}(
        :Misc => Dict(
            :startTime => DateTime("2022-01-01T14:00:00"),
            :endTime => DateTime("2022-01-01T17:40:00"),
        ),
        :Biology => Dict(
            :toto => 2
        )
    )
    refinedWindow2 = Dict{Symbol,Any}(
        :Misc => Dict(
            :startTime => DateTime("2022-01-01T18:10:00"),
            :endTime => DateTime("2022-01-01T21:40:00"),
        ),
        :Physiology => Dict(
            :tata => "aaaa"
        )
    )

    expected = DataFrame(
        Misc_startTime = [DateTime("2022-01-01T14:00:00"),DateTime("2022-01-01T18:10:00"),],
        Misc_endTime = [DateTime("2022-01-01T17:40:00"),DateTime("2022-01-01T21:40:00"),],
        Biology_toto = [2,missing],
        Physiology_tata = [missing,"aaaa"],
    )

    result = ETL.combineRefinedWindows([refinedWindow1, refinedWindow2])
    println(result)
    
    @test  ICUDYNUtil.check_if_dataframes_are_equal(result,expected)
    
end

DataFrame(a=[3,4],b=[3,missing]) == DataFrame(a=[3,4],b=[3,missing])

@testset "Test cut_patient_df" begin

    # Check that event at cutting time gets into the next window
    chartTime = [
            DateTime("2022-01-01T14:01:00"),
            DateTime("2022-01-01T10:00:00"),
            DateTime("2022-01-01T11:00:00"),
            DateTime("2022-01-01T13:59:59"),
            DateTime("2022-01-01T14:00:00"),
            ]
    df = DataFrame(
        chartTime = chartTime,
        a = ones(length(chartTime))
    )
    result = ETL.cut_patient_df(df) 
    
    @test length(result) == 2
    @test (result |> n -> isempty.(n) |> n -> .!(n) |> n -> all(n)) == true
         

    # Check border case
    chartTime = [
            DateTime("2022-01-01T10:00:00"),
            DateTime("2022-01-01T11:00:00"),
            DateTime("2022-01-01T13:59:59"),
            DateTime("2022-01-01T14:00:00"),
            ]
    df = DataFrame(
        chartTime = chartTime,
        a = ones(length(chartTime))
    )
    result = ETL.cut_patient_df(df) 
    
    @test length(result) == 2
    @test (result |> n -> isempty.(n) |> n -> .!(n) |> n -> all(n)) == true

    # Check empty windows
    chartTime = [
            DateTime("2022-01-01T10:00:00"),
            DateTime("2022-01-01T11:00:00"),
            DateTime("2022-01-01T13:59:59"),
            DateTime("2022-01-01T20:00:00"),
            DateTime("2022-01-02T20:00:00"),
            ]
    df = DataFrame(
        chartTime = chartTime,
        a = ones(length(chartTime))
    )
    result = ETL.cut_patient_df(df) 
    
    @test length(result) == 3
    @test (result |> n -> isempty.(n) |> n -> .!(n) |> n -> all(n)) == true
    
end