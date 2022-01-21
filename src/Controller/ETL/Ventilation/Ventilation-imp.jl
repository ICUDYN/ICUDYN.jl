

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
    else #TODO Bapt : pas sur qu'on ait besoin de ça, voir autres valeurs fichier excel comme "Epreuve"
        @error "Unknown ventilation type code[$n]"
        return ICUDYNUtil.getValueOfError()
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
    println(debitO2)

    nonCriticalVentilType = missing
    if debitO2 == "AA"
        nonCriticalVentilType = "ambiant_air"
        debitO2=0
    elseif !isnothing(match(r"\d+\.?\d*",debitO2))
        debitO2 = debitO2 |> n -> replace(n,"O2"=>"") |> strip |>  #TODO Bapt : pas de "02" sur terseForm mais sur verbose => utile ?
        n-> match(r"\d+\.?\d*",n).match |> n -> parse(Float64,n)
        
        println(debitO2)
        if (debitO2 >= 30 )
            criticalVentilType = "OHD"
        else
            nonCriticalVentilType = "spontaneous_ventilation"
        end
    end

    return Dict(
        :debitO2 => Int(debitO2),
        :criticalVentilType => criticalVentilType,
        :nonCriticalVentilType => nonCriticalVentilType
    )

end


function ETL.Ventilation.computeUnplugAttemptInvasiveVentilation
    # PtAssessment_VentModeInt.VentModeList
    # PtAssessment_Calcul_seances_VS_sur_tube.Etat
    # PtAssessment_Calcul_seances_VS_sur_tube.Duree

    unplugAttemptInvasiveVentilation = false
    unplugAttemptInvasiveVentilationDuration = missing # TODO Bapt : ou 0 ?

    unplugAttemptInvasiveVentilation = window |>
    n -> ICUDYNUtil.getNonMissingValues(
        n, 
        :attributeDictionaryPropName,
        "PtAssessment_VentModeInt.VentModeList", 
        :terseForm ) |>
    n -> filter(x -> contains(x,"Epreuve"),n) |> 
    if !isempty true end

    unplugAttemptInvasiveVentilation = window |>
    n -> ICUDYNUtil.getNonMissingValues(
        n, 
        :attributeDictionaryPropName,
        "PtAssessment_Calcul_seances_VS_sur_tube.Etat", 
        :terseForm ) |>
    n -> filter(x -> contains(x,"Fin VS/tube"),n) |> 
    if !isempty true end


    unplugAttemptInvasiveVentilationDuration = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_Calcul_seances_VS_sur_tube.Duree",
        maximum)

    return Dict(
        :unplugAttemptInvasiveVentilation => unplugAttemptInvasiveVentilationDuration,
        :unplugAttemptInvasiveVentilationDuration => unplugAttemptInvasiveVentilationDuration
    )

end

function ETL.Ventilation.computeRespiratoryVolumeMinute 
    # PtAssessment_Volume_minute_lmin.mesure
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_Volume_minute_lmin.mesure",
        n -> round(mean(n), digits=2))
end


function ETL.Ventilation.computeRespiratoryRate
    # PtAssessment_Frequence_respiratoire_par_min.mesuree
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(
            window,
            "PtAssessment_Frequence_respiratoire_par_min.mesuree",
            n -> round(mean(n), digits=2))
end


function ETL.Ventilation.computeFio2
    # PtAssessment_Fraction_en_oxygene_FiO2.mesure
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(
            window,
            "PtAssessment_Fraction_en_oxygene_FiO2.mesure",
            n -> round(mean(n), digits=2))
end


function ETL.Ventilation.computePao2OverFio2
    # PtAssessment_paO2FiO2ratioint.paO2FiO2ratiocalc

    pao2OverFio2 = ICUDYNUtil.getNumericValueFromWindowTerseForm(
        window,
        "PtAssessment_paO2FiO2ratioint.paO2FiO2ratiocalc",
        n -> round(mean(n), digits=2))

    # Hypoxemia
    hypoxemiaStatus = missing
    if pao2OverFio2 !== missing
        if pao2OverFio2 < 100 hypoxemia_status = "severe"
        elseif 100 <= pao2OverFio2 && pao2OverFio2 < 200 hypoxemiaStatus = "moderate"
        elseif 200 <= pao2OverFio2 && pao2OverFio2 < 300 hypoxemiaStatus = "light"
        elseif 300 <= pao2OverFio2 hypoxemiaStatus = "normal" 
        end
    end

    return Dict(
        :pao2OverFio2 => pao2OverFio2,
        :hypoxemiaStatus => hypoxemiaStatus
    )
end

function ETL.Ventilation.computePositiveExpiratoryPressure
    # PtAssessment_Pression_positive_PEP_cmH2O.mesure
    return ICUDYNUtil.getNumericValueFromWindowTerseForm(
            window,
            "PtAssessment_Pression_positive_PEP_cmH2O.mesure",
            n -> round(mean(n), digits=2))
end