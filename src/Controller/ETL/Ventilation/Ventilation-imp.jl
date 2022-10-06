

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


function ETL.Ventilation.computeUnplugAttemptInvasiveVentilation(window::DataFrame, invasive::Bool) 

    unplugAttemptInvasiveVentilation = missing
    unplugAttemptInvasiveVentilationDuration = missing

    # Unplug attempt only makes sense in the context of invasive ventilation type 
    if invasive
    
        unplugAttemptInvasiveVentilationFromVentMode = window |>
        n -> ICUDYNUtil.getNonMissingValues(
            n, 
            :attributeDictionaryPropName,
            "PtAssessment_VentModeInt.VentModeList", 
            :terseForm ) |>
        n -> filter(x -> contains(x,"Epreuve"),n) |> !isempty

        unplugAttemptInvasiveVentilationFromSeances = window |>
        n -> ICUDYNUtil.getNonMissingValues(
            n, 
            :attributeDictionaryPropName,
            "PtAssessment_Calcul_seances_VS_sur_tube.Etat", 
            :terseForm ) |>
        n -> filter(x -> contains(x,"Fin VS/tube"),n) |> !isempty 
        
        unplugAttemptInvasiveVentilation = 
            unplugAttemptInvasiveVentilationFromVentMode || 
            unplugAttemptInvasiveVentilationFromSeances
        
        unplugAttemptInvasiveVentilationDuration = ICUDYNUtil.getNumericValueFromWindowTerseForm(
            window,
            "PtAssessment_Calcul_seances_VS_sur_tube.Duree",
            maximum)

    end

    
    
    return RefiningFunctionResult(
        :unplugAttemptInvasiveVentilation => unplugAttemptInvasiveVentilation,
        :unplugAttemptInvasiveVentilationDuration => unplugAttemptInvasiveVentilationDuration
    )
    
end

function ETL.Ventilation.computeRespiratoryVolumeMinute(window::DataFrame)  
    res = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_Volume_minute_lmin.mesure",
        n -> round(mean(n), digits=2))
    
    return RefiningFunctionResult(:respiratoryVolumeMinute => res)
end


function ETL.Ventilation.computeRespiratoryRate(window::DataFrame) 
    res =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
            window,
            "PtAssessment_Frequence_respiratoire_par_min.mesuree",
            n -> round(mean(n), digits=2))

    return RefiningFunctionResult(:respiratoryRate => res)
end


function ETL.Ventilation.computeFio2(window::DataFrame, critical::Bool) 
    
    res = missing

    #Calculer FiO2 uniquement si ventilation critique
    if critical
    
        res =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
                window,
                "PtAssessment_Fraction_en_oxygene_FiO2.mesure",
                n -> round(mean(n), digits=2))
    
    end
    return RefiningFunctionResult(:fiO2 => res)
    
end


function ETL.Ventilation.computePao2OverFio2(window::DataFrame) 

    pao2OverFio2 = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_paO2FiO2ratioint.paO2FiO2ratiocalc",
        n -> round(mean(n), digits=2))

    # Hypoxemia
    hypoxemiaStatus = missing
    if pao2OverFio2 !== missing
        if pao2OverFio2 < 100 hypoxemiaStatus = "severe"
        elseif 100 <= pao2OverFio2 && pao2OverFio2 < 200 hypoxemiaStatus = "moderate"
        elseif 200 <= pao2OverFio2 && pao2OverFio2 < 300 hypoxemiaStatus = "light"
        elseif 300 <= pao2OverFio2 hypoxemiaStatus = "normal" 
        end
    end

    return RefiningFunctionResult(
        :pao2OverFio2 => pao2OverFio2,
        :hypoxemiaStatus => hypoxemiaStatus
    )
end

function ETL.Ventilation.computePositiveExpiratoryPressure(window::DataFrame, ohd::Bool)
     
    res = missing

    # On ne renseigne pas la PEP si patient sous OHD
    if !OHD
    
        res =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
                window,
                "PtAssessment_Pression_positive_PEP_cmH2O.mesure",
                n -> round(mean(n), digits=2))

    end

    return RefiningFunctionResult(:positiveExpiratoryPressure => res)
end