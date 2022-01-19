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
    return df
end

function ETL.processPatientRawHistory(df::DataFrame)
    rawWindows::Vector{DataFrame} = ETL.cutPatientDF(df)
    refinedWindows = DataFrame[] # ? or Dict[] or NamedTuple[]
    for rawWindow in rawWindows
        refinedWindow = ETL.initializeWindow(rawWindow)
        push!(refinedWindows,refinedWindow)
        ETL.refineWindow1stPass!(refinedWindow,rawWindow)
    end

    return combineRefinedWindows(refinedWindows)

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
    result::Dict{Symbol,Any} = Dict()
    return result
end

function ETL.refineWindow1stPass!(refinedWindow::Dict,window::DataFrame)    
    for _module in ICUDYNUtil.getRefiningModules()
        ETL.refineWindow1stPass!(refinedWindow, window,_module)
    end    
end

function ETL.refineWindow1stPass!(refinedWindow::Dict, window::DataFrame, _module::Module)
    moduleRes = ETL.refineWindow1stPass(window, _module)
    ICUDYNUtil.mergeResultsDictionaries!(refinedWindow,moduleRes) 
end

function ETL.refineWindow1stPass(window::DataFrame, _module::Module)
    moduleRes = Dict()
    refiningFunctions = names(_module, all=true) |> 
        n -> filter(x -> getproperty(_module,x) isa Function && x ∉ (:eval, :include),n) |>
        n -> filter(x -> startswith(string(x),"compute"),n)
    
    for f in refiningFunctions

        fctResult = getfield(_module, f)(window)
        # If the function does not return a Dict, create one
        if !isa(fctResult,Dict)
            varName = string(f) |> x -> replace(x,"compute" => "") |> lowercase
            fctResult = Dict(Symbol(varName) => fctResult)
        end

        # Add the result of the function to the results of the refining module
        ICUDYNUtil.mergeResultsDictionaries!(moduleRes,functionResult) 
    end

    return moduleRes
end




