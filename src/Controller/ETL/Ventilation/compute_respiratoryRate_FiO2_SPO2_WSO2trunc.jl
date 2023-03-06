function ETL.Ventilation.compute_respiratoryRate_FiO2_SPO2_WSO2trunc(window::DataFrame)

    # respiratoryRate
    respiratoryRate = ICUDYNUtil.getNumericValueFromWindowTerseForm(
            window,
            "PtAssessment_Frequence_respiratoire_par_min.mesuree") |>
            n -> ICUDYNUtil.computeStatisticsFromVector(n)

    print("respiratoryRate : ",respiratoryRate)

    # FiO2
    FiO2 = missing
    # if critical (uniquement si ventilation critique, commented out by vincent on 2023-02-10)
    FiO2 =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_Fraction_en_oxygene_FiO2.mesure",
        n -> round(mean(n), digits=2))
    # end

    # SPO2
    SPO2 = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_SpO2Int.SpO2msmt",
        n -> round(mean(n))
    )

    # EWSO2trunc
    EWSO2trunc = missing
    if !any(ismissing.([respiratoryRate[:mean],SPO2,FiO2]))
        EWSO2trunc = respiratoryRate[:mean]/(SPO2/FiO2) |> n -> round(mean(n), digits = 2)
    end

    return RefiningFunctionResult(
        :respiratoryRate => respiratoryRate[:mean],
        :FiO2 => FiO2,
        :SPO2 => SPO2,
        :EWSO2trunc => EWSO2trunc
    )

end
