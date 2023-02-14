function ETL.Ventilation.computeVentilationTypeAndDebitO2(window::DataFrame)

    debitO2 = criticalVentilType = nonCriticalVentilType = missing

    criticalVentilType = window |>
    n -> ICUDYNUtil.getNonMissingValues(
        n,
        :attributeDictionaryPropName,
        "PtAssessment_VentModeInt.VentModeList",
        :terseForm ) |>
    n -> if isempty(n) return missing else n end |>
    n-> if any(in(["VAC", "VS-AI", "VS AI"]).(n)) #TODO Bapt : in() or contains() ? check in excel file
        return "invasive"
    elseif any(in(["VNI-AI", "VNI AI"]).(n))
        return "non_invasive"
    elseif any(in(["optiflow", "airvo2"]).(n))
        return "OHD"
    else
        return missing
    end

     # NOTE: This means that the presence of debit O2 has precedence over the previous
    debitO2 = window |>
    n -> ICUDYNUtil.getNonMissingValues(
        n,
        :attributeDictionaryPropName,
        "PtAssessment_O2DeliveryInt.Debit_O2",
        :terseForm ) |>
    n -> if isempty(n) return missing else ICUDYNUtil.getMostFrequentValue(n) end
    # Use the most frequent value.
    # We don't use the mean because we don't want to mix with the values
    # from spontaneous ventilation (cf window 31 of BERGOT YVES)

    nonCriticalVentilType = missing

    if(debitO2 !== missing)
        if debitO2 == "AA"
            nonCriticalVentilType = "ambiant_air"
            debitO2=0
        elseif !isnothing(match(r"\d+\.?\d*",debitO2))
            debitO2 = debitO2 |>
            n-> match(r"\d+\.?\d*",n).match |> n -> parse(Float64,n)

            if (debitO2 >= 30 )
                criticalVentilType = "OHD"
            else
                nonCriticalVentilType = "spontaneous_ventilation"
            end
        end
    end

    return RefiningFunctionResult(
        :debitO2 => debitO2,
        :criticalVentilType => criticalVentilType,
        :nonCriticalVentilType => nonCriticalVentilType
    )

end
