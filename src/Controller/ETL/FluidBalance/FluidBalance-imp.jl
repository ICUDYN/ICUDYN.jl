function ETL.FluidBalance.computeVolumeInOut(window::DataFrame)
    in = ICUDYNUtil.getNumericValueFromWindowTerseForm(
                        window,
                        "PtTotalBalance_Total apports (24h)",
                        n->round(sum(n),digits=1))
    out = ICUDYNUtil.getNumericValueFromWindowTerseForm(
                        window,
                        "PtTotalBalance_Total pertes (24h)",
                        n->round(sum(n),digits=1))
    return RefiningFunctionResult(
        :volumeIn => in,
        :volumeOut => out
        )
end


function ETL.FluidBalance.computeVolumePerfusion(window::DataFrame)
    res =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtTotalBalance_Perfusion IV, 24h",
        n->round(sum(n), digits=1))
    return RefiningFunctionResult(:volumePerfusion => res)
end


function ETL.FluidBalance.computeVolumeAndTypeVascularFilling(window::DataFrame)
    volume =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtIntake_colloidsInt.intakeVolume",
        n->round(sum(n),digits=1))

    type = window |> 
        n -> ICUDYNUtil.getNonMissingValues(
            n,
            :attributeDictionaryPropName,
            "PtIntake_colloidsInt.intakeVolume",
            :interventionLongLabel) |>
        n-> if isempty(n) return missing else n end |>
        n -> split.(n, r"\s") |>
        # Return the second element (eg. 'PtIntake_IV NaCl 0.9% (500 ml)' -> 'NaCl')
        n -> getindex.(n,2) |>
        n -> unique(n) |>
        n -> sort(n) |>
        n -> join(n, ", ")

    return RefiningFunctionResult(
        :vascularFillingVolumeIn => volume,
        :vascularFillingType => type
        )
end


function ETL.FluidBalance.computeVolumeMedecine(window::DataFrame)
    res =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtTotalBalance_Médicaments, PSE et analgésie, 24h",
        n->round(sum(n),digits=1))

    return RefiningFunctionResult(:volumeMedecine => res)
end


function ETL.FluidBalance.computeVolumeEnteralFeeding(window::DataFrame)
    res =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtTotalBalance_Apports entéraux, 24h",
        n->round(sum(n),digits=1))

    return RefiningFunctionResult(:volumeEnteralFeeding => res)
end


function ETL.FluidBalance.computeVolumeParentalFeeding(window::DataFrame)
    res = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window, 
        "PtIntake_tpnInt.intakeVolume", 
        n->round(sum(n),digits=1))

    return RefiningFunctionResult(:volumeParentalFeeding => res)
end
