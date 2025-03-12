include("../../../runtests-prerequisite.jl")

@testset "Test ETL.compute_respiratoryRate_FiO2_SPO2_WSO2trunc" begin

    df = DataFrame(
        terseForm = [
            1,
            10.0,
            12.0,
            20.0,
            50,
            "111",
            112,
            112],
        attributeDictionaryPropName = [
            "case1",
            "PtAssessment_Frequence_respiratoire_par_min.mesuree",
            "PtAssessment_Frequence_respiratoire_par_min.mesuree",
            "PtAssessment_Frequence_respiratoire_par_min.mesuree",
            "PtAssessment_Fraction_en_oxygene_FiO2.mesure",
            "PtAssessment_SpO2Int.SpO2msmt",
            "PtAssessment_SpO2Int.SpO2msmt",
            "PtAssessment_SpO2Int.SpO2msmt",]
        )
    result = ETL.Ventilation.compute_respiratoryRate_FiO2_SPO2_WSO2trunc(df)

    dictStat=Dict(
        :min=>10.0,
        :max=>20.0,
        :mean=>14.0,
        :median=>12.0,
        :stdev=>5.29
    )

    targetDict = Dict(
        :SPO2=>112,
        :FiO2=>50,
        :EWSO2trunc=>6.25,
        :respiratoryRate=>dictStat
    )

    @test isequal(result, targetDict)

end
