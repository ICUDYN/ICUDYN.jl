function ETL.Ventilation.computeUnplugAttemptInvasiveVentilation(window::DataFrame, invasive::Bool)

    unplugAttemptInvasiveVentilation = missing
    unplugAttemptInvasiveVentilationDuration = missing

    # Unplug attempt only makes sense in the context of invasive ventilation type
    if invasive

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
        n -> filter(x -> contains(x,"Fin VS/tube"),n) |> !isempty

        unplugAttemptInvasiveVentilation =
            unplugAttemptInvasiveVentilationFromVentMode ||
            unplugAttemptInvasiveVentilationFromSeances

        unplugAttemptInvasiveVentilationDuration = ICUDYNUtil.getNumericValueFromWindowTerseForm(
            window,
            "PtAssessment_Calcul_seances_VS_sur_tube.Duree",
            maximum)

    end



    return RefiningFunctionResult(
        :unplugAttemptInvasiveVentilation => unplugAttemptInvasiveVentilation,
        :unplugAttemptInvasiveVentilationDuration => unplugAttemptInvasiveVentilationDuration
    )

end
