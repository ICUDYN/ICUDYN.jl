@testset "Test Ventilation.computePositiveExpiratoryPressure" begin

    df = DataFrame(
        terseForm = [
            1,
            "111",
            112,
            112],
        attributeDictionaryPropName = [
            "case1",
            "PtAssessment_Pression_positive_PEP_cmH2O.mesure",
            "PtAssessment_Pression_positive_PEP_cmH2O.mesure",
            "PtAssessment_Pression_positive_PEP_cmH2O.mesure",]
        )

    # Case not OHD
    result = ETL.Ventilation.computePositiveExpiratoryPressure(df, false)
    @test result == Dict(
        :positiveExpiratoryPressure => 111.67,
    )

    # Case OHD
    result = ETL.Ventilation.computePositiveExpiratoryPressure(df, true)
    @test result[:positiveExpiratoryPressure] === missing

end
