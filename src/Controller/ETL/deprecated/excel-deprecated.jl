
function ETL.preparePatientsFromRawExcelFile(
    patientsCodeNames::Vector{String}
    ;filepath = "$(tempname()).xlsx"
)
    # NOTE: Some implementations of processPatientRawHistoryWithFileLogging return missing
    #       when an error is raised
    patientsPreparedData::Vector{Union{DataFrame,Missing}} = DataFrame[]

    for patientCodeName in patientsCodeNames
        srcDF = ETL.getPatientDFFromExcel(patientCodeName)

        push!(patientsPreparedData,
                ETL.processPatientRawHistoryWithFileLogging(srcDF,patientCodeName) |>
                n -> begin
                    @info size(n)
                    n
                end
                )

    end
    @info length(patientsPreparedData)

    filter!(x -> !ismissing(x),patientsPreparedData)
    @info length(patientsPreparedData)


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
