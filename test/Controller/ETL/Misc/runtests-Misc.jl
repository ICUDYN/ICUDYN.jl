include("../../../runtests-prerequisite.jl")

@testset "Test computeStartTime and computeEndTime" begin

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
    result = ETL.Misc.computeStartTime(df)
    @test result == DateTime("2022-01-01T10:00:00")

    result = ETL.Misc.computeEndTime(df)
    @test result == DateTime("2022-01-01T14:01:00")

end



@testset "Test computeDischargeDisposition" begin

    #
    df = DataFrame(
        terseForm = ["xxxxx", "case1","case2","case3", "","case5"], 
        attributeDictionaryPropName = [
            "xxxxxxxxx",
            "V_Census_dischargeDisposition",
            "blabla", 
            "V_Census_dischargeDisposition", 
            "V_Census_dischargeDisposition", 
            ""]
        )
    result = ETL.Misc.computeDischargeDisposition(df)

    @test result == "case1"

    #
    df = DataFrame(
        terseForm = ["xxxxx", "case1","case2","case3", "","case5"], 
        attributeDictionaryPropName = [
            "xxxxxxxxx",
            "dfg",
            "blabla", 
            "vdfb", 
            "xchg", 
            ""]
        )

    result = ETL.Misc.computeDischargeDisposition(df)

    @test result === missing
    #
    df = DataFrame(
        terseForm = ["xxxxx", "NULL","case2"], 
        attributeDictionaryPropName = [
            "xxxxxxxxx",
            "V_Census_dischargeDisposition",
            ""]
        )
    result = ETL.Misc.computeDischargeDisposition(df)
    
    @test result === missing
end