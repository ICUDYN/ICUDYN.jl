include("../../../runtests-prerequisite.jl")

@testset "Test Ventilation.computeVentilationTypeAndDebitO2" begin

    # Test without unplug
    df = DataFrame(
        terseForm = [
            1,
            "airvo2",
            "VAC",
            "VS-AI",
            "AA",
            "2 l/min",
            "6 l/min"],
        attributeDictionaryPropName = [
            "case1",
            "PtAssessment_VentModeInt.VentModeList",
            "PtAssessment_VentModeInt.VentModeList",
            "PtAssessment_VentModeInt.VentModeList",
            "PtAssessment_O2DeliveryInt.Debit_O2",
            "PtAssessment_O2DeliveryInt.Debit_O2",
            "PtAssessment_O2DeliveryInt.Debit_O2"]
        )
    result = ETL.Ventilation.computeVentilationTypeAndDebitO2(
        df,
        true # unplugAttempt
    )

    @test result == Dict(
        :debitO2 => 4,
        :ventilType => "invasive,OHD,O2",
        :ventilCritical => true,
        :ventilInvasive => true
    )

    #TODO Bapt : do more tests

    # Test with unplug
    df = DataFrame(
        terseForm = [
            1,
            "airvo2",
            "AA",
            "2 l/min",
            "6 l/min"],
        attributeDictionaryPropName = [
            "case1",
            "PtAssessment_VentModeInt.VentModeList",
            "PtAssessment_O2DeliveryInt.Debit_O2",
            "PtAssessment_O2DeliveryInt.Debit_O2",
            "PtAssessment_O2DeliveryInt.Debit_O2"]
        )
    result = ETL.Ventilation.computeVentilationTypeAndDebitO2(
        df,
        true # unplugAttempt
    )

    @test result == Dict(
        :debitO2 => 4,
        :ventilType => "invasive,OHD,O2",
        :ventilCritical => true,
        :ventilInvasive => true
    )

    # Test without unplug and no critical ventilation
    df = DataFrame(
        terseForm = [
            1,
            "airvo2",
            "AA",
            "2 l/min",
            "6 l/min"],
        attributeDictionaryPropName = [
            "case1",
            "PtAssessment_VentModeInt.VentModeList",
            "PtAssessment_O2DeliveryInt.Debit_O2",
            "PtAssessment_O2DeliveryInt.Debit_O2",
            "PtAssessment_O2DeliveryInt.Debit_O2"]
        )
    result = ETL.Ventilation.computeVentilationTypeAndDebitO2(
        df,
        false # unplugAttempt
    )

    @test result == Dict(
        :debitO2 => 4,
        :ventilType => "OHD,O2",
        :ventilCritical => true,
        :ventilInvasive => false
    )


end
