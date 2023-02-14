function ETL.Ventilation.computePositiveExpiratoryPressure(window::DataFrame, ohd::Bool)

    res = missing

    # On ne renseigne pas la PEP si patient sous OHD
    if !ohd

        res =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
                window,
                "PtAssessment_Pression_positive_PEP_cmH2O.mesure",
                n -> round(mean(n), digits=2))

    end

    return RefiningFunctionResult(:positiveExpiratoryPressure => res)
end
