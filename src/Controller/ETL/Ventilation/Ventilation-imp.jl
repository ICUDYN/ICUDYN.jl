

function ETL.Ventilation.computeVentilationTypeAndDebitO2(window::DataFrame)

    ventilTypeArray = Vector{String}()
    ventilTypeString = missing
    meanDebitO2 = missing
    ventilCritical = ventilInvasive = missing

    # get all O2 debits
    debitsO2 = window |>
    n -> ICUDYNUtil.getNonMissingValues(
        n,
        :attributeDictionaryPropName,
        "PtAssessment_O2DeliveryInt.Debit_O2",
        :terseForm ) |>
    n -> if isempty(n) return missing else n end

    # refine array to get corresponding float values
    if !ismissing(debitsO2)
        for i in eachindex(debitsO2)
            if occursin("AA",debitsO2[i])
                debitsO2[i] = missing #TODO : to discuss with the point below, would be "missing" and not 0 because it would affect the mean debit otherwise
            elseif !isnothing(match(r"\d+\.?\d*",debitsO2[i]))
                debitsO2[i] = debitsO2[i] |>
                n-> match(r"\d+\.?\d*",n).match |> n -> parse(Float64,n)
            end
        end

        println("debitO2 before skipmissing : ", debitsO2)

        debitsO2 = skipmissing(debitsO2)
        # get the most frequent debit

        println("debitO2 after skipmissing : ", debitsO2)

        if !all(ismissing.(debitsO2))
            meanDebitO2 = mean(debitsO2)
        end
    end


    # We don't use the mean because we don't want to mix with the values
    # from spontaneous ventilation (cf window 31 of BERGOT YVES)

    #TODO Bapt : previous comment to discuss, found a patient  with a window containing following debits, once each: 1, 5, 6, 4, 7, 10
    #Si cas similaires, la variable perd tout son sens si on prend la valeur la plus fréquente

    # get ventil types
    ventilTypes = window |>
    n -> ICUDYNUtil.getNonMissingValues(
        n,
        :attributeDictionaryPropName,
        "PtAssessment_VentModeInt.VentModeList",
        :terseForm ) |>
    n -> if isempty(n) return missing else n end

    if !ismissing(ventilTypes)
        # get all ventil types occurences
        if any(in(["VAC", "VS-AI", "VS AI"]).(ventilTypes)) #TODO Bapt : in() or contains() ? check in excel file
            push!(ventilTypeArray,"invasive")
        end

        if any(in(["VNI-AI", "VNI AI"]).(ventilTypes))
            push!(ventilTypeArray,"VNI")
        end

        if any(in(["optiflow", "airvo2"]).(ventilTypes))
            push!(ventilTypeArray,"OHD")
        end
    end

    if !ismissing(debitsO2)
        if any(x->(x>=30 && x<55), debitsO2) # 55 because of issue #13. otherwise 60
            push!(ventilTypeArray,"OHD")
        end
        if any(x->(x>0 && x<30), debitsO2)
            push!(ventilTypeArray,"O2")
        end
        if any(x->ismissing(x), debitsO2)
            push!(ventilTypeArray,"ambiant_air")
        end
    end

    if !isempty(ventilTypeArray)
        ventilTypeString = join(ventilTypeArray, ',')
        ventilCritical = ventilInvasive = false
    end

    if any(in(["invasive", "VNI", "OHD"]).(ventilTypeArray))
        ventilCritical = true
    end

    if "invasive" in ventilTypeArray
        ventilInvasive = true
    end

    return RefiningFunctionResult(
        :ventilType => ventilTypeString,
        :debitO2 => meanDebitO2,
        :ventilCritical => ventilCritical,
        :ventilInvasive => ventilInvasive
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

function ETL.Ventilation.computeRespiratoryVolumeMinute(window::DataFrame, critical::Bool, ohd::Bool)

    res = missing

    # Calculer Volume si ventilation non critique et type de ventilation != OHD
    if !(critical || ohd)

        res = ICUDYNUtil.getNumericValueFromWindowTerseForm(
            window,
            "PtAssessment_Volume_minute_lmin.mesure",
            n -> round(mean(n), digits=2))
    end

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
    if !ohd

        res =  ICUDYNUtil.getNumericValueFromWindowTerseForm(
                window,
                "PtAssessment_Pression_positive_PEP_cmH2O.mesure",
                n -> round(mean(n), digits=2))

    end

    return RefiningFunctionResult(:positiveExpiratoryPressure => res)
end
