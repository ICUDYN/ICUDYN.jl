function ETL.FluidBalance.computeVolumeInOut(window::DataFrame)
    in = ICUDYNUtil.getTerseFormFromWindow(
                        window,
                        "PtTotalBalance_Total apports (24h)",
                        n->round(sum(n),digits=1))
    out = ICUDYNUtil.getTerseFormFromWindow(
                        window,
                        "PtTotalBalance_Total pertes (24h)",
                        n->round(sum(n),digits=1))
    return Dict(
        :volume_in => in,
        :volume_out => out
        )
end


function ETL.FluidBalance.computeVolumePerfusion(window::DataFrame)
    return ICUDYNUtil.getTerseFormFromWindow(
        window,
        "PtTotalBalance_Perfusion IV, 24h",
        n->round(sum(n), digits=1))
end


function ETL.FluidBalance.computeVolumeAndTypeVascularFilling(window::DataFrame)
    volume =  ICUDYNUtil.getTerseFormFromWindow(
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

    return Dict(
        :vascular_filling_volume_in => in,
        :vascular_filling_type => type
        )
end


function ETL.FluidBalance.computeVolumeMedecine(window::DataFrame)
    return ICUDYNUtil.getTerseFormFromWindow(window, "PtTotalBalance_Médicaments, PSE et analgésie, 24h", n->round(sum(n),digits=1))
end


function ETL.FluidBalance.computeVolumeEnteralFeeding(window::DataFrame)
    return ICUDYNUtil.getTerseFormFromWindow(window, "PtTotalBalance_Apports entéraux, 24h", n->round(sum(n),digits=1))
end


function ETL.FluidBalance.computeVolumeParentalFeeding(window::DataFrame)
    return ICUDYNUtil.getTerseFormFromWindow(window, "PtIntake_tpnInt.intakeVolume", n->round(sum(n),digits=1))
end
