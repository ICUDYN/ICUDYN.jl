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
