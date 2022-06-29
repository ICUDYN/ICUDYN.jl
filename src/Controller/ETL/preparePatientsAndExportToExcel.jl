function ETL.preparePatientsAndExportToExcel(
    patients::Vector{PatientInSrcDB},
    useCache::Bool,
    dbconn::ODBC.Connection,
    ;filepath = "$(tempname()).xlsx"
)

    patientsPreparedData::Vector{Union{DataFrame,Missing}} = DataFrame[]
    patientsCodeNames = String[]

    for p in patients

        patientCodeName = ICUDYNUtil.getPatientPrettyCodename(
            p.firstname, p.lastname, p.birthdate
        )

        rawDF = ETL.getPatientRawDFFromSrcDB(
            p.srcDBIDs,
            useCache,
            dbconn
        )

        push!(
            patientsPreparedData,
            ETL.processPatientRawHistoryWithFileLogging(rawDF,patientCodeName)
        )

        push!(patientsCodeNames, patientCodeName)

    end

    filter!(x -> !ismissing(x),patientsPreparedData)


    ICUDYNUtil.exportToExcel(
        patientsPreparedData,
        patientsCodeNames
        ;filepath = filepath
    )

end
