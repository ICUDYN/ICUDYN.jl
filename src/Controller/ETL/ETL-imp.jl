# ################################## #
# Include of the refiniing functions #
# ################################## #
include("./Misc/Misc-imp.jl")
include("./Physiological/Physiological-imp.jl")

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
        srcDF = getPatientDFFromXLSX(patientCodeName)
        push!(patientsPreparedData,
              ETL.processPatientRawHistory(srcDF))
    end

    ICUDYNUtil.exportToExcel(
        patientsPreparedData,
        patientsCodeNames
        ;filepath = filepath
    )
end

function ETL.getPatientDFFromXLSX(patientCodeName::String) 
    patientsDir = ICUDYNUtil.getDataInputDir()
    patientFilename = joinpath(patientsDir,"all_events_$patientCodeName.csv.xlsx")
    isfile(patientFilename)
    df = XLSX.readtable(patientFilename,1) |> n -> DataFrame(n...)
    return df
end

function ETL.processPatientRawHistory(df::DataFrame)
    rawWindows::Vector{DataFrame} = ETL.cutPatientDF(df)
    refinedWindows = DataFrame[] # ? or Dict[] or NamedTuple[]   
    for w in rawWindows
        push!(refinedWindows,ETL.refineWindow(w))
    end

    return combineRefinedWindows(refinedWindows)

end

function combineRefinedWindows(refinedWindows::Vector)

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

function ETL.refineWindow(window::DataFrame)
end