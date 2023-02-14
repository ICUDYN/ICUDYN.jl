include("../../../runtests-prerequisite.jl")

@testset "Test Ventilation.computePao2OverFio2" begin

    df = DataFrame(
        terseForm = [
            1,
            "111",
            112,
            112],
        attributeDictionaryPropName = [
            "case1",
            "PtAssessment_paO2FiO2ratioint.paO2FiO2ratiocalc",
            "PtAssessment_paO2FiO2ratioint.paO2FiO2ratiocalc",
            "PtAssessment_paO2FiO2ratioint.paO2FiO2ratiocalc",]
        )
    result = ETL.Ventilation.computePao2OverFio2(df)

    @test result == Dict(
        :pao2OverFio2 => 111.67,
        :hypoxemiaStatus => "moderate",
    )

end
