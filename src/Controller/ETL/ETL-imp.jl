# ################################## #
# Include of the refiniing functions #
# ################################## #
include("./Misc/Misc-imp.jl")
include("./Physiological/Physiological-imp.jl")

# ################################ #
# Main functions of the ETL module #
# ################################ #
function ETL.get_patient_df_from_csv(patient_name)
    patient_dir = "/home/baptiste/data/icudyn/DATA/" #hardcoded for now
    patient_csv_filename = patient_dir * "all_events_" * patient_name * ".csv"
    return DataFrame(CSV.File(patient_csv_filename))
end #get_patient_df_from_csv

function ETL.cut_patient_df(df::DataFrame)
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