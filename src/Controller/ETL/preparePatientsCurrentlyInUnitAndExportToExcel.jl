function ETL.preparePatientsCurrentlyInUnitAndExportToExcel(
    dbconn::ODBC.Connection,
    ;filepath = "$(tempname()).xlsx"
)

    patientsInSrcDB::Vector{PatientInSrcDB} = ETL.getPatientsCurrentlyInUnitFromSrcDB(dbconn)

    ETL.preparePatientsAndExportToExcel(
        patientsInSrcDB,
        dbconn,
        ;filepath = filepath
    )

end
