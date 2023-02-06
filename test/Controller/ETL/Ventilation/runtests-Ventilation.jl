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


@testset "Test Ventilation.computeUnplugAttemptInvasiveVentilation" begin

    df = DataFrame(
        terseForm = [
            1,
            "toto",
            "Epreuve",
            "tata",
            "titi",
            "Fin VS/tube",
            10,
            "20"],
        attributeDictionaryPropName = [
            "case1",
            "PtAssessment_VentModeInt.VentModeList",
            "PtAssessment_VentModeInt.VentModeList",
            "PtAssessment_VentModeInt.VentModeList",
            "PtAssessment_Calcul_seances_VS_sur_tube.Etat",
            "PtAssessment_Calcul_seances_VS_sur_tube.Etat",
            "PtAssessment_Calcul_seances_VS_sur_tube.Duree",
            "PtAssessment_Calcul_seances_VS_sur_tube.Duree"]
        )
    result = ETL.Ventilation.computeUnplugAttemptInvasiveVentilation(df)

    @test result == Dict(
        :unplugAttemptInvasiveVentilation => true,
        :unplugAttemptInvasiveVentilationDuration => 20,
    )

end



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


@testset "Test Ventilation.computeSPO2" begin

    df = DataFrame(
        terseForm = [
            1,
            "111",
            112,
            112],
        attributeDictionaryPropName = [
            "case1",
            "PtAssessment_SpO2msmt",
            "PtAssessment_SpO2msmt",
            "PtAssessment_SpO2msmt",]
        )
    result = ETL.Ventilation.computeSPO2(df)

    @test result == Dict(
        :SPO2 => 111.67
    )

end