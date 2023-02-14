include("../../../runtests-prerequisite.jl")

@testset "Test ETL.compute_respiratoryRate_FiO2_SPO2_WSO2trunc" begin

    df = DataFrame(
        terseForm = [
            1,
            "111",
            112,
            112],
        attributeDictionaryPropName = [
            "case1",
            "PtAssessment_SpO2Int.SpO2msmt",
            "PtAssessment_SpO2Int.SpO2msmt",
            "PtAssessment_SpO2Int.SpO2msmt",]
        )
    result = ETL.Ventilation.compute_respiratoryRate_FiO2_SPO2_WSO2trunc(df)

    @test result[:SPO2] == 112

end
