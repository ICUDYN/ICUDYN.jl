function ETL.Ventilation.computePao2OverFio2(window::DataFrame)

    pao2OverFio2 = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_paO2FiO2ratioint.paO2FiO2ratiocalc",
        n -> round(mean(n), digits=2))

    # Hypoxemia
    hypoxemiaStatus = missing
    if pao2OverFio2 !== missing
        if pao2OverFio2 < 100 hypoxemiaStatus = "severe"
        elseif 100 <= pao2OverFio2 && pao2OverFio2 < 200 hypoxemiaStatus = "moderate"
        elseif 200 <= pao2OverFio2 && pao2OverFio2 < 300 hypoxemiaStatus = "light"
        elseif 300 <= pao2OverFio2 hypoxemiaStatus = "normal"
        end
    end

    return RefiningFunctionResult(
        :pao2OverFio2 => pao2OverFio2,
        :hypoxemiaStatus => hypoxemiaStatus
    )
end
