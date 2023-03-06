function ICUDYNUtil.getWindowSize()
    return parse(Integer,getConf("window","size"))
end

function ICUDYNUtil.getWindowUnit()
    return parse(Integer,getConf("window","unit"))
end

function ICUDYNUtil.getNonMissingValues(
    window::DataFrame,
    filterColumn::Symbol,
    filterValue::String,
    columnOfInterest::Symbol)

    res = window |>
        n -> filter(
            r -> (r[filterColumn] === filterValue
                  && !isMissing(r[columnOfInterest])),n) |>
        n -> n[:,columnOfInterest]

    # res = try

    #     window |>
    #         n -> filter(r -> r[filterColumn] == filterValue,n) |>
    #         n -> filter(r -> !isMissing(r[columnOfInterest]),n) |>
    #         n -> n[:,columnOfInterest]

    # catch e
    #     @warn "filterColumn[$filterColumn] filterValue[$filterValue]"
    #     @warn "any(ismissing.(window[:,filterColumn]))[$(any(ismissing.(window[:,filterColumn])))]"
    # end

    return res
end

function ICUDYNUtil.getNumericValueFromWindowTerseForm(
    window::DataFrame,
    attribute::String,
    fun::Union{Function,Missing}=missing
)
    res = window |>
    n -> ICUDYNUtil.getNonMissingValues(
        window,
        :attributeDictionaryPropName,
        attribute,
        :terseForm) |>
    n -> if isempty(n) return missing else n end |>
    n -> convertToFloatIfPossible.(n) |>
    n -> if !ismissing(fun) fun(n) else n end

    return res
end

function ICUDYNUtil.firstNonMissingValue(variable::Symbol,refinedWindows::DataFrame)
   for r in eachrow(refinedWindows)
        if !ismissing(r[variable])
            return r[variable]
        end
   end
   return nothing
end

function ICUDYNUtil.sameWindowValue(
    refinedRow::DataFrameRow,
    variable::Symbol)
    if !hasproperty(refinedRow,variable)
        return missing
    end
    return getproperty(refinedRow,variable)
end

function ICUDYNUtil.closestNonMissingValue(
    variable::Symbol,
    dateOI::DateTime,
    refinedWindows::DataFrame)

    closestPastValue, closestPastDate = ICUDYNUtil.closestNonMissingValueInCurrentOrPreviousWindows(variable, dateOI, refinedWindows; returnDate = true)
    closestNextValue, closestNextDate = ICUDYNUtil.closestNonMissingValueInCurrentOrNextWindows(variable, dateOI, refinedWindows; returnDate = true)

    @info "past : $closestPastDate $closestPastValue"
    @info "next : $closestNextDate $closestNextValue"

    if !ismissing(closestPastValue) && !ismissing(closestNextValue)
        if dateOI-closestPastDate <= closestNextDate-dateOI
            return closestPastValue
        else
            return closestNextValue
        end
    elseif !ismissing(closestPastValue)
        return closestPastValue
    elseif !ismissing(closestNextValue)
        return closestNextValue
    else
        return missing
    end

end

function ICUDYNUtil.closestNonMissingValueInCurrentOrPreviousWindows(
        variable::Symbol,
        dateOI::DateTime,
        refinedWindows::DataFrame
        ;returnDate::Bool=false)

    value = missing
    idx = findlast(refinedWindows.startTime .<= dateOI)
    if !isnothing(idx)
        while idx > 0
            if !ismissing(refinedWindows[idx, variable])
                break
            end
            idx-=1
        end
    end

    if !returnDate
        if isnothing(idx) || idx == 0
            return missing
        else
            return refinedWindows[idx, variable]
        end
    else
        if isnothing(idx) || idx == 0
            return (missing, missing)
        else
            return (refinedWindows[idx, variable], refinedWindows.startTime[idx])
        end
    end
end


function ICUDYNUtil.closestNonMissingValueInCurrentOrNextWindows(
    variable::Symbol,
    dateOI::DateTime,
    refinedWindows::DataFrame
    ;returnDate::Bool=false)

    value = missing
    idx = findfirst(refinedWindows.startTime .>= dateOI)
    if !isnothing(idx)
        while idx <= nrow(refinedWindows)
            if !ismissing(refinedWindows[idx, variable])
                break
            end
            idx+=1
        end
    end

    if !returnDate
        if isnothing(idx) || idx > nrow(refinedWindows)
            return missing
        else
            return refinedWindows[idx, variable]
        end
    else
        if isnothing(idx) || idx > nrow(refinedWindows)
            return (missing, missing)
        else
            return (refinedWindows[idx, variable], refinedWindows.startTime[idx])
        end
    end


end


function ICUDYNUtil.computeStatisticsFromVector(x::Union{Missing,AbstractArray}; _digits::Int64=2)

    if ismissing(x)
        d = Dict(
            :min    => missing,
            :max    => missing,
            :mean   => missing,
            :med    => missing,
            :stdev  => missing
        )

    else
        d = Dict(
            :min    => minimum(x),
            :max    => maximum(x),
            :mean   => round(mean(x); digits=_digits),
            :med    => median(x),
            :stdev  => round(std(x); digits=_digits)
        )

    end

    return d

end
