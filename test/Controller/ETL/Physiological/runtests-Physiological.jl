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



@testset "Test computeAge" begin

    #
    df = DataFrame(
        terseForm = [
            20,
            40,
            22,
            26],
        attributeDictionaryPropName = [
            "ptDemographic_patientAgeInt.ageValue",
            "case1",
            "ptDemographic_patientAgeInt.ageValue",
            "ptDemographic_patientAgeInt.ageValue"]
        )
    result = ETL.Physiological.computeAge(df)

    @test result == 20
end


@testset "Test computeHeight" begin

    #
    df = DataFrame(
        terseForm = [
            180,
            200,
            182,
            186],
        attributeDictionaryPropName = [
            "ptDemographic_PtHeight.height",
            "case1",
            "ptDemographic_PtHeight.height",
            "ptDemographic_PtHeight.height"]
        )
    result = ETL.Physiological.computeHeight(df)

    @test result == 183
end


@testset "Test computeWeight" begin

    #
    df = DataFrame(
        terseForm = [
            80,
            100,
            82,
            86],
        attributeDictionaryPropName = [
            "PtAssessment_ptWeightIntervention.ptWeight",
            "case1",
            "PtAssessment_ptWeightIntervention.ptWeight",
            "PtAssessment_ptWeightIntervention.ptWeight"]
        )
    result = ETL.Physiological.computeWeight(df)

    @test result == 83
end


@testset "Test computeHeartRateVars" begin

    #
    df = DataFrame(
        terseForm = [
            60,
            65,
            70,
            75,
            82,
            91.72],
        attributeDictionaryPropName = [
            "blabla",
            "PtAssessment_heartRateInt.heartRate",
            "PtAssessment_heartRateInt.heartRate",
            "PtAssessment_heartRateInt.heartRate",
            "PtAssessment_heartRateInt.heartRate",
            "PtAssessment_heartRateInt.heartRate"]
        )
    result = ETL.Physiological.computeHeartRateVars(df)
    @test result == [65,91.72,76.74,75]
end




@testset "Test computeUrineVolume" begin

    #
    df = DataFrame(
        verboseForm = [
            "60 ml",
            "null",
            "120 ml",
            "130 ml",
            "140 ml"],
        attributeDictionaryPropName = [
            "blabla",
            "PtSiteCare_urineOuputInt.outputVolume",
            "PtSiteCare_urineOuputInt.outputVolume",
            "PtSiteCare_urineOuputInt.outputVolume",
            "PtSiteCare_urineOuputInt.outputVolume"]
        )
    result = ETL.Physiological.computeUrineVolume(df)
    @test result == 130
end



@testset "Test computeArterialBp" begin

    #
    df = DataFrame(
        terseForm = [
            80,
            100,
            82,
            86,
            72,
            "null",
            122,
            77,
            113
            ],
        attributeDictionaryPropName = [
            "PtAssessment_arterialBPInt.mean",
            "case1",
            "PtAssessment_arterialBPInt.mean",
            "PtAssessment_arterialBPInt.mean",
            "PtAssessment_arterialBPInt.diastolic",
            "case1",
            "PtAssessment_arterialBPInt.systolic",
            "PtAssessment_arterialBPInt.diastolic",
            "PtAssessment_arterialBPInt.systolic"
            ]
        )
    result = ETL.Physiological.computeArterialBp(df)

    @test result == [82.7,74.5,117.5]
end




@testset "Test computeTemperature" begin

    #
    df = DataFrame(
        terseForm = [
            37,
            36.8,
            "null",
            37.6],
        attributeDictionaryPropName = [
            "PtAssessment_temperatureInt.temperature",
            "case1",
            "PtAssessment_temperatureInt.temperature",
            "PtAssessment_temperatureInt.temperature"]
        )
    result = ETL.Physiological.computeTemperature(df)

    @test result == 37.3
end


@testset "Test computeNeuroGlasgow" begin

    #
    df = DataFrame(
        terseForm = [
            10,
            10,
            "null",
            11,
            11],
        attributeDictionaryPropName = [
            "PtAssessment_GCSInt.GCSNum",
            "case1",
            "PtAssessment_GCSInt.GCSNum",
            "PtAssessment_GCSInt.GCSNum",
            "PtAssessment_GCSInt.GCSNum"]
        )
    result = ETL.Physiological.computeNeuroGlasgow(df,false)

    @test result == 11

    result = ETL.Physiological.computeNeuroGlasgow(df,true)

    @test result == 16


end



# @testset "Test computeNeuroRamsay" begin

#     #TODO Bapt : finir fonction après discussion (voir dans implémentation fonction)
#     #
#     df = DataFrame(
#         terseForm = [
#             10,
#             10,
#             "null",
#             11,
#             11],
#         attributeDictionaryPropName = [
#             "PtAssessment_GCSInt.GCSNum",
#             "case1",
#             "PtAssessment_GCSInt.GCSNum",
#             "PtAssessment_GCSInt.GCSNum",
#             "PtAssessment_GCSInt.GCSNum"]
#         )
#     result = ETL.Physiological.computeNeuroRamsay(df)

#     @test result == 11

#     result = ETL.Physiological.computeNeuroRamsay(df,true)

#     @test result == 16


# end



@testset "Test computeDouleurNumValue" begin

    #
    df = DataFrame(
        terseForm = [
            2,
            2,
            "null",
            3,
            3],
        attributeDictionaryPropName = [
            "PtAssessment_Evaluation_douleur.EV_num",
            "case1",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_num"]
        )
    result = ETL.Physiological.computeDouleurNumValue(df)

    @test result == 3


    df = DataFrame(
        terseForm = [
            "",
            "",
            "null",
            "",
            ""],
        attributeDictionaryPropName = [
            "PtAssessment_Evaluation_douleur.EV_num",
            "case1",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_num"]
        )
    result = ETL.Physiological.computeDouleurNumValue(df)

    @test result === missing


end


@testset "Test computeDouleurStringValue" begin

    #
    df = DataFrame(
        verboseForm = [
            "faible",
            "faible",
            "null",
            "modérée",
            "forte",
            "faible"],
        attributeDictionaryPropName = [
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "case1",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Evaluation_douleur.EV_analogique"]
        )
    result = ETL.Physiological.computeDouleurStringValue(df)

    @test result == "faible"


end




@testset "Test computeDouleurBpsNumValue" begin

    #
    df = DataFrame(
        terseForm = [
            6,
            5,
            "null",
            7,
            7],
        attributeDictionaryPropName = [
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS",
            "case1",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS"]
        )
    result = ETL.Physiological.computeDouleurBpsNumValue(df)

    @test result == 7

end




@testset "Test computePain" begin

    #test numeric value of pain
    df = DataFrame(
        terseForm = [
            2,
            2,
            "null",
            3,
            3,
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            6,
            5,
            "null",
            7,
            7],
        verboseForm = [
            "null",
            "null",
            "null",
            "null",
            "null",
            "faible",
            "forte",
            "modérée",
            "faible",
            "faible",
            "modérée",
            "null",
            "null",
            "null",
            "null",
            "null"],
        attributeDictionaryPropName = [
            "PtAssessment_Evaluation_douleur.EV_num",
            "null",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "null",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS",
            "null",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS"]
        )
    result = ETL.Physiological.computePain(df)

    @test result == "not_or_low"




    #test string value of pain
    df = DataFrame(
        terseForm = [
            "",
            "",
            "null",
            "",
            "",
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            "",
            "",
            "null",
            "",
            ""],
        verboseForm = [
            "null",
            "null",
            "null",
            "null",
            "null",
            "faible",
            "forte",
            "modérée",
            "faible",
            "modérée",
            "modérée",
            "null",
            "null",
            "null",
            "null",
            "null"],
        attributeDictionaryPropName = [
            "PtAssessment_Evaluation_douleur.EV_num",
            "null",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "null",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS",
            "null",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS"]
        )
    result = ETL.Physiological.computePain(df)

    @test result == "moderate"

    #test bps value of pain
    df = DataFrame(
        terseForm = [
            "",
            "",
            "null",
            "",
            "",
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            10,
            10,
            "null",
            11,
            11],
        verboseForm = [
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            "null",
            "null"],
        attributeDictionaryPropName = [
            "PtAssessment_Evaluation_douleur.EV_num",
            "null",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_num",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "null",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Evaluation_douleur.EV_analogique",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS",
            "null",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS",
            "PtAssessment_Echelle_comportementale_douleur.Total_BPS"]
        )
    result = ETL.Physiological.computePain(df)

    @test result == "high"

end
