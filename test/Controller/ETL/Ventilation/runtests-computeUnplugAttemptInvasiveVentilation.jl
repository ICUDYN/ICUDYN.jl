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
    result = ETL.Ventilation.computeUnplugAttemptInvasiveVentilation(df,true)

    @test result == Dict(
        :unplugAttemptInvasiveVentilation => true,
        :unplugAttemptInvasiveVentilationDuration => 20,
    )

end
