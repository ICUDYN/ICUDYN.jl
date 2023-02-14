include("../../../runtests-prerequisite.jl")

@testset "Test Ventilation.computeVentilationTypeAndDebitO2" begin

    df = DataFrame(
        terseForm = [
            1,
            "airvo2",
            "VAC",
            "VS-AI",
            "AA",
            "4 l/min",
            "4 l/min"],
        attributeDictionaryPropName = [
            "case1",
            "PtAssessment_VentModeInt.VentModeList",
            "PtAssessment_VentModeInt.VentModeList",
            "PtAssessment_VentModeInt.VentModeList",
            "PtAssessment_O2DeliveryInt.Debit_O2",
            "PtAssessment_O2DeliveryInt.Debit_O2",
            "PtAssessment_O2DeliveryInt.Debit_O2"]
        )
    result = ETL.Ventilation.computeVentilationTypeAndDebitO2(df)

    @test result == Dict(
        :debitO2 => 4,
        :criticalVentilType => "invasive",
        :nonCriticalVentilType => "spontaneous_ventilation"
    )

    #TODO Bapt : do more tests

end
