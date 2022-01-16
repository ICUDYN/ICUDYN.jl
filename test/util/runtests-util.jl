include("../runtests-prerequisite.jl")

@testset "Test ICUDYNUtil.timeDiffInGivenUnit" begin
   time1 = TimeZones.ZonedDateTime(DateTime("2019-10-28T02:57:00"),
                                   TimeZones.TimeZone("Europe/Paris"))
   time2 = TimeZones.ZonedDateTime(DateTime("2019-10-28T02:57:01.90"),
                                   TimeZones.TimeZone("Europe/Paris"))

  ICUDYNUtil.timeDiffInGivenUnit(time1,time2,"mill")
  ICUDYNUtil.timeDiffInGivenUnit(time1,time2,"sec")
end


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

    @test ICUDYNUtil.getNonMissingValues(
        df,
        "PtSiteCare_DialysisOutSiteInt.outputVolume",
        :terseForm) == [10,50]

end

@testset "Test ICUDYNUtil.getTerseFormFromWindow" begin

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
    @test ICUDYNUtil.getTerseFormFromWindow(
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
    @test ICUDYNUtil.getTerseFormFromWindow(
        df,
        "PtSiteCare_DialysisOutSiteInt.outputVolume",
        missing) == [0,4]

    # Case with
    df = DataFrame(
        terseForm = [
            "",
            "100 ml",],
        attributeDictionaryPropName = [
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "toto"
            ]
        )
    ICUDYNUtil.getTerseFormFromWindow(df,"PtSiteCare_DialysisOutSiteInt.outputVolume",mean)
    @test ICUDYNUtil.getTerseFormFromWindow(
        df,
        "PtSiteCare_DialysisOutSiteInt.outputVolume",
        mean) === 2.0

end

@testset "Test ICUDYNUtil.getVerboseFormFromWindow" begin

    # Case with an aggregating function as last argument
    df = DataFrame(
        verboseForm = [
            0,
            4,
            "100 ml",],
        attributeDictionaryPropName = [
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "toto"
            ]
        )
    @test ICUDYNUtil.getVerboseFormFromWindow(
        df,
        "PtSiteCare_DialysisOutSiteInt.outputVolume",
        mean) === 2.0

    # Case with missing (i.e. no aggregating function) as last argument
    df = DataFrame(
        verboseForm = [
            0,
            4,
            "100 ml",],
        attributeDictionaryPropName = [
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "PtSiteCare_DialysisOutSiteInt.outputVolume",
            "toto"
            ]
        )
    @test ICUDYNUtil.getVerboseFormFromWindow(
        df,
        "PtSiteCare_DialysisOutSiteInt.outputVolume",
        missing) == [0,4]

end

@testset "Test ICUDYNUtil.rmAccentsAndLowercaseAndStrip" begin
    @test ICUDYNUtil.rmAccentsAndLowercaseAndStrip("À ") === "a"
end


@testset "Test ICUDYNUtil.getMostFrequentValue(vec::Vector{Any})" begin
    ICUDYNUtil.getMostFrequentValue(["a","b"])
end
