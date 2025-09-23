function ETL.Ventilation.computeRespiratoryRate(window::DataFrame)

    respiratoryRate = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_Frequence_respiratoire_par_min.mesuree") |>
        n -> ICUDYNUtil.computeStatisticsFromVector(n, "respiratoryRate", [ICUDYNUtil.Stats.all])

    return respiratoryRate
    
end