# ################################## #
# Include of the refiniing functions #
# ################################## #
include("./Misc/Misc-imp.jl")
include("./Physiological/Physiological-imp.jl")
include("./Transfusion/Transfusion-imp.jl")
include("./Dialysis/Dialysis-imp.jl")
include("./FluidBalance/FluidBalance-imp.jl")



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
              ETL.processPatientRawHistory(srcDF))
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

function ETL.processPatientRawHistory(df::DataFrame)

    rawWindows::Vector{DataFrame} = ETL.cutPatientDF(df)
    refinedWindows = Vector{Dict{Symbol, Any}}()
    for rawWindow in rawWindows
        refinedWindow = ETL.initializeWindow(rawWindow)
        push!(refinedWindows,refinedWindow)
        ETL.refineWindow1stPass!(refinedWindow,rawWindow)
    end

    return refinedWindows

    return ETL.combineRefinedWindows(refinedWindows[1:2])

end

function ETL.combineRefinedWindows(refinedWindows::Vector{Dict{Symbol, Any}})
    windowsDFs = DataFrame[]
    for refinedWindow in (refinedWindows)
        refinedWindowDict = Dict{Symbol,Any}()

        for (_module,dict) in refinedWindow

            ICUDYNUtil.mergeResultsDictionaries!(
                refinedWindowDict, dict
                ;keyPrefix = string(_module)*"_"
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
        if (r.chartTime >= windowEndTime)

            # Add the current window to the list of windows
            push!(df_array,window)

            # Create a new window
            window = DataFrame(r)
            windowFirstTime = windowEndTime
            windowEndTime = windowFirstTime + Hour(windowSize)

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
    result::Dict{Symbol,Any} = Dict{Symbol,Any}()
    return result
end

function ETL.refineWindow1stPass!(refinedWindow::Dict{Symbol,Any},window::DataFrame)
    for _module in ICUDYNUtil.getRefiningModules()
        ETL.refineWindow1stPass!(refinedWindow, window,_module)
    end
end

function ETL.refineWindow1stPass!(refinedWindow::Dict{Symbol,Any}, window::DataFrame, _module::Module)
    moduleRes = ETL.refineWindow1stPass(window, _module)
    ICUDYNUtil.mergeResultsDictionaries!(refinedWindow,moduleRes)
end

function ETL.getRefiningFunctions(_module::Module)

    refiningFunctions = names(_module, all=true) |>
        n -> map(x -> string(x) ,n) |>
        n -> filter(x -> !startswith(x,"#") ,n) |>
        n -> filter(x -> x ∉ ["eval","include"] ,n) |>
        n -> filter(x -> startswith(x,"compute") ,n) |>
        n -> Symbol.(n) |>
        n -> getproperty.(Ref(_module),n) |>
        n -> filter(x -> x isa Function,n) |>
        n -> filter(x -> !isempty(methods(x)),n)

    return refiningFunctions
end

function ETL.get1stPassRefiningFunctions(_module::Module)
    ETL.getRefiningFunctions(_module) |>
    n -> filter(x -> length(first(methods(x)).sig.parameters) == 2,n)
end

function ETL.get2ndPassRefiningFunctions(_module::Module)
    ETL.getRefiningFunctions(_module) |>
    n -> filter(x -> length(first(methods(x)).sig.parameters) == 3,n)
end

function ETL.refineWindow1stPass(window::DataFrame, _module::Module)

    moduleRes = Dict{Symbol,Any}()

    # Get the 1st pass functions of the module
    refiningFunctions = ETL.get1stPassRefiningFunctions(_module)

    for fct in refiningFunctions
        @info "Call $_module.$fct !"

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
