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
    
    return RefiningFunctionResult(:gender => res)
    
end


"""
    computeAge(window::DataFrame)

Computes the age of the patient
"""
function ETL.Physiological.computeAge(window::DataFrame)
    res =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window, 
        "ptDemographic_patientAgeInt.ageValue", 
        n-> first(n))

    return RefiningFunctionResult(:age => res)
end



"""
    computeHeight(window::DataFrame)

Computes the height of the patient
"""
function ETL.Physiological.computeHeight(window::DataFrame)
    res =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "ptDemographic_PtHeight.height",
        n->round(Int,mean(n)))

    return RefiningFunctionResult(:height => res)
end


# """
#     computeWeight(window::DataFrame)

# Computes the weight of the patient
# """
function ETL.Physiological.computeWeight(window::DataFrame)
    res = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window, 
        "PtAssessment_ptWeightIntervention.ptWeight", 
        n->round(Int,mean(n)))

    return RefiningFunctionResult(:weight => res)
end


# """
#     computeHeartRateVars(window::DataFrame)

# Computes the heart rate of the patient
# """
function ETL.Physiological.computeHeartRateVars(window::DataFrame)
    
    min,max,_mean,_median = window |>
        n -> ICUDYNUtil.getNumericValueFromWindowTerseForm(
            n,
            "PtAssessment_heartRateInt.heartRate",
            x -> round.([minimum(x), maximum(x),mean(x), median(x)], digits = 2)) |>
        # Force the number of result to four
        n -> if ismissing(n)
                [missing, missing, missing, missing]
             else
                n
             end |>
        n -> tuple(n...)
    

    Dict(
        :heartRateMin => min,
        :heartRateMax => max,
        :heartRateMean => _mean,
        :heartRateMedian => _median
    )
    
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

    if res !== missing
        res = replace.(res, "ml"=>"")
        res = parse.(Int,res)
        res = round(mean(res),digits=2)
    end

    return RefiningFunctionResult(:urineVolume => res)
end


# """
#     computeArterialBp(window::DataFrame)

# Computes the arterial parameters of the patient (diasolic, systolic and mean value)
# """
function ETL.Physiological.computeArterialBp(window::DataFrame)
    bpMean = ICUDYNUtil.getNumericValueFromWindowTerseForm(window,"PtAssessment_arterialBPInt.mean", n->round(mean(n),digits=1))
    bpDiastolic = ICUDYNUtil.getNumericValueFromWindowTerseForm(window,"PtAssessment_arterialBPInt.diastolic", n->round(mean(n),digits=1))
    bpSystolic = ICUDYNUtil.getNumericValueFromWindowTerseForm(window,"PtAssessment_arterialBPInt.systolic", n->round(mean(n),digits=1))

    return RefiningFunctionResult(
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
    res =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_temperatureInt.temperature",
        n->round(mean(n),digits=1))

    return RefiningFunctionResult(:temperature => res)
end


# """
#     computeNeuroGlasgow(window::DataFrame, any_sedative::Bool=false)

# Computes the Glasgow score of the patient
# """
function ETL.Physiological.computeNeuroGlasgow(window::DataFrame, anySedative::Bool)


    if anySedative
        res = 16
    else
        res = ICUDYNUtil.getNumericValueFromWindowTerseForm(window,"PtAssessment_GCSInt.GCSNum", n->round(Int,mean(n)))
    end

    return RefiningFunctionResult(:neuroGlasgow => res)
end



# """
#     computeNeuroRamsay(window::DataFrame,
#       sedative_isoflurane,
#       target_score,
#       any_sedative::Bool=false)

# Computes the Ramsay score of the patient
# """
function ETL.Physiological.computeNeuroRamsay(
    window::DataFrame,
    sedativeIsoflurane,
    targetScore,
    anySedative)

#TODO Bapt : Code R pas fini ? Fonction a discuter
    error("Implementation of this method not finished")

    res = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_GCSInt.GCSNum",
        n->round(Int,mean(n)))

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

    return RefiningFunctionResult(:neuroRamsay => res)
end



# """
#     computeDouleurNumValue(window::DataFrame)

# Computes the pain of the patient from numeric value
# """
function ETL.Physiological._computeDouleurNumValue(window::DataFrame)
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_Evaluation_douleur.EV_num",
        n->round(Int,mean(n)))
end



# """
#     computeDouleurStringValue(window::DataFrame)

# Computes the pain of the patient from string value
# """
function ETL.Physiological._computeDouleurStringValue(window::DataFrame)

    return window |>
        n -> ICUDYNUtil.getNonMissingValues(
            n,
            :attributeDictionaryPropName,
            "PtAssessment_Evaluation_douleur.EV_analogique",
            :verboseForm) |>
        n -> if isempty(n) return missing else n end |>
        n -> rmAccentsAndLowercaseAndStrip.(n) |> 
        ICUDYNUtil.getMostFrequentValue

end


# """
#     computeDouleurBpsNumValue(window::DataFrame)

# Computes the pain of the patient from Bps value
# """
function ETL.Physiological._computeDouleurBpsNumValue(window::DataFrame)
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_Echelle_comportementale_douleur.Total_BPS", 
        n -> round(Int,mean(n)))
end



# """
#     computePain(window::DataFrame)

# Computes the pain of the patient
# """
function ETL.Physiological.computePain(window::DataFrame)
    douleurNumValue = ETL.Physiological._computeDouleurNumValue(window)
    douleurStringValue = ETL.Physiological._computeDouleurStringValue(window)
    douleurBpsNumValue = ETL.Physiological._computeDouleurBpsNumValue(window)

    res = missing
    if douleurNumValue !== missing
        if douleurNumValue <= 3
            res = "not_or_low"
        elseif douleurNumValue <= 7
            res = "moderate"
        elseif douleurNumValue > 7
            res = "high"
        # else
        #     #do error ?
        end
    elseif douleurStringValue !== missing
        if occursin("aucune", douleurStringValue) || occursin("faible", douleurStringValue)
            res = "not_or_low"
        elseif occursin("moderee", douleurStringValue)
            res = "moderate"
        else
            res = "high"
        end
    elseif douleurBpsNumValue !== missing
        if douleurBpsNumValue <= 6
            res = "not_or_low"
        elseif douleurBpsNumValue <= 9
            res = "moderate"
        elseif douleurBpsNumValue > 9
            res = "high"
        # else
        #     #do error ?
        end
    end

    return RefiningFunctionResult(:pain => res)
end
