include("../../../runtests-prerequisite.jl")


@testset "Test computeGender" begin

    #
    df = DataFrame(
        terseForm = [
            1,
            "",
            1,
            3],
        attributeDictionaryPropName = [
            "case1",
            "ptDemographic_Demographic90Int.Sexe",
            "ptDemographic_Demographic90Int.Sexe",
            "ptDemographic_Demographic90Int.Sexe"]
        )
    result = ETL.Physiological.computeGender(df)

    @test result == Dict(:gender => "male")

    # #
    # df = DataFrame(
    #     terseForm = [
    #         1,
    #         "",
    #         3,
    #         3],
    #     attributeDictionaryPropName = [
    #         "case1",
    #         "ptDemographic_Demographic90Int.Sexe",
    #         "ptDemographic_Demographic90Int.Sexe",
    #         "ptDemographic_Demographic90Int.Sexe"]
    #     )
    # result = ETL.Physiological.computeGender(df)

    # @test result == "ERROR" #TODO Bapt : le test ne devrait pas réussir quand même ?
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

    @test result == Dict(:age => 20)
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

    @test result == Dict(:height => 183)
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

    @test result == Dict(:weight => 83)

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

    @test result == Dict(
        :heartRateMax => 91.72,
        :heartRateMedian => 75.0,
        :heartRateMin => 65.0,
        :heartRateMean => 76.74,
    )


    #
    df = DataFrame(
        terseForm = [
            60,],
        attributeDictionaryPropName = [
            "blabla",]
        )
    result = ETL.Physiological.computeHeartRateVars(df)

    @test all(ismissing.(collect(values(result))))    
    
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
    @test result == Dict(:urineVolume => 130)
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

    @test result == Dict(
        :bpMean => 82.7,
        :bpDiastolic => 74.5,
        :bpSystolic => 117.5)
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

    @test result == Dict(:temperature => 37.3)
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

    @test result == Dict(:neuroGlasgow => 11)

    result = ETL.Physiological.computeNeuroGlasgow(df,true)

    @test result == Dict(:neuroGlasgow => 16)



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
    result = ETL.Physiological._computeDouleurNumValue(df)

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
    result = ETL.Physiological._computeDouleurNumValue(df)

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
    result = ETL.Physiological._computeDouleurStringValue(df)

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
    result = ETL.Physiological._computeDouleurBpsNumValue(df)

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

    @test result == Dict(:pain => "not_or_low")

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

    @test result == Dict(:pain => "moderate")

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

    @test result == Dict(:pain => "high")

end
