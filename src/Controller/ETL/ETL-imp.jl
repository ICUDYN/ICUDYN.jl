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


# ################################ #
# Main functions of the ETL module #
# ################################ #
# function ETL.getPatientDFFromCSV(csvPath::String)

# end #get_patient_df_from_csv

function ETL.preparePatientsFromRawExcelFile(
    patientsCodeNames::Vector{String}
    ;filepath = "$(tempname()).xlsx"
)
    # NOTE: Some implementations of processPatientRawHistoryWithFileLogging return missing 
    #       when an error is raised
    patientsPreparedData::Vector{DataFrame,Missing} = DataFrame[]

    for patientCodeName in patientsCodeNames
        srcDF = ETL.getPatientDFFromExcel(patientCodeName)
        
        push!(patientsPreparedData,
                ETL.processPatientRawHistoryWithFileLogging(srcDF,patientCodeName))        
        filter!(x -> ismissing(x),patientsPreparedData)        
    end

    ICUDYNUtil.exportToExcel(
        patientsPreparedData,
        patientsCodeNames
        ;filepath = filepath
    )
end

function ETL.getPatientDFFromExcel(patientCodeName::String)
    patientsDir = ICUDYNUtil.getDataInputDir()
    patientFilename = joinpath(patientsDir,"all_events_$patientCodeName.csv.xlsx")
    isfile(patientFilename)
    df = XLSX.readtable(patientFilename,1) |> n -> DataFrame(n...)

    # Only for excel file inputs
    if !isa(df.chartTime, Vector{DateTime})
        df.chartTime = ICUDYNUtil.convertStringToDateTime.(df.chartTime)
    end

    if !isa(df.storeTime, Vector{DateTime})
        df.storeTime = ICUDYNUtil.convertStringToDateTime.(df.storeTime)
    end

    return df
end

function ETL.processPatientRawHistoryWithFileLogging(df::DataFrame,patientCodeName::String)

    timestamp_logger(logger) = TransformerLogger(logger) do log
        merge(log, (; message = "$(Dates.format(now(), date_format)) $(log.message)"))
    end

    patientETLLogger = TeeLogger(
        FileLogger(joinpath(getLogDir(),"$patientCodeName.log")) |> 
        n -> TransformerLogger(n) do log
            merge(log, (; message = "$(Dates.format(now(), "yyyy-mm-dd HH:MM:SS")) $(log.message)"))
        end,
        ConsoleLogger(stdout, Logging.Debug)
    )
    ETL.processPatientRawHistory(df,patientETLLogger)
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
    filter!(x-> x.attributeDictionaryPropName != "PtSite_startTime" ,df)

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

    @info "nrow(df1stPass) == nrow(df2ndPass)[$(nrow(df1stPass) == nrow(df2ndPass))]"

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

    @info orderedNames

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
    df_array = DataFrame[]

    # Order DataFrame
    sort!(df, :chartTime)
    windowSize = 4
    window = DataFrame()
    windowFirstTime = df[1,:chartTime]

    windowEndTime = windowFirstTime + Hour(windowSize)

    # Loop
    for r in eachrow(df)

        # If chartTime after cut off time of the current window
        if (r.chartTime >= windowEndTime)
            # Add the current window to the list of windows
            push!(df_array,window)

            # Create a new window
            window = DataFrame(r)

            # Look for the next window end time (in case there are holes in the history of
            #   the events)
            while r.chartTime >= windowEndTime
                windowEndTime += Hour(windowSize)
            end
            windowFirstTime = windowEndTime - Hour(windowSize)

        # else, same window
        else
            push!(window,r)
        end
    end

    # Add last window
    push!(df_array,window)

    return df_array
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
        @info "Call $_module.$fct"

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
        ICUDYNUtil.sameWindowValue(
            row,
            :Prescription_norepinephrineDrip)
    )

    # Same window EpinephrineMeanMgHeure
    ETL.updateCache!(
        cache, 
        :sameWindowEpinephrineMeanMgHeure, 
        ICUDYNUtil.sameWindowValue(
            row,
            :Prescription_epinephrineDrip)
    )

    # Same window DobutamineMeanMgHeure
    ETL.updateCache!(
        cache, 
        :sameWindowDobutamineMeanGammaKgMinute, 
        ICUDYNUtil.sameWindowValue(
            row,
            :Prescription_dobutamineDrip)
    )

    # Any sedative ?
    anySedative = ETL.getCachedVariable(cache, :anySedative)
    if ismissing(anySedative)
        anySedative = ICUDYNUtil.firstNonMissingValue(:Prescription_sedative, refinedWindows) 
        ETL.updateCache!(cache, :anySedative, anySedative)
    end

end

function ETL.updateCache!(
    cache::Dict{Symbol, RefiningFunctionAllowedValueType},
    varName::Symbol,
    value::RefiningFunctionAllowedValueType)

    cache[varName] = value
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


