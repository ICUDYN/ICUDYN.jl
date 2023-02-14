function ETL.Ventilation.computeRespiratoryVolumeMinute(window::DataFrame, critical::Bool, ohd::Bool)

    res = missing

    # Calculer Volume si ventilation non critique et type de ventilation != OHD
    if !(critical || ohd)

        res = ICUDYNUtil.getNumericValueFromWindowTerseForm(
            window,
            "PtAssessment_Volume_minute_lmin.mesure",
            n -> round(mean(n), digits=2))
    end

    return RefiningFunctionResult(:respiratoryVolumeMinute => res)
end
