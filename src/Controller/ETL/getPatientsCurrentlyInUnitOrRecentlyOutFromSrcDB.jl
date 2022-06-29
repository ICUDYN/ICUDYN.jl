function ETL.getPatientsCurrentlyInUnitOrRecentlyOutFromSrcDB(dbconn::ODBC.Connection)

    patientsCurrentlyInUnit = ETL.getPatientsCurrentlyInUnitFromSrcDB(dbconn)
    patientsRecentlyOut = ETL.getPatientsRecentlyOutFromSrcDB(dbconn)

    [patientsCurrentlyInUnit..., patientsRecentlyOut...]

end
