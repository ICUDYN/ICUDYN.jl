"""
     computeGender(window::DataFrame)

Computes the gender of the patient
"""
function ETL.Physiological.computeGender(window::DataFrame)
    res = window |>
    n -> ICUDYNUtil.getNonMissingValues(
        n, 
        :attributeDictionaryPropName,
        "ptDemographic_Demographic90Int.Sexe", 
        :terseForm ) |>
    n -> if isempty(n) return missing else n end |>
    (string ∘ first) |>
    n-> if n == "1"
        return "male"
    elseif n == "2"
        return "female"
    else  
        @error "Unknown gender code[$n]"
        return ICUDYNUtil.getValueOfError()
    end 
end


"""
    computeAge(window::DataFrame)

Computes the age of the patient
"""
function ETL.Physiological.computeAge(window::DataFrame)
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window, 
        "ptDemographic_patientAgeInt.ageValue", 
        n-> first(n))
end



"""
    computeHeight(window::DataFrame)

Computes the height of the patient
"""
function ETL.Physiological.computeHeight(window::DataFrame)
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(window, "ptDemographic_PtHeight.height", n->round(Int,mean(n)))
end


# """
#     computeWeight(window::DataFrame)

# Computes the weight of the patient
# """
function ETL.Physiological.computeWeight(window::DataFrame)
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(window, "PtAssessment_ptWeightIntervention.ptWeight", n->round(Int,mean(n)))
end


# """
#     computeHeartRateVars(window::DataFrame)

# Computes the heart rate of the patient
# """
function ETL.Physiological.computeHeartRateVars(window::DataFrame)
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(
                window,
                "PtAssessment_heartRateInt.heartRate",
                n->round.([minimum(n), maximum(n),mean(n), median(n)], digits = 2))
end


# """
#     computeUrineVolume(window::DataFrame)

# Computes the urine volume of the patient
# """
function ETL.Physiological.computeUrineVolume(window::DataFrame)
    
    res = window |>
    n -> getNonMissingValues(n,:attributeDictionaryPropName,
    "PtSiteCare_urineOuputInt.outputVolume", :verboseForm) |>
    n -> if isempty(n) return missing else n end

    if res === missing
        return res
    else
        res = replace.(res, "ml"=>"")
        res = parse.(Int,res)
        return round(mean(res),digits=2)
    end

end


# """
#     computeArterialBp(window::DataFrame)

# Computes the arterial parameters of the patient (diasolic, systolic and mean value)
# """
function ETL.Physiological.computeArterialBp(window::DataFrame)
    bpMean = ICUDYNUtil.getNumericValueFromWindowTerseForm(window,"PtAssessment_arterialBPInt.mean", n->round(mean(n),digits=1))
    bpDiastolic = ICUDYNUtil.getNumericValueFromWindowTerseForm(window,"PtAssessment_arterialBPInt.diastolic", n->round(mean(n),digits=1))
    bpSystolic = ICUDYNUtil.getNumericValueFromWindowTerseForm(window,"PtAssessment_arterialBPInt.systolic", n->round(mean(n),digits=1))

    return Dict(
        :bpMean => bpMean,
        :bpDiastolic => bpDiastolic,
        :bpSystolic => bpSystolic
        )
end


# """
#     computeTemperature(window::DataFrame)

# Computes the temperature of the patient
# """
function ETL.Physiological.computeTemperature(window::DataFrame)
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(window,"PtAssessment_temperatureInt.temperature", n->round(mean(n),digits=1))
end


# """
#     computeNeuroGlasgow(window::DataFrame, any_sedative::Bool=false)

# Computes the Glasgow score of the patient
# """
function ETL.Physiological.computeNeuroGlasgow(window::DataFrame, any_sedative::Bool)

    if any_sedative
        return 16
    else
        return ICUDYNUtil.getNumericValueFromWindowTerseForm(window,"PtAssessment_GCSInt.GCSNum", n->round(Int,mean(n)))
    end
end



# """
#     computeNeuroRamsay(window::DataFrame, sedative_isoflurane, target_score, any_sedative::Bool=false)

# Computes the Ramsay score of the patient
# """
function ETL.Physiological.computeNeuroRamsay(window::DataFrame, sedative_isoflurane, target_score, any_sedative)

#TODO Bapt : Code R pas fini ? Fonction a discuter
    error("Implementation of this method not finished")

    res = ICUDYNUtil.getNumericValueFromWindowTerseForm(window,"PtAssessment_GCSInt.GCSNum", n->round(Int,mean(n)))

    #code R :
    # NOTE: imposseible d'avoir la valeur cible
  # if (is.nan(neuro_ramsay)) {
  #   neuro_ramsay <- CONFIG$missing_value
  # } else {
  #
  #   if (!is.na(sedative_isoflurane) && sedative_isoflurane > 0) {
  #
  #     if (neuro_ramsay >= 5) {
  #       neuro_ramsay_normal = T
  #     } else {
  #       neuro_ramsay_normal = F
  #     }
  #
  #   } else if (isTRUE(any_sedative)) {
  #     if (neuro_ramsay >= target_score) {
  #       neuro_ramsay_normal = T
  #     } else {
  #       neuro_ramsay_normal = F
  #     }
  #   }
  #
  # }

    return res
end



# """
#     computeDouleurNumValue(window::DataFrame)

# Computes the pain of the patient from numeric value
# """
function ETL.Physiological._computeDouleurNumValue(window::DataFrame)
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(window,"PtAssessment_Evaluation_douleur.EV_num", n->round(Int,mean(n)))
end



# """
#     computeDouleurStringValue(window::DataFrame)

# Computes the pain of the patient from string value
# """
function ETL.Physiological._computeDouleurStringValue(window::DataFrame)
    "PtAssessment_Evaluation_douleur.EV_analogique"

    res = window |>
    n -> ICUDYNUtil.getNonMissingValues(n, :attributeDictionaryPropName,
            "PtAssessment_Evaluation_douleur.EV_analogique", :verboseForm) |>
    n -> if isempty(n) return missing else n end |>
    n -> rmAccentsAndLowercaseAndStrip.(n) |> ICUDYNUtil.getMostFrequentValue

    return res

end


# """
#     computeDouleurBpsNumValue(window::DataFrame)

# Computes the pain of the patient from Bps value
# """
function ETL.Physiological._computeDouleurBpsNumValue(window::DataFrame)
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(window,"PtAssessment_Echelle_comportementale_douleur.Total_BPS", n->round(Int,mean(n)))
end



# """
#     computePain(window::DataFrame)

# Computes the pain of the patient
# """
function ETL.Physiological.computePain(window::DataFrame)
    douleurNumValue = ETL.Physiological._computeDouleurNumValue(window)
    douleurStringValue = ETL.Physiological._computeDouleurStringValue(window)
    douleurBpsNumValue = ETL.Physiological._computeDouleurBpsNumValue(window)

    if douleurNumValue !== missing
        println("numeric")
        if douleurNumValue <= 3
            return "not_or_low"
        elseif douleurNumValue <= 7
            return "moderate"
        elseif douleurNumValue > 7
            return "high"
        # else
        #     #do error ?
        end
    end

    if douleurStringValue !== missing
        println("string")

        if occursin("aucune", douleurStringValue) || occursin("faible", douleurStringValue)
            return "not_or_low"
        elseif occursin("moderee", douleurStringValue)
            return "moderate"
        else
            return "high"
        end
    end


    if douleurBpsNumValue !== missing
        println("bps")

        if douleurBpsNumValue <= 6
            return "not_or_low"
        elseif douleurBpsNumValue <= 9
            return "moderate"
        elseif douleurBpsNumValue > 9
            return "high"
        # else
        #     #do error ?
        end
    end

    return missing
end
