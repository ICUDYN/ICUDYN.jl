# ################################## #
# Include of the refiniing functions #
# ################################## #
include("./Misc/Misc-imp.jl")
include("./Physiological/Physiological-imp.jl")
include("./Transfusion/Transfusion-imp.jl")
include("./Dialysis/Dialysis-imp.jl")
include("./FluidBalance/FluidBalance-imp.jl")
include("./Ventilation/Ventilation-imp.jl")
include("./Biology/Biology-imp.jl")



# ################################ #
# Main functions of the ETL module #
# ################################ #
# function ETL.getPatientDFFromCSV(csvPath::String)

# end #get_patient_df_from_csv

function ETL.preparePatientsFromRawExcelFile(
    patientsCodeNames::Vector{String}
    ;filepath = "$(tempname()).xlsx"
)
    patientsPreparedData::Vector{DataFrame} = DataFrame[]

    for patientCodeName in patientsCodeNames
        srcDF = ETL.getPatientDFFromExcel(patientCodeName)
        push!(patientsPreparedData,
              ETL.processPatientRawHistory(srcDF, DataFrame))
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

function ETL.processPatientRawHistory(df::DataFrame, expectedReturnType::DataType)

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
    refinedWindows = Vector{Dict{Module, Any}}()
    for rawWindow in rawWindows
        refinedWindow = ETL.initializeWindow(rawWindow)
        push!(refinedWindows,refinedWindow)
        ETL.refineWindow1stPass!(refinedWindow,rawWindow)
    end

    # ####### #
    # Combine #
    # ####### #
    if expectedReturnType == Vector{Dict}
        return refinedWindows
    elseif expectedReturnType == DataFrame
        df =  ETL.combineRefinedWindows(refinedWindows)
        return ETL.orderColmunsOfRefinedHistory!(df)
    else
        error("Unknown expected return type[$expectedReturnType]," 
            *" known types are: Vector{Dict}, DataFrame")
    end

    


end

function ETL.orderColmunsOfRefinedHistory!(df::DataFrame)

    @info "ORDER"

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
    firstNames = ["Misc_StartTime","Misc_EndTime"]
    orderedNames = [firstNames...,filter(x -> x ∉ firstNames,orderedNames)...]

    select!(df, orderedNames)
    
    @info orderedNames

    df
end

function ETL.combineRefinedWindows(refinedWindows::Vector{Dict{Module, Any}})
    windowsDFs = DataFrame[]
    for refinedWindow in (refinedWindows)
        refinedWindowDict = Dict{Symbol,Any}()

        for (_module,dict) in refinedWindow

            ICUDYNUtil.mergeResultsDictionaries!(
                refinedWindowDict, dict
                ;keyPrefix = (string ∘ first ∘ propertynames)(_module)*"_"
            )
        end
        windowDF = DataFrame(;[Symbol(var)=>val for (var,val) in refinedWindowDict]...)
        push!(windowsDFs,windowDF)
    end
    vcat(windowsDFs..., cols=:union)
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


    # for indices in RollingTimeWindow(df.chartTime, Hour(4))
    #     println(indices)
    #    push!(df_array,df[indices,:])
    # end
    return df_array
end #cut_patient_df

function ETL.initializeWindow(window::DataFrame)
    result::Dict{Module,Any} = Dict{Module,Any}()
    return result
end

function ETL.refineWindow1stPass!(refinedWindow::Dict{Module,Any},window::DataFrame)
    for _module in ICUDYNUtil.getRefiningModules()
        refinedWindow[_module] = ETL.refineWindow1stPass(window, _module)        
    end
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

function ETL.refineWindow1stPass(window::DataFrame, _module::Module)

    moduleRes = Dict{Symbol,Any}()

    # Get the 1st pass functions of the module
    refiningFunctions = ETL.get1stPassRefiningFunctions(_module)
    
    for fct in refiningFunctions
        @info "Call $_module.$fct"

        fctResultTmp = fct(window)

        # If the function does not return a Dict, create one
        if !isa(fctResultTmp,Dict)
            varName = string(fct) |> x -> replace(x,"compute" => "")
            fctResult::Dict{Symbol,Any} = Dict(Symbol(varName) => fctResultTmp)
        else
            fctResult = fctResultTmp
        end

        # Add the result of the function to the results of the refining module
        ICUDYNUtil.mergeResultsDictionaries!(moduleRes,fctResult)
    end

    return moduleRes
end
