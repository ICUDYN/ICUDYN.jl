include("../../../runtests-prerequisite.jl")

@testset "Test Ventilation.computeUnplugAttemptInvasiveVentilation" begin

    df = DataFrame(
        terseForm = [
            1,
            "toto",
            "Epreuve",
            "tata",
            "titi",
            "Debut VS/tube",
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
