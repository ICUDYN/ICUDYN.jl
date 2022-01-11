using .Controller.ETL

function ETL.Misc.computeStartTime(window::DataFrame)
    return(minimum(window.chartTime))
end

function ETL.Misc.computeEndTime(window::DataFrame)
    return(maximum(window.chartTime))
end


"""
    computeDischargeDisposition(window::DataFrame)

Computes the discharge disposition of the patient
"""
function ETL.Misc.computeDischargeDisposition(window::DataFrame)

        
    res = window |>
        n -> filter(
            r -> (
                r.attributeDictionaryPropName == "V_Census_dischargeDisposition"
                && !passmissing(isMissing)(r.terseForm)
                ), 
            n) |> 
        n -> n.terseForm |>
        n -> if isempty(n) missing else first(n) end
             
    return res
    
end