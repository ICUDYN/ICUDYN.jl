using .Controller.ETL
using Statistics
using DataStructures


# """
#     computeGender(window::DataFrame)

# Computes the gender of the patient
# """
function ETL.Physiological.computeGender(window::DataFrame)
    res = window |> 
        n -> filter(
            r -> (
                r.attributeDictionaryPropName == "ptDemographic_Demographic90Int.Sexe"
                && !passmissing(isMissing)(r.terseForm)
                ), 
            n) |> 
        n -> n.terseForm |>
        n -> if isempty(n) return missing else (string ∘ first)(n) end |>
        n-> if n == "1" "male" elseif n=="2" "female" else error("Unknown gender code[$n]") end 
    
    return res
end


# """
#     computeAge(window::DataFrame)

# Computes the age of the patient
# """
function ETL.Physiological.computeAge(window::DataFrame)

    res = window |>
        n -> filter(
            r -> (
                r.attributeDictionaryPropName == "ptDemographic_patientAgeInt.ageValue"
                && !passmissing(isMissing)(r.terseForm)
                ), 
            n) |> 
        n -> n.terseForm |>
        n -> if isempty(n) missing else round(Int,mean(n)) end 
        #TODO Bapt : Vérifier qu'on veut bien faire la moyenne de l'age si plusieurs valeurs
        #Plus logique de prendre le dernier age ?
             
    return res
end



# """
#     computeHeight(window::DataFrame)

# Computes the height of the patient
# """
function ETL.Physiological.computeHeight(window::DataFrame)

    res = window |>
    n -> filter(
        r -> (
            r.attributeDictionaryPropName == "ptDemographic_PtHeight.height"
            && !passmissing(isMissing)(r.terseForm)
            ), 
        n) |> 
    n -> n.terseForm |>
    n -> if isempty(n) missing else round(Int, mean(n)) end 
    
         
return res

end


# """
#     computeWeight(window::DataFrame)

# Computes the weight of the patient
# """
function ETL.Physiological.computeWeight(window::DataFrame)

    res = window |>
    n -> filter(
        r -> (
            r.attributeDictionaryPropName == "PtAssessment_ptWeightIntervention.ptWeight"
            && !passmissing(isMissing)(r.terseForm)
            ), 
        n) |> 
    n -> n.terseForm |>
    n -> if isempty(n) missing else round(Int, mean(n)) end 
    
         
return res
end



# """
#     computeHeartRateVars(window::DataFrame)

# Computes the heart rate of the patient
# """
function ETL.Physiological.computeHeartRateVars(window::DataFrame)

    res = window |>
    n -> filter(
        r -> (
            r.attributeDictionaryPropName == "PtAssessment_heartRateInt.heartRate"
            && !passmissing(isMissing)(r.terseForm)
            ), 
        n) |> 
    n -> n.terseForm |>
    n -> if isempty(n) missing else round.([minimum(n), maximum(n),mean(n), median(n)], digits = 2) end 
          
    return res

end


# """
#     computeUrineVolume(window::DataFrame)

# Computes the urine volume of the patient
# """
function ETL.Physiological.computeUrineVolume(window::DataFrame)

    res = window |>
    n -> filter(
        r -> (
            r.attributeDictionaryPropName == "PtSiteCare_urineOuputInt.outputVolume"
            && !passmissing(isMissing)(r.verboseForm)
            ), 
        n) |> 
    n -> n.verboseForm

    if isempty(res) 
        return missing 
    else 
        res = replace.(res, " ml"=>"")
        res = parse.(Int,res)
        return round(mean(res),digits=2)
    end
    
        

end


# """
#     computeArterialBp(window::DataFrame)

# Computes the arterial parameters of the patient (diasolic, systolic and mean value)
# """
function ETL.Physiological.computeArterialBp(window::DataFrame)

    bp_mean = window |>
    n -> filter(
        r -> (
            r.attributeDictionaryPropName == "PtAssessment_arterialBPInt.mean"
            && !passmissing(isMissing)(r.terseForm)
            ), 
        n) |> 
    n -> n.terseForm |>
    n -> if isempty(n) missing else round(mean(n), digits = 1) end 

    bp_diastolic = window |>
    n -> filter(
        r -> (
            r.attributeDictionaryPropName == "PtAssessment_arterialBPInt.diastolic"
            && !passmissing(isMissing)(r.terseForm)
            ), 
        n) |> 
    n -> n.terseForm |>
    n -> if isempty(n) missing else round(mean(n), digits = 1) end 

    bp_systolic = window |>
    n -> filter(
        r -> (
            r.attributeDictionaryPropName == "PtAssessment_arterialBPInt.systolic"
            && !passmissing(isMissing)(r.terseForm)
            ), 
        n) |> 
    n -> n.terseForm |>
    n -> if isempty(n) missing else round(mean(n), digits = 1) end 


    return [bp_mean, bp_diastolic, bp_systolic]
    
end


# """
#     computeTemperature(window::DataFrame)

# Computes the temperature of the patient
# """
function ETL.Physiological.computeTemperature(window::DataFrame)
    
    res = window |>
    n -> filter(
        r -> (
            r.attributeDictionaryPropName == "PtAssessment_temperatureInt.temperature"
            && !passmissing(isMissing)(r.terseForm)
            ), 
        n) |> 
    n -> n.terseForm |>
    n -> if isempty(n) missing else round(mean(n),digits=1) end 
    
         
return res
end


# """
#     computeNeuroGlasgow(window::DataFrame, any_sedative::Bool=false)

# Computes the Glasgow score of the patient
# """
function ETL.Physiological.computeNeuroGlasgow(window::DataFrame, any_sedative::Bool=false)
    
    if any_sedative
        return 16
    else
        res = window |>
        n -> filter(
            r -> (
                r.attributeDictionaryPropName == "PtAssessment_GCSInt.GCSNum"
                && !passmissing(isMissing)(r.terseForm)
                ), 
            n) |> 
        n -> n.terseForm |>
        n -> if isempty(n) missing else round(Int,mean(n)) end 
        return res
    end

end



# """
#     computeNeuroRamsay(window::DataFrame, sedative_isoflurane, target_score, any_sedative::Bool=false)

# Computes the Ramsay score of the patient
# """
function ETL.Physiological.computeNeuroRamsay(window::DataFrame, sedative_isoflurane, target_score, any_sedative::Bool=false)

#TODO Bapt : Code R pas fini ? Fonction a discuter
    res = window |>
    n -> filter(
        r -> (
            r.attributeDictionaryPropName == "PtAssessment_GCSInt.GCSNum"
            && !passmissing(isMissing)(r.terseForm)
            ), 
        n) |> 
    n -> n.terseForm |>
    n -> if isempty(n) missing else round(Int,mean(n)) end 
    return res


end



# """
#     computeDouleurNumValue(window::DataFrame)

# Computes the pain of the patient from numeric value
# """
function ETL.Physiological.computeDouleurNumValue(window::DataFrame)

    res = window |>
    n -> filter(
        r -> (
            r.attributeDictionaryPropName == "PtAssessment_Evaluation_douleur.EV_num"
            && !passmissing(isMissing)(r.terseForm)
            ), 
        n) |> 
    n -> n.terseForm |>
    n -> if isempty(n) missing else round(Int,mean(n)) end 
    return res

end



# """
#     computeDouleurStringValue(window::DataFrame)

# Computes the pain of the patient from string value
# """
function ETL.Physiological.computeDouleurStringValue(window::DataFrame)
    "PtAssessment_Evaluation_douleur.EV_analogique"

    res = window |>
    n -> filter(
        r -> (
            r.attributeDictionaryPropName == "PtAssessment_Evaluation_douleur.EV_analogique"
            && !passmissing(isMissing)(r.verboseForm)
            ), 
        n) |> 
    n -> n.verboseForm |> 
    n -> if isempty(n) return missing else n end |>
    n -> counter(n) |>
    # n -> max(n, key=n.get())
    n -> collect(keys(n))[argmax(collect(values(n)))]

    #TODO Bapt : on fait quoi si 2 valeurs ont le même nombre d'occurences ? Pour l'instant prend la dernière occurence max apparaissant dans le dict
    return res
    

end


# """
#     computeDouleurBpsNumValue(window::DataFrame)

# Computes the pain of the patient from Bps value
# """
function ETL.Physiological.computeDouleurBpsNumValue(window::DataFrame)
    
    res = window |>
    n -> filter(
        r -> (
            r.attributeDictionaryPropName == "PtAssessment_Echelle_comportementale_douleur.Total_BPS"
            && !passmissing(isMissing)(r.terseForm)
            ), 
        n) |> 
    n -> n.terseForm |>
    n -> if isempty(n) missing else round(Int,mean(n)) end 
    return res

end



# """
#     computePain(window::DataFrame)

# Computes the pain of the patient
# """
function ETL.Physiological.computePain(window::DataFrame)
    douleurNumValue = ETL.Physiological.computeDouleurNumValue(window)
    douleurStringValue = ETL.Physiological.computeDouleurStringValue(window)
    douleurBpsNumValue = ETL.Physiological.computeDouleurBpsNumValue(window)

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
        elseif occursin("modérée", douleurStringValue)
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
