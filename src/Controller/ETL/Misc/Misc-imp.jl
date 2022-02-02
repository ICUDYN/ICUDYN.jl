using .Controller.ETL

function ETL.Misc.computeStartTime(window::DataFrame)
    res = minimum(window.chartTime)

    return RefiningFunctionResult(:startTime => res)
end

function ETL.Misc.computeEndTime(window::DataFrame)
    res = maximum(window.chartTime)

    return RefiningFunctionResult(:endTime => res)
end


"""
    computeDischargeDisposition(window::DataFrame)

Computes the discharge disposition of the patient
"""
function ETL.Misc.computeDischargeDisposition(window::DataFrame)
    res = window |>
        n -> getNonMissingValues(n, :attributeDictionaryPropName,
                "V_Census_dischargeDisposition", :terseForm) |>
        n -> if isempty(n) missing else first(n) end

    return RefiningFunctionResult(:dischargeDisposition => res)

end
