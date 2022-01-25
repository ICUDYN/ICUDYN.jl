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