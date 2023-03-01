function ETL.refreshCache!(
    cache::Dict{Symbol, RefiningFunctionAllowedValueType},
    refinedWindows::DataFrame,
    currentStartTime::DateTime)

    row = filter(r -> r.startTime == currentStartTime, refinedWindows) |> first

    # Weight at admission (first recorded weight)
    weightAtAdmission = ETL.getCachedVariable(cache, :weightAtAdmission)
    if ismissing(weightAtAdmission)
        weightAtAdmission = firstNonMissingValue(:Physiological_weight, refinedWindows)
        ETL.updateCache!(cache, :weightAtAdmission, weightAtAdmission)
    end

    # Age (first recorded age)
    age = ETL.getCachedVariable(cache, :age)
    if ismissing(age)
        age = firstNonMissingValue(:Physiological_age, refinedWindows)
        ETL.updateCache!(cache, :age, age)
    end

    # Gender
    gender = ETL.getCachedVariable(cache, :gender)
    if ismissing(gender)
        gender = firstNonMissingValue(:Physiological_gender, refinedWindows)
        ETL.updateCache!(cache, :gender, gender)
    end

    # Last recorded weight
    lastWeight = sameWindowValue(row, :Physiological_weight)
    if !ismissing(lastWeight)
        #if weight is in the current window, update it in cache, even if it's already in
        ETL.updateCache!(cache, :lastWeight, lastWeight)
    end

    # Same window NorepinephrineMeanMgHeure
    ETL.updateCache!(
        cache,
        :sameWindowNorepinephrineMeanMgHeure,
        sameWindowValue(row,:Prescription_norepinephrineDrip)
    )

    # Same window EpinephrineMeanMgHeure
    ETL.updateCache!(
        cache,
        :sameWindowEpinephrineMeanMgHeure,
        sameWindowValue(row,:Prescription_epinephrineDrip)
    )

    # Same window DobutamineMeanMgHeure
    ETL.updateCache!(
        cache,
        :sameWindowDobutamineMeanGammaKgMinute,
        sameWindowValue(row,:Prescription_dobutamineDrip)
    )

    # Same window unplugAttemptInvasiveVentilation
    ETL.updateCache!(
        cache,
        :unplugAttemptInvasiveVentilation,
        sameWindowValue(row,:Ventilation_unplugAttemptInvasiveVentilation)
    )

    # Any sedative ?
    anySedative = ETL.getCachedVariable(cache, :anySedative)
    if ismissing(anySedative)
        # NOTE: Security check, the column may not exist
        if hasproperty(refinedWindows,:Prescription_sedative)
            anySedative = firstNonMissingValue(:Prescription_sedative, refinedWindows)
            ETL.updateCache!(cache, :anySedative, anySedative)
        end
    end

    # Same window SPO2
    ETL.updateCache!(
        cache,
        :sameWindowSPO2,
        sameWindowValue(row,:Ventilation_SPO2)
    )

    # Same window respiratoryRate
    ETL.updateCache!(
        cache,
        :sameWindowRespiratoryRate,
        sameWindowValue(row,:Ventilation_respiratoryRate)
    )

    # Same window FiO2
    ETL.updateCache!(
        cache,
        :sameWindowFiO2,
        sameWindowValue(row,:Ventilation_fiO2)
    )


end

function ETL.updateCache!(
    cache::Dict{Symbol, RefiningFunctionAllowedValueType},
    varName::Symbol,
    value::RefiningFunctionAllowedValueType)

    cache[varName] = value
end


function ETL.updateCache!(
    cache::Dict{Symbol, RefiningFunctionAllowedValueType},
    varName::Symbol,
    value::Nothing)

    # DO NOTHING, nothing cannot be a cached value

end
