include("../runtests-prerequisite.jl")

# @testset "Test ICUDYNUtil.timeDiffInGivenUnit" begin
#    time1 = TimeZones.ZonedDateTime(DateTime("2019-10-28T02:57:00"),
#                                    TimeZones.TimeZone("Europe/Paris"))
#    time2 = TimeZones.ZonedDateTime(DateTime("2019-10-28T02:57:01.90"),
#                                    TimeZones.TimeZone("Europe/Paris"))

#   ICUDYNUtil.timeDiffInGivenUnit(time1,time2,"mill")
#   ICUDYNUtil.timeDiffInGivenUnit(time1,time2,"sec")
# end


@testset "Test ICUDYNUtil.timeDiffInGivenUnit" begin
  df = DataFrame(a = [21,22,23,24], b = [11,12,13,14])
  ICUDYNUtil.cutAt(df,
                   [3])
  ICUDYNUtil.cutAt(df,
                  [4])
  ICUDYNUtil.cutAt(df,
                   [1])
end

@testset "Test ICUDYNUtil.getNonMissingValues" begin

    # Case with an aggregating function as last argument
    df = DataFrame(
        terseForm = [
            10,
            missing,
            "100 ml",
            50],
        attributeDictionaryPropName = [
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "toto",
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            ]
        )

    @test ICUDYNUtil.getNonMissingValues(
        df,
        :attributeDictionaryPropName,
        "PtSiteCare_DialysisOutSiteInt.outputVolume",
        :terseForm) == [10,50]

end

@testset "Test ICUDYNUtil.getNumericValueFromWindowTerseForm" begin

    # Case with an aggregating function as last argument
    df = DataFrame(
        terseForm = [
            0,
            4,
            "100 ml",],
        attributeDictionaryPropName = [
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "toto"
            ]
        )
    @test ICUDYNUtil.getNumericValueFromWindowTerseForm(
        df,
        "PtSiteCare_DialysisOutSiteInt.outputVolume",
        mean) === 2.0

    # Case with missing (i.e. no aggregating function) as last argument
    df = DataFrame(
        terseForm = [
            0,
            4,
            "100 ml",],
        attributeDictionaryPropName = [
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "toto"
            ]
        )
    @test ICUDYNUtil.getNumericValueFromWindowTerseForm(
        df,
        "PtSiteCare_DialysisOutSiteInt.outputVolume",
        missing) == [0,4]

    # Case with no interesting value
    df = DataFrame(
        terseForm = [
            "",
            "100 ml",],
        attributeDictionaryPropName = [
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "toto"
            ]
        )
    @test ICUDYNUtil.getNumericValueFromWindowTerseForm(
        df,
        "PtSiteCare_DialysisOutSiteInt.outputVolume",
        mean) === missing

end

@testset "Test ICUDYNUtil.rmAccentsAndLowercaseAndStrip" begin
    @test ICUDYNUtil.rmAccentsAndLowercaseAndStrip("À ") === "a"
end


@testset "Test ICUDYNUtil.getMostFrequentValue" begin
    ICUDYNUtil.getMostFrequentValue(["a","b"])
end


@testset "ICUDYNUtil.convertToFloatIfPossible" begin
    ICUDYNUtil.convertToFloatIfPossible.(
        [1,"1","null","NULL",missing,"3.3","1,1","100, 200"]
    )
end