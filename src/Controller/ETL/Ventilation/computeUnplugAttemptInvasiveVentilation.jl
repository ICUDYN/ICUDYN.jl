function ETL.Ventilation.computeUnplugAttemptInvasiveVentilation(window::DataFrame)

    unplugAttemptInvasiveVentilation::Union{Missing,Bool} = missing
    unplugAttemptInvasiveVentilationDuration = missing

    unplugAttemptInvasiveVentilationDuration = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_Calcul_seances_VS_sur_tube.Duree",
        maximum)

    # We want to avoid the 0 value logged at unplug attempt beginning

    if unplugAttemptInvasiveVentilationDuration === 0
        unplugAttemptInvasiveVentilationDuration = missing
    end

    unplugAttemptInvasiveVentilationFromVentMode = window |>
        n -> ICUDYNUtil.getNonMissingValues(
            n,
            :attributeDictionaryPropName,
            "PtAssessment_VentModeInt.VentModeList",
            :terseForm ) |>
        n -> filter(x -> contains(x,"Epreuve"),n) |> !isempty

    unplugAttemptInvasiveVentilationFromSeances = window |>
        n -> ICUDYNUtil.getNonMissingValues(
            n,
            :attributeDictionaryPropName,
            "PtAssessment_Calcul_seances_VS_sur_tube.Etat",
            :terseForm ) |>
        n -> filter(x -> contains(x,r"Debut VS/tube|Fin VS/tube"),n) |> !isempty

    unplugAttemptInvasiveVentilation =
        unplugAttemptInvasiveVentilationFromVentMode ||
        unplugAttemptInvasiveVentilationFromSeances ||
        unplugAttemptInvasiveVentilationDuration

    return RefiningFunctionResult(
        :unplugAttemptInvasiveVentilation => unplugAttemptInvasiveVentilation,
        :unplugAttemptInvasiveVentilationDuration => unplugAttemptInvasiveVentilationDuration
    )

end
