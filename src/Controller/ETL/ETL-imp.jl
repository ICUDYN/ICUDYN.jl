# ################################## #
# Include of the refining functions #
# ################################## #
include("./Misc/Misc-imp.jl")
include("./Physiological/Physiological-imp.jl")
include("./Transfusion/Transfusion-imp.jl")
include("./Dialysis/Dialysis-imp.jl")
include("./FluidBalance/FluidBalance-imp.jl")
include("./Ventilation/Ventilation-imp.jl")
include("./Biology/Biology-imp.jl")
include("./Prescription/Prescription-imp.jl")
include("./Nutrition/Nutrition-imp.jl")

include("getPatientIDsFromSrcDB.jl")
include("preparePatientsAndExportToExcel.jl")
include("exportPatientsToWebServer.jl")
include("getPatientsCurrentlyInUnitFromSrcDB.jl")
include("getPatientsRecentlyOutFromSrcDB.jl")
include("getPatientsCurrentlyInUnitOrRecentlyOutFromSrcDB.jl")

include("deprecated/excel-deprecated.jl")

# ################################ #
# Main functions of the ETL module #
# ################################ #


function ETL.getPatientRawDFFromSrcDB(
    patientIDs::Vector{T} where T <: Integer,
    useCache::Bool,
    dbconn::ODBC.Connection
)

    # Get the cache file path
    basicInfo = ETL.getPatientBasicInfoFromSrcDB(patientIDs, dbconn)
    cacheFilePath = ICUDYNUtil.getPatientRawCacheFilePath(
        basicInfo.firstname,
        basicInfo.lastname,
        basicInfo.birthdate
    )

    # Load the data from cached file or database
    if !useCache || !ispath(cacheFilePath)
        queryString = open("src/queries/get-patient-raw-data-from-src-db.sql","r") do io
            read(io, String)
        end |>
        n -> replace(n, "COMMA_SEPARATED_IDS" => string.(patientIDs) |> t -> join(t,","))
        df = DBInterface.execute(dbconn, queryString) |> DataFrame
        serialize(cacheFilePath, df)
        return df
    else
        @info "Load cache[$cacheFilePath]"
        return deserialize(cacheFilePath)
    end


end

function ETL.getPatientBasicInfoFromSrcDB(
    patientIDs::Vector{T} where T <:Integer,
    dbconn::ODBC.Connection
)
    ETL.getPatientBasicInfoFromSrcDB(first(patientIDs), dbconn)

end

function ETL.getPatientBasicInfoFromSrcDB(patientID::Integer, dbconn::ODBC.Connection)

    # Get a first list of patients names
    queryString = "
        SELECT TOP 1
            vc.encounterId,
            vc.firstname,
            vc.lastname,
            vc.dateOfBirth AS birthdate
        FROM dbo.V_Census vc
        WHERE vc.encounterId = ?
        "

    df = DBInterface.execute(dbconn, queryString,[patientID]) |> DataFrame

    return (
        firstname = first(df).firstname,
        lastname = first(df).lastname,
        birthdate = Date(first(df).birthdate),
    )

end

function ETL.processPatientRawHistoryWithFileLogging(df::DataFrame,patientCodeName::String)

    timestamp_logger(logger) = TransformerLogger(logger) do log
        merge(log, (; message = "$(Dates.format(now(), date_format)) $(log.message)"))
    end

    patientLogFilePath = joinpath(getLogDir(),"$patientCodeName.log")
    patientETLLogger = TeeLogger(
        FileLogger(patientLogFilePath) |>
        n -> TransformerLogger(n) do log
            merge(log, (; message = "$(Dates.format(now(), "yyyy-mm-dd HH:MM:SS")) $(log.message)"))
        end,
        ConsoleLogger(stdout, Logging.Debug)
    )
    refinedHistory::RefinedHistory = ETL.processPatientRawHistory(df, patientETLLogger)

    # If refined history is missing it means that a problem happened
    if ismissing(refinedHistory)
        @error ("Problem while refining history of patient[$patientCodeName]."
        * "See log[$patientLogFilePath]")
    end

    return refinedHistory
end

function ETL.processPatientRawHistory(df::DataFrame,patientETLLogger::Logging.AbstractLogger)
    with_logger(patientETLLogger) do
        try
            return ETL.processPatientRawHistory(df)
        catch e
            @error "Error while processing patient"
            @error formatExceptionAndStackTrace(e,stacktrace(catch_backtrace()))
            return missing
        end
    end
end

function ETL.processPatientRawHistory(df::DataFrame)

    # ##### #
    # Clean #
    # ##### #
    filter!(x -> x.attributeDictionaryPropName != "PtSite_startTime" ,df)
    filter!(x -> !ismissing(x.chartTime),df)

    # ### #
    # Cut #
    # ### #
    rawWindows::Vector{DataFrame} = ETL.cutPatientDF(df)

    # ###### #
    # Refine #
    # ###### #
    refinedWindows = Vector{RefinedWindow}()
    for rawWindow in rawWindows
        refinedWindow::RefinedWindow = ETL.initializeWindow(rawWindow)
        push!(refinedWindows,refinedWindow)
        ETL.refineWindow1stPass!(refinedWindow,rawWindow)
    end

    # ########################## #
    # Combine result of 1st pass #
    # ########################## #
    df1stPass =  ETL.combineRefinedWindows(refinedWindows)

    # ########### #
    # Second pass #
    # ########### #
    # Prepare variables often needed in second pass (for performance)
    cache = Dict{Symbol, RefiningFunctionAllowedValueType}()

    refinedWindows = Vector{RefinedWindow}()
    for rawWindow in rawWindows
        refinedWindow = ETL.initializeWindow(rawWindow)
        push!(refinedWindows,refinedWindow)
        ETL.refineWindow2ndPass!(refinedWindow,rawWindow,df1stPass,cache)
    end

    # ########################## #
    # Combine result of 2nd pass #
    # ########################## #
    df2ndPass =  ETL.combineRefinedWindows(refinedWindows)

    # Join on startTime and
    df = innerjoin(
        df1stPass,
        df2ndPass,
        on = :startTime,
        makeunique = true # So that the column endTime (in both dataframe) is not a problem
        )

    ETL.orderColmunsOfRefinedHistory!(df)

    return df

end

function ETL.orderColmunsOfRefinedHistory!(df::DataFrame)

    unorderedNames = names(df) |> sort
    orderedNames = String[]

    modulesBaseNames = ICUDYNUtil.getRefiningModules() |>
        n -> propertynames.(n) |>
        n -> first.(n) |>
        n -> string.(n)

    # Order by module
    for m in modulesBaseNames
        for colName in unorderedNames
            # If the name starts with the module name
            if startswith(lowercase(colName),"$(lowercase(m))_")
                getindex(unorderedNames, findfirst(x -> x == colName,unorderedNames)) |>
                n -> push!(orderedNames,n)
            end
        end
    end

    # Put the startTime and endTime first
    firstNames = ["startTime","endTime"]
    orderedNames = [firstNames...,filter(x -> x ∉ firstNames,orderedNames)...]

    select!(df, orderedNames)

    df
end

function ETL.combineRefinedWindows(refinedWindows::Vector{RefinedWindow})
    windowsDFs = DataFrame[]
    for refinedWindow in (refinedWindows)
        refinedWindowDict = RefinedWindowModuleResults()

        for (_module,dict) in refinedWindow

            ICUDYNUtil.mergeResultsDictionaries!(
                refinedWindowDict, dict
                ;keyPrefix = (string ∘ first ∘ propertynames)(_module)*"_"
            )
        end
        windowDF = DataFrame(;[Symbol(var)=>val for (var,val) in refinedWindowDict]...)
        push!(windowsDFs,windowDF)
    end
    df = vcat(windowsDFs..., cols=:union)

    # Rename for convenience
    DataFrames.rename!(df, :Misc_startTime => :startTime, :Misc_endTime => :endTime)

    return df
end

function ETL.cutPatientDF(df::DataFrame)
    dfArray = DataFrame[]

    # Order DataFrame
    sort!(df, :chartTime)
    windowSize = 4
    windowTpl = DataFrame(
        encounterId = Vector{Union{Missing,Int32}}(),
        chartTime = Vector{Union{Missing,DateTime}}(),
        storeTime = Vector{Union{Missing,DateTime}}(),
        terseForm = Vector{Union{Missing,String}}(),
        verboseForm = Vector{Union{Missing,String}}(),
        interventionLongLabel = Vector{Union{Missing,String}}(),
        attributeDictionaryPropName = Vector{Union{Missing,String}}(),
        interventionShortLabel = Vector{Union{Missing,String}}(),
        interventionPropName = Vector{Union{Missing,String}}(),
        interventionBaseLongLabel = Vector{Union{Missing,String}}(),
        attributeLongLabel = Vector{Union{Missing,String}}(),
        attributeShortLabel = Vector{Union{Missing,String}}(),
        attributePropName = Vector{Union{Missing,String}}(),
        materialPropName = Vector{Union{Missing,String}}(),
    )
    window = deepcopy(windowTpl)
    windowFirstTime = df[1,:chartTime]

    windowEndTime = windowFirstTime + Hour(windowSize)

    # Loop
    for r in eachrow(df)

        if ismissing(r.chartTime)
            error("ismissing(r.chartTime)")
        end

        # If chartTime after cut off time of the current window
        if (r.chartTime >= windowEndTime)
            # Add the current window to the list of windows
            push!(dfArray,window)

            # Create a new window
            window = deepcopy(windowTpl)
            push!(window,r)

            # Look for the next window end time (in case there are holes in the history of
            #   the events)
            while r.chartTime >= windowEndTime
                windowEndTime += Hour(windowSize)
            end
            windowFirstTime = windowEndTime - Hour(windowSize)

        # else, same window
        else
            try
                push!(window,r)
            catch e
                serialize("tmp/debug/window.jld",window)
                @warn window
                @warn r
                rethrow(e)
            end
        end
    end

    # Add last window
    push!(dfArray,window)

    return dfArray
end #cut_patient_df

function ETL.initializeWindow(window::DataFrame)
    result::RefinedWindow = RefinedWindow()
    return result
end

function ETL.getRefiningFunctions(_module::Module)

    refiningFunctions = names(_module, all=true) |>
        symb -> map(x -> string(x) ,symb) |>
        str -> filter(x -> !startswith(x,"#") ,str) |>
        str -> filter(x -> x ∉ ["eval","include"] ,str) |>
        str -> filter(x -> startswith(x,"compute") ,str) |>
        str -> Symbol.(str) |>
        symb -> getproperty.(Ref(_module),symb) |>
        n -> filter(x -> x isa Function,n) |>
        # filter out functions that are not implemented yet
        fct -> filter(x -> !isempty(methods(x)),fct)

    return refiningFunctions
end

function ETL.get1stPassRefiningFunctions(_module::Module)
    ETL.getRefiningFunctions(_module) |>
    n -> filter(x -> length(first(methods(x)).sig.parameters) == 2,n)
end

function ETL.get2ndPassRefiningFunctions(_module::Module)
    ETL.getRefiningFunctions(_module) |>
    n -> filter(x -> length(first(methods(x)).sig.parameters) > 2,n)
end

function ETL.refineWindow1stPass!(refinedWindow::RefinedWindow, window::DataFrame)
    for _module in ICUDYNUtil.getRefiningModules()
        refinedWindow[_module] = ETL.refineWindow1stPass(window, _module)
    end
end

function ETL.refineWindow1stPass(window::DataFrame, _module::Module)

    moduleRes = RefinedWindowModuleResults()

    # Get the 1st pass functions of the module
    refiningFunctions = ETL.get1stPassRefiningFunctions(_module)

    for fct in refiningFunctions

        fctResultTmp = fct(window)

        ETL.enrichModuleResultWithFunctionResult!(moduleRes,fct,fctResultTmp)

    end

    return moduleRes
end

function ETL.enrichModuleResultWithFunctionResult!(
    moduleRes::IRefinedWindowModuleResults,
    fct::Function,
    fctRes::IRefiningFunctionResult)

    # Add the result of the function to the results of the refining module
    ICUDYNUtil.mergeResultsDictionaries!(moduleRes,fctRes)

end

function ETL.enrichModuleResultWithFunctionResult!(
    moduleRes::IRefinedWindowModuleResults,
    fct::Function,
    fctRes::Union{String,Number,Missing,DateTime})

    varName = string(fct) |> x -> replace(x,"compute" => "") |> lowercasefirst

    # Add the result of the function to the results of the refining module
    ICUDYNUtil.mergeResultsDictionaries!(moduleRes, Dict(Symbol(varName) => fctRes))

end


function ETL.enrichWindowModulesResultsWith2ndPassFunctionResult!(
    refinedWindow::RefinedWindow,
    _module::Module,
    fct::Function,
    fctResult::Union{RefiningFunctionAllowedValueType,IRefiningFunctionResult})

    if !haskey(refinedWindow,_module)
        refinedWindow[_module] = RefinedWindowModuleResults()
    end

    moduleRes = refinedWindow[_module]
    ETL.enrichModuleResultWithFunctionResult!(moduleRes,fct,fctResult)

end


function ETL.refineWindow2ndPass!(
    refinedWindow::RefinedWindow,
    rawWindow::DataFrame,
    refinedWindows1stPass::DataFrame,
    cache::Dict{Symbol, RefiningFunctionAllowedValueType}
    )

    ETL.refreshCache!(cache,refinedWindows1stPass,first(rawWindow).chartTime)

    # Compute window startTime
    fctResult = ETL.Misc.computeStartTime(rawWindow)
    ETL.enrichWindowModulesResultsWith2ndPassFunctionResult!(
        refinedWindow,
        ETL.Misc,
        ETL.Misc.computeStartTime,
        fctResult)

    # Compute window endTime
    fctResult = ETL.Misc.computeEndTime(rawWindow)
    ETL.enrichWindowModulesResultsWith2ndPassFunctionResult!(
        refinedWindow,
        ETL.Misc,
        ETL.Misc.computeEndTime,
        fctResult)

    # Compute variable amine agent (Prescription)
    fctResult = passmissing(ETL.Prescription.computeAmineAgentsAdditionalVars)(
        ETL.getCachedVariable(cache,:sameWindowNorepinephrineMeanMgHeure),
        ETL.getCachedVariable(cache,:sameWindowEpinephrineMeanMgHeure),
        ETL.getCachedVariable(cache,:sameWindowDobutamineMeanGammaKgMinute),
        ETL.getCachedVariable(cache,:weightAtAdmission))
    ETL.enrichWindowModulesResultsWith2ndPassFunctionResult!(
        refinedWindow,
        ETL.Prescription,
        ETL.Prescription.computeAmineAgentsAdditionalVars,
        fctResult)

    # Compute creatinine (Biology) age weight gender
    fctResult = passmissing(ETL.Biology.computeCreatinine)(
        rawWindow,
        ETL.getCachedVariable(cache, :age),
        ETL.getCachedVariable(cache, :lastWeight),
        ETL.getCachedVariable(cache, :gender)
    )
    ETL.enrichWindowModulesResultsWith2ndPassFunctionResult!(
        refinedWindow,
        ETL.Biology,
        ETL.Biology.computeCreatinine,
        fctResult)

    # Compute neuro Glasgow score (Physiological)
    fctResult = passmissing(ETL.Physiological.computeNeuroGlasgow)(
        rawWindow,
        ETL.getCachedVariable(cache, :anySedative)
    )
    ETL.enrichWindowModulesResultsWith2ndPassFunctionResult!(
        refinedWindow,
        ETL.Physiological,
        ETL.Physiological.computeNeuroGlasgow,
        fctResult)


    # Compute unplugAttempt
    invasive = ETL.getCachedVariable(cache, :criticalVentilType) === "invasive"
    fctResult = passmissing(ETL.Ventilation.computeUnplugAttemptInvasiveVentilation)(
        rawWindow,
        invasive
    )
    ETL.enrichWindowModulesResultsWith2ndPassFunctionResult!(
        refinedWindow,
        ETL.Ventilation,
        ETL.Ventilation.computeUnplugAttemptInvasiveVentilation,
        fctResult)


    # Compute positiveExpiratoryPressure
    ohd = ETL.getCachedVariable(cache, :criticalVentilType) === "OHD"
    fctResult = passmissing(ETL.Ventilation.computePositiveExpiratoryPressure)(
        rawWindow,
        ohd
    )
    ETL.enrichWindowModulesResultsWith2ndPassFunctionResult!(
        refinedWindow,
        ETL.Ventilation,
        ETL.Ventilation.computeUnplugAttemptInvasiveVentilation,
        fctResult)

    return refinedWindow

end

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

    # Any sedative ?
    anySedative = ETL.getCachedVariable(cache, :anySedative)
    if ismissing(anySedative)
        # NOTE: Security check, the column may not exist
        if hasproperty(refinedWindows,:Prescription_sedative)
            anySedative = firstNonMissingValue(:Prescription_sedative, refinedWindows)
            ETL.updateCache!(cache, :anySedative, anySedative)
        end
    end

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

function ETL.getCachedVariable(
    cache::Dict{Symbol, RefiningFunctionAllowedValueType},
    varName::Symbol)

    if haskey(cache,varName)
        return cache[varName]
    else
        return missing
    end
end
